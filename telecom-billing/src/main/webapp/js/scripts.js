// Document Ready Function
$(document).ready(function() {
    // Initialize DataTables
    $('.datatable').DataTable({
        "pageLength": 25,
        "responsive": true
    });

    // Form Validation
    $('form').submit(function(e) {
        let isValid = true;
        $(this).find('.required').each(function() {
            if ($(this).val() === '') {
                $(this).addClass('is-invalid');
                isValid = false;
            } else {
                $(this).removeClass('is-invalid');
            }
        });
        return isValid;
    });

    // Date Picker Initialization
    $('.datepicker').datepicker({
        format: 'yyyy-mm-dd',
        autoclose: true
    });

    // Confirm before delete
    $('.confirm-delete').on('click', function() {
        return confirm('Are you sure you want to delete this record?');
    });

    // AJAX Customer Search
    $('#customerSearch').on('keyup', function() {
        const searchTerm = $(this).val();
        if (searchTerm.length > 2) {
            $.get('/customers?action=search&searchTerm=' + searchTerm, function(data) {
                $('#customerTable').html(data);
            });
        }
    });
});

// Helper function for formatting numbers
function formatCurrency(amount) {
    
    const pattern = /\d(?=(\d{3})+\./g;
    return '$' + parseFloat(amount).toFixed(2).replace(pattern, '$&,');
}

// PDF Download Handler
function downloadInvoice(invoiceId) {
    window.location.href = '/invoices?action=download&id=' + invoiceId;
}