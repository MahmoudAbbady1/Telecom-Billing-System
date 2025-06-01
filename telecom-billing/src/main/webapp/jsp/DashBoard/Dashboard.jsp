
<%@ include file="../includes/header.jsp" %>
<link rel="stylesheet" href="../../css/styles.jsp"/>
<!-- Welcome Header -->

<div class="welcome-hero mb-4 rounded-3">
    <div class="container-fluid py-5">
        <h1 class="display-5 fw-bold">Welcome back, Mahmoud Ibrahim</h1>
        <p class="col-md-8 fs-4">Here's what's happening with your telecom billing system today.</p>
    </div>
</div>

<!-- Quick Stats -->
<div class="row mb-4">



    <div class="col-md-4">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Total Customers</h6>
                        <h3 class="mb-0" id="totalCount">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-users"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Active Customers</h6>
                        <h3 class="mb-0" id="activeCount">0</h3>

                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-user-check"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card dashboard-card quick-stats">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6 class="text-muted mb-2">Total Revenue</h6>
                        <h3 class="mb-0" id="totalRevenue">0</h3>
                    </div>
                    <div class="card-icon bg-light bg-opacity-10 p-3 rounded-circle">
                        <i class="fas fa-dollar-sign"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row mt-5">
    </div>


    <!-- Quick Actions & Profile -->
    <div class="col-lg-24">
        <div class="row mb-12">
            <div class="card dashboard-card mb-12">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-bolt me-2"></i>Quick Actions</h5>
                </div>
                <div class="card-body d-flex justify-content-between">
                    <a href="../customer/form.jsp" class="btn-outline-primary">
                        <button class="btn btn-outline-primary" style="width: 400px;">
                            <i class="fas fa-user-plus me-2"></i>Add Customer
                        </button>
                    </a>

                    <a href="../rateplan/form.jsp" class="btn-outline-primary">
                        <button class="btn btn-outline-primary" style="width: 450px;">
                            <i class="fas fa-file-import me-2"></i>Create new Rate Plan
                        </button>
                    </a>

                    <a href="../service-package/form.jsp" class="btn-outline-primary">
                        <button class="btn btn-outline-primary" style="width: 400px;">
                            <i class="fas fa-chart-pie me-2"></i>New Service Package
                        </button>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>



<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    // Activate the current nav item
    document.querySelectorAll('.nav-link').forEach(link => {
        if (link.href === window.location.href) {
            link.classList.add('active');
        }
    });

    // Simple greeting based on time of day
    document.addEventListener('DOMContentLoaded', function () {
        const hour = new Date().getHours();
        let greeting;
        if (hour < 12) {
            greeting = "Good morning";
        } else if (hour < 18) {
            greeting = "Good afternoon";
        } else {
            greeting = "Good evening";
        }

        const welcomeHeader = document.querySelector('.welcome-hero h1');
        if (welcomeHeader) {
            welcomeHeader.textContent = `${greeting} Welcome Back, Mahmoud Ibrahim`;
        }
    });


    // Fetch Active Customer Count
    $(document).ready(function () {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/customers/stats',
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken() // Ensure this function returns your JWT token
            },
            success: function (data) {
                $('#totalCount').text(data.TOTAL || 0);
                $('#activeCount').text(data.ACTIVE || 0);
            },
            error: function (xhr) {
                console.error("Failed to load active customers:", xhr);
            }
        });
    });

$(document).ready(function () {
    // Fetch total revenue
    $.ajax({
        url: '${pageContext.request.contextPath}/api/invoices/total-revenue',
        method: 'GET',
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function (data) {
            $('#totalRevenue').text(formatCurrency(data));
        },
        error: function (xhr) {
            console.error("Failed to load total revenue:", xhr);
            $('#totalRevenue').text('0 EGP');
        }
    });

    // Helper function to format currency
    function formatCurrency(amount) {
        return amount.toLocaleString('en-US', {
            style: 'currency',
            currency: 'EGP',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }
});
    // Dummy getAuthToken function (replace with real logic if needed)
    function getAuthToken() {
        return localStorage.getItem("authToken") || "";
    }
</script>

</body>
</html>