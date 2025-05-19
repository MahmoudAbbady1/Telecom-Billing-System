<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

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
                        <div class="invalid-feedback">Please provide a valid national ID.</div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="name" class="form-label required">Full Name</label>
                        <input type="text" class="form-control" id="name" name="name" required maxlength="100">
                        <div class="invalid-feedback">Please provide the customer's full name.</div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="phone" class="form-label required">Phone Number</label>
                        <input type="text" class="form-control" id="phone" name="phone" required maxlength="20">
                        <div id="phoneError" class="invalid-feedback">Please provide a valid phone number.</div>
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
                        <div class="invalid-feedback">Please select a status.</div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="creditLimit" class="form-label required">Credit Limit (EGP)</label>
                        <input type="number" class="form-control" id="creditLimit" name="creditLimit" required min="0">
                        <div class="invalid-feedback">Please provide a valid credit limit.</div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="planId" class="form-label">Plan</label>
                        <select class="form-control" id="planId" name="planId">
                            <option value="">Select Plan</option>
                            <c:forEach items="${ratePlans}" var="plan">
                                <option value="${plan.planId}">${plan.planName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="freeUnitId" class="form-label">Free Unit Package</label>
                        <select class="form-control" id="freeUnitId" name="freeUnitId">
                            <option value="">Select Package</option>
                            <c:forEach items="${freeUnits}" var="unit">
                                <option value="${unit.serviceId}">${unit.serviceName}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="occName" class="form-label">OCC Name</label>
                        <input type="text" class="form-control" id="occName" name="occName" maxlength="50">
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group mb-3">
                        <label for="occPrice" class="form-label">OCC Price</label>
                        <input type="number" class="form-control" id="occPrice" name="occPrice" min="0" value="0">
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
    $(document).ready(function() {
        const urlParams = new URLSearchParams(window.location.search);
        const customerId = urlParams.get('id');

        if (customerId) {
            loadCustomerData(customerId);
        }

        // Phone number uniqueness check
        $('#phone').on('blur', function() {
            const phone = $(this).val().trim();
            if (phone) {
                const url = '${pageContext.request.contextPath}/api/customers/check-phone?phone=' + 
                            encodeURIComponent(phone) + 
                            (customerId ? '&excludeId=' + customerId : '');
                
                $.ajax({
                    url: url,
                    method: 'GET',
                    headers: {
                        'Authorization': 'Bearer ' + getAuthToken()
                    },
                    success: function(exists) {
                        const phoneField = $('#phone');
                        const errorElement = $('#phoneError');
                        
                        if (exists) {
                            phoneField.addClass('is-invalid');
                            errorElement.text('This phone number is already registered.');
                        } else {
                            phoneField.removeClass('is-invalid');
                            errorElement.text('');
                        }
                    }
                });
            }
        });

        $('#customerForm').submit(function(e) {
            e.preventDefault();

            if (!this.checkValidity()) {
                e.stopPropagation();
                $(this).addClass('was-validated');
                return;
            }

            const formData = {
                nid: $('#nid').val(),
                name: $('#name').val(),
                phone: $('#phone').val(),
                email: $('#email').val(),
                address: $('#address').val(),
                status: $('#status').val(),
                creditLimit: parseInt($('#creditLimit').val()),
                planId: $('#planId').val() ? parseInt($('#planId').val()) : null,
                freeUnitId: $('#freeUnitId').val() ? parseInt($('#freeUnitId').val()) : null,
                occName: $('#occName').val(),
                occPrice: $('#occPrice').val() ? parseInt($('#occPrice').val()) : 0
            };

            const method = customerId ? 'PUT' : 'POST';
            const url = '${pageContext.request.contextPath}/api/customers' + (customerId ? '/' + customerId : '');

            $('#submitBtn').prop('disabled', true);

            $.ajax({
                url: url,
                method: method,
                contentType: 'application/json',
                data: JSON.stringify(formData),
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function(data) {
                    showAlert('success', customerId ? 'Customer updated successfully!' : 'Customer created successfully!');
                    
                    if (!customerId) {
                        setTimeout(function() {
                            window.location.href = 'view.jsp?id=' + data.customerId;
                        }, 1500);
                    }
                },
                error: function(xhr) {
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

    function loadCustomerData(customerId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/customers/' + customerId,
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function(data) {
                $('#formTitle').text('Edit Customer');
                $('#customerId').val(data.customerId);
                $('#nid').val(data.nid);
                $('#name').val(data.name);
                $('#phone').val(data.phone);
                $('#email').val(data.email || '');
                $('#address').val(data.address || '');
                $('#status').val(data.status);
                $('#creditLimit').val(data.creditLimit);
                $('#planId').val(data.planId || '');
                $('#freeUnitId').val(data.freeUnitId || '');
                $('#occName').val(data.occName || '');
                $('#occPrice').val(data.occPrice || 0);
            },
            error: function(xhr) {
                showAlert('danger', 'Failed to load customer data');
                console.error('Error loading customer:', xhr);
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
</script>

<%@ include file="../includes/footer.jsp" %>