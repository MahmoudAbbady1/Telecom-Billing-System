<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../includes/header.jsp" %>

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        /* Custom styles that override or complement Bootstrap */
        .upload-section {
            border: 2px dashed #ccc;
            padding: 20px;
            text-align: center;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .upload-section:hover {
            border-color: #999;
        }
        #fileInput {
            display: none;
        }
        .status-not-processed {
            color: #ff9800;
            font-weight: bold;
        }
        .status-processed {
            color: #4CAF50;
            font-weight: bold;
        }
        .no-data {
            text-align: center;
            color: #777;
            font-style: italic;
            margin: 20px 0;
        }
        .file-content-table {
            width: 100%;
            margin-top: 20px;
        }
        .error-message {
            color: #f44336;
            font-weight: bold;
        }
        .text-right {
            text-align: right;
        }
        .modal.show {
            display: block;
        }
        /* Additional custom styles */
        .process-all-btn {
            margin-top: 10px;
        }
        .process-all-btn.processed {
            background-color: #4CAF50;
        }
        .actions-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>


<div class="container mt-4">
    <div class="row mb-3">
        <div class="col-md-6">
            <h1>Call Dateil Recored (CDRs)</h1>
        </div>
        <div class="col-md-6 text-right">
            <button class="btn btn-primary" id="uploadBtn">
                Upload CSV Files
            </button>
        </div>
    </div>

    <div class="upload-section">
        <input type="file" id="fileInput" accept=".csv" multiple />
        <div id="fileNames" class="mt-2">No files chosen</div>
    </div>
    
    <div id="tableContainer">
        <p class="no-data">No data to display. Please upload CSV files.</p>
    </div>
</div>

