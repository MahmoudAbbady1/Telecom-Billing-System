<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<script src="${pageContext.request.contextPath}/js/scripts.js"></script>

<style>
    .card {
        margin-bottom: 20px;
        border-radius: 8px;
    }
    .card-header {
        padding: 12px 20px;
        border-bottom: 1px solid rgba(0,0,0,.125);
    }
    .form-label {
        font-weight: 500;
        margin-bottom: 5px;
    }
    .invalid-feedback {
        font-size: 0.85rem;
    }
    .required:after {
        content: " *";
        color: #dc3545;
    }
    .toggle-container {
        margin-bottom: 15px;
    }
    .toggle-content {
        display: none;
        margin-top: 10px;
        padding: 10px;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        background-color: #f8f9fa;
    }
    #cugSection {
        display: none;
        margin-top: 15px;
        padding: 15px;
        border: 1px solid #dee2e6;
        border-radius: 5px;
        background-color: #f8f9fa;
    }
    .cug-member-input {
        margin-bottom: 10px;
    }
    #addCugMemberBtn {
        margin-bottom: 15px;
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
    .cug-member-item .remove-cug-btn {
        color: #dc3545;
        cursor: pointer;
    }
    .cug-error {
        color: #dc3545;
        font-size: 0.85rem;
        margin-top: 5px;
    }
    #serviceSelection {
        display: none;
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
        <div class="card-header bg-light">
            <h5 class="card-title mb-0">
                <i class="fas fa-info-circle"></i> Personal Information
            </h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="nid" class="form-label required">National ID</label>
                        <input type="text" class="form-control" id="nid" name="nid" required maxlength="20">
                    </div>

                    <div class="form-group mb-3">
                        <label for="name" class="form-label required">Full Name</label>
                        <input type="text" class="form-control" id="name" name="name" required maxlength="100">
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="phone" class="form-label required">Phone Number</label>
                        <div class="input-group">
                            <span class="input-group-text">+2016</span>
                            <input type="text" class="form-control" id="phone" name="phone" required 
                                   pattern="\d{8}" maxlength="8"
                                   title="Enter the remaining 8 digits after +2016">
                            <div id="phoneError" class="invalid-feedback">Please enter 8 digits after +2016.</div>
                        </div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="email" class="form-label">Email</label>
                        <input type="email" class="form-control" id="email" name="email" maxlength="100">
                        <div class="invalid-feedback">Please provide a valid email address.</div>
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
        <div class="card-header bg-light">
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
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="planId" class="form-label">Rate Plan</label>
                        <select class="form-control" id="planId" name="planId">
                            <option value="">Select Plan to add</option>
                            <!-- Options will be loaded dynamically -->
                        </select>
                    </div>

                    <!-- CUG Section -->
                    <div id="cugSection">
                        <h6>Closed User Group (CUG) Members</h6>
                        <div id="cugInfo" class="mb-3">
                            <small class="text-muted">This plan allows up to <span id="maxCugMembersDisplay">0</span> CUG members.</small>
                        </div>

                        <div id="cugMembersContainer">
                            <!-- CUG member inputs will be added here -->
                        </div>

                        <div id="cugError" class="cug-error"></div>

                        <button type="button" id="addCugMemberBtn" class="btn btn-sm btn-outline-primary">
                            <i class="fas fa-plus"></i> Add CUG Member
                        </button>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="creditLimit" class="form-label required">Credit Limit (EGP)</label>
                        <input type="number" class="form-control" id="creditLimit" name="creditLimit" required min="0">
                    </div>
                </div>
            </div>

            <!-- Free Unit Package Toggle -->
            <div class="toggle-container">
                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" id="hasFreeUnit" name="hasFreeUnit">
                    <label class="form-check-label" for="hasFreeUnit">Customer needs free unit package</label>
                </div>
                <div id="freeUnitContainer" class="toggle-content">
                    <div class="form-group mb-3">
                        <label for="freeUnitId" class="form-label">Free Unit Package</label>
                        <select class="form-control" id="freeUnitId" name="freeUnitId">
                            <option value="">Select Free unit</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- OCC Toggle -->
            <div class="toggle-container">
                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" id="hasOcc" name="hasOcc">
                    <label class="form-check-label" for="hasOcc">Customer needs OCC</label>
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
                                <label for="occPrice" class="form-label">Total OCC Price</label>
                                <input type="number" class="form-control" id="occPrice" name="occPrice" min="0" value="0">
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group mb-3">
                                <label for="months_number_installments" class="form-label">Installment Months</label>
                                <input type="number" class="form-control" id="months_number_installments" name="months_number_installments" min="0" value="0" data-require-when-occ="true">
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

    // Do not call loadRatePlans here; it will be called in loadCustomerData if editing
    // Initialize other form elements and event handlers

    // CUG functionality
    $('#addCugMemberBtn').click(function () {
        if (cugNumbers.length >= maxCugMembers) {
            $('#cugError').text('Maximum number of CUG members reached for this plan');
            return;
        }

        const newInput = $(`
            <div class="cug-member-item">
                <div class="input-group">
                    <span class="input-group-text">+2016</span>
                    <input type="text" class="form-control cug-number-input" placeholder="Enter 8 digits" pattern="\\d{8}" maxlength="8" required>
                    <button type="button" class="btn btn-link remove-cug-btn">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>
        `);

        $('#cugMembersContainer').append(newInput);
        $('#cugError').text('');
    });

    $(document).on('click', '.remove-cug-btn', function () {
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
            $('#freeUnitId').val('');
        }
    });

    // Toggle OCC fields
    $('#hasOcc').change(function () {
        if ($(this).is(':checked')) {
            $('#occContainer').show();
            $('#months_number_installments').attr('required', true);
        } else {
            $('#occContainer').hide();
            $('#occName').val('');
            $('#occPrice').val('0');
            $('#months_number_installments').val('0').removeAttr('required');
        }
    });

    // Phone number uniqueness check
    $('#phone').on('blur', function () {
        const phone = $(this).val().trim();
        if (phone) {
            const fullPhone = '+2016' + phone;
            const url = '${pageContext.request.contextPath}/api/customers/check-phone?phone=' +
                    encodeURIComponent(fullPhone) +
                    (customerId ? '&excludeId=' + customerId : '');

            $.ajax({
                url: url,
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function (exists) {
                    const phoneField = $('#phone');
                    const errorElement = $('#phoneError');

                    if (exists) {
                        phoneField.addClass('is-invalid');
                        errorElement.text('This phone number is already registered.');
                    } else {
                        phoneField.removeClass('is-invalid');
                        errorElement.text('');
                    }
                },
                error: function (xhr) {
                    console.error('Error checking phone number:', xhr);
                    showAlert('danger', 'Failed to validate phone number.');
                }
            });
        }
    });

    // Load CUG details when rate plan is selected
    $('#planId').change(function () {
        const planId = $(this).val();
        if (planId) {
            $.ajax({
                url: '${pageContext.request.contextPath}/api/rate-plans/' + planId,
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function (plan) {
                    maxCugMembers = plan.maxCugMembers || 0;
                    $('#maxCugMembersDisplay').text(maxCugMembers);

                    if (maxCugMembers > 0) {
                        $('#cugSection').show();
                    } else {
                        $('#cugSection').hide();
                        $('#cugMembersContainer').empty();
                        cugNumbers = [];
                    }
                },
                error: function (xhr) {
                    console.error('Error loading rate plan details:', xhr);
                    showAlert('danger', 'Failed to load rate plan details.');
                }
            });
        } else {
            $('#cugSection').hide();
            $('#cugMembersContainer').empty();
            cugNumbers = [];
            maxCugMembers = 0;
        }
    });

