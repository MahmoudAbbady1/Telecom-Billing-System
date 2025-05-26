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
    .cug-badge {
        margin-right: 5px;
        margin-bottom: 5px;
    }
</style>

<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-user"></i> Customer Details
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

<div class="row">
    <div class="col-md-4">
        <div class="card detail-card">
            <div class="card-header">
                <i class="fas fa-id-card"></i> Basic Information
            </div>
            <div class="card-body">
                <dl>
                    <dt>Customer ID:</dt>
                    <dd id="customerId">Loading...</dd>

                    <dt>Name:</dt>
                    <dd id="name">Loading...</dd>

                    <dt>National ID:</dt>
                    <dd id="nid">Loading...</dd>

                    <dt>Status:</dt>
                    <dd id="status">Loading...</dd>
                </dl>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card detail-card">
            <div class="card-header">
                <i class="fas fa-phone"></i> Contact Information
            </div>
            <div class="card-body">
                <dl>
                    <dt>Phone:</dt>
                    <dd id="phone">Loading...</dd>

                    <dt>Email:</dt>
                    <dd id="email">Loading...</dd>

                    <dt>Address:</dt>
                    <dd id="address">Loading...</dd>
                </dl>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card detail-card">
            <div class="card-header">
                <i class="fas fa-credit-card"></i> Account Information
            </div>
            <div class="card-body">
                <dl>
                    <dt>Rate Plane </dt>
                    <dd id="planName">Loading...</dd>

                    <dt>Credit Limit:</dt>
                    <dd id="creditLimit">Loading...</dd>

                    <dt>Registration Date:</dt>
                    <dd id="registrationDate">Loading...</dd>



                    <dt>Free Unit Package:</dt>
                    <dd id="freeUnitName">Loading...</dd>
                </dl>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <div class="card detail-card">
            <div class="card-header">
                <i class="fas fa-info-circle"></i> Additional Information
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-4">
                        <dl>
                            <dt>OCC Plan:</dt>
                            <dd id="occName">Loading...</dd>
                        </dl>
                    </div>
                    <div class="col-md-4">
                        <dl>
                            <dt>OCC Price:</dt>
                            <dd id="occPrice">Loading...</dd>
                        </dl>
                    </div>
                    <div class="col-md-4">
                        <dl>
                            <dt>Installment Months:</dt>
                            <dd id="monthsNumberInstallments">Loading...</dd>
                        </dl>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <dl>
                            <dt>Promotion Package:</dt>
                            <dd id="promotionPackage">Loading...</dd>
                        </dl>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <dl>
                            <dt>CUG Numbers:</dt>
                            <dd id="cugNumbers">Loading...</dd>
                        </dl>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        const urlParams = new URLSearchParams(window.location.search);
        const customerId = urlParams.get('id');

        if (!customerId) {
            showAlert('danger', 'No customer ID specified in the URL');
            return;
        }

        // Load customer and related data from combined API
        $.ajax({
            url: '${pageContext.request.contextPath}/api/customers/' + customerId,
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function (response) {
                const customerData = response.customer;
                const planData = response.ratePlan;
                const freeUnit = response.freeUnit;

                // Basic Information
                $('#customerId').text(customerData.customerId);
                $('#name').text(customerData.name);
                $('#nid').text(customerData.nid || 'N/A');
                $('#status').text(customerData.status)
                            .addClass(getStatusClass(customerData.status));

                // Contact Information
                $('#phone').text(customerData.phone);
                $('#email').text(customerData.email || 'N/A');
                $('#address').text(customerData.address || 'N/A');

                // Account Information
                $('#creditLimit').text('EGP ' + customerData.creditLimit);
                $('#registrationDate').text(formatDate(customerData.registrationDate));
                $('#planName').text(planData ? (planData.planName + ' - Fees: ' + planData.monthlyFee + ' LE') : 'N/A');
                $('#freeUnitName').text(freeUnit ? (freeUnit.serviceName + ' - Fees: ' + freeUnit.freeUnitMonthlyFee + ' LE') : 'N/A');

                // Additional Information
                $('#occName').text(customerData.occName || 'N/A');
                $('#occPrice').text(customerData.occPrice ? 'EGP ' + customerData.occPrice : 'N/A');
                $('#monthsNumberInstallments').text(customerData.monthsNumberInstallments || 'N/A');
                $('#promotionPackage').text(customerData.promotionPackage ? 'Package #' + customerData.promotionPackage : 'N/A');

                // CUG Numbers
                if (customerData.cugNumbers && customerData.cugNumbers.length > 0) {
                    var cugHtml = '';
                    customerData.cugNumbers.forEach(function (num) {
                        cugHtml += '<span class="badge bg-primary cug-badge">' + num + '</span>';
                    });
                    $('#cugNumbers').html(cugHtml);
                } else {
                    $('#cugNumbers').text('N/A');
                }

                // Set edit button href
                $('#editBtn').attr('href', 'form.jsp?id=' + customerData.customerId);
            },
            error: function (xhr) {
                handleApiError(xhr);
            }
        });
    });

    function getStatusClass(status) {
        if (!status) return '';
        switch (status.toUpperCase()) {
            case 'ACTIVE':
                return 'status-active';
            case 'INACTIVE':
                return 'status-inactive';
            case 'SUSPENDED':
                return 'status-suspended';
            default:
                return '';
        }
    }

    function formatDate(timestamp) {
        if (!timestamp) return 'N/A';
        const date = new Date(timestamp);
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
    }

    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    function handleApiError(xhr) {
        console.error('API Error:', xhr);
        var message = 'An error occurred while loading customer details';

        if (xhr.status === 403) {
            message = 'Your session has expired. Please login again.';
            clearAuthTokens();
            setTimeout(function () {
                window.location.href = '${pageContext.request.contextPath}/login.jsp';
            }, 2000);
        } else if (xhr.status === 404) {
            message = 'Customer not found';
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