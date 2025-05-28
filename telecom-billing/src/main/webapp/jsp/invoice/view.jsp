<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Invoice #${invoice.invoiceId}</h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <button onclick="downloadInvoice(${invoice.invoiceId})" 
                class="btn btn-primary">Download PDF</button>
        <a href="list.jsp" class="btn btn-secondary">Back to List</a>
    </div>
</div>

<div class="card mb-3">
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <h5>Bill To:</h5>
                <dl>

                    <dd id="name">Loading...</dd>
                    <dt>Phone:</dt>
                    <dd id="phone">Loading...</dd>
                    <dt>Email:</dt>
                    <dd id="email">Loading...</dd>
                </dl>
            </div>
            <div class="col-md-6 text-right" >
                <br>
                <dt>Address:&nbsp;&nbsp;&nbsp;<span id="address" style="font-weight: normal;"></span></dt>

                <p><strong>Invoice Date:</strong> <span id="invoice-date"></span></p>

                <p><strong>Status:</strong> 

                </p>
            </div>
        </div>
    </div>
</div>
<div class="card">
    <div class="card-body">
        <table class="table">
            <thead>
                <tr>
                    <th>Description</th>
                    <th class="text-right">Description</th>
                    <th class="text-center">Fees</th>
                </tr>
            </thead>
            <tfoot>
                <tr>
                    <th class="text-right">Rate plane:</th>
                    <th><span id="planName" style="font-weight: normal;"></span></th>
                    <th class="text-center"><span id="monthlyFee" style="font-weight: normal;"></span> <span>EGP</span></th>
                </tr>

                <tr>
                    <th class="text-right">Free Unite package:</th>
                    <th><span id="freeUnitName" style="font-weight: normal;"></span></th>
                    <th class="text-center"><span id="freeUnitMonthlyFee" style="font-weight: normal;"></span> <span>EGP</span></th>
                </tr>

                <tr>
                    <th class="text-right">OCC:</th>
                    <th><span id="occName" style="font-weight: normal;"></span></th>
                    <th class="text-center"><span id="occPrice" style="font-weight: normal;"></span> <span>EGP</span></th>
                </tr>
                
                <tr>
                    <th colspan="2" class="text-right">ROR Usage</th>
                    <th class="text-center"><span id="rorusage" style="font-weight: normal;"></span> <span>EGP</span></th>
                </tr>


                <tr>
                    <th colspan="2" class="text-right">Subtotal:</th>
                    <th class="text-center"><span id="Subtotal" style="font-weight: normal;"></span> <span>EGP</span></th>
                </tr>

                <tr>
                    <th colspan="2" class="text-right">Tax (10%):</th>
                    <th class="text-center"><span id="Tax" style="font-weight: normal;"></span> <span>EGP</span></th>
                </tr>

                <tr>
                    <th colspan="2" class="text-right">Promotion package:</th>
                    <th class="text-center"><span id="promotionPackage" style="font-weight: normal;"></span> <span>EGP</span></th>
                </tr>

                <tr>
                    <th colspan="2" class="text-right">Total:</th>
                    <th class="text-center"><span id="total" style="font-weight: normal;"></span> <span>EGP</span></th>
                </tr>
            </tfoot>
        </table>
    </div>
</div>

<script>

    const today = new Date();
    const formattedDate = today.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
    $(document).ready(function () {
        const urlParams = new URLSearchParams(window.location.search);
        const customerId = urlParams.get('id');
        let maxCugMembers = 0;
        let tempPromotionPackage = null;
        if (!customerId) {
            showAlert('danger', 'No customer ID specified in the URL');
            return;
        }

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

        const occPrice = parseFloat(customerData.occPrice) || 0;
        const installments = parseFloat(customerData.monthsNumberInstallments) || 1; // Avoid division by 0
        const monthlyFee = parseFloat(planData?.monthlyFee) || 0;
        const freeUnitFee = parseFloat(freeUnit?.freeUnitMonthlyFee) || 0;
        const promoDiscount = parseFloat(customerData.promotionPackage) || 0;
        const random = Math.random() * customerData.creditLimit;
        const creditLimit = parseFloat(customerData.creditLimit);

        const occInstallment = occPrice / installments;
        // Include random in subtotal if random <= creditLimit, else add 0
        const usageCost = creditLimit -random || 0;
        const subtotal = occInstallment + monthlyFee + freeUnitFee + usageCost;
        const tax = subtotal * 0.1;
        const total = subtotal + tax - promoDiscount;

        // Set UI fields
        $('#customerId').text(customerData.customerId);
        $('#name').text(customerData.name);
        $('#nid').text(customerData.nid || 'N/A');
        $('#status').text(customerData.status)
            .addClass(getStatusClass(customerData.status));
        $('#phone').text(customerData.phone);
        $('#email').text(customerData.email || 'N/A');
        $('#address').text(customerData.address || 'N/A');
        $('#rorusage').text(random <= customerData.creditLimit ? (customerData.creditLimit - random).toFixed(2) : customerData.creditLimit);
        $('#registrationDate').text(formatDate(customerData.registrationDate));
        $('#planName').text(planData ? (planData.planName + '[ ' + planData.servicePackages.map(sp => sp.serviceType + '-' + sp.qouta).join(', ') + ']') : 'N/A');
        $('#freeUnitName').text(freeUnit ? (freeUnit.serviceName + ' - ' + freeUnit.serviceType + '-' + freeUnit.qouta) : 'Not Have');
        $('#monthlyFee').text(planData ? (planData.monthlyFee + ' ') : 'N/A');
        $('#occName').text(customerData.occName || 'Not Have');
        tempPromotionPackage = sessionStorage.getItem('tempPromotionPackage_' + customerId) || customerData.promotionPackage;
        $('#promotionPackage').text(tempPromotionPackage !== null ? tempPromotionPackage : 'N/A');

        $('#freeUnitMonthlyFee').text(freeUnitFee.toFixed(2));
        $('#occPrice').text(occInstallment.toFixed(2));
        $('#monthsNumberInstallments').text(installments);
        // Update Subtotal, Tax, and Total
        $('#Subtotal').text('EGP ' + subtotal.toFixed(2));
        $('#Tax').text('EGP ' + tax.toFixed(2));
        $('#total').text('EGP ' + total.toFixed(2));
    },
    error: handleApiError
});
    }
    ); // ? CLOSE $(document).ready

    function getStatusClass(status) {
        if (!status)
            return '';
        switch (status.toUpperCase()) {
            case 'Paid':
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
        if (!timestamp)
            return 'N/A';
        const date = new Date(timestamp);
        return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
    }

    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    function handleApiError(xhr) {
        console.error('API Error:', xhr);
        let message = 'An error occurred while loading customer details';
        if (xhr.status === 403) {
            message = 'Your session has expired. Please login again.';
            clearAuthTokens();
            setTimeout(() => {
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
        const alertId = 'alert-' + Date.now();
        const alertHtml = `
            <div id="${alertId}" class="alert alert-${type} alert-dismissible fade show" role="alert">
    ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>`;
        $('#alertContainer').html(alertHtml);
        if (type !== 'danger') {
            setTimeout(() => {
                $('#' + alertId).alert('close');
            }, 5000);
        }
    }
</script>


<%@ include file="../includes/footer.jsp" %>