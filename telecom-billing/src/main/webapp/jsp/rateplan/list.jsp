<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="container">
    <h1>Rate Plans</h1>
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Description</th>
                <th>Base Price</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="plan" items="${ratePlans}">
                <tr>
                    <td>${plan.planId}</td>
                    <td>${plan.planName}</td>
                    <td>${plan.description}</td>
                    <td>${plan.basePrice}</td>
                    <td>
                        <a href="#" class="btn btn-sm btn-primary">View Services</a>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>