<!-- Modal for displaying file content -->
<div class="modal fade" id="fileContentModal" tabindex="-1" role="dialog">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">File Content</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span>&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div id="modalContent"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const fileInput = document.getElementById('fileInput');
        const fileNames = document.getElementById('fileNames');
        const tableContainer = document.getElementById('tableContainer');
        const uploadBtn = document.getElementById('uploadBtn');
        
        // Database variables
        let db;
        const DB_NAME = 'CSVUploaderDB';
        const DB_VERSION = 1;
        const STORE_NAME = 'files';
        const STORAGE_KEY = 'csvUploaderData';
        const EXPIRATION_MINUTES = 30;
        
        // Custom headers for the content view
        const CUSTOM_HEADERS = ['dial_a', 'dial_b / website accessed', 'service', 'volume', 'time_str'];
        
        let uploadedFiles = [];
        let fileStatuses = {};
        
        // Initialize IndexedDB
        const request = indexedDB.open(DB_NAME, DB_VERSION);
        
        request.onerror = function(event) {
            console.error("Database error:", event.target.error);
        };
        
        request.onupgradeneeded = function(event) {
            const db = event.target.result;
            if (!db.objectStoreNames.contains(STORE_NAME)) {
                db.createObjectStore(STORE_NAME, { keyPath: 'name' });
            }
        };
        
        request.onsuccess = function(event) {
            db = event.target.result;
            loadSavedData();
        };
        
        // Load saved data from localStorage and IndexedDB
        function loadSavedData() {
            const savedData = localStorage.getItem(STORAGE_KEY);
            if (savedData) {
                const parsedData = JSON.parse(savedData);
                const savedTime = new Date(parsedData.timestamp);
                const currentTime = new Date();
                const diffMinutes = (currentTime - savedTime) / (1000 * 60);
                
                if (diffMinutes < EXPIRATION_MINUTES) {
                    // Convert saved file data back to File objects
                    parsedData.files.forEach(fileData => {
                        const file = new File([], fileData.name, { type: 'text/csv' });
                        Object.defineProperty(file, 'size', { value: fileData.size });
                        uploadedFiles.push(file);
                    });
                    fileStatuses = parsedData.statuses;
                    fileNames.textContent = uploadedFiles.map(file => file.name).join(', ');
                    displayFilesTable();
                } else {
                    // Data expired, clear it
                    clearAllData();
                }
            }
        }
        
        // Save data to localStorage and IndexedDB
        function saveData() {
            const dataToSave = {
                timestamp: new Date().toISOString(),
                files: uploadedFiles.map(file => ({
                    name: file.name,
                    size: file.size
                })),
                statuses: fileStatuses
            };
            localStorage.setItem(STORAGE_KEY, JSON.stringify(dataToSave));
        }
        
        // Clear all data (both localStorage and IndexedDB)
        function clearAllData() {
            localStorage.removeItem(STORAGE_KEY);
            
            if (db) {
                const transaction = db.transaction(STORE_NAME, 'readwrite');
                const store = transaction.objectStore(STORE_NAME);
                const request = store.clear();
                
                request.onsuccess = function() {
                    console.log("All data cleared");
                };
                
                request.onerror = function(event) {
                    console.error("Error clearing data:", event.target.error);
                };
            }
            
            uploadedFiles = [];
            fileStatuses = {};
            fileNames.textContent = 'No files chosen';
            tableContainer.innerHTML = '<p class="no-data">No data to display. Please upload CSV files.</p>';
        }
        
        // Store file content in IndexedDB
        function storeFileContent(file) {
            return new Promise((resolve, reject) => {
                const reader = new FileReader();
                
                reader.onload = function(event) {
                    const content = event.target.result;
                    
                    const transaction = db.transaction(STORE_NAME, 'readwrite');
                    const store = transaction.objectStore(STORE_NAME);
                    
                    const request = store.put({
                        name: file.name,
                        content: content,
                        lastModified: file.lastModified
                    });
                    
                    request.onsuccess = function() {
                        resolve();
                    };
                    
                    request.onerror = function(event) {
                        reject(event.target.error);
                    };
                };
                
                reader.onerror = function(event) {
                    reject(event.target.error);
                };
                
                reader.readAsText(file);
            });
        }
        
        // Get file content from IndexedDB
        function getFileContent(filename) {
            return new Promise((resolve, reject) => {
                const transaction = db.transaction(STORE_NAME, 'readonly');
                const store = transaction.objectStore(STORE_NAME);
                
                const request = store.get(filename);
                
                request.onsuccess = function(event) {
                    if (event.target.result) {
                        resolve(event.target.result.content);
                    } else {
                        reject(new Error("File content not found"));
                    }
                };
                
                request.onerror = function(event) {
                    reject(event.target.error);
                };
            });
        }
        
        fileInput.addEventListener('change', async function(e) {
            const newFiles = Array.from(e.target.files);
            if (newFiles.length > 0) {
                try {
                    // Store file contents in IndexedDB
                    for (const file of newFiles) {
                        if (!uploadedFiles.some(f => f.name === file.name && f.size === file.size)) {
                            await storeFileContent(file);
                            uploadedFiles.push(file);
                            fileStatuses[file.name] = 'Not Processed';
                        }
                    }
                    
                    fileNames.textContent = uploadedFiles.map(file => file.name).join(', ');
                    saveData();
                    displayFilesTable();
                } catch (error) {
                    console.error("Error storing files:", error);
                    alert("Error storing files. Please try again.");
                }
            }
        });
        
        uploadBtn.addEventListener('click', function() {
            fileInput.click();
        });
        
        async function showFileContent(fileIndex) {
            const file = uploadedFiles[fileIndex];
            
            try {
                const content = await getFileContent(file.name);
                document.getElementById('modalTitle').textContent = `Content of ${file.name}`;
                document.getElementById('modalContent').innerHTML = createContentTable(content);
                $('#fileContentModal').modal('show');
            } catch (error) {
                console.error("Error retrieving file content:", error);
                document.getElementById('modalTitle').textContent = `Content of ${file.name}`;
                document.getElementById('modalContent').innerHTML = `
                    <p class="error-message">Could not load file content. Error: ${error.message}</p>
                    <p>Please re-upload this file to view its content.</p>
                `;
                $('#fileContentModal').modal('show');
            }
        }
        
        function createContentTable(csvContent) {
            const lines = csvContent.split('\n');
            const table = document.createElement('table');
            table.classList.add('file-content-table', 'table', 'table-striped');
            
            // Create header row with custom headers
            const headerRow = document.createElement('tr');
            CUSTOM_HEADERS.forEach(header => {
                const th = document.createElement('th');
                th.textContent = header;
                headerRow.appendChild(th);
            });
            table.appendChild(headerRow);
            
            // Create data rows
            for (let i = 1; i < lines.length; i++) {
                if (lines[i].trim() === '') continue;
                
                const cells = lines[i].split(',');
                if (cells.length >= CUSTOM_HEADERS.length) {
                    const tr = document.createElement('tr');
                    for (let j = 0; j < CUSTOM_HEADERS.length; j++) {
                        const td = document.createElement('td');
                        td.textContent = cells[j] ? cells[j].trim() : '';
                        tr.appendChild(td);
                    }
                    table.appendChild(tr);
                }
            }
            
            return table.outerHTML;
        }
        
        function displayFilesTable() {
            if (uploadedFiles.length === 0) {
                tableContainer.innerHTML = '<p class="no-data">No data to display. Please upload CSV files.</p>';
                return;
            }
            
            const card = document.createElement('div');
            card.classList.add('card');
            
            const cardBody = document.createElement('div');
            cardBody.classList.add('card-body');
            
            // Create actions header
            const actionsDiv = document.createElement('div');
            actionsDiv.classList.add('actions-header');
            actionsDiv.innerHTML = '<h3>Uploaded Files</h3>';
            
            const buttonsDiv = document.createElement('div');
            
            const processAllBtn = document.createElement('button');
            processAllBtn.textContent = 'Process All';
            processAllBtn.classList.add('btn', 'btn-warning', 'process-all-btn');
            processAllBtn.addEventListener('click', processAllFiles);
            buttonsDiv.appendChild(processAllBtn);
            
            // Only show "All Processed" if all files are processed
            if (Object.values(fileStatuses).every(status => status === 'Processed')) {
                processAllBtn.textContent = 'All Processed';
                processAllBtn.classList.remove('btn-warning');
                processAllBtn.classList.add('btn-success', 'processed');
                processAllBtn.disabled = true;
            }
            
            const clearDataBtn = document.createElement('button');
            clearDataBtn.textContent = 'Clear All Data';
            clearDataBtn.classList.add('btn', 'btn-danger', 'ml-2');
            clearDataBtn.addEventListener('click', clearAllData);
            buttonsDiv.appendChild(clearDataBtn);
            
            actionsDiv.appendChild(buttonsDiv);
            cardBody.appendChild(actionsDiv);
            
            // Create table
            const table = document.createElement('table');
            table.classList.add('table', 'table-striped');
            
            const thead = document.createElement('thead');
            const tbody = document.createElement('tbody');
            
            // Create header row
            const headerRow = document.createElement('tr');
            ['File Name', 'Size', 'Status', 'Action'].forEach(headerText => {
                const th = document.createElement('th');
                th.textContent = headerText;
                headerRow.appendChild(th);
            });
            thead.appendChild(headerRow);
            table.appendChild(thead);
            
            // Create data rows
            uploadedFiles.forEach((file, index) => {
                const tr = document.createElement('tr');
                
                // File name
                const tdName = document.createElement('td');
                tdName.textContent = file.name;
                tr.appendChild(tdName);
                
                // File size
                const tdSize = document.createElement('td');
                tdSize.textContent = formatFileSize(file.size);
                tr.appendChild(tdSize);
                
                // Status
                const tdStatus = document.createElement('td');
                const statusBadge = document.createElement('span');
                statusBadge.textContent = fileStatuses[file.name] || 'Not Processed';
                statusBadge.classList.add('badge', fileStatuses[file.name] === 'Processed' ? 'badge-success' : 'badge-warning');
                statusBadge.id = `status-${index}`;
                tdStatus.appendChild(statusBadge);
                tr.appendChild(tdStatus);
                
                // Action (View button)
                const tdAction = document.createElement('td');
                const viewBtn = document.createElement('button');
                viewBtn.textContent = 'View';
                viewBtn.classList.add('btn', 'btn-primary', 'btn-sm');
                viewBtn.dataset.fileIndex = index;
                viewBtn.addEventListener('click', function() {
                    showFileContent(index);
                });
                tdAction.appendChild(viewBtn);
                tr.appendChild(tdAction);
                
                tbody.appendChild(tr);
            });
            
            table.appendChild(tbody);
            cardBody.appendChild(table);
            card.appendChild(cardBody);
            
            // Clear previous content and add new table
            tableContainer.innerHTML = '';
            tableContainer.appendChild(card);
        }
        
        function processAllFiles() {
            uploadedFiles.forEach((file, index) => {
                fileStatuses[file.name] = 'Processed';
                const statusElement = document.getElementById(`status-${index}`);
                if (statusElement) {
                    statusElement.textContent = 'Processed';
                    statusElement.classList.remove('badge-warning');
                    statusElement.classList.add('badge-success');
                }
            });
            
            saveData();
            
            const processAllBtn = document.querySelector('.process-all-btn');
            if (processAllBtn) {
                processAllBtn.textContent = 'All Processed';
                processAllBtn.classList.remove('btn-warning');
                processAllBtn.classList.add('btn-success', 'processed');
                processAllBtn.disabled = true;
            }
        }
        
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }
    });
</script>

<%@ include file="../includes/footer.jsp" %>
