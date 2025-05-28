<%@ include file="../includes/header.jsp" %>

<div class="row mb-3">
    <div class="col-md-6">
        <h3>Call Detail Records (CDR)</h3>
    </div>
    <div class="col-md-6 text-right">
        <button class="btn btn-primary" data-toggle="modal" data-target="#uploadModal">
            Upload CDR File
        </button>
        <a href="#" id="processCdrsBtn" class="btn btn-success">Process CDRs</a>
    </div>
</div>

<!-- Upload Modal -->
<div class="modal fade" id="uploadModal" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Upload CDR File</h5>
                <button type="button" class="close" data-dismiss="modal">
                    <span>×</span>
                </button>
            </div>
            <form id="uploadForm" action="${pageContext.request.contextPath}/api/cdrs" method="post" enctype="multipart/form-data">
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
        <table class="table table-striped datatable" id="cdrTable">
            <thead>
                <tr>
                    <th>Customer-CDR</th>
                    <th>Processed</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
</div>

<script src="${pageContext.request.contextPath}/webjars/jquery/3.6.0/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/webjars/datatables/1.10.20/js/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/webjars/bootstrap/4.3.1/js/bootstrap.min.js"></script>
<script>
$(document).ready(function() {
    // Verify jQuery version
    console.log('jQuery version:', $.fn.jquery);

    // Initialize DataTable only if not already initialized
    var table = $('#cdrTable').DataTable();
    if (!$.fn.DataTable.isDataTable('#cdrTable')) {
        table = $('#cdrTable').DataTable({
            ajax: {
                url: '${pageContext.request.contextPath}/api/cdrs',
                dataSrc: '',
                error: function(xhr, error, thrown) {
                    console.error('DataTable AJAX error:', xhr, error, thrown);
                    var errorMessage = xhr.responseJSON && xhr.responseJSON.message 
                        ? xhr.responseJSON.message 
                        : 'Failed to load CDR data: ' + thrown;
                    alert('Error: ' + errorMessage);
                }
            },
            columns: [
                { data: 'filename' },
                { 
                    data: 'processed',
                    render: function(data) {
                        return data ? 'Processed' : 'Not Processed';
                    }
                }
            ]
        });
    } else {
        // Reload data if table already initialized
        table.ajax.reload();
    }

    // Handle Process CDRs button click
    $('#processCdrsBtn').click(function(e) {
        e.preventDefault();
        $.ajax({
            url: '${pageContext.request.contextPath}/api/cdrs/process',
            method: 'GET',
            success: function(response) {
                alert(response.message);
                table.ajax.reload();
            },
            error: function(xhr) {
                var errorMessage = xhr.responseJSON && xhr.responseJSON.message 
                    ? xhr.responseJSON.message 
                    : 'Failed to process CDRs';
                alert('Error processing CDRs: ' + errorMessage);
            }
        });
    });

    // Handle form submission with AJAX
    $('#uploadForm').submit(function(e) {
        e.preventDefault();
        var formData = new FormData(this);
        $.ajax({
            url: '${pageContext.request.contextPath}/api/cdrs',
            method: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(response) {
                alert(response.message);
                $('#uploadModal').modal('hide');
                table.ajax.reload();
            },
            error: function(xhr) {
                var errorMessage = xhr.responseJSON && xhr.responseJSON.message 
                    ? xhr.responseJSON.message 
                    : 'Failed to upload CDR';
                alert('Error uploading CDR: ' + errorMessage);
            }
        });
    });
});
</script>

<%@ include file="../includes/footer.jsp" %>