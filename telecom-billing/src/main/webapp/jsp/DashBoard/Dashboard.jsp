
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
                        <h6 class="text-muted mb-2">Today's Revenue</h6>
                        <h3 class="mb-0">$12,450</h3>
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
    <div class="col-lg-12">
        <div class="row mb-4">
            <div class="card dashboard-card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="fas fa-bolt me-2"></i>Quick Actions</h5>
                </div>
                <div class="card-body">
                    <div class="d-flex justify-content-between">
                        <a href="../invoice/list.jsp" class="btn-outline-primary">
                            <button class="btn btn-outline-primary me-2">
                                <i class="fas fa-plus me-2"></i>Create New Invoice
                            </button>
                        </a>

                        <a href="../customer/form.jsp" class="btn-outline-primary">
                            <button class="btn btn-outline-primary me-2">
                                <i class="fas fa-user-plus me-2"></i>Add Customer
                            </button>
                        </a>

                        <a href="../rateplan/form.jsp" class="btn-outline-primary">
                            <button class="btn btn-outline-primary me-2">
                                <i class="fas fa-file-import me-2"></i>Create new Rate Plan
                            </button>
                        </a>

                        <a href="../service-package/form.jsp" class="btn-outline-primary">
                            <button class="btn btn-outline-primary">
                                <i class="fas fa-chart-pie me-2"></i>New Service Package
                            </button>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>



    <!-- Recent Invoices -->
    <div class="row mt-4">
        <div class="col-lg-14">
            <div class="card dashboard-card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="fas fa-file-invoice-dollar me-2"></i>Recent Invoices</h5>
                    <a href="#" class="btn btn-sm btn-primary">View All</a>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Invoice #</th>
                                    <th>Customer</th>
                                    <th>Date</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>INV-2023-1056</td>
                                    <td>Acme Corporation</td>
                                    <td>2023-06-15</td>
                                    <td>$1,250.00</td>
                                    <td><span class="badge bg-success">Paid</span></td>
                                    <td><a href="#" class="btn btn-sm btn-outline-primary">View</a></td>
                                </tr>
                                <tr>
                                    <td>INV-2023-1055</td>
                                    <td>Global Telecom</td>
                                    <td>2023-06-14</td>
                                    <td>$890.50</td>
                                    <td><span class="badge bg-warning">Pending</span></td>
                                    <td><a href="#" class="btn btn-sm btn-outline-primary">View</a></td>
                                </tr>
                                <tr>
                                    <td>INV-2023-1054</td>
                                    <td>Tech Solutions Inc.</td>
                                    <td>2023-06-13</td>
                                    <td>$2,150.75</td>
                                    <td><span class="badge bg-success">Paid</span></td>
                                    <td><a href="#" class="btn btn-sm btn-outline-primary">View</a></td>
                                </tr>
                                <tr>
                                    <td>INV-2023-1053</td>
                                    <td>Data Networks Ltd.</td>
                                    <td>2023-06-12</td>
                                    <td>$1,750.00</td>
                                    <td><span class="badge bg-danger">Overdue</span></td>
                                    <td><a href="#" class="btn btn-sm btn-outline-primary">View</a></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
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

    // Dummy getAuthToken function (replace with real logic if needed)
    function getAuthToken() {
        return localStorage.getItem("authToken") || "";
    }
</script>

</body>
</html>