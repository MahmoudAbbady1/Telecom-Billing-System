<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Service Packages </h3>
    </div>

    <div class="col-md-6 text-right" style="text-align: right">
        <a href="form.jsp" class="btn btn-primary">Create New SP</a>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table class="table table-striped datatable">
            <thead>
                <tr>
                    <th>Package Id</th>
                    <th>name</th>
                    <th>type</th>
                    <th>quota</th>
                    <th>price</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <c:forEach var="SP" items="${SP}">
                <tr>
                    <td>${SP.SPId}</td>
                    <td>${SP.name}</td>
                    <td>${SP.type}</td>
                    <td>${SP.quota}</td>
                    <td>${SP.price}</td>
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