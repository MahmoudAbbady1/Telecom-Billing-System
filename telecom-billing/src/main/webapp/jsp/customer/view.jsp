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
                    <dt>Rate Plan:</dt>
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
                <button type="button" class="btn btn-sm btn-primary float-end me-2" data-bs-toggle="modal" data-bs-target="#promotionModal">
                    <i class="fas fa-plus"></i> Add Promotion Package
                </button>
                <button type="button" class="btn btn-sm btn-primary float-end me-2" data-bs-toggle="modal" data-bs-target="#cugModal">
                    <i class="fas fa-edit"></i> Modify CUG Numbers
                </button>
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

<!-- Promotion Package Modal -->
<div class="modal fade" id="promotionModal" tabindex="-1" aria-labelledby="promotionModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="promotionModalLabel">Add Promotion Package</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="promotionForm">
                    <div class="mb-3">
                        <label for="promotionPackageInput" class="form-label">Promotion Package Value</label>
                        <input type="number" class="form-control" id="promotionPackageInput" name="promotionPackage" min="0" required>
                        <div class="invalid-feedback">Please enter a valid promotion package value (non-negative number).</div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="savePromotionBtn">Save</button>
            </div>
        </div>
    </div>
</div>

<!-- CUG Numbers Modal -->
<div class="modal fade" id="cugModal" tabindex="-1" aria-labelledby="cugModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="cugModalLabel">Modify CUG Numbers</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="cugForm">
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
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="saveCugBtn">Save</button>
            </div>
        </div>
    </div>
</div>
<!-- Previous JSP content remains the same until the <script> section -->

<script>
$(document).ready(function () {
    const urlParams = new URLSearchParams(window.location.search);
    const customerId = urlParams.get('id');
    let maxCugMembers = 0;
    let tempPromotionPackage = null; // Store promotion package temporarily

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
            // Initialize with temporary value if exists, else use server value
            tempPromotionPackage = sessionStorage.getItem('tempPromotionPackage_' + customerId) || customerData.promotionPackage;
            $('#promotionPackage').text(tempPromotionPackage !== null ? tempPromotionPackage : 'N/A');

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

            // Set promotion package input value
            $('#promotionPackageInput').val(tempPromotionPackage !== null ? tempPromotionPackage : customerData.promotionPackage);

            // Load CUG data if applicable
            if (planData && planData.isCug) {
                maxCugMembers = planData.maxCugMembers || 0;
                $('#maxCugMembersDisplay').text(maxCugMembers);
                loadCugNumbers(customerData.cugNumbers);
            } else {
                $('#cugModal').find('.modal-footer').hide(); // Hide save button if no CUG support
                $('#addCugMemberBtn').hide();
            }
        },
        error: function (xhr) {
            handleApiError(xhr);
        }
    });

// Load CUG numbers into modal
    function loadCugNumbers(cugNumbers) {
        console.log('Loading CUG numbers:', cugNumbers);
        const container = $('#cugMembersContainer');
        container.empty();
        if (cugNumbers && cugNumbers.length > 0) {
            cugNumbers.forEach(number => {
                const cugNumber = number.startsWith('+2016') ? number.substring(5) : number;
                const newInput = $(`
                    <div class="cug-member-item">
                        <div class="input-group">
                            <span class="input-group-text">+2016</span>
                            <input type="text" class="form-control cug-number-input" value="${cugNumber}" pattern="\\d{8}" maxlength="8" required>
                            <button type="button" class="btn btn-link remove-cug-btn">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                `);
                container.append(newInput);
            });
        } else {
            console.log('No CUG numbers to load');
            container.html('<div class="text-muted">No CUG numbers available.</div>');
        }
    }
    
   
    
    
    
    // Add CUG member input
    $('#addCugMemberBtn').click(function () {
        if ($('#cugMembersContainer .cug-member-item').length >= maxCugMembers) {
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

    // Remove CUG member
    $(document).on('click', '.remove-cug-btn', function () {
        $(this).closest('.cug-member-item').remove();
        $('#cugError').text('');
    });

    // Save promotion package (client-side only)
$('#savePromotionBtn').click(function () {
    const promotionPackage = $('#promotionPackageInput').val();
    if (!promotionPackage || parseInt(promotionPackage) < 0) {
        $('#promotionPackageInput').addClass('is-invalid');
        return;
    }
    $('#promotionPackageInput').removeClass('is-invalid');

    // Fetch current customer data to update only promotionPackage
    $.ajax({
        url: '${pageContext.request.contextPath}/api/customers/' + customerId,
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function (data) {
            const customer = data.customer || data;

            // Prepare update data
            const updateData = {
                customerId: customerId,
                nid: customer.nid,
                name: customer.name,
                phone: customer.phone,
                creditLimit: customer.creditLimit,
                email: customer.email,
                address: customer.address,
                status: customer.status,
                planId: customer.planId,
                freeUnitId: customer.freeUnitId,
                occName: customer.occName,
                occPrice: customer.occPrice,
                monthsNumberInstallments: customer.monthsNumberInstallments,
                cugNumbers: customer.cugNumbers,
                promotionPackage: parseInt(promotionPackage)
            };

            // Send update request
            $.ajax({
                url: '${pageContext.request.contextPath}/api/customers/' + customerId,
                method: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(updateData),
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function () {
                    // Update UI
                    tempPromotionPackage = parseInt(promotionPackage);
                    sessionStorage.setItem('tempPromotionPackage_' + customerId, tempPromotionPackage);
                    $('#promotionPackage').text(tempPromotionPackage);
                    showAlert('success', 'Promotion package updated successfully!');
                    $('#promotionModal').modal('hide');
                },
                error: function (xhr) {
                    showAlert('danger', xhr.responseJSON?.message || 'Failed to update promotion package');
                }
            });
        },
        error: function (xhr) {
            showAlert('danger', 'Failed to fetch customer data for update');
        }
    });
});

    // Save CUG numbers
    $('#saveCugBtn').click(function () {
        const cugNumbers = [];
        let valid = true;
        $('.cug-number-input').each(function () {
            const phone = $(this).val().trim();
            if (phone) {
                if (!phone.match(/^\d{8}$/)) {
                    $('#cugError').text('CUG numbers must be 8 digits.');
                    valid = false;
                    return false;
                }
                cugNumbers.push('+2016' + phone);
            }
        });

        if (!valid) return;

        if (cugNumbers.length > maxCugMembers) {
            $('#cugError').text('Maximum number of CUG members is ' + maxCugMembers);
            return;
        }

        const updateData = {
            customerId: customerId,
            cugNumbers: cugNumbers
        };

        $.ajax({
            url: '${pageContext.request.contextPath}/api/customers/' + customerId,
            method: 'PUT',
            contentType: 'application/json',
            data: JSON.stringify(updateData),
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function () {
                showAlert('success', 'CUG numbers updated successfully!');
                $('#cugModal').modal('hide');
                let cugHtml = cugNumbers.length > 0 ? cugNumbers.map(num => '<span class="badge bg-primary cug-badge">' + num + '</span>').join('') : 'N/A';
                $('#cugNumbers').html(cugHtml);
            },
            error: function (xhr) {
                showAlert('danger', xhr.responseJSON?.message || 'Failed to update CUG numbers');
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
});
</script>

<%@ include file="../includes/footer.jsp" %>