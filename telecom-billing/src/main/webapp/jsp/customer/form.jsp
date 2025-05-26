<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css">
<link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">

<style>
    .card {
        margin-bottom: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .card-header {
        background-color: #f8f9fa;
        padding: 12px 20px;
        border-bottom: 1px solid rgba(0,0,0,.125);
    }
    .form-label {
        font-weight: 500;
        margin-bottom: 5px;
    }
    .required:after {
        content: " *";
        color: #dc3545;
    }
    #cugSection {
        display: none;
        margin-top: 15px;
        padding: 15px;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        background-color: #f8f9fa;
    }
    .cug-member-item {
        display: flex;
        align-items: center;
        margin-bottom: 8px;
    }
    .cug-member-item input {
        flex-grow: 1;
        margin-right: 10px;
    }
    .remove-cug-btn {
        color: #dc3545;
        cursor: pointer;
    }
    .plan-option {
        display: flex;
        justify-content: space-between;
    }
    .plan-name {
        font-weight: bold;
    }
    .plan-price {
        color: #28a745;
        font-weight: bold;
    }
    .plan-services {
        color: #6c757d;
        font-size: 0.9em;
        display: block;
    }
    .cug-badge {
        background-color: #17a2b8;
        color: white;
        font-size: 0.75em;
        padding: 2px 5px;
        border-radius: 3px;
        margin-left: 5px;
    }
    .service-type-header {
        font-weight: bold;
        background-color: #f8f9fa;
        padding: 5px 10px;
        margin-top: 5px;
    }
    .toggle-container {
        margin-bottom: 15px;
    }
    .toggle-content {
        display: none;
        margin-top: 10px;
        padding: 15px;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        background-color: #f8f9fa;
    }
    #phoneError {
        display: none;
        color: #dc3545;
        font-size: 0.85rem;
        margin-top: 5px;
    }
</style>

<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-user"></i> <span id="formTitle">Add Customer</span>
        </h3>
    </div>
    <div class="col-md-6 text-end">
        <a href="list.jsp" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div id="alertContainer"></div>

