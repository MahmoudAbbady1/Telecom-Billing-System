<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<style>
    .status-active {
        color: green;
        font-weight: bold;
    }
    .status-inactive {
        color: red;
        font-weight: bold;
    }
    .status-suspended {
        color: orange;
        font-weight: bold;
    }
    .card-icon {
        width: 50px;
        height: 50px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
    }
    .detail-card {
        margin-bottom: 20px;
        box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
    }
    .detail-card .card-header {
        background-color: #f8f9fa;
        font-weight: 600;
    }
    .cug-fields {
        display: none;
    }
    .service-list {
        max-height: 300px;
        overflow-y: auto;
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 10px;
    }
    .service-item {
        padding: 8px;
        border-bottom: 1px solid #eee;
        display: flex;
        align-items: center;
    }
    .service-item:last-child {
        border-bottom: none;
    }
    .service-checkbox {
        margin-right: 10px;
    }
    .service-item label {
        margin-bottom: 0;
        cursor: pointer;
        flex-grow: 1;
    }
    .service-type-badge {
        margin-left: 10px;
        font-size: 0.8em;
    }
    .service-details {
        font-size: 0.9em;
        color: #6c757d;
        margin-top: 4px;
    }
    .free-status {
        font-weight: bold;
    }
    .free-status.yes {
        color: #28a745;
    }
    .free-status.no {
        color: #dc3545;
    }
</style>

<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-tags"></i> ${empty param.id ? 'Create' : 'Edit'} Rate Plan
        </h3>
    </div>
    <div class="col-md-6 text-end">
        <a href="list.jsp" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div id="alertContainer"></div>

<div class="row">
    <div class="col-md-12">
        <div class="card detail-card">
            <div class="card-header">
                <i class="fas fa-info-circle"></i> Rate Plan Information
            </div>
            <div class="card-body">
                <form id="ratePlanForm">
                    <input type="hidden" id="planId" name="planId" value="${param.id}">

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="planName" class="form-label">Plan Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="planName" name="planName" required>
                            <div class="invalid-feedback">Please provide a plan name.</div>
                        </div>
                        <div class="col-md-6">
                            <label for="monthlyFee" class="form-label">Monthly Fee <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <span class="input-group-text">EGP</span>
                                <input type="number" class="form-control" id="monthlyFee" name="monthlyFee" 
                                       step="0.01" min="0" required>
                                <div class="invalid-feedback">Please provide a valid monthly fee.</div>
                            </div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-12">
                            <label for="description" class="form-label">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="2"></textarea>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="isCug" name="isCug">
                                <label class="form-check-label" for="isCug">Closed User Group (CUG)</label>
                            </div>
                        </div>
                    </div>

                    <div id="cugFields" class="row mb-3 cug-fields">
                        <div class="col-md-6">
                            <label for="maxCugMembers" class="form-label">Max CUG Members <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="maxCugMembers" name="maxCugMembers" min="1">
                            <div class="invalid-feedback">Please provide maximum CUG members.</div>
                        </div>
                        <div class="col-md-6">
                            <label for="cugUnit" class="form-label">CUG Unit (minutes/SMS/MB) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="cugUnit" name="cugUnit" min="1">
                            <div class="invalid-feedback">Please provide CUG unit value.</div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-12">
                            <label class="form-label">Service Packages</label>
                            <div class="service-list" id="serviceList">
                                <div class="text-center py-3">
                                    <div class="spinner-border text-primary" role="status">
                                        <span class="visually-hidden">Loading...</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-12 text-end">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> Save
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    
    
    <%!
    private boolean toBoolean(Object value) {
        if (value == null) return false;
        if (value instanceof Boolean) return (Boolean) value;
        if (value instanceof Number) return ((Number) value).intValue() != 0;
        if (value instanceof String) {
            String s = ((String) value).toLowerCase();
            return s.equals("true") || s.equals("1") || s.equals("yes") || s.equals("on");
        }
        return false;
    }
