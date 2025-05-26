<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

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
                            <option value="NET">On-Net</option>
                            <option value="ROAMING">Roaming</option>
                            <option value="CROSS">Cross-Net</option>
                        </select>
                        <div class="invalid-feedback">Please select a network zone.</div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="qouta" class="form-label">Quota *</label>
                        <input type="number" class="form-control" id="qouta" name="qouta" value="1000" required min="0">
                        <small class="form-text text-muted">Enter 0 for unlimited quota</small>
                        <div class="invalid-feedback">Please provide a valid quota (positive number).</div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="unitDescription" class="form-label">Unit Description *</label>
                        <select class="form-control" id="unitDescription" name="unitDescription" required>
                            <option value="">Select Unit</option>
                            <option value="Minutes">Minutes</option>
                            <option value="MB">MB</option>
                            <option value="Texts">Texts</option>
                            <option value="Unlimited">Unlimited</option>
                        </select>
                        <div class="invalid-feedback">Please select a unit description.</div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group mb-3" id="freeUnitFeeGroup" style="display: none;">
                        <label for="freeUnitMonthlyFee" class="form-label">Monthly Fee (EGP) *</label>
                        <div class="input-group">
                            <input type="number" step="0.01" class="form-control" id="freeUnitMonthlyFee" name="freeUnitMonthlyFee" value="0.00" min="0" required>
                            <span class="input-group-text">EGP</span>
                        </div>
                        <small class="form-text text-muted">Monthly subscription fee for this package</small>
                        <div class="invalid-feedback">Please provide a valid monthly fee (positive number).</div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="form-group mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="isFreeUnite" name="isFreeUnite">
                        <label class="form-check-label" for="isFreeUnite">Is Free Unit</label>
                        <small class="form-text text-muted d-block">Check this if this package is a subscription-based free unit package</small>
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
        // Toggle free unit fee field based on checkbox
        $('#isFreeUnite').change(function () {
            if ($(this).is(':checked')) {
                $('#freeUnitFeeGroup').show();
                $('#freeUnitMonthlyFee').attr('required', true);
            } else {
                $('#freeUnitFeeGroup').hide();
                $('#freeUnitMonthlyFee').removeAttr('required');
                $('#freeUnitMonthlyFee').val('0.00');
            }
        });

        // Auto-select unit description based on service type
        $('#serviceType').change(function () {
            const type = $(this).val();
            const unitSelect = $('#unitDescription');

            if (type === 'VOICE') {
                unitSelect.val('Minutes');
            } else if (type === 'SMS') {
                unitSelect.val('Texts');
            } else if (type === 'DATA') {
                unitSelect.val('MB');
            }
        });

        // Form submission handler
        $('#packageForm').submit(function (e) {
            e.preventDefault();

            // Validate form
            if (!this.checkValidity()) {
                e.stopPropagation();
                $(this).addClass('was-validated');
                return;
            }

            // Prepare form data
            const formData = {
                serviceName: $('#serviceName').val(),
                serviceType: $('#serviceType').val(),
                serviceNetworkZone: $('#serviceNetworkZone').val(),
                qouta: parseInt($('#qouta').val()),
                unitDescription: $('#unitDescription').val(),
                freeUnite: $('#isFreeUnite').is(':checked'),
                freeUnitMonthlyFee: $('#isFreeUnite').is(':checked') ?
                        parseFloat($('#freeUnitMonthlyFee').val()) : 0.00
            };

            // Disable submit button to prevent multiple submissions
            $('#submitBtn').prop('disabled', true);

            // Show loading state
            $('#submitBtn').html('<i class="fas fa-spinner fa-spin"></i> Saving...');

            // Send AJAX request
            $.ajax({
                url: '${pageContext.request.contextPath}/api/service-packages',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(formData),
                success: function (response) {
                    showAlert('success', 'Service package created successfully!');
                    // Reset form
                    $('#packageForm')[0].reset();
                    $('#packageForm').removeClass('was-validated');

                    // Redirect after short delay
                    setTimeout(function () {
                        window.location.href = 'view.jsp?id=' + response.serviceId;
                    }, 1500);
                },

                error: function (xhr) {
                    let errorMessage = 'Error creating service package';
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        errorMessage = xhr.responseJSON.message;
                    }
                    showAlert('danger', errorMessage);
                },
                complete: function () {
                    // Re-enable submit button
                    $('#submitBtn').prop('disabled', false);
                    $('#submitBtn').html('<i class="fas fa-save"></i> Save Package');
                }
            });
        });

        // Function to show alert messages
        function showAlert(type, message) {
            const alertHtml = `
            <div class="alert alert-${type} alert-dismissible fade show" role="alert">
    ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        `;
            $('#alertContainer').html(alertHtml);
        }
    });

</script>
<%@ include file="../includes/footer.jsp" %>