// Document Ready Function
$(document).ready(function() {
    // Initialize DataTables
    $('.datatable').DataTable({
        "pageLength": 25,
        "responsive": true,
        "language": {
            "search": "Search:",
            "lengthMenu": "Show _MENU_ entries per page",
            "info": "Showing _START_ to _END_ of _TOTAL_ entries"
        }
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
    $('.confirm-delete').on('click', function(e) {
        e.preventDefault();
        const deleteUrl = $(this).attr('href');
        if (confirm('Are you sure you want to delete this record?')) {
            window.location.href = deleteUrl;
        }
    });

    // AJAX Customer Search
    $('#customerSearch').on('keyup', function() {
        const searchTerm = $(this).val();
        if (searchTerm.length > 2) {
            $.ajax({
                url: '${pageContext.request.contextPath}/customers',
                type: 'GET',
                data: {
                    action: 'search',
                    searchTerm: searchTerm
                },
                success: function(data) {
                    $('#customerTable').html(data);
                },
                error: function(xhr, status, error) {
                    console.error('Search error:', error);
                }
            });
        }
    });

    // Initialize tooltips
    $('[data-bs-toggle="tooltip"]').tooltip();

    // Initialize popovers
    $('[data-bs-toggle="popover"]').popover();

    // Format numbers with commas
function formatNumber(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

    // Format currency
    function formatCurrency(amount) {
        return '$' + formatNumber(amount.toFixed(2));
    }
});