$('#customerForm').submit(function (e) {
    e.preventDefault();

    if (!this.checkValidity()) {
        e.stopPropagation();
        $(this).addClass('was-validated');
        return;
    }

    const cugNumbers = [];
    $('.cug-number-input').each(function () {
        const phone = $(this).val().trim();
        if (phone) {
            if (!phone.match(/^\d{8}$/)) {
                $('#cugError').text('CUG numbers must be 8 digits after +2016.');
                return false;
            }
            cugNumbers.push('+2016' + phone);
        }
    });

    if ($('#cugError').text()) {
        return; // Stop submission if there?s a CUG error
    }

    if ($('#hasOcc').is(':checked')) {
        const months = parseInt($('#months_number_installments').val());
        const occPrice = parseInt($('#occPrice').val());

        if (occPrice > 0 && months <= 0) {
            showAlert('danger', 'Installment months must be at least 1 when OCC price is greater than 0');
            return false;
        }
    }

    const formData = {
        nid: $('#nid').val().trim(),
        name: $('#name').val().trim(),
        phone: '+2016' + $('#phone').val().trim(),
        email: $('#email').val().trim(),
        address: $('#address').val().trim(),
        status: $('#status').val(),
        creditLimit: parseInt($('#creditLimit').val()) || 100,
        planId: $('#planId').val() ? parseInt($('#planId').val()) : null,
        freeUnitId: $('#hasFreeUnit').is(':checked') && $('#freeUnitId').val() ? parseInt($('#freeUnitId').val()) : null,
        occPrice: $('#hasOcc').is(':checked') ? parseInt($('#occPrice').val()) || 0 : 0,
        monthsNumberInstallments: $('#hasOcc').is(':checked') ? Math.max(1, parseInt($('#months_number_installments').val()) || 0) : 0,
        occName: $('#hasOcc').is(':checked') ? $('#occName').val().trim() : '',
        cugNumbers: cugNumbers
    };

    console.log('Submitting form data:', formData);

    const method = customerId ? 'PUT' : 'POST';
    const url = '${pageContext.request.contextPath}/api/customers' + (customerId ? '/' + customerId : '');

    $('#submitBtn').prop('disabled', true)
        .html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...');

    $.ajax({
        url: url,
        method: method,
        contentType: 'application/json',
        data: JSON.stringify(formData),
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function (data) {
            showAlert('success', customerId ? 'Customer updated successfully!' : 'Customer created successfully!');
            setTimeout(function () {
                window.location.href = 'view.jsp?id=' + (customerId || data.customerId);
            }, 1500);
        },
        error: function (xhr) {
            $('#submitBtn').prop('disabled', false)
                .html('<i class="fas fa-save"></i> Save Customer');
            let message = xhr.responseJSON && xhr.responseJSON.message ? xhr.responseJSON.message : 'An error occurred';
            if (xhr.status === 403) {
                message = 'Authentication failed. Please login again.';
                setTimeout(() => window.location.href = '${pageContext.request.contextPath}/index.jsp', 2000);
            }
            showAlert('danger', message);
            console.error('Error details:', xhr.responseJSON || xhr);
        }
    });
});
    // Load customer data if editing
    if (customerId) {
        loadCustomerData(customerId);
    } else {
        // For new customer, load rate plans without pre-selection
        console.log('No customerId, loading rate plans without selection');
        loadRatePlans(null);
    }