<form id="customerForm" class="needs-validation" novalidate>
    <input type="hidden" id="customerId" name="customerId">

    <!-- Personal Information Card -->
    <div class="card shadow-sm mb-4">
        <div class="card-header">
            <h5 class="card-title mb-0">
                <i class="fas fa-info-circle"></i> Personal Information
            </h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="nid" class="form-label required">National ID</label>
                        <input type="text" class="form-control" id="nid" name="nid" required>
                        <div class="invalid-feedback">Please provide a national ID</div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="name" class="form-label required">Full Name</label>
                        <input type="text" class="form-control" id="name" name="name" required maxlength="100">
                        <div class="invalid-feedback">Please provide a full name</div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="phone" class="form-label required">Phone Number</label>
                        <input type="text" class="form-control" id="phone" name="phone" required 
                               pattern="\+2016\d{8}" maxlength="13"
                               title="Phone number must start with +2016 followed by 8 digits">
                        <div id="phoneError" class="invalid-feedback">Please provide a valid phone number</div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" class="form-control" id="email" name="email" maxlength="100">
                        <div class="invalid-feedback">Please provide a valid email</div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="form-group mb-3">
                        <label for="address" class="form-label">Address</label>
                        <textarea class="form-control" id="address" name="address" rows="2" maxlength="200"></textarea>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Account Settings Card -->
    <div class="card shadow-sm mb-4">
        <div class="card-header">
            <h5 class="card-title mb-0">
                <i class="fas fa-cog"></i> Account Settings
            </h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="status" class="form-label required">Status</label>
                        <select class="form-control" id="status" name="status" required>
                            <option value="">Select Status</option>
                            <option value="ACTIVE">Active</option>
                            <option value="INACTIVE">Inactive</option>
                            <option value="SUSPENDED">Suspended</option>
                        </select>
                        <div class="invalid-feedback">Please select a status</div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="planId" class="form-label required">Rate Plan</label>
                        <select class="form-control select2" id="planId" name="planId" required>
                            <option value="">Select a rate plan</option>
                        </select>
                        <div class="invalid-feedback">Please select a rate plan</div>
                    </div>
                    
                    <div id="cugSection">
                        <h6>Closed User Group (CUG) Members</h6>
                        <div id="cugInfo" class="mb-3">
                            <small class="text-muted">This plan allows up to <span id="maxCugMembersDisplay">0</span> CUG members.</small>
                        </div>
                        
                        <div id="cugMembersContainer">
                            <!-- CUG member inputs will be added here -->
                        </div>
                        
                        <div id="cugError" class="text-danger small mb-2"></div>
                        
                        <button type="button" id="addCugMemberBtn" class="btn btn-sm btn-outline-primary">
                            <i class="fas fa-plus"></i> Add CUG Member
                        </button>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="creditLimit" class="form-label required">Credit Limit (EGP)</label>
                        <input type="number" class="form-control" id="creditLimit" name="creditLimit" required min="0" value="0">
                        <div class="invalid-feedback">Please provide a valid credit limit</div>
                    </div>
                </div>
            </div>

            <!-- Free Unit Package Toggle -->
            <div class="toggle-container">
                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" id="hasFreeUnit" name="hasFreeUnit">
                    <label class="form-check-label" for="hasFreeUnit">Add Free Unit Package</label>
                </div>
                <div id="freeUnitContainer" class="toggle-content">
                    <div class="form-group mb-3">
                        <label for="freeUnitId" class="form-label">Free Unit Package</label>
                        <select class="form-control select2" id="freeUnitId" name="freeUnitId">
                            <option value="">Select a free unit package</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- OCC Toggle -->
            <div class="toggle-container">
                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" id="hasOcc" name="hasOcc">
                    <label class="form-check-label" for="hasOcc">Add OCC (Optional Customer Commitment)</label>
                </div>
                <div id="occContainer" class="toggle-content">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group mb-3">
                                <label for="occName" class="form-label">OCC Name</label>
                                <input type="text" class="form-control" id="occName" name="occName" maxlength="50">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group mb-3">
                                <label for="occPrice" class="form-label">Total OCC Price (EGP)</label>
                                <input type="number" class="form-control" id="occPrice" name="occPrice" min="0" value="0">
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group mb-3">
                                <label for="months_number_installments" class="form-label">Installment Months</label>
                                <input type="number" class="form-control" id="months_number_installments" name="months_number_installments" min="0" value="0">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="text-end mb-4">
        <button type="submit" class="btn btn-primary" id="submitBtn">
            <i class="fas fa-save"></i> Save Customer
        </button>
    </div>
</form>

