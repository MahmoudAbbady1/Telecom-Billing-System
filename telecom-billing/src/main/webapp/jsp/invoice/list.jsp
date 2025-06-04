<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Invoices</h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <a href="/telecom-billing/invoices/downloadAll" class="btn btn-success">Download All Invoices</a>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table id="invoicesTable" class="table table-striped" style="width:100%">
            <thead>
                <tr>
                    <th>Invoice ID</th>
                    <th>Customer</th>
                    <th>Date</th>
                    <th>Total</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap4.min.js"></script>
<link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap4.min.css">

<script>
$(document).ready(function() {
    if ($.fn.DataTable.isDataTable('#invoicesTable')) {
        $('#invoicesTable').DataTable().destroy();
    }
    $('#invoicesTable').DataTable({
        ajax: {
            url: 'http://localhost:8080/telecom-billing/api/invoices',
            dataSrc: ''
        },
        columns: [
            { data: 'invoiceId' },
            { data: 'customer.name' },
            { 
                data: 'invoiceDate',
                render: function(data) {
                    return new Date(data).toLocaleDateString('en-US', {
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric'
                    });
                }
            },
            { 
                data: 'total',
                render: function(data) {
                    return parseFloat(data).toFixed(2) + ' EGP';
                }
            },
            { 
                data: null,
                render: function(data, type, row) {
                    return '<a href="view.jsp?id=' + row.invoiceId + '" class="btn btn-primary btn-sm">View</a> ' +
                           '<a href="/telecom-billing/invoices/download?id=' + row.invoiceId + '" class="btn btn-secondary btn-sm">Download</a>';
                }
            }
        ],
        "bDestroy": true
    });
});
</script>
<%@ include file="../includes/footer.jsp" %>