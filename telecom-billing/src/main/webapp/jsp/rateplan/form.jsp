<%@ include file="../includes/header.jsp" %>
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
<script src="https://code.jquery.com/ui/1.13.2/jquery-ui.js"></script>
<div class="row mb-4">
    <div class="col-md-6">
        <h3 class="page-header">
            <i class="fas fa-file-invoice-dollar"></i> 
            <span id="formTitle">Create New Rate Plan</span>
        </h3>
    </div>
    <div class="col-md-6 text-end">
        <a href="list.jsp" class="btn btn-secondary">
            <i class="fas fa-arrow-left"></i> Back to List
        </a>
    </div>
</div>

<div id="alertContainer"></div>

<div class="card shadow-sm mb-4">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-info-circle"></i> Plan Information</h5>
    </div>
    <div class="card-body">
        <form id="ratePlanForm">
            <input type="hidden" id="planId" name="planId" value="">

            <div class="row mb-3">
                <div class="col-md-6">
                    <label for="planName" class="form-label">Plan Name <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="planName" name="planName" required
                           maxlength="100" pattern="[A-Za-z0-9 ]+" title="Alphanumeric characters only">
                </div>
                <div class="col-md-6">
                    <label for="monthlyFee" class="form-label">Monthly Fee (EGP) <span class="text-danger">*</span></label>
                    <input type="number" class="form-control" id="monthlyFee" name="monthlyFee" 
                           min="0" step="0.01" max="999999.99" required>
                </div>
            </div>

            <div class="row mb-3">
                <div class="col-md-12">
                    <label for="description" class="form-label">Description</label>
                    <textarea class="form-control" id="description" name="description" rows="3"
                              maxlength="500"></textarea>
                </div>
            </div>

            <div class="row mb-3">
                <div class="col-md-6">
                    <div class="form-check form-switch">
                        <input class="form-check-input" type="checkbox" id="isCug" name="isCug">
                        <label class="form-check-label" for="isCug">Is CUG (Closed User Group) Plan</label>
                    </div>
                </div>
            </div>

            <div id="cugDetails" style="display: none;">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <label for="maxCugMembers" class="form-label">Max CUG Members <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="maxCugMembers" name="maxCugMembers" 
                               min="1" max="1000">
                    </div>
                    <div class="col-md-6">
                        <label for="cugUnit" class="form-label">CUG Unit (Minutes/Texts/MB) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="cugUnit" name="cugUnit" 
                               min="1" max="100000">
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="card shadow-sm mb-4">
    <div class="card-header bg-light">
        <h5 class="card-title mb-0"><i class="fas fa-cubes"></i> Included Services</h5>
    </div>
    <div class="card-body">
        <div class="row mb-3">
            <div class="col-md-6">
                <select id="serviceSelect" class="form-select">
                    <option value="">Select a service to add</option>
                </select>
            </div>
            <div class="col-md-6">
                <button id="addServiceBtn" class="btn btn-primary">
                    <i class="fas fa-plus"></i> Add Service
                </button>
            </div>
        </div>

        <div class="table-responsive">
            <table id="selectedServicesTable" class="table table-striped" style="width:100%">
                <thead>
                    <tr>
                        <th>Service ID</th>
                        <th>Name</th>
                        <th>Type</th>
                        <th>Network Zone</th>
                        <th>Quota</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</div>

<div class="text-center mb-4">
    <button id="saveBtn" class="btn btn-success me-2">
        <i class="fas fa-save"></i> Save Rate Plan
    </button>
    <button id="cancelBtn" class="btn btn-danger">
        <i class="fas fa-times"></i> Cancel
    </button>
</div>

