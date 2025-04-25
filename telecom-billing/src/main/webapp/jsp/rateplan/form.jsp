<%@ include file="../includes/header.jsp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-file-invoice-dollar"></i> <span id="formTitle">Add Rate Plan</span>
        </h3>
    </div>
    <div class="col-md-6 text-end">
        <a href="list.jsp" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div id="alertContainer"></div>

<form id="planForm" class="needs-validation" novalidate>
    <input type="hidden" id="planId" name="planId">
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-light">
            <h5 class="card-title mb-0">
                <i class="fas fa-info-circle"></i> Plan Details
            </h5>
        </div>
        <div class="card-body">
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="planName" class="form-label">Name *</label>
                        <input type="text" class="form-control" id="planName" name="planName" required maxlength="50">
                        <div class="invalid-feedback">Please provide a plan name</div>
                    </div>

                    <div class="form-group mb-3">
                        <label for="basePrice" class="form-label">Base Price (EGP) *</label>
                        <div class="input-group">
                            <input type="number" step="0.01" class="form-control" id="basePrice" name="basePrice" value="0.00" required min="0">
                            <span class="input-group-text">EGP</span>
                        </div>
                        <div class="invalid-feedback">Please provide a valid base price</div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="description" class="form-label">Description</label>
                        <textarea class="form-control" id="description" name="description" rows="3" maxlength="500"></textarea>
                        <small class="form-text text-muted">Max 500 characters</small>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-check mb-3">
                                <input type="checkbox" class="form-check-input" id="cug" name="cug">
                                <label class="form-check-label" for="cug">Closed User Group (CUG)</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-check mb-3">
                                <input type="checkbox" class="form-check-input" id="isActive" name="isActive" checked>
                                <label class="form-check-label" for="isActive">Active Plan</label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="validityDays" class="form-label">Validity Days</label>
                        <input type="number" class="form-control" id="validityDays" name="validityDays" min="1" value="30">
                        <small class="form-text text-muted">Default is 30 days</small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow-sm mb-4">
        <div class="card-header bg-light">
            <h5 class="card-title mb-0">
                <i class="fas fa-list"></i> Included Services
            </h5>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered" id="servicesTable">
                    <thead>
                        <tr>
                            <th>Service</th>
                            <th>Type</th>
                            <th>Included Units</th>
                            <th>Unlimited</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="servicesBody">
                        <!-- Services will be added here dynamically -->
                    </tbody>
                </table>
            </div>
            <div class="text-end mt-3">
                <button type="button" class="btn btn-primary" id="addServiceBtn">
                    <i class="fas fa-plus"></i> Add Service
                </button>
            </div>
        </div>
    </div>

    <div class="text-end mb-4">
        <button type="submit" class="btn btn-primary" id="submitBtn">
            <i class="fas fa-save"></i> Save Rate Plan
        </button>
    </div>
</form>

