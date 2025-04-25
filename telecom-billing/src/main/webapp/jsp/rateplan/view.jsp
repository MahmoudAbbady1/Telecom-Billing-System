<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<style>
    .service-badge {
        margin-right: 5px;
        margin-bottom: 5px;
    }
    .badge-voice {
        background-color: #6f42c1;
    }
    .badge-sms {
        background-color: #fd7e14;
    }
    .badge-data {
        background-color: #20c997;
    }
    .badge-vas {
        background-color: #6610f2;
    }
</style>

<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-file-invoice-dollar"></i> Rate Plan Details
        </h3>
    </div>
    <div class="col-md-6 text-end">
        <a href="#" id="editBtn" class="btn btn-primary">
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
                    <dt class="col-sm-4">Base Price:</dt>
                    <dd class="col-sm-8" id="basePrice">Loading...</dd>

                    <dt class="col-sm-4">CUG:</dt>
                    <dd class="col-sm-8" id="cug">Loading...</dd>

                    <dt class="col-sm-4">Status:</dt>
                    <dd class="col-sm-8" id="status">Loading...</dd>
                </dl>
            </div>
        </div>
    </div>
</div>

<div class="card shadow-sm mb-4">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-calendar-alt"></i> Validity</h5>
    </div>
    <div class="card-body">
        <dl class="row">
            <dt class="col-sm-2">Validity:</dt>
            <dd class="col-sm-10" id="validityDays">Loading...</dd>
        </dl>
    </div>
</div>

<div class="card shadow-sm mb-4">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-list"></i> Included Services</h5>
    </div>
    <div class="card-body">
        <div class="table-responsive">
            <table class="table table-striped" id="servicesTable">
                <thead>
                    <tr>
                        <th>Service</th>
                        <th>Type</th>
                        <th>Included Units</th>
                        <th>Unlimited</th>
                    </tr>
                </thead>
                <tbody id="servicesBody">
                    <!-- Services will be loaded here -->
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        // Get the ID from the URL
        const urlParams = new URLSearchParams(window.location.search);
        const planId = urlParams.get('id');

        if (!planId) {
            showAlert('danger', 'No rate plan ID specified in the URL');
            return;
        }

        // Fetch plan details
        $.ajax({
            url: '${pageContext.request.contextPath}/api/rate-plans/' + planId,
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function (data) {
                // Update the view with the plan data
                $('#planId').text(data.planId);
                $('#planName').text(data.planName);
                $('#description').text(data.description || 'N/A');
                $('#basePrice').text('EGP ' + parseFloat(data.basePrice).toFixed(2));
                $('#cug').text(data.cug ? 'Yes' : 'No');
                $('#status').html(data.isActive ? '<span class="badge bg-success">Active</span>' : '<span class="badge bg-danger">Inactive</span>');
                $('#validityDays').text(data.validityDays + ' days');

                // Set up edit button
                $('#editBtn').attr('href', 'form.jsp?id=' + data.planId);

                // Load services
                const tbody = $('#servicesBody');
                tbody.empty();

                if (data.services && data.services.length > 0) {
                    data.services.forEach(service => {
                        const row = `
                            <tr>
                                <td>${service.serviceName}</td>
                                <td><span class="badge ${getServiceTypeBadgeClass(service.serviceType)}">${service.serviceType}</span></td>
                                <td>${service.isUnlimited ? 'Unlimited' : service.includedUnits + ' ' + (service.unitDescription || 'units')}</td>
                                <td>${service.isUnlimited ? '<i class="fas fa-check text-success"></i>' : '<i class="fas fa-times text-danger"></i>'}</td>
                            </tr>
                        `;
                        tbody.append(row);
                    });
                } else {
                    tbody.append('<tr><td colspan="4" class="text-center">No services included in this plan</td></tr>');
                }
            },
            error: function (xhr) {
                console.error('API Error:', xhr);
                var message = 'An error occurred while loading rate plan details';

                if (xhr.status === 403) {
                    message = 'Your session has expired. Please login again.';
                    clearAuthTokens();
                    setTimeout(function () {
                        window.location.href = '${pageContext.request.contextPath}/login.jsp';
                    }, 2000);
                } else if (xhr.status === 404) {
                    message = 'Rate plan not found';
                } else if (xhr.status === 500) {
                    // Parse the server error message if available
                    try {
                        const errorResponse = JSON.parse(xhr.responseText);
                        message = 'Server error: ' + (errorResponse.message || xhr.statusText);
                    } catch (e) {
                        message = 'Server error: ' + xhr.statusText;
                    }
                }

                showAlert('danger', message);
                // Optionally redirect to list page if the plan doesn't exist
                if (xhr.status === 404) {
                    setTimeout(function () {
                        window.location.href = 'list.jsp';
                    }, 3000);
                }
            }
        });
    });

    function getServiceTypeBadgeClass(serviceType) {
        switch (serviceType) {
            case 'VOICE':
                return 'badge-voice';
            case 'SMS':
                return 'badge-sms';
            case 'DATA':
                return 'badge-data';
            case 'VAS':
                return 'badge-vas';
            default:
                return 'badge-secondary';
        }
    }

    // Get authentication token
    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    // Handle API errors
    function handleApiError(xhr) {
        console.error('API Error:', xhr);
        var message = 'An error occurred while loading rate plan details';

        if (xhr.status === 403) {
            message = 'Your session has expired. Please login again.';
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