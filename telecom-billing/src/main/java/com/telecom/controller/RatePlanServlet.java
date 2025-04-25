package com.telecom.controller;

import com.telecom.dao.RatePlanDAO;
import com.telecom.model.RatePlan;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@Path("/rate-plans")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class RatePlanServlet {
    private static final Logger LOGGER = Logger.getLogger(RatePlanServlet.class.getName());
    private final RatePlanDAO ratePlanDAO;

    public RatePlanServlet() {
        this.ratePlanDAO = new RatePlanDAO();
        LOGGER.info("RatePlanServlet initialized");
    }

    @GET
    public Response getAllRatePlans() {
        try {
            LOGGER.info("Fetching all rate plans");
            List<RatePlan> ratePlans = ratePlanDAO.getAllRatePlans();
            LOGGER.info("Successfully retrieved " + ratePlans.size() + " rate plans");
            return Response.ok(ratePlans).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving rate plans", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving rate plans: " + e.getMessage())
                    .build();
        }
    }

    @GET
    @Path("/{id}")
    public Response getRatePlanById(@PathParam("id") int id) {
        try {
            LOGGER.log(Level.INFO, "Fetching rate plan with ID: {0}", id);
            RatePlan ratePlan = ratePlanDAO.getRatePlanById(id);
            
            if (ratePlan != null) {
                if (ratePlan.getServices() == null) {
                    LOGGER.log(Level.INFO, "Initializing empty services list for plan ID: {0}", id);
                    ratePlan.setServices(new ArrayList<>());
                }
                LOGGER.log(Level.INFO, "Successfully retrieved rate plan ID: {0}", id);
                return Response.ok(ratePlan).build();
            } else {
                LOGGER.log(Level.WARNING, "Rate plan not found with ID: {0}", id);
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Rate plan not found with id: " + id)
                        .build();
            }
        } catch (SQLException e) {
            String errorMsg = "Database error retrieving rate plan: " + e.getMessage();
            LOGGER.log(Level.SEVERE, errorMsg, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(errorMsg)
                    .build();
        } catch (Exception e) {
            String errorMsg = "Unexpected error retrieving rate plan: " + e.getMessage();
            LOGGER.log(Level.SEVERE, errorMsg, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(errorMsg)
                    .build();
        }
    }

    @POST
    public Response createRatePlan(RatePlan ratePlan) {
        try {
            LOGGER.log(Level.INFO, "Creating new rate plan: {0}", ratePlan);
            LOGGER.log(Level.INFO, "Services count: {0}", 
                (ratePlan.getServices() != null ? ratePlan.getServices().size() : 0));

            int planId = ratePlanDAO.addRatePlan(ratePlan);
            ratePlan.setPlanId(planId);
            
            LOGGER.log(Level.INFO, "Successfully created rate plan with ID: {0}", planId);
            return Response.status(Response.Status.CREATED)
                    .entity(ratePlan)
                    .build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error creating rate plan", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error creating rate plan: " + e.getMessage())
                    .build();
        }
    }

    @PUT
    @Path("/{id}")
    public Response updateRatePlan(@PathParam("id") int id, RatePlan ratePlan) {
        try {
            LOGGER.log(Level.INFO, "Updating rate plan ID: {0}", id);
            ratePlan.setPlanId(id);
            ratePlanDAO.updateRatePlan(ratePlan);
            
            LOGGER.log(Level.INFO, "Successfully updated rate plan ID: {0}", id);
            return Response.ok(ratePlan).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating rate plan ID: " + id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error updating rate plan: " + e.getMessage())
                    .build();
        }
    }

    @DELETE
    @Path("/{id}")
    public Response deleteRatePlan(@PathParam("id") int id) {
        try {
            LOGGER.log(Level.INFO, "Deleting rate plan ID: {0}", id);
            ratePlanDAO.deleteRatePlan(id);
            
            LOGGER.log(Level.INFO, "Successfully deleted rate plan ID: {0}", id);
            return Response.noContent().build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting rate plan ID: " + id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error deleting rate plan: " + e.getMessage())
                    .build();
        }
    }

    @GET
    @Path("/counts")
    public Response getRatePlanCounts() {
        try {
            LOGGER.info("Fetching rate plan counts");
            Map<String, Integer> counts = ratePlanDAO.getRatePlanCounts();
            
            LOGGER.info("Successfully retrieved rate plan counts");
            return Response.ok(counts).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving rate plan counts", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving rate plan counts: " + e.getMessage())
                    .build();
        }
    }
}