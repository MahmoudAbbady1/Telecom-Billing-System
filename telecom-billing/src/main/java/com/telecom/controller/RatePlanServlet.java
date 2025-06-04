package com.telecom.controller;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.telecom.dao.RatePlanDAO;
import com.telecom.dao.ServicePackageDAO;
import com.telecom.model.RatePlan;
import com.telecom.model.ServicePackage;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.math.BigDecimal;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Path("/rate-plans")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class RatePlanServlet {
    private static final Logger LOGGER = Logger.getLogger(RatePlanServlet.class.getName());
    private final RatePlanDAO ratePlanDAO;
    private final ServicePackageDAO servicePackageDAO;

    public RatePlanServlet() {
        this.ratePlanDAO = new RatePlanDAO();
        this.servicePackageDAO = new ServicePackageDAO();
    }

    @GET
    public Response getAllRatePlans() {
        try {
            List<RatePlan> ratePlans = ratePlanDAO.getAllRatePlansWithServices();
            return Response.ok(ratePlans).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving rate plans", e);
            return errorResponse("Error retrieving rate plans", e);
        }
    }

    @GET
    @Path("/counts")
    public Response getRatePlanCounts() {
        try {
            Map<String, Integer> counts = new HashMap<>();
            counts.put("totalCount", ratePlanDAO.getTotalRatePlansCount());
            counts.put("cugCount", ratePlanDAO.getCugRatePlansCount());
            counts.put("nonCugCount", ratePlanDAO.getNonCugRatePlansCount());
            return Response.ok(counts).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving rate plan counts", e);
            return errorResponse("Error retrieving rate plan counts", e);
        }
    }

    @GET
    @Path("/{id}")
    public Response getRatePlanById(@PathParam("id") int id) {
        try {
            RatePlan ratePlan = ratePlanDAO.getRatePlanWithServices(id);
            if (ratePlan != null) {
                return Response.ok(ratePlan).build();
            }
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Rate plan not found with id: " + id)
                    .build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving rate plan", e);
            return errorResponse("Error retrieving rate plan", e);
        }
    }

    @POST
    public Response createRatePlan(RatePlanRequest request) {
        try {
            Response validationResponse = validateRatePlanRequest(request);
            if (validationResponse != null) return validationResponse;

            RatePlan ratePlan = new RatePlan();
            ratePlan.setPlanName(request.getPlanName());
            ratePlan.setDescription(request.getDescription());
            ratePlan.setMonthlyFee(request.getMonthlyFee());
            ratePlan.setCug(request.isCug());
            ratePlan.setMaxCugMembers(request.isCug() ? request.getMaxCugMembers() : 0);
            ratePlan.setCugUnit(request.isCug() ? request.getCugUnit() : 0);

            int planId = ratePlanDAO.addRatePlan(ratePlan);
            
            if (request.getServiceIds() != null && !request.getServiceIds().isEmpty()) {
                addServicesToRatePlan(planId, request.getServiceIds());
            }

            RatePlan createdPlan = ratePlanDAO.getRatePlanWithServices(planId);
            return Response.status(Response.Status.CREATED).entity(createdPlan).build();
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating rate plan", e);
            return errorResponse("Error creating rate plan", e);
        }
    }

    @PUT
    @Path("/{id}")
    public Response updateRatePlan(@PathParam("id") int id, RatePlanRequest request) {
        try {
            RatePlan existing = ratePlanDAO.getRatePlanById(id);
            if (existing == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Rate plan not found with id: " + id)
                        .build();
            }

            Response validationResponse = validateRatePlanRequest(request);
            if (validationResponse != null) return validationResponse;

            RatePlan ratePlan = new RatePlan();
            ratePlan.setPlanId(id);
            ratePlan.setPlanName(request.getPlanName());
            ratePlan.setDescription(request.getDescription());
            ratePlan.setMonthlyFee(request.getMonthlyFee());
            ratePlan.setCug(request.isCug());
            ratePlan.setMaxCugMembers(request.isCug() ? request.getMaxCugMembers() : 0);
            ratePlan.setCugUnit(request.isCug() ? request.getCugUnit() : 0);

            ratePlanDAO.updateRatePlan(ratePlan);

            ratePlanDAO.removeAllServicesFromRatePlan(id);
            if (request.getServiceIds() != null && !request.getServiceIds().isEmpty()) {
                addServicesToRatePlan(id, request.getServiceIds());
            }

            RatePlan updatedPlan = ratePlanDAO.getRatePlanWithServices(id);
            return Response.ok(updatedPlan).build();
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating rate plan", e);
            return errorResponse("Error updating rate plan", e);
        }
    }

    @DELETE
    @Path("/{id}")
    public Response deleteRatePlan(@PathParam("id") int id) {
        try {
            ratePlanDAO.deleteRatePlan(id);
            return Response.noContent().build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting rate plan", e);
            return errorResponse("Error deleting rate plan", e);
        }
    }

    @GET
    @Path("/services/available")
    public Response getAvailableServices() {
        try {
            List<ServicePackage> services = servicePackageDAO.getAllServicePackages();
            return Response.ok(services).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving available services", e);
            return errorResponse("Error retrieving services", e);
        }
    }

    @GET
    @Path("/{planId}/services")
    public Response getServicesForRatePlan(@PathParam("planId") int planId) {
        try {
            List<ServicePackage> services = ratePlanDAO.getServicesForRatePlan(planId);
            return Response.ok(services).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving services for rate plan", e);
            return errorResponse("Error retrieving services", e);
        }
    }

    private Response validateRatePlanRequest(RatePlanRequest request) {
        if (request.getPlanName() == null || request.getPlanName().trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("Plan name is required")
                    .build();
        }

        if (request.getMonthlyFee() == null || request.getMonthlyFee().compareTo(BigDecimal.ZERO) < 0) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("Valid monthly fee is required")
                    .build();
        }

        if (request.isCug()) {
            if (request.getMaxCugMembers() <= 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Max CUG members must be greater than 0 for CUG plans")
                        .build();
            }
            if (request.getCugUnit() <= 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("CUG unit must be greater than 0 for CUG plans")
                        .build();
            }
        }
        return null;
    }

    private void addServicesToRatePlan(int planId, List<Integer> serviceIds) throws Exception {
        List<ServicePackage> validServices = servicePackageDAO.getAllServicePackages();
        Set<Integer> validServiceIds = validServices.stream()
                .map(ServicePackage::getServiceId)
                .collect(Collectors.toSet());

        for (int serviceId : serviceIds) {
            if (validServiceIds.contains(serviceId)) {
                try {
                    ratePlanDAO.addServiceToRatePlan(planId, serviceId);
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Failed to add service: " + serviceId, e);
                }
            } else {
                LOGGER.log(Level.WARNING, "Invalid service ID: " + serviceId);
            }
        }
    }

    private Response errorResponse(String message, Exception e) {
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(message + ": " + e.getMessage())
                .build();
    }

    public static class RatePlanRequest {
        private String planName;
        private String description;
        private BigDecimal monthlyFee;
        
        @JsonProperty("isCug")
        private boolean cug;
        private int maxCugMembers;
        private int cugUnit;
        private List<Integer> serviceIds;

        public String getPlanName() { return planName; }
        public void setPlanName(String planName) { this.planName = planName; }
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        public BigDecimal getMonthlyFee() { return monthlyFee; }
        public void setMonthlyFee(BigDecimal monthlyFee) { this.monthlyFee = monthlyFee; }
        public boolean isCug() { return cug; }
        public void setCug(boolean cug) { this.cug = cug; }
        public int getMaxCugMembers() { return maxCugMembers; }
        public void setMaxCugMembers(int maxCugMembers) { this.maxCugMembers = maxCugMembers; }
        public int getCugUnit() { return cugUnit; }
        public void setCugUnit(int cugUnit) { this.cugUnit = cugUnit; }
        public List<Integer> getServiceIds() { return serviceIds; }
        public void setServiceIds(List<Integer> serviceIds) { this.serviceIds = serviceIds; }
    }
}