<script>
    $(document).ready(function () {
        const urlParams = new URLSearchParams(window.location.search);
        const customerId = urlParams.get('id');
        let maxCugMembers = 0;
        let cugNumbers = [];

        // Initialize form elements
        $('.select2').select2();
        loadRatePlans();
        
        // Set form title if editing
        if (customerId) {
            $('#formTitle').text('Edit Customer');
            loadCustomerData(customerId);
        }

        // CUG functionality
        $('#addCugMemberBtn').click(function() {
            if (cugNumbers.length >= maxCugMembers) {
                $('#cugError').text('Maximum number of CUG members reached for this plan');
                return;
            }
            
            const newInput = $(`
                <div class="cug-member-item">
                    <input type="text" class="form-control cug-number-input" placeholder="Enter CUG number" pattern="\\d+" title="Numbers only">
                    <button type="button" class="btn btn-link remove-cug-btn">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            `);
            
            $('#cugMembersContainer').append(newInput);
            $('#cugError').text('');
        });
        
        $(document).on('click', '.remove-cug-btn', function() {
            $(this).closest('.cug-member-item').remove();
            $('#cugError').text('');
        });

        // Toggle free unit package fields
        $('#hasFreeUnit').change(function () {
            if ($(this).is(':checked')) {
                $('#freeUnitContainer').show();
                loadFreeUnitPackages();
            } else {
                $('#freeUnitContainer').hide();
                $('#freeUnitId').val(null).trigger('change');
            }
        });

        // Toggle OCC fields
        $('#hasOcc').change(function () {
            $('#occContainer').toggle($(this).is(':checked'));
            if (!$(this).is(':checked')) {
                $('#occName').val('');
                $('#occPrice').val('0');
                $('#months_number_installments').val('0');
            }
        });

        // Phone number validation
        $('#phone').on('input', function() {
            const phone = $(this).val();
            if (!/^\+2016\d{8}$/.test(phone)) {
                $('#phoneError').show().text('Format: +2016 followed by 8 digits (13 characters total)');
            } else {
                $('#phoneError').hide();
                checkPhoneUniqueness(phone);
            }
        });

        function checkPhoneUniqueness(phone) {
            const url = `${pageContext.request.contextPath}/api/customers/check-phone?phone=${encodeURIComponent(phone)}` + 
                       (customerId ? `&excludeId=${customerId}` : '');
            
            $.ajax({
                url: url,
                method: 'GET',
                headers: { 'Authorization': 'Bearer ' + getAuthToken() },
                success: function(exists) {
                    if (exists) {
                        $('#phone').addClass('is-invalid');
                        $('#phoneError').show().text('This phone number is already registered');
                    } else {
                        $('#phone').removeClass('is-invalid');
                        $('#phoneError').hide();
                    }
                }
            });
        }

        // Load CUG details when rate plan is selected
        $('#planId').change(function() {
            const planId = $(this).val();
            if (planId) {
                $.ajax({
                    url: `${pageContext.request.contextPath}/api/rate-plans/${planId}`,
                    method: 'GET',
                    headers: { 'Authorization': 'Bearer ' + getAuthToken() },
                    success: function(plan) {
                        maxCugMembers = plan.maxCugMembers || 0;
                        $('#maxCugMembersDisplay').text(maxCugMembers);
                        $('#cugSection').toggle(maxCugMembers > 0);
                        if (maxCugMembers <= 0) {
                            $('#cugMembersContainer').empty();
                        }
                    }
                });
            } else {
                $('#cugSection').hide();
                $('#cugMembersContainer').empty();
            }
        });

        // Form submission
        $('#customerForm').submit(function (e) {
            e.preventDefault();
            e.stopPropagation();

            if (!this.checkValidity()) {
                $(this).addClass('was-validated');
                return;
            }

            // Collect CUG numbers
            const cugNumbers = [];
            $('.cug-number-input').each(function() {
                const value = $(this).val().trim();
                if (value) cugNumbers.push(parseInt(value));
            });

            // Validate CUG numbers if needed
            if (maxCugMembers > 0 && cugNumbers.length === 0) {
                $('#cugError').text('Please add at least one CUG member for this plan');
                return;
            }

            const formData = {
                nid: $('#nid').val(),
                name: $('#name').val(),
                phone: $('#phone').val(),
                email: $('#email').val() || null,
                address: $('#address').val() || null,
                status: $('#status').val(),
                creditLimit: parseInt($('#creditLimit').val()),
                planId: parseInt($('#planId').val()),
                freeUnitId: $('#hasFreeUnit').is(':checked') ? parseInt($('#freeUnitId').val()) : null,
                occName: $('#hasOcc').is(':checked') ? $('#occName').val() : null,
                occPrice: $('#hasOcc').is(':checked') ? parseFloat($('#occPrice').val()) : 0,
                monthsNumberInstallments: $('#hasOcc').is(':checked') ? parseInt($('#months_number_installments').val()) : 0,
                cugNumbers: cugNumbers.length > 0 ? cugNumbers : null
            };

            const method = customerId ? 'PUT' : 'POST';
            const url = `${pageContext.request.contextPath}/api/customers` + (customerId ? `/${customerId}` : '');

            $('#submitBtn').prop('disabled', true)
                .html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...');

            $.ajax({
                url: url,
                method: method,
                contentType: 'application/json',
                data: JSON.stringify(formData),
                headers: { 'Authorization': 'Bearer ' + getAuthToken() },
                success: function (response) {
                    showAlert('success', customerId ? 'Customer updated successfully!' : 'Customer created successfully!');
                    if (!customerId) {
                        setTimeout(() => window.location.href = `view.jsp?id=${response.customerId}`, 1500);
                    }
                },
                error: function (xhr) {
                    $('#submitBtn').prop('disabled', false).html('<i class="fas fa-save"></i> Save Customer');
                    const message = xhr.responseJSON?.message || 'An error occurred while saving';
                    showAlert('danger', message);
                    if (xhr.status === 403) {
                        setTimeout(() => window.location.href = '${pageContext.request.contextPath}/login.jsp', 2000);
                    }
                }
            });
        });

        function loadCustomerData(customerId) {
            $.ajax({
                url: `${pageContext.request.contextPath}/api/customers/${customerId}`,
                method: 'GET',
                headers: { 'Authorization': 'Bearer ' + getAuthToken() },
                success: function (data) {
                    $('#customerId').val(data.customerId);
                    $('#nid').val(data.nid);
                    $('#name').val(data.name);
                    $('#phone').val(data.phone);
                    $('#email').val(data.email || '');
                    $('#address').val(data.address || '');
                    $('#status').val(data.status);
                    $('#creditLimit').val(data.creditLimit);
                    $('#planId').val(data.planId).trigger('change');

                    // Load CUG numbers
                    if (data.cugNumbers?.length > 0) {
                        data.cugNumbers.forEach(num => {
                            $('#cugMembersContainer').append(`
                                <div class="cug-member-item">
                                    <input type="text" class="form-control cug-number-input" value="${num}" pattern="\\d+">
                                    <button type="button" class="btn btn-link remove-cug-btn">
                                        <i class="fas fa-times"></i>
                                    </button>
                                </div>
                            `);
                        });
                    }

                    // Set free unit if exists
                    if (data.freeUnitId) {
                        $('#hasFreeUnit').prop('checked', true).trigger('change');
                        setTimeout(() => $('#freeUnitId').val(data.freeUnitId).trigger('change'), 300);
                    }

                    // Set OCC if exists
                    if (data.occName || data.occPrice > 0) {
                        $('#hasOcc').prop('checked', true).trigger('change');
                        $('#occName').val(data.occName || '');
                        $('#occPrice').val(data.occPrice || 0);
                        $('#months_number_installments').val(data.monthsNumberInstallments || 0);
                    }
                },
                error: function (xhr) {
                    showAlert('danger', 'Failed to load customer data');
                    console.error('Error loading customer:', xhr);
                }
            });
        }

        function loadRatePlans() {
            $.ajax({
                url: `${pageContext.request.contextPath}/api/rate-plans`,
                method: 'GET',
                headers: { 'Authorization': 'Bearer ' + getAuthToken() },
                success: function (plans) {
                    $('#planId').empty().append('<option value="">Select a rate plan</option>');
                    plans.forEach(plan => {
                        const option = new Option(
                            `${plan.planName} - EGP ${plan.monthlyFee.toFixed(2)}${plan.isCug ? ' (CUG)' : ''}`,
                            plan.planId,
                            false,
                            false
                        );
                        option.dataset.cug = plan.isCug;
                        $('#planId').append(option);
                    });
                    
                    if (customerId) {
                        // This will be set after customer data loads
                    }
                }
            });
        }

        function loadFreeUnitPackages(selectedId = null) {
            $.ajax({
                url: `${pageContext.request.contextPath}/api/customers/free-unit-options`,
                method: 'GET',
                headers: { 'Authorization': 'Bearer ' + getAuthToken() },
                success: function (packages) {
                    $('#freeUnitId').empty().append('<option value="">Select a free unit package</option>');
                    
                    // Group by service type
                    const grouped = packages.reduce((acc, pkg) => {
                        if (!acc[pkg.serviceType]) acc[pkg.serviceType] = [];
                        acc[pkg.serviceType].push(pkg);
                        return acc;
                    }, {});
                    
                    // Add grouped options
                    Object.entries(grouped).forEach(([type, items]) => {
                        const group = new Option(type, null, false, false);
                        group.disabled = true;
                        $('#freeUnitId').append(group);
                        
                        items.forEach(pkg => {
                            const option = new Option(
                                `${pkg.serviceName} - ${pkg.qouta} ${pkg.unitDescription} (EGP ${pkg.freeUnitMonthlyFee.toFixed(2)}/month)`,
                                pkg.serviceId
                            );
                            $('#freeUnitId').append(option);
                        });
                    });
                    
                    if (selectedId) {
                        $('#freeUnitId').val(selectedId).trigger('change');
                    }
                }
            });
        }

        function getAuthToken() {
            return localStorage.getItem('authToken') || '';
        }

        function showAlert(type, message) {
            const alert = $(`
                <div class="alert alert-${type} alert-dismissible fade show" role="alert">
                    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            `);
            $('#alertContainer').html(alert);
            setTimeout(() => alert.alert('close'), 5000);
        }
    });
</script>

<%@ include file="../includes/footer.jsp" %>