function loadCustomerData(customerId) {
    $.ajax({
        url: '${pageContext.request.contextPath}/api/customers/' + customerId,
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function (data) {
            const customer = data.customer || data;
            const ratePlan = data.ratePlan || null;

            console.log('Full API Response:', data);
            console.log('Customer Data:', customer);
            console.log('Rate Plan Data:', ratePlan);

            $('#formTitle').text('Edit Customer');
            $('#customerId').val(customer.customerId);
            $('#nid').val(customer.nid);
            $('#name').val(customer.name);
            const phone = customer.phone.startsWith('+2016') ?
                customer.phone.substring(5) :
                customer.phone.startsWith('0') ? customer.phone.substring(1) : customer.phone;
            $('#phone').val(phone);
            $('#email').val(customer.email || '');
            $('#address').val(customer.address || '');
            $('#status').val(customer.status);
            $('#creditLimit').val(customer.creditLimit);

            if (customer.planId) {
                console.log('Customer has planId:', customer.planId, 'Type:', typeof customer.planId);
                loadRatePlans(Number(customer.planId));
                if (ratePlan && ratePlan.isCug) {
                    maxCugMembers = ratePlan.maxCugMembers || 0;
                    $('#maxCugMembersDisplay').text(maxCugMembers);
                    $('#cugSection').show();
                    if (customer.cugNumbers && customer.cugNumbers.length > 0) {
                        $('#cugMembersContainer').empty();
                        customer.cugNumbers.forEach(number => {
                            const cugNumber = number.toString().startsWith('+2016') ?
                                number.toString().substring(5) :
                                number.toString().startsWith('0') ? number.toString().substring(1) : number;
                            const newInput = $(`
                                <div class="cug-member-item">
                                    <div class="input-group">
                                        <span class="input-group-text">+2016</span>
                                        <input type="text" class="form-control cug-number-input"
                                               value="${cugNumber}" pattern="\\d{8}" maxlength="8" required>
                                        <button type="button" class="btn btn-link remove-cug-btn">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            `);
                            $('#cugMembersContainer').append(newInput);
                        });
                    }
                }
            } else {
                console.log('No planId for customer');
                loadRatePlans(null);
            }
        },
        error: function(xhr) {
            console.error('Error loading customer:', xhr);
            showAlert('danger', 'Failed to load customer data');
            loadRatePlans(null);
        }
    });
}
//----------------
function loadRatePlans(customerPlanId) {
    console.log('loadRatePlans called with customerPlanId:', customerPlanId, 'Type:', typeof customerPlanId);
    
    const select = $('#planId');
    select.prop('disabled', true).html('<option value="">Loading rate plans...</option>');

    $.ajax({
        url: '${pageContext.request.contextPath}/api/rate-plans',
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function (ratePlans) {
            select.empty().append('<option value="">Select Plan to add</option>');

            console.log('Received rate plans:', ratePlans);
            
            ratePlans.forEach(function (plan) {
                console.log('Processing plan:', plan.planId, 'Type:', typeof plan.planId);
                
                var servicesSummary = '';
                for (var i = 0; i < plan.servicePackages.length; i++) {
                    var service = plan.servicePackages[i];
                    servicesSummary += service.serviceType + ': ' + service.qouta + ' ' + service.unitDescription;
                    if (i < plan.servicePackages.length - 1) {
                        servicesSummary += ', ';
                    }
                }

                // Handle null monthlyFee gracefully
                var monthlyFee = plan.monthlyFee ? plan.monthlyFee.toFixed(2) : '0.00';
                var displayText = plan.planName + ' (EGP ' + monthlyFee + ') - ' + servicesSummary;

                var option = new Option(displayText, plan.planId);
                
                if (customerPlanId != null && plan.planId == customerPlanId) {
                    console.log('Marking plan as selected:', plan.planId);
                    option.selected = true;
                }
                select.append(option);
            });

            // Ensure the select is enabled after loading
            select.prop('disabled', false);
            
            // Trigger change event to update CUG section if a plan is pre-selected
            if (customerPlanId) {
                console.log('Setting select value to:', customerPlanId);
                select.val(customerPlanId);
                console.log('Current select value after setting:', select.val());
                select.trigger('change');
            }
        },
        error: function (xhr) {
            select.prop('disabled', false)
                .html('<option value="">Error loading rate plans</option>');
            console.error('Error loading rate plans:', xhr);
            showAlert('danger', 'Failed to load rate plans.');
        }
    });
}

//--------------------
    function loadFreeUnitPackages(selectedId = null) {
        $('#freeUnitId').prop('disabled', true).html('<option value="">Loading free unit packages...</option>');

        $.ajax({
            url: '${pageContext.request.contextPath}/api/customers/free-unit-options',
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function (packages) {
                const select = $('#freeUnitId');
                select.empty().append('<option value="">Select Free unit package</option>');

                packages.forEach(pkg => {
                    const displayText = pkg.serviceName + ' (' + pkg.serviceType + ') -  Qouta: ' +
                            pkg.qouta + '  ' + pkg.unitDescription + ' \t - Fees: ' + pkg.freeUnitMonthlyFee.toFixed(2) + ' - LE ';

                    select.append(new Option(
                            displayText,
                            pkg.serviceId,
                            false,
                            selectedId === pkg.serviceId
                    ));
                });

                select.prop('disabled', false);
            },
            error: function (xhr) {
                $('#freeUnitId').prop('disabled', false)
                    .html('<option value="">Error loading packages</option>');
                console.error('Error loading free unit packages:', xhr);
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
});
</script>

<%@ include file="../includes/footer.jsp" %>