%>
    $(document).ready(function () {
        const planId = $('#planId').val();

        // Initialize form validation
        initFormValidation();

        // Load services
        loadAvailableServices();

        // Toggle CUG fields
        $('#isCug').change(function () {
            toggleCugFields($(this).is(':checked'));
        });

        // If editing, load the existing rate plan
        if (planId) {
            loadRatePlan(planId);
        }

        // Form submission
        $('#ratePlanForm').submit(function (e) {
            e.preventDefault();
            if (validateForm()) {
                saveRatePlan();
            }
        });
    });

    function initFormValidation() {
        // Enable Bootstrap validation
        $('#ratePlanForm').on('submit', function (event) {
            if (this.checkValidity() === false) {
                event.preventDefault();
                event.stopPropagation();
            }
            $(this).addClass('was-validated');
        });
    }

    function toggleCugFields(show) {
        if (show) {
            $('#cugFields').show();
            $('#maxCugMembers').prop('required', true);
            $('#cugUnit').prop('required', true);
        } else {
            $('#cugFields').hide();
            $('#maxCugMembers').prop('required', false);
            $('#cugUnit').prop('required', false);
        }
    }

        
        
        
    
    function loadRatePlan(planId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/api/rate-plans/' + planId,
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function (data) {
            console.log("Rate plan data:", data);
            
            $('#planName').val(data.planName);
            $('#description').val(data.description);
            $('#monthlyFee').val(data.monthlyFee);

            // Handle boolean conversion safely - using the 'cug' field from response
            const isCug = data.cug === true || data.cug === 1 || 
                         (typeof data.cug === 'string' && 
                          (data.cug.toLowerCase() === 'true' || data.cug === 't'));
            
            $('#isCug').prop('checked', isCug).trigger('change');
            
            if (isCug) {
                $('#maxCugMembers').val(data.maxCugMembers || '');
                $('#cugUnit').val(data.cugUnit || '');
            }

            // Mark selected services
            if (data.servicePackages && data.servicePackages.length > 0) {
                data.servicePackages.forEach(service => {
                    $(`#service-${service.serviceId}`).prop('checked', true);
                });
            }
        },
        error: function (xhr) {
            handleApiError(xhr);
        }
    });
}
        
        
        
    function loadAvailableServices() {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/rate-plans/services/available',
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function (data) {
                const serviceList = $('#serviceList');
                serviceList.empty();

                if (data && data.length > 0) {
                    data.forEach(service => {
                        const isFree = service.freeUnite;
                        const freeStatusClass = isFree ? 'yes' : 'no';
                        const freeFeeDisplay = isFree ? ` | Fee: EGP ${service.freeUnitMonthlyFee || 0}` : '';

                        const serviceItem = $(`
                            <div class="service-item">
                                <input type="checkbox" class="form-check-input service-checkbox" 
                                       id="service-${service.serviceId}" 
                                       name="serviceIds" value="${service.serviceId}">
                                <label for="service-${service.serviceId}" class="form-check-label">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="fw-bold">${service.serviceName}</span>
                                        <span class="badge bg-secondary service-type-badge">${service.serviceType}</span>
                                    </div>
                                    <div class="service-details">
                                        ${service.qouta || 0} ${service.unitDescription || 'units'} | 
                                        ${service.serviceNetworkZone || 'Unknown'} | 
                                        <span class="free-status ${freeStatusClass}">
                                            Free: ${isFree ? 'Yes' : 'No'}${freeFeeDisplay}
                                        </span>
                                    </div>
                                </label>
                            </div>
                        `);
                        serviceList.append(serviceItem);
                    });
                } else {
                    serviceList.html('<div class="text-center py-3">No services available</div>');
                }
            },
            error: function (xhr) {
                console.error("Error loading services:", xhr);
                $('#serviceList').html(`
                    <div class="alert alert-danger">
                        Error loading services. Status: ${xhr.status}
                        ${xhr.responseText ? '<br>' + xhr.responseText : ''}
                    </div>
                `);
            }
        });
    }

    function validateForm() {
        const form = document.getElementById('ratePlanForm');
        if (!form.checkValidity()) {
            $(form).addClass('was-validated');
            return false;
        }

        // Additional validation for CUG fields if CUG is enabled
        if ($('#isCug').is(':checked')) {
            if (!$('#maxCugMembers').val() || $('#maxCugMembers').val() <= 0) {
                $('#maxCugMembers').addClass('is-invalid');
                return false;
            }
            if (!$('#cugUnit').val() || $('#cugUnit').val() <= 0) {
                $('#cugUnit').addClass('is-invalid');
                return false;
            }
        }

        return true;
    }

   
   
    function saveRatePlan() {
    const planId = $('#planId').val();
    const method = planId ? 'PUT' : 'POST';
    const url = planId
            ? '${pageContext.request.contextPath}/api/rate-plans/' + planId
            : '${pageContext.request.contextPath}/api/rate-plans';

    // Collect selected service IDs
    const serviceIds = [];
    $('input[name="serviceIds"]:checked').each(function () {
        serviceIds.push(parseInt($(this).val()));
    });

    const requestData = {
        planName: $('#planName').val(),
        description: $('#description').val(),
        monthlyFee: parseFloat($('#monthlyFee').val()),
        isCug: $('#isCug').is(':checked'),
        maxCugMembers: $('#isCug').is(':checked') ? parseInt($('#maxCugMembers').val()) : 0,
        cugUnit: $('#isCug').is(':checked') ? parseInt($('#cugUnit').val()) : 0,
        serviceIds: serviceIds
    };

    $.ajax({
        url: url,
        method: method,
        contentType: 'application/json',
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        data: JSON.stringify(requestData),
        success: function (data) {
            showAlert('success', `Rate plan ${planId ? 'updated' : 'created'} successfully!`);
            if (!planId) {
                setTimeout(() => {
                    window.location.href = `form.jsp?id=${data.planId}`;
                }, 1500);
            }
        },
        error: function (xhr) {
            if (xhr.status === 400) {
                showAlert('danger', 'Validation error: ' + xhr.responseText);
            } else {
                handleApiError(xhr);
            }
        }
    });
}

    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    function handleApiError(xhr) {
        console.error('API Error:', xhr);
        var message = 'An error occurred';

        if (xhr.status === 403) {
            message = 'Your session has expired. Please login again.';
            clearAuthTokens();
            setTimeout(function () {
                window.location.href = '${pageContext.request.contextPath}/login.jsp';
            }, 2000);
        } else if (xhr.status === 400) {
            message = 'Validation error: ' + (xhr.responseJSON ? xhr.responseJSON.message : 'Invalid data');
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
            setTimeout(function () {
                $('#' + alertId).alert('close');
            }, 5000);
        }
    }
</script>

<%@ include file="../includes/footer.jsp" %>