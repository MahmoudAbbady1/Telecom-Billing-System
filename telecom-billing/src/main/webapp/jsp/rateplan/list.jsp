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
    <div class="col-md-4">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Total Rate Plans</h6>
                        <h3 class="mb-0" id="totalCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-list"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Rate Plans With CUG</h6>
                        <h3 class="mb-0" id="cugCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-users"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Rate Plans Without CUG</h6>
                        <h3 class="mb-0" id="nonCugCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-user-slash"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table id="ratePlansTable" class="table table-striped" style="width:100%">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Monthly Fee</th>
                    <th>CUG</th>
                    <th>Max Members</th>
                    <th>CUG Units</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>
<script>
    $(document).ready(function () {
        // Fetch and display counts
        $.ajax({
            url: '${pageContext.request.contextPath}/api/rate-plans/counts',
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function (data) {
                $('#totalCount').text(data.totalCount);
                $('#cugCount').text(data.cugCount);
                $('#nonCugCount').text(data.nonCugCount);
            },
            error: function (xhr) {
                handleApiError(xhr);
            }
        });

        // Destroy if already initialized
        if ($.fn.DataTable.isDataTable('#ratePlansTable')) {
            $('#ratePlansTable').DataTable().clear().destroy();
        }

        // Initialize DataTable
        $('#ratePlansTable').DataTable({
            responsive: true,
            ajax: {
                url: '${pageContext.request.contextPath}/api/rate-plans',
                dataSrc: '',
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                error: function (xhr) {
                    handleApiError(xhr);
                }
            },
            columns: [
                { data: 'planId' },
                { data: 'planName' },
                {
                    data: 'monthlyFee',
                    render: function (fee) {
                        return fee ? 'EGP ' + parseFloat(fee).toFixed(2) : 'N/A';
                    }
                },
                {
                    data: 'isCug',
                    render: function (cug) {
                        return cug
                            ? '<span class="badge bg-success">Yes</span>'
                            : '<span class="badge bg-danger">No</span>';
                    }
                },
                {
                    data: 'maxCugMembers',
                    render: function (members) {
                        return members > 0 ? members : '-';
                    }
                },
                {
                    data: 'cugUnit',
                    render: function (units) {
                        return units > 0 ? units : '-';
                    }
                },
                {
                    data: null,
                    render: function (data) {
                        return '<a href="view.jsp?id=' + data.planId + '" class="btn btn-sm btn-info me-1">View</a>' +
                            '<a href="form.jsp?id=' + data.planId + '" class="btn btn-sm btn-warning me-1">Edit</a>';
                    }
                }
            ]
        });

        // Handle delete button
        $('#ratePlansTable').on('click', '.delete-btn', function () {
            var planId = $(this).data('id');
            if (confirm('Are you sure you want to delete rate plan ID ' + planId + '?')) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/rate-plans/' + planId,
                    type: 'DELETE',
                    headers: {
                        'Authorization': 'Bearer ' + getAuthToken()
                    },
                    success: function () {
                        $('#ratePlansTable').DataTable().ajax.reload();
                        // Refresh counts after deletion
                        $.ajax({
                            url: '${pageContext.request.contextPath}/api/rate-plans/counts',
                            method: 'GET',
                            headers: {
                                'Authorization': 'Bearer ' + getAuthToken()
                            },
                            success: function (data) {
                                $('#totalCount').text(data.totalCount);
                                $('#cugCount').text(data.cugCount);
                                $('#nonCugCount').text(data.nonCugCount);
                            },
                            error: function (xhr) {
                                handleApiError(xhr);
                            }
                        });
                        showAlert('success', 'Rate plan deleted successfully');
                    },
                    error: function (xhr) {
                        handleApiError(xhr);
                    }
                });
            }
        });
    });

    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    function handleApiError(xhr) {
        console.error('API Error:', xhr);
        var message = 'An error occurred while processing your request';
        if (xhr.status === 403) {
            message = 'Session expired. Redirecting...';
            clearAuthTokens();
            setTimeout(function () {
                window.location.href = '${pageContext.request.contextPath}/login.jsp';
            }, 2000);
        } else if (xhr.status === 404) {
            message = 'Rate plan not found';
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
        $('body').prepend(alertHtml);
        if (type !== 'danger') {
            setTimeout(function () {
                $('#' + alertId).alert('close');
            }, 5000);
        }
    }
</script>

<%@ include file="../includes/footer.jsp" %>