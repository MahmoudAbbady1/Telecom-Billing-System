<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Customer List</h3>
    </div>
    <div class="col-md-6 text-right" style="text-align: right">
        <a href="form.jsp" class="btn btn-primary">Add New Customer</a>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table class="table table-striped datatable">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Phone</th>
                    <th>Email</th>
                    <th>Address</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="customer" items="${customers}">
                    <tr>
                        <td>${customer.customerId}</td>
                        <td>${customer.name}</td>
                        <td>${customer.phone}</td>
                        <td>${customer.email}</td>
                        <td>${customer.Address}</td>
                        <td>
                            <span class="badge badge-${customer.status == 'ACTIVE' ? 'success' : 'danger'}">
                                ${customer.status}
                            </span>
                        </td>
                        <td>
                            <a href="customers?action=edit&id=${customer.customerId}" 
                               class="btn btn-sm btn-warning">Edit</a>
                            <a href="customers?action=delete&id=${customer.customerId}" 
                               class="btn btn-sm btn-danger confirm-delete">Delete</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>