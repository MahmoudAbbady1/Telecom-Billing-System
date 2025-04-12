<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Management</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
</head>
<body>
    <div class="container">
        <h1>Customer List</h1>
        <a href="customers?action=new" class="btn btn-primary mb-3">Add New Customer</a>
        
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Phone</th>
                    <th>Email</th>
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
                        <td>${customer.status}</td>
                        <td>
                            <a href="customers?action=edit&id=${customer.customerId}" 
                               class="btn btn-sm btn-warning">Edit</a>
                            <a href="customers?action=delete&id=${customer.customerId}" 
                               class="btn btn-sm btn-danger">Delete</a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</body>
</html>