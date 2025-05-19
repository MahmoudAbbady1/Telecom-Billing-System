<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Customers</h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <a href="form.jsp" class="btn btn-primary">Create New Customer</a>
    </div>
</div>

<!-- Quick Stats -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Total Customers</h6>
                        <h3 class="mb-0" id="totalCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-users"></i>
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
                        <h6 class="text-muted mb-2">Active</h6>
                        <h3 class="mb-0" id="activeCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-user-check"></i>
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
                        <h6 class="text-muted mb-2">Inactive</h6>
                        <h3 class="mb-0" id="inactiveCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-user-slash"></i>
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
                        <h6 class="text-muted mb-2">Suspended</h6>
                        <h3 class="mb-0" id="suspendedCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-user-clock"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card mb-3">
    <div class="card-body">
        <form id="searchForm" class="row g-3">
            <div class="col-md-8">
                <input type="text" class="form-control" id="searchQuery" placeholder="Search by name, phone, email or NID">
            </div>
            <div class="col-md-3">
                <select class="form-control" id="statusFilter">
                    <option value="">All Status</option>
                    <option value="ACTIVE">Active</option>
                    <option value="INACTIVE">Inactive</option>
                    <option value="SUSPENDED">Suspended</option>
                </select>
            </div>
            <div class="col-md-1">
                <button type="submit" class="btn btn-primary w-100">Search</button>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table id="customersTable" class="table table-striped" style="width:100%">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Phone</th>
                    <th>Email</th>
                    <th>Status</th>
                    <th>Credit Limit</th>
                    <th>Plan</th>
                    <th>Registration Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>

<script>
    $(document).ready(function() {
        // Load customer stats
        loadCustomerStats();
        var planNamesCache = {};
$.ajax({
    url: '${pageContext.request.contextPath}/api/rate-plans',
    method: 'GET',
    headers: {
        'Authorization': 'Bearer ' + getAuthToken()
    },
    success: function(plans) {
        plans.forEach(function(plan) {
            planNamesCache[plan.planId] = plan.planName;
        });

        // Initialize the DataTable **after** rate plans are loaded
        initializeCustomersTable();
    },
    error: function(xhr) {
        handleApiError(xhr);
    }
});

        
  function initializeCustomersTable() {
    var table = $('#customersTable').DataTable({
        responsive: true,
        ajax: {
            url: '${pageContext.request.contextPath}/api/customers',
            dataSrc: '',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            error: function(xhr) {
                handleApiError(xhr);
            }
        },
        columns: [
            {data: 'customerId'},
            {data: 'name'},
            {data: 'phone'},
            {data: 'email'},
            {
                data: 'status',
                render: function(status) {
                    var badgeClass = 'bg-secondary';
                    if (status === 'ACTIVE') badgeClass = 'bg-success';
                    else if (status === 'SUSPENDED') badgeClass = 'bg-warning';
                    else if (status === 'INACTIVE') badgeClass = 'bg-danger';
                    
                    return '<span class="badge ' + badgeClass + '">' + status + '</span>';
                }
            },
            {
                data: 'creditLimit',
                render: function(limit) {
                    return 'EGP ' + limit;
                }
            },
            {
                data: 'planId',
                render: function(planId, type, row) {
                    if (planId && planNamesCache[planId]) {
                        return '<span class="badge bg-info">' + planNamesCache[planId] + '</span>';
                    } else if (planId) {
                        return '<span class="badge bg-secondary">Plan #' + planId + '</span>';
                    }
                    return 'None';
                }
            },
            {
                data: 'registrationDate',
                render: function(date) {
                    return new Date(date).toLocaleDateString();
                }
            },
            {
                data: null,
                render: function(data) {
                    return '<a href="view.jsp?id=' + data.customerId + '" class="btn btn-sm btn-info me-1">View</a>' +
                           '<a href="form.jsp?id=' + data.customerId + '" class="btn btn-sm btn-warning">Edit</a>';
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
}

        
        // Search form handler
        $('#searchForm').submit(function(e) {
            e.preventDefault();
            var query = $('#searchQuery').val();
            var status = $('#statusFilter').val();
            
            $.ajax({
                url: '${pageContext.request.contextPath}/api/customers/search',
                method: 'GET',
                data: {
                    query: query,
                    status: status
                },
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function(data) {
                    table.clear().rows.add(data).draw();
                },
                error: function(xhr) {
                    handleApiError(xhr);
                }
            });
        });
    });

    

    function loadCustomerStats() {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/customers/stats',
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function(data) {
                $('#totalCount').text(data.TOTAL || 0);
                $('#activeCount').text(data.ACTIVE || 0);
                $('#inactiveCount').text(data.INACTIVE || 0);
                $('#suspendedCount').text(data.SUSPENDED || 0);
            },
            error: function(xhr) {
                console.error('Error loading customer stats:', xhr);
                showAlert('danger', 'Failed to load customer statistics');
            }
        });
    }

    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    function handleApiError(xhr) {
        console.error('API Error:', xhr);
        var message = 'An error occurred while loading customers';

        if (xhr.status === 403) {
            message = 'Your session has expired. Please login again.';
            clearAuthTokens();
            setTimeout(function() {
                window.location.href = '${pageContext.request.contextPath}/login.jsp';
            }, 2000);
        } else if (xhr.status === 500) {
            message = 'Server error: ' + (xhr.responseJSON ? xhr.responseJSON.message : xhr.statusText);
        }

        showAlert('danger', message);
    }

    function clearAuthTokens() {
        localStorage.removeItem('authToken');
        document.cookie = 'authToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    }

    function showAlert(type, message) {
        var alertId = 'alert-' + Date.now();
        var alertHtml = '<div id="' + alertId + '" class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' +
                message +
                '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                '</div>';

        $('#alertContainer').append(alertHtml);

        if (type !== 'danger') {
            setTimeout(function() {
                $('#' + alertId).alert('close');
            }, 5000);
        }
    }
</script>

<%@ include file="../includes/footer.jsp" %>