<script>
    $(document).ready(function () {
        const urlParams = new URLSearchParams(window.location.search);
        const planId = urlParams.get('id');
        let isEditMode = !!planId;
        let selectedServices = [];
        let allServices = [];
        const addedServiceIds = new Set();

        // Initialize form based on mode (create/edit)
        if (isEditMode) {
            $('#formTitle').text('Edit Rate Plan');
            loadRatePlan(planId);
        } else {
            $('#formTitle').text('Create New Rate Plan');
        }

        // Load available services
        loadAvailableServices();

        // Toggle CUG details based on checkbox
        $('#isCug').change(function () {
            if ($(this).is(':checked')) {
                $('#cugDetails').show();
                $('#maxCugMembers').prop('required', true);
                $('#cugUnit').prop('required', true);
            } else {
                $('#cugDetails').hide();
                $('#maxCugMembers').prop('required', false);
                $('#cugUnit').prop('required', false);
            }
        });

        // Add service to the plan
        $('#addServiceBtn').click(function () {
            const serviceId = parseInt($('#serviceSelect').val());
            if (!serviceId) {
                showAlert('warning', 'Please select a service to add');
                return;
            }

            if (addedServiceIds.has(serviceId)) {
                showAlert('warning', 'This service has already been added');
                return;
            }

            const service = allServices.find(s => s.serviceId === serviceId);
            if (service) {
                selectedServices.push(service);
                addedServiceIds.add(serviceId);
                refreshSelectedServicesTable();
                $('#serviceSelect').val('');
            }
        });

        // Remove service from the plan
        $(document).on('click', '.remove-service-btn', function () {
            const serviceId = parseInt($(this).data('service-id'));
            selectedServices = selectedServices.filter(s => s.serviceId !== serviceId);
            addedServiceIds.delete(serviceId);
            refreshSelectedServicesTable();
        });

        // Save rate plan
        $('#saveBtn').click(function () {
            if (!validateForm())
                return;

            const requestData = {
                planName: $('#planName').val(),
                description: $('#description').val(),
                monthlyFee: parseFloat($('#monthlyFee').val()).toFixed(2),
                isCug: $('#isCug').is(':checked'),
                maxCugMembers: $('#isCug').is(':checked') ? parseInt($('#maxCugMembers').val()) : 0,
                cugUnit: $('#isCug').is(':checked') ? parseInt($('#cugUnit').val()) : 0,
                serviceIds: selectedServices.map(s => s.serviceId)
            };

            console.log("Sending data:", JSON.stringify(requestData, null, 2));

            if (isEditMode) {
                updateRatePlan(requestData);
            } else {
                createRatePlan(requestData);
            }
        });

        // Cancel button
        $('#cancelBtn').click(function () {
            window.location.href = 'list.jsp';
        });

        // Initialize selected services table
        const servicesTable = $('#selectedServicesTable').DataTable({
            responsive: true,
            searching: false,
            paging: false,
            info: false,
            autoWidth: false,
            columns: [
                {data: 'serviceId'},
                {data: 'serviceName'},
                {data: 'serviceType'},
                {data: 'serviceNetworkZone'},
                {
                    data: null,
                    render: function (data) {
                        return data.qouta + ' ' + (data.unitDescription || '');
                    }
                },
                {
                    data: null,
                    render: function (data) {
                        return `<button class="btn btn-sm btn-danger remove-service-btn" 
                                data-service-id="${data.serviceId}">
                                <i class="fas fa-trash-alt"></i> Remove
                                </button>`;
                    },
                    orderable: false
                }
            ],
            createdRow: function (row, data, dataIndex) {
                $(row).attr('data-service-id', data.serviceId);
            }
        });

        function refreshSelectedServicesTable() {
            servicesTable.clear().rows.add(selectedServices).draw();

            if (selectedServices.length > 0) {
                $('#selectedServicesTable').closest('.table-responsive').show();
            } else {
                $('#selectedServicesTable').closest('.table-responsive').hide();
            }
        }

        function loadRatePlan(planId) {
            $.ajax({
                url: '${pageContext.request.contextPath}/api/rate-plans/' + planId,
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function (data) {
                    $('#planId').val(data.planId);
                    $('#planName').val(data.planName);
                    $('#description').val(data.description || '');
                    $('#monthlyFee').val(parseFloat(data.monthlyFee).toFixed(2));

                    if (data.isCug) {
                        $('#isCug').prop('checked', true).trigger('change');
                        $('#maxCugMembers').val(data.maxCugMembers);
                        $('#cugUnit').val(data.cugUnit);
                    }

                    // Load services for this plan
                    $.ajax({
                        url: '${pageContext.request.contextPath}/api/rate-plans/' + planId + '/services',
                        method: 'GET',
                        headers: {
                            'Authorization': 'Bearer ' + getAuthToken()
                        },
                        success: function (services) {
                            selectedServices = services;
                            services.forEach(s => addedServiceIds.add(s.serviceId));
                            refreshSelectedServicesTable();
                        },
                        error: function (xhr) {
                            handleApiError(xhr);
                        }
                    });
                },
                error: function (xhr) {
                    handleApiError(xhr);
                }
            });
        }

        function loadAvailableServices() {
            $('#serviceSelect').prop('disabled', true).html('<option value="">Loading services...</option>');

            $.ajax({
                url: '${pageContext.request.contextPath}/api/rate-plans/services/available',
                method: 'GET',
                headers: {
                    'Authorization': 'Bearer ' + getAuthToken()
                },
                success: function (services) {
                    allServices = services;
                    const select = $('#serviceSelect');
                    select.empty().append('<option value="">Select a service to add</option>');

                    services.forEach(service => {
                        select.append(new Option(
                                service.serviceName + ' (' + service.serviceType + ')',
                                service.serviceId
                                ));
                    });

                    select.prop('disabled', false);
                },
                error: function (xhr) {
                    handleApiError(xhr);
                    $('#serviceSelect').prop('disabled', false)
                            .html('<option value="">Error loading services</option>');
                }
            });
        }






        function createRatePlan(ratePlanData) {
    $('#saveBtn').prop('disabled', true)
        .html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...');

    $.ajax({
        url: '${pageContext.request.contextPath}/api/rate-plans',
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(ratePlanData),
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function (data) {
            showAlert('success', 'Rate plan created successfully!');
            setTimeout(() => {
                window.location.href = 'view.jsp?id=' + data.planId;
            }, 1500);
        },
        error: function (xhr) {
            $('#saveBtn').prop('disabled', false)
                .html('<i class="fas fa-save"></i> Save Rate Plan');
            handleApiError(xhr);
        }
    });
}














function updateRatePlan(ratePlanData) {
    $('#saveBtn').prop('disabled', true)
        .html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...');

    const planId = parseInt($('#planId').val()); // Get planId from form, not payload
    $.ajax({
        url: '${pageContext.request.contextPath}/api/rate-plans/' + planId,
        method: 'PUT',
        contentType: 'application/json',
        data: JSON.stringify({
            planName: ratePlanData.planName,
            description: ratePlanData.description,
            monthlyFee: parseFloat(ratePlanData.monthlyFee), // Ensure number, not string
            isCug: ratePlanData.isCug,
            maxCugMembers: ratePlanData.maxCugMembers,
            cugUnit: ratePlanData.cugUnit,
            serviceIds: ratePlanData.serviceIds
        }),
        headers: {
            'Authorization': 'Bearer ' + getAuthToken()
        },
        success: function (data) {
            showAlert('success', 'Rate plan updated successfully!');
            setTimeout(() => {
                window.location.href = 'view.jsp?id=' + data.planId;
            }, 1500);
        },
        error: function (xhr) {
            $('#saveBtn').prop('disabled', false)
                .html('<i class="fas fa-save"></i> Save Rate Plan');
            handleApiError(xhr);
        }
    });
}
        function validateForm() {
            const form = document.getElementById('ratePlanForm');
            if (!form.checkValidity()) {
                form.reportValidity();
                return false;
            }

            if ($('#isCug').is(':checked')) {
                if (!$('#maxCugMembers').val() || $('#maxCugMembers').val() <= 0) {
                    showAlert('danger', 'Please enter a valid max CUG members value (greater than 0)');
                    return false;
                }

                if (!$('#cugUnit').val() || $('#cugUnit').val() <= 0) {
                    showAlert('danger', 'Please enter a valid CUG unit value (greater than 0)');
                    return false;
                }
            }

            if (selectedServices.length === 0) {
                showAlert('warning', 'Please add at least one service to the rate plan');
                return false;
            }

            return true;
        }

        function getAuthToken() {
            return localStorage.getItem('authToken') || '';
        }

        function handleApiError(xhr) {
            console.error('API Error:', xhr);
            let message = 'An error occurred';

            if (xhr.status === 403) {
                message = 'Your session has expired. Please login again.';
                clearAuthTokens();
                setTimeout(function () {
                    window.location.href = '${pageContext.request.contextPath}/login.jsp';
                }, 2000);
            } else if (xhr.status === 400) {
                // Try to parse the response for more detailed error message
                try {
                    const response = JSON.parse(xhr.responseText);
                    message = 'Validation error: ' + (response.message || xhr.responseText || 'Invalid data');
                } catch (e) {
                    message = 'Validation error: ' + (xhr.responseText || 'Invalid data');
                }
            } else if (xhr.status === 404) {
                message = 'Resource not found';
            } else if (xhr.status === 500) {
                message = 'Server error: ' + (xhr.responseJSON?.message || xhr.statusText);
            }

            showAlert('danger', message);
        }

        function clearAuthTokens() {
            localStorage.removeItem('authToken');
            document.cookie = 'authToken=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
        }

        function showAlert(type, message) {
            const alertId = 'alert-' + Date.now();
            const alertHtml = `
                <div id="${alertId}" class="alert alert-${type} alert-dismissible fade show" role="alert">
    ${message}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>`;

            $('#alertContainer').html(alertHtml);

            if (type !== 'danger') {
                setTimeout(() => $(`#${alertId}`).alert('close'), 5000);
            }
        }
    });
</script>

<%@ include file="../includes/footer.jsp" %>