<!-- Service Selection Modal -->
<div class="modal fade" id="serviceModal" tabindex="-1" aria-labelledby="serviceModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="serviceModalLabel">Select Service</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <table class="table table-striped" id="availableServicesTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Type</th>
                            <th>Network Zone</th>
                            <th>Rate/Unit</th>
                            <th>Select</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Available services will be loaded here -->
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        // Get the ID from the URL if editing
        const urlParams = new URLSearchParams(window.location.search);
        const planId = urlParams.get('id');
        let selectedServices = [];

        if (planId) {
            loadPlanData(planId);
        }

        // Initialize available services table
        $('#availableServicesTable').DataTable({
            ajax: {
                url: '${pageContext.request.contextPath}/api/service-packages',
                dataSrc: '',
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                }
            },
            columns: [
                {data: 'serviceId'},
                {data: 'serviceName'},
                {data: 'serviceType'},
                {data: 'serviceNetworkZone'},
                {
                    data: 'ratePerUnit',
                    render: function (data) {
                        return 'EGP ' + parseFloat(data).toFixed(4);
                    }
                },
                {
                    data: null,
                    render: function (data) {
                        return '<button class="btn btn-sm btn-primary select-service" data-service-id="' + data.serviceId + '">Select</button>';
                    }
                }
            ]
        });

        // Handle service selection
        $('#availableServicesTable').on('click', '.select-service', function () {
            const serviceId = $(this).data('service-id');
            const serviceName = $(this).closest('tr').find('td:eq(1)').text();
            const serviceType = $(this).closest('tr').find('td:eq(2)').text();

            // Check if service is already added
            if (selectedServices.some(s => s.serviceId === serviceId)) {
                showAlert('warning', 'This service is already added to the plan');
                return;
            }

            // Add to selected services
            selectedServices.push({
                serviceId: serviceId,
                serviceName: serviceName,
                serviceType: serviceType,
                includedUnits: 0,
                isUnlimited: false
            });

            // Update services table
            updateServicesTable();

            // Hide modal
            $('#serviceModal').modal('hide');
        });

        // Add service button click
        $('#addServiceBtn').click(function () {
            $('#serviceModal').modal('show');
        });

        // Update services table
        function updateServicesTable() {
            const tbody = $('#servicesBody');
            tbody.empty();

            selectedServices.forEach((service, index) => {
                const row = `
                <tr data-service-id="${service.serviceId}">
                    <td>${service.serviceName}</td>
                    <td>${service.serviceType}</td>
                    <td>
                        <input type="number" class="form-control form-control-sm included-units" 
                               value="${service.includedUnits}" min="0" ${service.isUnlimited ? 'disabled' : ''}>
                    </td>
                    <td>
                        <div class="form-check">
                            <input type="checkbox" class="form-check-input unlimited-checkbox" 
    ${service.isUnlimited ? 'checked' : ''}>
                        </div>
                    </td>
                    <td>
                        <button class="btn btn-sm btn-danger remove-service">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `;
                tbody.append(row);
            });

            // Handle unlimited checkbox change
            $('.unlimited-checkbox').change(function () {
                const row = $(this).closest('tr');
                const input = row.find('.included-units');
                input.prop('disabled', $(this).is(':checked'));

                const serviceId = row.data('service-id');
                const service = selectedServices.find(s => s.serviceId === serviceId);
                if (service) {
                    service.isUnlimited = $(this).is(':checked');
                    if (service.isUnlimited) {
                        service.includedUnits = 0;
                        row.find('.included-units').val(0);
                    }
                }
            });

            // Handle included units change
            $('.included-units').change(function () {
                const serviceId = $(this).closest('tr').data('service-id');
                const service = selectedServices.find(s => s.serviceId === serviceId);
                if (service) {
                    service.includedUnits = parseInt($(this).val()) || 0;
                }
            });

            // Handle remove service
            $('.remove-service').click(function () {
                const serviceId = $(this).closest('tr').data('service-id');
                selectedServices = selectedServices.filter(s => s.serviceId !== serviceId);
                updateServicesTable();
            });
        }

        // Form submission handler
        $('#planForm').submit(function (e) {
            e.preventDefault();

            if (!this.checkValidity()) {
                e.stopPropagation();
                $(this).addClass('was-validated');
                return;
            }

            const formData = {
                planName: $('#planName').val(),
                description: $('#description').val(),
                basePrice: parseFloat($('#basePrice').val()),
                cug: $('#cug').is(':checked'),
                isActive: $('#isActive').is(':checked'),
                validityDays: parseInt($('#validityDays').val()) || 30,
                services: selectedServices.map(s => ({
                        serviceId: s.serviceId,
                        includedUnits: s.includedUnits,
                        isUnlimited: s.isUnlimited
                    }))
            };
            console.log("Submitting data:", JSON.stringify(formData, null, 2)); // Debug log

            const method = planId ? 'PUT' : 'POST';
            const url = '${pageContext.request.contextPath}/api/rate-plans' + (planId ? '/' + planId : '');

            $('#submitBtn').prop('disabled', true);

            $.ajax({
                url: url,
                method: method,
                contentType: 'application/json',
                data: JSON.stringify(formData),
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function (data) {
                    console.log("Success response:", data); // Debug log
                    showAlert('success', planId ? 'Rate plan updated successfully!' : 'Rate plan created successfully!');

                    if (!planId) {
                        setTimeout(function () {
                            window.location.href = 'view.jsp?id=' + data.planId;
                        }, 1000);
                    }
                },
                error: function (xhr) {
                    console.error("Error details:", xhr.responseText); // Debug log
                    $('#submitBtn').prop('disabled', false);
                    let message = 'An error occurred';

                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        message = xhr.responseJSON.message;
                    } else if (xhr.status === 403) {
                        message = 'Authentication failed. Please login again.';
                        setTimeout(() => window.location.href = '${pageContext.request.contextPath}/index.jsp', 2000);
                    }

                    showAlert('danger', message);
                }
            });
        });
    });

    function loadPlanData(planId) {
        $.ajax({
            url: '${pageContext.request.contextPath}/api/rate-plans/' + planId,
            method: 'GET',
            headers: {
                'Authorization': 'Bearer ' + getAuthToken()
            },
            success: function (data) {
                $('#formTitle').text('Edit Rate Plan');
                $('#planId').val(data.planId);
                $('#planName').val(data.planName);
                $('#description').val(data.description);
                $('#basePrice').val(data.basePrice);
                $('#cug').prop('checked', data.cug);
                $('#isActive').prop('checked', data.isActive);
                $('#validityDays').val(data.validityDays);

                // Load services
                selectedServices = data.services.map(s => ({
                        serviceId: s.serviceId,
                        serviceName: s.serviceName,
                        serviceType: s.serviceType,
                        includedUnits: s.includedUnits,
                        isUnlimited: s.isUnlimited
                    }));

                updateServicesTable();
            },
            error: function (xhr) {
                showAlert('danger', 'Failed to load rate plan data');
                console.error('Error loading rate plan:', xhr);
            }
        });
    }

    function getAuthToken() {
        return localStorage.getItem('authToken') || '';
    }

    function showAlert(type, message) {
        const alertHtml = `<div class="alert alert-${type} alert-dismissible fade show" role="alert">
    ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>`;
        $('#alertContainer').html(alertHtml);
    }
</script>

<%@ include file="../includes/footer.jsp" %>