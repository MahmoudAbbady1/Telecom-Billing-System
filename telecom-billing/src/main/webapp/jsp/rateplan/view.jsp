<%@ include file="../includes/header.jsp" %>

<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-file-invoice-dollar"></i> Rate Plan Details
        </h3>
    </div>
    <div class="col-md-6 text-end">
        <a href="#" id="editBtn" class="btn btn-primary me-2">
            <i class="fas fa-edit"></i> Edit
        </a>
        <a href="list.jsp" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div id="alertContainer"></div>

<div class="card shadow-sm mb-4">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-info-circle"></i> Plan Information</h5>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <dl class="row">
                    <dt class="col-sm-4">Plan ID:</dt>
                    <dd class="col-sm-8" id="planId">Loading...</dd>

                    <dt class="col-sm-4">Name:</dt>
                    <dd class="col-sm-8" id="planName">Loading...</dd>

                    <dt class="col-sm-4">Description:</dt>
                    <dd class="col-sm-8" id="description">Loading...</dd>
                </dl>
            </div>
            <div class="col-md-6">
                <dl class="row">
                    <dt class="col-sm-4">Monthly Fee:</dt>
                    <dd class="col-sm-8" id="monthlyFee">Loading...</dd>

                    <dt class="col-sm-4">Is CUG:</dt>
                    <dd class="col-sm-8" id="isCug">Loading...</dd>

                    <dt class="col-sm-4">Created At:</dt>
                    <dd class="col-sm-8" id="createdAt">Loading...</dd>
                </dl>
            </div>
        </div>
    </div>
</div>

<div class="card shadow-sm mb-4" id="cugDetailsCard" style="display: none;">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-users"></i> CUG Details</h5>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <dl class="row">
                    <dt class="col-sm-4">Max Members:</dt>
                    <dd class="col-sm-8" id="maxCugMembers">Loading...</dd>
                </dl>
            </div>
            <div class="col-md-6">
                <dl class="row">
                    <dt class="col-sm-4">CUG Units:</dt>
                    <dd class="col-sm-8" id="cugUnit">Loading...</dd>
                </dl>
            </div>
        </div>
    </div>
</div>

<div class="card shadow-sm">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-cubes"></i> Included Services</h5>
    </div>
    <div class="card-body">
        <table id="servicesTable" class="table table-striped" style="width:100%">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Network Zone</th>
                    <th>Quota</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>

<script>
    $(document).ready(function() {
        const urlParams = new URLSearchParams(window.location.search);
        const planId = urlParams.get('id');

        if (!planId) {
            showAlert('danger', 'No plan ID specified in the URL');
            return;
        }

        // Load rate plan details
        $.ajax({
            url: '${pageContext.request.contextPath}/api/rate-plans/' + planId,
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function(data) {
                $('#planId').text(data.planId);
                $('#planName').text(data.planName);
                $('#description').text(data.description || 'N/A');
                $('#monthlyFee').text('EGP ' + parseFloat(data.monthlyFee).toFixed(2));
                $('#isCug').text(data.isCug ? 'Yes' : 'No');
                $('#createdAt').text(new Date(data.createdAt).toLocaleString());
                $('#editBtn').attr('href', 'form.jsp?id=' + data.planId);

                if (data.cug) {
                    $('#cugDetailsCard').show();
                    $('#maxCugMembers').text(data.maxCugMembers);
                    $('#cugUnit').text(data.cugUnit);
                }

                // Initialize services table
                $('#servicesTable').DataTable({
                    responsive: true,
                    ajax: {
                        url: '${pageContext.request.contextPath}/api/rate-plans/' + planId + '/services',
                        dataSrc: '',
                        headers: {
                            'Authorization': 'Bearer ' + getAuthToken()
                        }
                    },
                    columns: [
                        {data: 'serviceId'},
                        {data: 'serviceName'},
                        {data: 'serviceType'},
                        {data: 'serviceNetworkZone'},
                        {
                            data: null,
                            render: function(data) {
                                return data.qouta + ' ' + (data.unitDescription || '');
                            }
                        },
                        {
                            data: null,
                            render: function(data) {
                                return '<button class="btn btn-sm btn-danger remove-service" data-service-id="' + 
                                       data.serviceId + '">Remove</button>';
                            }
                        }
                    ]
                });
            },
            error: function(xhr) {
                handleApiError(xhr);
            }
        });

        // Handle service removal
        $(document).on('click', '.remove-service', function() {
            const serviceId = $(this).data('service-id');
            if (confirm('Are you sure you want to remove this service from the rate plan?')) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/rate-plans/' + planId + '/services/' + serviceId,
                    method: 'DELETE',
                    headers: {
                        'Authorization': 'Bearer ' + getAuthToken()
                    },
                    success: function() {
                        $('#servicesTable').DataTable().ajax.reload();
                        showAlert('success', 'Service removed successfully');
                    },
                    error: function(xhr) {
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
        var message = 'An error occurred';

        if (xhr.status === 403) {
            message = 'Your session has expired. Please login again.';
            clearAuthTokens();
            setTimeout(function() {
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

        $('#alertContainer').html(alertHtml);

        if (type !== 'danger') {
            setTimeout(function() {
                $('#' + alertId).alert('close');
            }, 5000);
        }
    }
</script>

<%@ include file="../includes/footer.jsp" %>