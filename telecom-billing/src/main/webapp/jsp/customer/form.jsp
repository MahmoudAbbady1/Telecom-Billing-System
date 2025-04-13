<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

<h3>${not empty customer.customerId ? 'Edit' : 'Add'} Customer</h3>

<form action="customers" method="post">
    <input type="hidden" name="action" value="${not empty customer.customerId ? 'update' : 'insert'}">
    
    <c:if test="${not empty customer.customerId}">
        <input type="hidden" name="id" value="${customer.customerId}">
    </c:if>
    
            <br>
    <div class="form-group">
        <label for="name">Name *</label>
        <input type="text" class="form-control required" id="name" name="name" 
               value="${customer.name}" required>
    </div>
            <br>
    
    <div class="form-group">
        <label for="phone">Phone *</label>
        <input type="text" class="form-control required" id="phone" name="phone" 
               value="${customer.phone}" required>
    </div>
            <br>
    
    <div class="form-group">
        <label for="email">Email *</label>
        <input type="email" class="form-control" id="email" name="email" 
               value="${customer.email}" required>
    </div>
    
            <br>
    <div class="form-group">
        <label for="address">Address *</label>
        <textarea class="form-control" id="address" name="address" required>${customer.address}</textarea> 
    </div>
            <br>
<div class="form-group">
    <label for="rateplan">Select Rateplan*</label>
    <select class="form-control" id="rateplan" name="rateplan" required>
        <option value="">-- Select Rateplan --</option>
        <option value="PlanA" ${customer.rateplan == 'PlanA' ? 'selected' : ''}>Plan A</option>
        <option value="PlanB" ${customer.rateplan == 'PlanB' ? 'selected' : ''}>Plan B</option>
        <option value="PlanC" ${customer.rateplan == 'PlanC' ? 'selected' : ''}>Plan C</option>
    </select>
</div>

            <br>
    <c:if test="${not empty customer.customerId}">
        <div class="form-group">
            <label for="status">Status</label>
            <select class="form-control" id="status" name="status">
                <option value="ACTIVE" ${customer.status == 'ACTIVE' ? 'selected' : ''}>Active</option>
                <option value="INACTIVE" ${customer.status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
            </select>
        </div>
    </c:if>
            <br>
            <br>
            <br>
    <button type="submit" class="btn btn-primary">Save</button>
    <a href="customers" class="btn btn-secondary">Cancel</a>
</form>

<%@ include file="../includes/footer.jsp" %>