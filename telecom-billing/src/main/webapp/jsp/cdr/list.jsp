
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
    .processing-message {
        color: #007bff;
        font-weight: bold;
        margin-left: 10px;
    }
</style>
</head>
<body>

    <div class="container mt-4">
        <div class="row mb-3">
            <div class="col-md-6">
                <h1>Call Detail Records (CDRs)</h1>
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

    <!-- Modal for displaying file content or Python output -->
    <div class="modal fade" id="fileContentModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalTitle">File Content</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span>×</span>
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

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
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

            request.onerror = function (event) {
                console.error("Database error:", event.target.error);
            };

            request.onupgradeneeded = function (event) {
                const db = event.target.result;
                if (!db.objectStoreNames.contains(STORE_NAME)) {
                    db.createObjectStore(STORE_NAME, {keyPath: 'name'});
                }
            };

            request.onsuccess = function (event) {
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
                        parsedData.files.forEach(fileData => {
                            const file = new File([], fileData.name, {type: 'text/csv'});
                            Object.defineProperty(file, 'size', {value: fileData.size});
                            uploadedFiles.push(file);
                        });
                        fileStatuses = parsedData.statuses;
                        fileNames.textContent = uploadedFiles.map(file => file.name).join(', ');
                        displayFilesTable();
                    } else {
                        clearAllData();
                    }
                }
            }

            // Save data to localStorage
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
            async function clearAllData() {
                try {
                    const response = await fetch('<%=request.getContextPath()%>/api/invoices', {
                        method: 'DELETE',
                        headers: {
                            'Content-Type': 'application/json'
                        }
                    });

                    if (!response.ok) {
                        throw new Error(`Failed to delete invoices: ${response.statusText}`);
                    }

                    const result = await response.text();
                    console.log(result);
                } catch (error) {
                    console.error('Error deleting invoices from database:', error);
                    alert(`Error deleting invoices from database: ${error.message}. Local data will still be cleared.`);
                }

                localStorage.removeItem(STORAGE_KEY);

                if (db) {
                    const transaction = db.transaction(STORE_NAME, 'readwrite');
                    const store = transaction.objectStore(STORE_NAME);
                    const request = store.clear();

                    request.onsuccess = function () {
                        console.log("All data cleared from IndexedDB");
                    };

                    request.onerror = function (event) {
                        console.error("Error clearing IndexedDB data:", event.target.error);
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

                    reader.onload = function (event) {
                        const content = event.target.result;

                        const transaction = db.transaction(STORE_NAME, 'readwrite');
                        const store = transaction.objectStore(STORE_NAME);

                        const request = store.put({
                            name: file.name,
                            content: content,
                            lastModified: file.lastModified
                        });

                        request.onsuccess = function () {
                            resolve();
                        };

                        request.onerror = function (event) {
                            reject(event.target.error);
                        };
                    };

                    reader.onerror = function (event) {
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

                    request.onsuccess = function (event) {
                        if (event.target.result) {
                            resolve(event.target.result.content);
                        } else {
                            reject(new Error("File content not found"));
                        }
                    };

                    request.onerror = function (event) {
                        reject(event.target.error);
                    };
                });
            }

            // Fetch customer data from API
            async function fetchCustomerData() {
                try {
                    const response = await fetch('<%=request.getContextPath()%>/api/customers');
                    if (!response.ok) {
                        throw new Error('Failed to fetch customer data');
                    }
                    const customers = await response.json();
                    return customers.map(customer => customer.customer.customerId);
                } catch (error) {
                    console.error('Error fetching customer data:', error);
                    throw error;
                }
            }

            // Validate filename against customer IDs
            function validateFilename(filename, customerIds) {
                const match = filename.match(/^(\d+)_/);
                if (!match) {
                    return false;
                }
                const fileCustomerId = parseInt(match[1], 10);
                return customerIds.includes(fileCustomerId);
            }

            fileInput.addEventListener('change', async function (e) {
                const newFiles = Array.from(e.target.files);
                if (newFiles.length > 0) {
                    try {
                        const customerIds = await fetchCustomerData();

                        const validFiles = [];
                        const invalidFiles = [];

                        for (const file of newFiles) {
                            if (!validateFilename(file.name, customerIds)) {
                                invalidFiles.push(file.name);
                                continue;
                            }
                            if (!uploadedFiles.some(f => f.name === file.name && f.size === file.size)) {
                                await storeFileContent(file);
                                validFiles.push(file);
                                fileStatuses[file.name] = 'Not Processed';
                            }
                        }

                        if (invalidFiles.length > 0) {
                            alert(`The following files were not uploaded because their customer ID does not match any in the database: ${invalidFiles.join(', ')}`);
                        }

                        if (validFiles.length > 0) {
                            uploadedFiles.push(...validFiles);
                            fileNames.textContent = uploadedFiles.map(file => file.name).join(', ');
                            saveData();
                            displayFilesTable();
                        } else if (invalidFiles.length === newFiles.length) {
                            fileNames.textContent = uploadedFiles.length > 0 ? uploadedFiles.map(file => file.name).join(', ') : 'No files chosen';
                        }
                    } catch (error) {
                        console.error('Error processing files:', error);
                    }
                }
            });

            uploadBtn.addEventListener('click', function () {
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

                const headerRow = document.createElement('tr');
                CUSTOM_HEADERS.forEach(header => {
                    const th = document.createElement('th');
                    th.textContent = header;
                    headerRow.appendChild(th);
                });
                table.appendChild(headerRow);

                for (let i = 1; i < lines.length; i++) {
                    if (lines[i].trim() === '')
                        continue;

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

                const actionsDiv = document.createElement('div');
                actionsDiv.classList.add('actions-header');
                actionsDiv.innerHTML = '<h3>Uploaded Files</h3>';

                const buttonsDiv = document.createElement('div');

                const processAllBtn = document.createElement('button');
                processAllBtn.textContent = 'Process All';
                processAllBtn.classList.add('btn', 'btn-warning', 'process-all-btn');
                processAllBtn.addEventListener('click', processAllFiles);
                buttonsDiv.appendChild(processAllBtn);
//
//                const runPythonBtn = document.createElement('button');
//                runPythonBtn.textContent = 'Run Python Code';
//                runPythonBtn.classList.add('btn', 'btn-info', 'ml-2');
//                runPythonBtn.addEventListener('click', runPythonCode);
//                buttonsDiv.appendChild(runPythonBtn);

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

                const table = document.createElement('table');
                table.classList.add('table', 'table-striped');

                const thead = document.createElement('thead');
                const tbody = document.createElement('tbody');

                const headerRow = document.createElement('tr');
                ['File Name', 'Size', 'Status', 'Action'].forEach(headerText => {
                    const th = document.createElement('th');
                    th.textContent = headerText;
                    headerRow.appendChild(th);
                });
                thead.appendChild(headerRow);
                table.appendChild(thead);

                uploadedFiles.forEach((file, index) => {
                    const tr = document.createElement('tr');

                    const tdName = document.createElement('td');
                    tdName.textContent = file.name;
                    tr.appendChild(tdName);

                    const tdSize = document.createElement('td');
                    tdSize.textContent = formatFileSize(file.size);
                    tr.appendChild(tdSize);

                    const tdStatus = document.createElement('td');
                    const statusBadge = document.createElement('span');
                    statusBadge.textContent = fileStatuses[file.name] || 'Not Processed';
                    statusBadge.classList.add('badge', fileStatuses[file.name] === 'Processed' ? 'badge-success' : 'badge-warning');
                    statusBadge.id = `status-${index}`;
                    tdStatus.appendChild(statusBadge);
                    tr.appendChild(tdStatus);

                    const tdAction = document.createElement('td');
                    const viewBtn = document.createElement('button');
                    viewBtn.textContent = 'View';
                    viewBtn.classList.add('btn', 'btn-primary', 'btn-sm');
                    viewBtn.dataset.fileIndex = index;
                    viewBtn.addEventListener('click', function () {
                        showFileContent(index);
                    });
                    tdAction.appendChild(viewBtn);
                    tr.appendChild(tdAction);

                    tbody.appendChild(tr);
                });

                table.appendChild(tbody);
                cardBody.appendChild(table);
                card.appendChild(cardBody);

                tableContainer.innerHTML = '';
                tableContainer.appendChild(card);
            }

            async function processAllFiles() {
                if (uploadedFiles.length === 0) {
                    alert('No files to process.');
                    return;
                }

                const processAllBtn = document.querySelector('.process-all-btn');
                processAllBtn.disabled = true;
                processAllBtn.textContent = 'Processing...';
                const processingMessage = document.createElement('span');
                processingMessage.textContent = 'Generating invoices...';
                processingMessage.classList.add('processing-message');
                processAllBtn.parentNode.appendChild(processingMessage);

                try {
                    const customerCsvMap = {};
                    for (const file of uploadedFiles) {
                        const match = file.name.match(/^(\d+)_/);
                        if (match) {
                            const customerId = match[1];
                            const csvContent = await getFileContent(file.name);
                            customerCsvMap[customerId] = csvContent;
                        }
                    }

                    if (Object.keys(customerCsvMap).length === 0) {
                        alert('No valid files to process.');
                        return;
                    }

                    const response = await fetch('<%=request.getContextPath()%>/api/invoices/process-all', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(customerCsvMap)
                    });

                    processingMessage.remove();

                    if (response.ok) {
                        const result = await response.text();
                        alert(result || 'Invoices processed successfully!');

                        uploadedFiles.forEach(file => {
                            fileStatuses[file.name] = 'Processed';
                        });

                        saveData();
                        displayFilesTable();
                    } else {
                        const error = await response.text();
                        alert(`Error processing invoices: ${error}`);
                        processAllBtn.textContent = 'Process All';
                        processAllBtn.classList.add('btn-warning');
                        processAllBtn.disabled = false;
                    }
                } catch (error) {
                    console.error('Error processing files:', error);
                    alert(`Error processing invoices: ${error.message}`);
                    processingMessage.remove();
                    processAllBtn.textContent = 'Process All';
                    processAllBtn.classList.add('btn-warning');
                    processAllBtn.disabled = false;
                }
            }

            async function runPythonCode() {
                const runPythonBtn = document.querySelector('.btn-info');
                runPythonBtn.disabled = true;
                runPythonBtn.textContent = 'Running...';

                try {
                    const customerCsvMap = {};
                    for (const file of uploadedFiles) {
                        const match = file.name.match(/^(\d+)_/);
                        if (match) {
                            const customerId = match[1];
                            const csvContent = await getFileContent(file.name);
                            customerCsvMap[customerId] = csvContent;
                        }
                    }

                    const response = await fetch('<%=request.getContextPath()%>/api/run-python', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(customerCsvMap)
                    });

                    if (response.ok) {
                        const result = await response.text();
                        document.getElementById('modalTitle').textContent = 'Python Script Output';
                        document.getElementById('modalContent').innerHTML = `<pre>${result}</pre>`;
                        $('#fileContentModal').modal('show');
                    } else {
                        const error = await response.text();
                        alert(`Error running Python script: ${error}`);
                    }
                } catch (error) {
                    console.error('Error running Python script:', error);
                    alert(`Error running Python script: ${error.message}`);
                } finally {
                    runPythonBtn.textContent = 'Run Python Code';
                    runPythonBtn.disabled = false;
                }
            }

            function formatFileSize(bytes) {
                if (bytes === 0)
                    return '0 Bytes';
                const k = 1024;
                const sizes = ['Bytes', 'KB', 'MB', 'GB'];
                const i = Math.floor(Math.log(bytes) / Math.log(k));
                return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
            }
        });
    </script>

    <%@ include file="../includes/footer.jsp" %>

