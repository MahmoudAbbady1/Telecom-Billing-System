<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

<h3>${not empty ratePlan.planId ? 'Edit' : 'Add'} Rate Plan</h3>

<form action="rateplans" method="post">
    <input type="hidden" name="action" value="${not empty ratePlan.planId ? 'update' : 'insert'}">
    
    <c:if test="${not empty ratePlan.planId}">
        <input type="hidden" name="id" value="${ratePlan.planId}">
    </c:if>
    
    <div class="form-group">
        <label for="planName">Plan Name *</label>
        <input type="text" class="form-control required" id="planName" name="planName" 
               value="${ratePlan.planName}" required>
    </div>
    
    <div class="form-group">
        <label for="description">Description</label>
        <textarea class="form-control" id="description" name="description">${ratePlan.description}</textarea>
    </div>
    
    <div class="form-group">
        <label for="basePrice">Base Price *</label>
        <input type="number" step="0.01" class="form-control required" id="basePrice" name="basePrice" 
               value="${ratePlan.basePrice}" required>
    </div>
    
    <div class="form-group form-check">
        <input type="checkbox" class="form-check-input" id="isActive" name="isActive" 
               ${ratePlan.active ? 'checked' : ''}>
        <label class="form-check-label" for="isActive">Active</label>
    </div>
    
    <button type="submit" class="btn btn-primary">Save</button>
    <a href="rateplans" class="btn btn-secondary">Cancel</a>
</form>

<%@ include file="../includes/footer.jsp" %>