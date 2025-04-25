<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-cube"></i> <span id="formTitle">Add Service Package</span>
        </h3>
    </div>
    <div class="col-md-6 text-end">
        <a href="list.jsp" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div id="alertContainer"></div>

<form id="packageForm" class="needs-validation" novalidate>
    <input type="hidden" id="serviceId" name="serviceId">

    <div class="card shadow-sm mb-4">
        <div class="card-header bg-light">
            <h5 class="card-title mb-0">
                <i class="fas fa-info-circle"></i> Package Details
            </h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="serviceName" class="form-label">Name *</label>
                        <input type="text" class="form-control" id="serviceName" name="serviceName" required maxlength="50">
                        <div class="invalid-feedback">Please provide a package name (max 50 characters).</div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="serviceType" class="form-label">Type *</label>
                        <select class="form-control" id="serviceType" name="serviceType" required>
                            <option value="">Select Type</option>
                            <option value="VOICE">Voice</option>
                            <option value="SMS">SMS</option>
                            <option value="DATA">Data</option>
                        </select>
                        <div class="invalid-feedback">Please select a package type.</div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="serviceNetworkZone" class="form-label">Network Zone *</label>
                        <select class="form-control" id="serviceNetworkZone" name="serviceNetworkZone" required>
                            <option value="">Select Zone</option>
                            <option value="ON_NET">On-Net</option>
                            <option value="ROAMING">Roaming</option>
                            <option value="CROSS_NET">Cross-Net</option>
                        </select>
                        <div class="invalid-feedback">Please select a network zone.</div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="quota" class="form-label">Quota *</label>
                        <input type="number" class="form-control" id="quota" name="quota" value="1000" required min="0">
                        <small class="form-text text-muted">Enter 0 for unlimited quota</small>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="ratePerUnit" class="form-label">Rate Per Unit (EGP) *</label>
                        <div class="input-group">
                            <input type="number" step="0.0001" class="form-control" id="ratePerUnit" name="ratePerUnit" value="0.0500" required min="0">
                            <span class="input-group-text">EGP</span>
                        </div>
                        <small class="form-text text-muted">Must be a number with up to 4 decimal places</small>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="unitDescription" class="form-label">Unit Description</label>
                        <input type="text" class="form-control" id="unitDescription" name="unitDescription" maxlength="50">
                        <small class="form-text text-muted">e.g. "Per minute", "Per MB", "Per SMS" (max 50 characters)</small>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="validityDays" class="form-label">Validity Days</label>
                        <input type="number" class="form-control" id="validityDays" name="validityDays" min="1">
                        <small class="form-text text-muted">Leave empty if no expiration</small>
                    </div>
                </div>

                <div class="col-md-12">
                    <div class="form-group mb-25 form-check">
                        <input type="checkbox" class="form-check-input" id="isFreeUnit" name="is_free_unit">
                        <label class="form-check-label" for="isFreeUnit">Is Free Unit</label>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <div class="text-end mb-4">
        <button type="submit" class="btn btn-primary" id="submitBtn">
            <i class="fas fa-save"></i> Save Package
        </button>
    </div>
</form>

<script>
    $(document).ready(function () {
        // Get the ID from the URL if editing
        const urlParams = new URLSearchParams(window.location.search);
        const packageId = urlParams.get('id');

        if (packageId) {
            loadPackageData(packageId);
        }

        // Form submission handler
        $('#packageForm').submit(function (e) {
            e.preventDefault();

            if (!this.checkValidity()) {
                e.stopPropagation();
                $(this).addClass('was-validated');
                return;
            }

            const formData = {
                serviceName: $('#serviceName').val(),
                serviceType: $('#serviceType').val(),
                serviceNetworkZone: $('#serviceNetworkZone').val(),
                quota: parseInt($('#quota').val()),
                ratePerUnit: $('#ratePerUnit').val(), // Send as string, let Java convert
                unitDescription: $('#unitDescription').val() || null,
                validityDays: $('#validityDays').val() ? parseInt($('#validityDays').val()) : null,
                is_free_unit: $('#isFreeUnit').is(':checked') // Match Java field name exactly
            };

            const method = packageId ? 'PUT' : 'POST';
            const url = '${pageContext.request.contextPath}/api/service-packages' + (packageId ? '/' + packageId : '');

            $('#submitBtn').prop('disabled', true);

            $.ajax({
                url: url,
                method: method,
                contentType: 'application/json',
                data: JSON.stringify(formData),
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function (data) {

                    console.log('Success handler triggered'); // Add this line
                    showAlert('success', packageId ? 'Package updated successfully!' : 'Package created successfully!');

                    if (!packageId) {
                        setTimeout(function () {
                            window.location.href = 'view.jsp?id=' + data.serviceId;
                        }, 1000); // More time before redirect
                    }

                },
                error: function (xhr) {
                    $('#submitBtn').prop('disabled', false);
                    let message = 'An error occurred';

                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        message = xhr.responseJSON.message;
                    } else if (xhr.status === 403) {
                        message = 'Authentication failed. Please login again.';
                        setTimeout(() => window.location.href = '${pageContext.request.contextPath}/login.jsp', 2000);
                    }

                    showAlert('danger', message);
                    console.error('Error:', xhr);
                }
            });
        });
    });

    function loadPackageData(packageId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/service-packages/' + packageId,
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function (data) {
                $('#formTitle').text('Edit Service Package');
                $('#serviceId').val(data.serviceId);
                $('#serviceName').val(data.serviceName);
                $('#serviceType').val(data.serviceType);
                $('#serviceNetworkZone').val(data.serviceNetworkZone);
                $('#quota').val(data.quota);
                $('#ratePerUnit').val(data.ratePerUnit);
                $('#unitDescription').val(data.unitDescription || '');
                if (data.validityDays) {
                    $('#validityDays').val(data.validityDays);
                }
            },
            error: function (xhr) {
                showAlert('danger', 'Failed to load package data');
                console.error('Error loading package:', xhr);
            }
        });
    }

    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    function showAlert(type, message) {
        const alertHtml = `<div class="alert alert-${type} alert-dismissible fade show" role="alert">
    ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>`;
        $('#alertContainer').html(alertHtml);
    }
// Simple BigDecimal implementation for JavaScript
    function BigDecimal(value) {
        this.value = parseFloat(value);
        this.setScale = function (scale, roundingMode) {
            const factor = Math.pow(10, scale);
            const rounded = Math.round(this.value * factor) / factor;
            return rounded;
        };
        return this;
    }

// Rounding mode constants
    const RoundingMode = {
        HALF_UP: 4
    };
</script>

<%@ include file="../includes/footer.jsp" %>