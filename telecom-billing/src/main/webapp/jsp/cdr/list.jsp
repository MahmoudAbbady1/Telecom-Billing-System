<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Call Detail Records (CDR)</h3>
    </div>
    <div class="col-md-6 text-right">
        <button class="btn btn-primary" data-toggle="modal" data-target="#uploadModal">
            Upload CDR File
        </button>
        <a href="cdrs?action=process" class="btn btn-success">Process CDRs</a>
    </div>
</div>

<!-- Upload Modal -->
<div class="modal fade" id="uploadModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Upload CDR File</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>&times;</span>
                </button>
            </div>
            <form action="cdrs" method="post" enctype="multipart/form-data">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Select CDR File (CSV format)</label>
                        <input type="file" class="form-control-file" name="cdrFile" accept=".csv" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Upload</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <table class="table table-striped datatable">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Dial A</th>
                    <th>Dial B</th>
                    <th>Service</th>
                    <th>Quantity</th>
                    <th>Start Time</th>
                    <th>Processed</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="cdr" items="${cdrs}">
                    <tr>
                        <td>${cdr.cdrId}</td>
                        <td>${cdr.dialA}</td>
                        <td>${cdr.dialB}</td>
                        <td>
                            <c:choose>
                                <c:when test="${cdr.serviceId == 1}">Voice</c:when>
                                <c:when test="${cdr.serviceId == 2}">SMS</c:when>
                                <c:when test="${cdr.serviceId == 3}">Data</c:when>
                                <c:otherwise>Unknown</c:otherwise>
                            </c:choose>
                        </td>
                        <td>${cdr.quantity}</td>
                        <td>${cdr.startTime}</td>
                        <td>
                            <span class="badge badge-${cdr.processed ? 'success' : 'warning'}">
                                ${cdr.processed ? 'Yes' : 'No'}
                            </span>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>