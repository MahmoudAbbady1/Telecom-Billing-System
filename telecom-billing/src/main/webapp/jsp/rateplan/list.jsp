<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Rate Plans</h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <a href="form.jsp" class="btn btn-primary">Create New Rate Plan</a>
    </div>
</div>

<!-- Quick Stats -->
<div class="row mb-4">
    <div class="col-md-3">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Total Plans</h6>
                        <h3 class="mb-0" id="totalCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-list-alt"></i>
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
                        <h6 class="text-muted mb-2">Active Plans</h6>
                        <h3 class="mb-0" id="activeCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-check-circle"></i>
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
                        <h6 class="text-muted mb-2">CUG Plans</h6>
                        <h3 class="mb-0" id="cugCount">0</h3>
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
                        <h6 class="text-muted mb-2">Avg. Price</h6>
                        <h3 class="mb-0" id="avgPrice">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-money-bill-wave"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table id="plansTable" class="table table-striped" style="width:100%">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Description</th>
                    <th>Base Price</th>
                    <th>CUG</th>
                    <th>Status</th>
                    <th>Services</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>

<script>
    $(document).ready(function() {
        // Load plan counts
        loadPlanCounts();
        
        // Initialize DataTable with AJAX
        var table = $('#plansTable').DataTable({
            responsive: true,
            ajax: {
                url: '${pageContext.request.contextPath}/api/rate-plans',
                dataSrc: '',
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                error: function(xhr) {
                    handleApiError(xhr);
                }
            },
            columns: [
                {data: 'planId'},
                {data: 'planName'},
                {
                    data: 'description',
                    render: function(data) {
                        return data ? (data.length > 50 ? data.substring(0, 50) + '...' : data) : 'N/A';
                    }
                },
                {
                    data: 'basePrice',
                    render: function(data) {
                        return 'EGP ' + parseFloat(data).toFixed(2);
                    }
                },
                {
                    data: 'cug',
                    render: function(data) {
                        return data ? '<span class="badge bg-success">Yes</span>' : '<span class="badge bg-secondary">No</span>';
                    }
                },
                {
                    data: 'isActive',
                    render: function(data) {
                        return data ? '<span class="badge bg-success">Active</span>' : '<span class="badge bg-danger">Inactive</span>';
                    }
                },
                {
                    data: null,
                    render: function(data) {
                        return data.servicesCount ? data.servicesCount + ' services' : '0 services';
                    }
                },
                {
                    data: null,
                    render: function(data) {
                        return '<a href="view.jsp?id=' + data.planId + '" class="btn btn-sm btn-info">View</a>';
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

    function loadPlanCounts() {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/rate-plans/counts',
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function(data) {
                // Update the counts
                $('#totalCount').text(data.TOTAL || 0);
                $('#activeCount').text(data.ACTIVE || 0);
                $('#cugCount').text(data.CUG || 0);
                $('#avgPrice').text('EGP ' + (data.AVG_PRICE ? parseFloat(data.AVG_PRICE).toFixed(2) : '0.00'));
            },
            error: function(xhr) {
                console.error('Error loading plan counts:', xhr);
                showAlert('danger', 'Failed to load rate plan statistics');
            }
        });
    }

    // Get authentication token
    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    // Handle API errors
    function handleApiError(xhr) {
        console.error('API Error:', xhr);
        var message = 'An error occurred while loading rate plans';

        if (xhr.status === 403) {
            message = 'Your session has expired. Please login again.';
            clearAuthTokens();
            setTimeout(function() {
                window.location.href = '${pageContext.request.contextPath}/index.jsp';
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
            setTimeout(function() {
                $('#' + alertId).alert('close');
            }, 5000);
        }
    }
</script>

<%@ include file="../includes/footer.jsp" %>