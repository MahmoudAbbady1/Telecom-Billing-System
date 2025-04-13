<%@ include file="../includes/header.jsp" %>
<%--<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>--%>

<form action="ServicePackageServlet" method="post">
    <input type="hidden" name="action" value="update" />
    <input type="hidden" name="spId" value="${sp.spId}" />

    <div class="row mb-3">
        <div class="col-md-6">
            <h3>Edit Service Package #${sp.spId}</h3>
        </div>
        <div class="col-md-6 text-right" style="text-align: right">
            <button type="submit" class="btn btn-success">Save Changes</button>
            <a href="list.jsp" class="btn btn-secondary">Back to List</a>
        </div>
    </div>

    <div class="card mb-3">
        <div class="card-body">
            <div class="row">
                <!-- Left column -->
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="name">Package Name</label>
                        <input type="text" class="form-control" id="name" name="name" 
                               value="${sp.name}" required>
                    </div>
                    <br>
                    <div class="form-group">
                        <label for="type">Type</label>
                        <select class="form-control" id="type" name="type" required>
                            <option value="Data" ${sp.type == 'Data' ? 'selected' : ''}>Data</option>
                            <option value="Voice" ${sp.type == 'Voice' ? 'selected' : ''}>Voice</option>
                            <option value="SMS" ${sp.type == 'SMS' ? 'selected' : ''}>SMS</option>
                            <option value="Mixed" ${sp.type == 'Mixed' ? 'selected' : ''}>Mixed</option>
                        </select>
                    </div>
                    <br>

                </div>

                <!-- Right column -->
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="quota">Quota</label>
                        <input type="number" class="form-control" id="quota" name="quota" 
                               value="${sp.quota}" min="0" required>
                    </div>
                    <br>
                    <div class="form-group">
                        <label for="price">Price (EGP)</label>
                        <input type="number" step="0.01" class="form-control" id="price" name="price"
                               value="${sp.price}" min="0" required>
                    </div>
                    <br>

                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="form-group">
                <label for="description">Description</label>
                <textarea class="form-control" id="description" name="description" rows="4">${sp.description}</textarea>
            </div>
        </div>
    </div>
</form>

<%@ include file="../includes/footer.jsp" %>
