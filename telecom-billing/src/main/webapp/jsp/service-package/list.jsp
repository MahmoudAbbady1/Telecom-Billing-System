<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Service Packages</h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <a href="form.jsp" class="btn btn-primary">Create New Package</a>
    </div>
</div>
<!-- Quick Stats -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Total Packages</h6>
                        <h3 class="mb-0" id="totalCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-cubes"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Voice Packages</h6>
                        <h3 class="mb-0" id="voiceCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-phone"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">SMS Packages</h6>
                        <h3 class="mb-0" id="smsCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-sms"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Data Packages</h6>
                        <h3 class="mb-0" id="dataCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fa-solid fa-globe"></i>                    
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="card">
    <div class="card-body">
        <table id="packagesTable" class="table table-striped" style="width:100%">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Network Zone</th>
                    <th>Quota</th>
                    <th>Rate/Unit</th>
                    <th>Validity</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>
<style>
    .dashboard-card {
        border-radius: 10px;
        transition: all 0.3s ease;
        border: none;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }

    .dashboard-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
    }

    .quick-stats .card-icon {
        font-size: 1.5rem;
        color: #5e72e4;
    }

    .quick-stats h3 {
        font-weight: 600;
        color: #2d3748;
    }

    .quick-stats h6 {
        font-size: 0.875rem;
    }
</style>

<script>
$(document).ready(function() {
    // Load package counts
    loadPackageCounts();
    
    // Your existing DataTable initialization code...
});

function loadPackageCounts() {
    $.ajax({
        url: '${pageContext.request.contextPath}/api/service-packages/counts',
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function(data) {
            // Update the counts
            $('#totalCount').text(data.TOTAL || 0);
            $('#voiceCount').text(data.VOICE || 0);
            $('#smsCount').text(data.SMS || 0);
            $('#dataCount').text(data.DATA || 0);
            
            // You can add VAS count if needed
            // $('#vasCount').text(data.VAS || 0);
        },
        error: function(xhr) {
            console.error('Error loading package counts:', xhr);
            showAlert('danger', 'Failed to load package statistics');
        }
    });
}

// Keep your existing helper functions (getAuthToken, showAlert, etc.)
</script>
<script>
    $(document).ready(function () {
        // Initialize DataTable with AJAX
        var table = $('#packagesTable').DataTable({
            responsive: true,
            ajax: {
                url: '${pageContext.request.contextPath}/api/service-packages',
                dataSrc: '',
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                error: function (xhr) {
                    handleApiError(xhr);
                }
            },
            columns: [
                {data: 'serviceId'},
                {data: 'serviceName'},
                {data: 'serviceType'},
                {data: 'serviceNetworkZone'},
                {
                    data: null,
                    render: function (data) {
                        return data.quota === 0 ? 'Unlimited' : data.quota + ' ' + (data.unitDescription || '');
                    }
                },
                {
                    data: null,
                    render: function (data) {
                        var rate = parseFloat(data.ratePerUnit);
                        return isNaN(rate) ? 'N/A' : 'EGP ' + rate.toFixed(4) + ' / ' + (data.unitDescription || 'unit');
                    }
                },
                {
                    data: 'validityDays',
                    render: function (validityDays) {
                        return validityDays ? validityDays + ' days' : 'N/A';
                    }
                },
                {
                    data: null,
                    render: function (data) {
                        return '<a href="view.jsp?id=' + data.serviceId + '" class="btn btn-sm btn-info">View</a>';
                    }
                }
            ],
            language: {
                search: "Search:",
                lengthMenu: "Show _MENU_ entries",
                info: "Showing _START_ to _END_ of _TOTAL_ entries",
                paginate: {
                    previous: "Previous",
                    next: "Next"
                }
            }
        });
    });

    // Get authentication token
    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    // Handle API errors
    function handleApiError(xhr) {
        console.error('API Error:', xhr);
        var message = 'An error occurred while loading service packages';

        if (xhr.status === 403) {
            message = 'Your session has expired. Please login again.';
            clearAuthTokens();
            setTimeout(function () {
                window.location.href = '${pageContext.request.contextPath}/login.jsp';
            }, 2000);
        } else if (xhr.status === 500) {
            message = 'Server error: ' + (xhr.responseJSON ? xhr.responseJSON.message : xhr.statusText);
        }

        showAlert('danger', message);
    }

    // Clear all authentication tokens
    function clearAuthTokens() {
        localStorage.removeItem('authToken');
        document.cookie = 'authToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    }

    // Show alert message
    function showAlert(type, message) {
        var alertId = 'alert-' + Date.now();
        var alertHtml = '<div id="' + alertId + '" class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' +
                message +
                '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                '</div>';

        $('#alertContainer').append(alertHtml);

        // Auto-dismiss after 5 seconds (except for danger alerts)
        if (type !== 'danger') {
            setTimeout(function () {
                $('#' + alertId).alert('close');
            }, 5000);
        }
    }
</script>

<%@ include file="../includes/footer.jsp" %>