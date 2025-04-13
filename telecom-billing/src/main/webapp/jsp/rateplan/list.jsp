<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Rateplane list</h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <a href="invoices?action=generate" class="btn btn-success">Create New RatePlane</a>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table class="table table-striped datatable">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Date</th>
                    <th>Service Packages</th>
                    <th>Price</th>
                    <th>No of Subscriber</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="invoice" items="${invoices}">
                    <tr>
                        <td>${RatePlan.ID}</td>
                        <td>${RatePlan.Name}</td>
                        <td>${RatePlan.ServicePackages}</td>
                        <td>${RatePlan.Price}</td>
                        <td>${RatePlan.Price}</td>
                        <td>${RatePlan.NOofSubscriber}</td>
                        <td>
                            <!--<a href="invoices?action=view&id=${invoice.invoiceId}"--> 
                            <a href="view.jsp" 
                               class="btn btn-sm btn-info">Edit</a>
                             
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>