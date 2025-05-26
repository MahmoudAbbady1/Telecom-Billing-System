<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String uri = request.getRequestURI();
%>

<c:if test="${empty sessionScope.username}">
    <c:redirect url="/index.jsp"/>
</c:if>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>T3mya Egypt</title>
        <!-- CSS -->
        <link rel="icon" href="../../css/icon.ico">

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="../../css/styles.jsp">

        <!-- JavaScript (LOAD IN THIS ORDER!) -->
        <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
        <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
    </head>
    <body>
        <!-- Navigation -->
        <nav class="navbar navbar-expand-lg navbar-dark" style="background-color: var(--secondary-color);">
            <div class="container">
                <a class="navbar-brand fw-bold" href="../DashBoard/Dashboard.jsp">
                    <i class="fas fa-satellite-dish me-2"></i>T3mya -Egypt
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <li class="nav-item" style="text-align: right">
                    <a class="nav-link text-danger" href="${pageContext.request.contextPath}/logout">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </li>
            </div>
        </nav>

        <div class="container-fluid">
            <div class="row">
                <!-- Sidebar -->
                <div class="col-md-3 col-lg-2 d-md-block sidebar p-0">
                    <div class="position-sticky pt-3">
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link <%= uri.contains("Dashboard.jsp") ? "active" : ""%>" href="../DashBoard/Dashboard.jsp">
                                    <i class="fas fa-tachometer-alt"></i> Dashboard
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link <%= uri.contains("invoice") ? "active" : ""%>" href="../invoice/list.jsp">
                                    <i class="fas fa-file-invoice-dollar"></i> Invoices
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link <%= uri.contains("customer") ? "active" : ""%>" href="../customer/list.jsp">
                                    <i class="fas fa-users"></i> Customers
                                </a>
                            </li>

                            <li class="nav-item">
                                <a class="nav-link <%= uri.contains("rateplan") ? "active" : ""%>" href="../rateplan/list.jsp">
                                    <i class="fas fa-chart-line"></i> Rate planes 
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link <%= uri.contains("service-package") ? "active" : ""%>" href="../service-package/list.jsp">
                                    <i class="fas fa-cogs"></i> Service Packages
                                </a>
                            </li>
                            <!--
                            <li class="nav-item">
                                <a class="nav-link" href="#">
                                    <i class="fas fa-credit-card"></i> Installments
                                </a>
                            </li>
                            -->
                        </ul>
                    </div>
                </div>

                <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 py-4">
