<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

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
        <table class="table table-striped datatable">
            <thead>
                <tr>
                    <th>Invoice #</th>
                    <th>Customer</th>
                    <th>Date</th>
                    <th>Due Date</th>
                    <th>Total</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="invoice" items="${invoices}">
                    <tr>
                        <td>${invoice.invoiceId}</td>
                        <td>${invoice.customer.name}</td>
                        <td>${invoice.invoiceDate}</td>
                        <td>${invoice.dueDate}</td>
                        <td>${invoice.total} EGP</td>
                        <td>
                            <span class="badge badge-${invoice.status == 'PAID' ? 'success' : 
                                                  invoice.status == 'OVERDUE' ? 'danger' : 'warning'}">
                                ${invoice.status}
                            </span>
                        </td>
                        <td>
                            <!--<a href="invoices?action=view&id=${invoice.invoiceId}"--> 
                            <a href="view.jsp" 
                               class="btn btn-sm btn-info">View</a>
                            <button onclick="downloadInvoice(${invoice.invoiceId})" 
                               class="btn btn-sm btn-primary">Download</button>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>