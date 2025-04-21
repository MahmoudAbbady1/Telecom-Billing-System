<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-cube"></i> Service Package Details
        </h3>
    </div>
    <div class="col-md-6 text-end">
        <a href="#" id="editBtn" class="btn btn-primary">
            <i class="fas fa-edit"></i> Edit
        </a>
        <a href="list.jsp" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div id="alertContainer"></div>

<div class="card shadow-sm mb-4">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-info-circle"></i> Package Information</h5>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <dl class="row">
                    <dt class="col-sm-4">Package ID:</dt>
                    <dd class="col-sm-8" id="serviceId">Loading...</dd>

                    <dt class="col-sm-4">Name:</dt>
                    <dd class="col-sm-8" id="serviceName">Loading...</dd>

                    <dt class="col-sm-4">Type:</dt>
                    <dd class="col-sm-8" id="serviceType">Loading...</dd>
                </dl>
            </div>
            <div class="col-md-6">
                <dl class="row">
                    <dt class="col-sm-4">Network Zone:</dt>
                    <dd class="col-sm-8" id="networkZone">Loading...</dd>
                    
                    <dt class="col-sm-4">Number of Rate Planes used:</dt>
                    <dd class="col-sm-8" id="networkZone">Loading...</dd>
                </dl>
            </div>
        </div>
    </div>
</div>

<div class="card shadow-sm mb-4">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-chart-line"></i> Pricing & Quota</h5>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-md-6">
                <dl class="row">
                    <dt class="col-sm-4">Quota:</dt>
                    <dd class="col-sm-8" id="quota">Loading...</dd>

                    <dt class="col-sm-4">Unit Description:</dt>
                    <dd class="col-sm-8" id="unitDescription">Loading...</dd>
                </dl>
            </div>
            <div class="col-md-6">
                <dl class="row">
                    <dt class="col-sm-4">Rate Per Unit:</dt>
                    <dd class="col-sm-8" id="ratePerUnit">Loading...</dd>

                    <dt class="col-sm-4">Validity:</dt>
                    <dd class="col-sm-8" id="validityDays">Loading...</dd>
                </dl>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Get the ID from the URL
    const urlParams = new URLSearchParams(window.location.search);
    const packageId = urlParams.get('id');
    
    if (!packageId) {
        showAlert('danger', 'No package ID specified in the URL');
        return;
    }
    
    // Fetch package details
    $.ajax({
        url: '${pageContext.request.contextPath}/api/service-packages/' + packageId,
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function(data) {
            // Update the view with the package data
            $('#serviceId').text(data.serviceId);
            $('#serviceName').text(data.serviceName);
            $('#serviceType').text(data.serviceType);
            $('#networkZone').text(formatNetworkZone(data.serviceNetworkZone));
            $('#quota').text(data.quota === 0 ? 'Unlimited' : data.quota + ' ' + (data.unitDescription || ''));
            $('#unitDescription').text(data.unitDescription || 'N/A');
            
            const rate = parseFloat(data.ratePerUnit);
            $('#ratePerUnit').text(isNaN(rate) ? 'N/A' : 'EGP ' + rate.toFixed(4) + ' / ' + (data.unitDescription || 'unit'));
            
            $('#validityDays').text(data.validityDays ? data.validityDays + ' days' : 'N/A');
            
            // Set up edit button
            $('#editBtn').attr('href', 'form.jsp?id=' + data.serviceId);
        },
        error: function(xhr) {
            handleApiError(xhr);
        }
    });
});

// Format network zone for display
function formatNetworkZone(zone) {
    if (!zone) return 'N/A';
    return zone.split('_').map(word => 
        word.charAt(0) + word.slice(1).toLowerCase()
    ).join('-');
}

// Get authentication token
function getAuthToken() {
    return localStorage.getItem('authToken') || '';
}

// Handle API errors
function handleApiError(xhr) {
    console.error('API Error:', xhr);
    var message = 'An error occurred while loading service package details';
    
    if (xhr.status === 403) {
        message = 'Your session has expired. Please login again.';
        clearAuthTokens();
        setTimeout(function() {
            window.location.href = '${pageContext.request.contextPath}/login.jsp';
        }, 2000);
    } else if (xhr.status === 404) {
        message = 'Service package not found';
    } else if (xhr.status === 500) {
        message = 'Server error: ' + (xhr.responseJSON ? xhr.responseJSON.message : xhr.statusText);
    }
    
    showAlert('danger', message);
}

// Clear all authentication tokens
function clearAuthTokens() {
    localStorage.removeItem('authToken');
    document.cookie = 'authToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
}

// Show alert message
function showAlert(type, message) {
    var alertId = 'alert-' + Date.now();
    var alertHtml = '<div id="' + alertId + '" class="alert alert-' + type + ' alert-dismissible fade show" role="alert">' +
                    message +
                    '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>' +
                    '</div>';
    
    $('#alertContainer').append(alertHtml);
    
    // Auto-dismiss after 5 seconds (except for danger alerts)
    if (type !== 'danger') {
        setTimeout(function() {
            $('#' + alertId).alert('close');
        }, 5000);
    }
}
</script>

<%@ include file="../includes/footer.jsp" %>