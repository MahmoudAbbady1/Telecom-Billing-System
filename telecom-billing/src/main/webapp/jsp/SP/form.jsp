<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

<h3>${not empty ratePlan.planId ? 'Edit' : 'Add'} Service Package</h3>

<form action="rateplans" method="post">
    <input type="hidden" name="action" value="${not empty ratePlan.planId ? 'update' : 'insert'}">
    
    <c:if test="${not empty ratePlan.planId}">
        <input type="hidden" name="id" value="${ratePlan.planId}">
    </c:if>
    <br>
    <div class="form-group">
        <label for="planName">Name *</label>
        <input type="text" class="form-control required" id="planName" name="planName" 
               value="${ratePlan.planName}" required>
    </div>
    <br>
 <div class="form-group">
                        <label for="type">Type*</label>
                        <select class="form-control" id="type" name="type" required>
                            <option value="Data" ${sp.type == 'Data' ? 'selected' : ''}>Data</option>
                            <option value="Voice" ${sp.type == 'Voice' ? 'selected' : ''}>Voice</option>
                            <option value="SMS" ${sp.type == 'SMS' ? 'selected' : ''}>SMS</option>
                            <option value="Mixed" ${sp.type == 'Mixed' ? 'selected' : ''}>Mixed</option>
                        </select>
                    </div>
    <br>
    
    
    <div class="form-group">
        <label for="basePrice">Quota *</label>
        <input type="number" step="0.01" class="form-control required" id="basePrice" name="basePrice" 
               value="${ratePlan.basePrice}" required>  
    </div>
    <br>
    <div class="form-group">
        <label for="basePrice">Base Price *</label>
        <input type="number" step="0.01" class="form-control required" id="basePrice" name="basePrice" 
               value="${ratePlan.basePrice}" required>
    </div>
    
    <br>
    <br>
    <br>
    
    <button type="submit" class="btn btn-primary">Save</button>
    <a href="list.jsp" class="btn btn-secondary">Cancel</a>
</form>

<%@ include file="../includes/footer.jsp" %>