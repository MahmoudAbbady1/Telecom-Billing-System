<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Invoices</h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <a href="invoices?action=generate" class="btn btn-success">Generate All Invoices</a>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table id="invoicesTable" class="table table-striped datatable" style="width:100%">
            <thead>
                <tr>
                    <th>Invoice ID</th>
                    <th>Customer</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>

<script>
$(document).ready(function() {
    // Prevent DataTable reinitialization
    if ($.fn.DataTable.isDataTable('#invoicesTable')) {
        $('#invoicesTable').DataTable().clear().destroy();
    }

    // Initialize DataTable
    var table = $('#invoicesTable').DataTable({
        responsive: true,
        ajax: {
            url: 'http://localhost:8080/telecom-billing/api/customers',
            dataSrc: function(json) {
                // Generate invoices from customer data
                let invoices = [];
                json.forEach(function(customerData) {
                    const customer = customerData.customer || {};
                    // Generate invoiceId as customerId + phone (non-digits removed)
                    const phoneClean = customer.phone ? customer.phone.replace(/\D/g, '') : '';
                    const invoiceId = customer.customerId + phoneClean;
                    const invoice = {
                        invoiceId: invoiceId,
                        invoiceDate: new Date().toISOString(), // Current date for mock invoice
                        customer: customer
                    };
                    invoice._fullData = {
                        customer: customer,
                        ratePlan: customerData.ratePlan || {},
                        freeUnit: customerData.freeUnit || {}
                    };
                    invoices.push(invoice);
                });
                return invoices;
            },
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            error: function(xhr) {
                console.error('API Error:', xhr);
                var message = 'An error occurred while loading invoices';
                if (xhr.status === 403) {
                    message = 'Your session has expired. Please login again.';
                    clearAuthTokens();
                    setTimeout(function() {
                        window.location.href = '${pageContext.request.contextPath}/login.jsp';
                    }, 2000);
                } else if (xhr.status === 404) {
                    message = 'Requested resource not found. Please check if the API endpoint is available.';
                } else if (xhr.status === 500) {
                    message = 'Server error: ' + (xhr.responseJSON ? xhr.responseJSON.message : xhr.statusText);
                }
                console.error(message);
            }
        },
        columns: [
            { data: 'invoiceId' },
            {
                data: null,
                render: function(data) {
                    return data.customer ? data.customer.name : 'N/A';
                }
            },
            {
                data: 'invoiceDate',
                render: function(date) {
                    return date ? new Date(date).toLocaleDateString() : 'N/A';
                }
            },
            {
                data: null,
                render: function(data) {
                    return '<a href="view.jsp?id=' + data.customer.customerId + '" class="btn btn-sm btn-info me-1">View</a>' +
                           '<button onclick="downloadInvoice(\'' + data.invoiceId + '\')" class="btn btn-sm btn-primary">Download PDF</button>';
                }
            }
        ],
        language: {
            search: "Search:",
            lengthMenu: "Show _MENU_ entries",
            info: "Showing _START_ to _END_ of _TOTAL_ entries",
            paginate: {
                previous: "Previous",
                next: "Next"
            }
        }
    });

    // Download invoice function
    window.downloadInvoice = function(invoiceId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/invoices/' + invoiceId + '/download',
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            xhrFields: {
                responseType: 'blob'
            },
            success: function(data) {
                const url = window.URL.createObjectURL(data);
                const a = document.createElement('a');
                a.href = url;
                a.download = 'invoice_' + invoiceId + '.pdf';
                document.body.appendChild(a);
                a.click();
                a.remove();
                window.URL.revokeObjectURL(url);
            },
            error: function(xhr) {
                console.error('API Error:', xhr);
                var message = 'Failed to download invoice';
                if (xhr.status === 403) {
                    message = 'Your session has expired. Please login again.';
                    clearAuthTokens();
                    setTimeout(function() {
                        window.location.href = '${pageContext.request.contextPath}/login.jsp';
                    }, 2000);
                } else if (xhr.status === 404) {
                    message = 'Invoice not found. Please check if the download endpoint is available.';
                } else if (xhr.status === 500) {
                    message = 'Server error: ' + (xhr.responseJSON ? xhr.responseJSON.message : xhr.statusText);
                }
                console.error(message);
            }
        });
    };
});

function getAuthToken() {
    return localStorage.getItem('authToken') || '';
}

function clearAuthTokens() {
    localStorage.removeItem('authToken');
    document.cookie = 'authToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
}
</script>

<%@ include file="../includes/footer.jsp" %>