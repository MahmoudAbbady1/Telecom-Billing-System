<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Invoice #${invoice.invoiceId}</h3>
    </div>
    <div class="col-md-6 text-right">
        <button onclick="downloadInvoice(${invoice.invoiceId})" 
                class="btn btn-primary">Download PDF</button>
        <a href="invoices" class="btn btn-secondary">Back to List</a>
    </div>
</div>

<div class="card mb-3">
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <h5>Bill To:</h5>
                <p>
                    ${invoice.customer.name}<br>
                    ${invoice.customer.address}<br>
                    Phone: ${invoice.customer.phone}<br>
                    Email: ${invoice.customer.email}
                </p>
            </div>
            <div class="col-md-6 text-right">
                <p><strong>Invoice Date:</strong> ${invoice.invoiceDate}</p>
                <p><strong>Due Date:</strong> ${invoice.dueDate}</p>
                <p><strong>Status:</strong> 
                    <span class="badge badge-${invoice.status == 'PAID' ? 'success' : 
                                          invoice.status == 'OVERDUE' ? 'danger' : 'warning'}">
                        ${invoice.status}
                    </span>
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
                    <th class="text-right">Quantity</th>
                    <th class="text-right">Unit Price</th>
                    <th class="text-right">Amount</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${invoice.items}">
                    <tr>
                        <td>${item.description}</td>
                        <td class="text-right">${item.quantity}</td>
                        <td class="text-right">$${item.unitPrice}</td>
                        <td class="text-right">$${item.amount}</td>
                    </tr>
                </c:forEach>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="3" class="text-right">Subtotal:</th>
                    <th class="text-right">$${invoice.subtotal}</th>
                </tr>
                <tr>
                    <th colspan="3" class="text-right">Tax (10%):</th>
                    <th class="text-right">$${invoice.tax}</th>
                </tr>
                <tr>
                    <th colspan="3" class="text-right">Total:</th>
                    <th class="text-right">$${invoice.total}</th>
                </tr>
            </tfoot>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>