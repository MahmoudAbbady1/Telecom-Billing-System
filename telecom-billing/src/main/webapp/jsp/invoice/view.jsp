<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Invoice #<span id="invoiceId">Loading...</span></h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <button onclick="downloadInvoice()" class="btn btn-primary">Download PDF</button>
        <a href="list.jsp" class="btn btn-secondary">Back to List</a>
    </div>
</div>

<div class="card mb-3">
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <h5>Bill To:</h5>
                <dl>
                    <dt>Name:</dt>
                    <dd id="name">Loading...</dd>
                    <dt>Phone:</dt>
                    <dd id="phone">N/A</dd>
                    <dt>Email:</dt>
                    <dd id="email">N/A</dd>
                </dl>
            </div>
            <div class="col-md-6 text-right">
                <dt>Address:</dt>
                <dd id="address" style="font-weight: normal;">N/A</dd>
                <p><strong>Invoice Date:</strong> <span id="invoiceDate">Loading...</span></p>
                <p><strong>Status:</strong> <span id="status">N/A</span></p>
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
                    <th>Details</th>
                    <th class="text-center">Fees (EGP)</th>
                </tr>
            </thead>
            <tfoot>
                <tr>
                    <th class="text-right">Rate Plan:</th>
                    <th><span id="planName" style="font-weight: normal;">N/A</span></th>
                    <th class="text-center"><span id="monthlyFee" style="font-weight: normal;">0.00</span></th>
                </tr>
                <tr>
                    <th class="text-right">Free Unit Package:</th>
                    <th><span id="freeUnitName" style="font-weight: normal;">N/A</span></th>
                    <th class="text-center"><span id="freeUnitMonthlyFee" style="font-weight: normal;">0.00</span></th>
                </tr>
                <tr>
                    <th class="text-right">OCC:</th>
                    <th><span id="occName" style="font-weight: normal;">N/A</span></th>
                    <th class="text-center"><span id="price_occ_per_month" style="font-weight: normal;">0.00</span></th>
                </tr>
                <tr>
                    <th class="text-right">ROR Usage:</th>
                    <th><span id="rorUsage" style="font-weight: normal;">0.00</span></th>
                    <th class="text-center"><span id="rorUsageFee" style="font-weight: normal;">0.00</span></th>
                </tr>
                <tr>
                    <th colspan="2" class="text-right">Subtotal:</th>
                    <th class="text-center"><span id="subtotalFee" style="font-weight: normal;">0.00</span></th>
                </tr>
                <tr>
                    <th colspan="2" class="text-right">Tax (10%):</th>
                    <th class="text-center"><span id="taxFee" style="font-weight: normal;">0.00</span></th>
                </tr>
                <tr>
                    <th colspan="2" class="text-right">Promotion Package:</th>
                    <th class="text-center"><span id="promotionPackageFee" style="font-weight: normal;">0.00</span></th>
                </tr>
                <tr>
                    <th colspan="2" class="text-right">Total:</th>
                    <th class="text-center"><span id="totalFee" style="font-weight: bold;">0.00</span></th>
                </tr>
            </tfoot>
        </table>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
            function getQueryParam(param) {
                const urlParams = new URLSearchParams(window.location.search);
                return urlParams.get(param);
            }

            function downloadInvoice() {
                const invoiceId = getQueryParam('id');
                if (invoiceId) {
                    console.log('Downloading PDF for invoice: ' + invoiceId);
                    window.location.href = '/telecom-billing/invoices/download?id=' + invoiceId;
                } else {
                    alert('No invoice ID provided for PDF download.');
                }
            }

            $(document).ready(function () {
                const invoiceId = getQueryParam('id');
                if (invoiceId) {
                    console.log('Fetching invoice data for ID: ' + invoiceId);
                    $.ajax({
                        url: 'http://localhost:8080/telecom-billing/api/invoices/' + invoiceId,
                        method: 'GET',
                        dataType: 'json',
                        success: function (data) {
                            console.log('API response:', data);
                            console.log('Promotion Package:', data.customer?.promotionPackage); // Debug line

                            // Populate invoice details
                            $('#invoiceId').text(data.invoice?.invoiceId || 'N/A');
                            $('#name').text(data.customer?.name || 'N/A');
                            $('#phone').text(data.customer?.phone || 'N/A');
                            $('#email').text(data.customer?.email || 'N/A');
                            $('#address').text(data.customer?.address || 'N/A');
                            $('#invoiceDate').text(data.invoice?.invoiceDate ?
                                    new Date(data.invoice.invoiceDate).toLocaleDateString('en-US', {
                                year: 'numeric', month: 'short', day: 'numeric'
                            }) : 'N/A');
                            $('#status').text(data.customer?.status || 'N/A');

                            // Populate table
                            $('#planName').text(data.ratePlan?.planName || 'N/A');
                            $('#monthlyFee').text(data.ratePlan?.monthlyFee ?
                                    parseFloat(data.ratePlan.monthlyFee).toFixed(2) : '0.00');
                            $('#freeUnitName').text(data.freeUnit?.serviceName || 'Not Have');
                            $('#freeUnitMonthlyFee').text(data.freeUnit?.freeUnitMonthlyFee ?
                                    parseFloat(data.freeUnit.freeUnitMonthlyFee).toFixed(2) : '0.00');
                            $('#occName').text(data.customer?.occName || 'Not Have ');
                            $('#price_occ_per_month').text(data.customer?.price_occ_per_month ?
                                    parseFloat(data.customer.price_occ_per_month).toFixed(2) : '0.00');
                            $('#rorUsage').text(data.invoice?.rorUsage ?
                                    parseFloat(data.invoice.rorUsage).toFixed(2) : '0.00');
                            $('#rorUsageFee').text(data.invoice?.rorUsage ?
                                    parseFloat(data.invoice.rorUsage).toFixed(2) : '0.00');
                            $('#subtotal').text(data.invoice?.subtotal ?
                                    parseFloat(data.invoice.subtotal).toFixed(2) : '0.00');
                            $('#subtotalFee').text(data.invoice?.subtotal ?
                                    parseFloat(data.invoice.subtotal).toFixed(2) : '0.00');
                            $('#tax').text(data.invoice?.tax ?
                                    parseFloat(data.invoice.tax).toFixed(2) : '0.00');
                            $('#taxFee').text(data.invoice?.tax ?
                                    parseFloat((data.invoice.tax / 100) * data.invoice.subtotal).toFixed(2) : '0.00');

                            // Ensure promotion package is formatted as a number
                            $('#promotionPackage').text(data.customer?.promotionPackage ?
                                    parseFloat(data.customer.promotionPackage).toFixed(2) : '0.00');
                            $('#promotionPackageFee').text(data.customer?.promotionPackage ?
                                    parseFloat(data.customer.promotionPackage).toFixed(2) : '0.00');
                            $('#total').text(data.invoice?.total ?
                                    parseFloat(data.invoice.total).toFixed(2) : '0.00');
                            $('#totalFee').text(data.invoice?.total ?
                                    parseFloat(data.invoice.total).toFixed(2) : '0.00');
                        },
                        error: function (xhr, status, error) {
                            console.error('AJAX error:', status, error, xhr.responseText);
                            alert('Failed to load invoice details: ' + error);
                        }
                    });
                } else {
                    console.error('No invoice ID provided in URL');
                    alert('No invoice ID provided in the URL.');
                }
            });
</script>

<%@ include file="../includes/footer.jsp" %>