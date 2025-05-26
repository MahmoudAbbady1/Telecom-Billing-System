package com.telecom.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.telecom.dao.ServicePackageDAO;
import com.telecom.model.ServicePackage;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/service-packages")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ServicePackageServlet {
    private static final Logger LOGGER = Logger.getLogger(ServicePackageServlet.class.getName());
    private final ServicePackageDAO servicePackageDAO;

    public ServicePackageServlet() {
        this.servicePackageDAO = new ServicePackageDAO();
    }

    @GET
    public Response getAllServicePackages() {
        try {
            List<ServicePackage> packages = servicePackageDAO.getAllServicePackagesAndFreeUnit();
            return Response.ok(packages).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting all service packages", e);
            return Response.serverError().entity(Map.of("message", "Error retrieving service packages")).build();
        }
    }

    @GET
    @Path("/{id}")
    public Response getServicePackageById(@PathParam("id") int id) {
        try {
            ServicePackage servicePackage = servicePackageDAO.getServicePackageById(id);
            if (servicePackage != null) {
                return Response.ok(servicePackage).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity(Map.of("message", "Service package not found"))
                        .build();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting service package by ID: " + id, e);
            return Response.serverError().entity(Map.of("message", "Error retrieving service package")).build();
        }
    }

    @POST
    public Response createServicePackage(String jsonPayload) {
        try {
            LOGGER.log(Level.INFO, "Received payload: {0}", jsonPayload);
            
            ObjectMapper mapper = new ObjectMapper();
            ServicePackage servicePackage = mapper.readValue(jsonPayload, ServicePackage.class);
            
            // Validate required fields
            if (servicePackage.getServiceName() == null || servicePackage.getServiceName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("message", "Service name is required"))
                        .build();
            }
            
            if (servicePackage.getServiceType() == null || 
                !Arrays.asList("VOICE", "SMS", "DATA").contains(servicePackage.getServiceType())) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("message", "Valid service type is required (VOICE, SMS, DATA)"))
                        .build();
            }
            
            if (servicePackage.getServiceNetworkZone() == null || 
                !Arrays.asList("NET", "CROSS", "ROAMING").contains(servicePackage.getServiceNetworkZone())) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("message", "Valid network zone is required (NET, CROSS, ROAMING)"))
                        .build();
            }
            
            if (servicePackage.getQouta() < 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("message", "Quota must be a positive number"))
                        .build();
            }

            // Set default values if null
            if (servicePackage.getFreeUnitMonthlyFee() == null) {
                servicePackage.setFreeUnitMonthlyFee(BigDecimal.ZERO);
            }

            // Additional validation for free units
            if (servicePackage.isFreeUnite() && 
                servicePackage.getFreeUnitMonthlyFee().compareTo(BigDecimal.ZERO) <= 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("message", "Free unit packages must have a positive monthly fee"))
                        .build();
            }

            // Add to database
            servicePackageDAO.addServicePackage(servicePackage);
            
            return Response.status(Response.Status.CREATED)
                    .entity(servicePackage)
                    .build();
            
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Invalid JSON format", e);
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("message", "Invalid JSON format"))
                    .build();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error creating service package", e);
            return Response.serverError()
                    .entity(Map.of("message", "Database error: " + e.getMessage()))
                    .build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Unexpected error creating service package", e);
            return Response.serverError()
                    .entity(Map.of("message", "Unexpected error: " + e.getMessage()))
                    .build();
        }
    }

    @PUT
    @Path("/{id}")
    public Response updateServicePackage(@PathParam("id") int id, String jsonPayload) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            ServicePackage servicePackage = mapper.readValue(jsonPayload, ServicePackage.class);
            servicePackage.setServiceId(id);
            
            // Validate the existing package
            ServicePackage existing = servicePackageDAO.getServicePackageById(id);
            if (existing == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity(Map.of("message", "Service package not found"))
                        .build();
            }

            // Perform validations
            if (servicePackage.getServiceName() == null || servicePackage.getServiceName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity(Map.of("message", "Service name is required"))
                        .build();
            }
            
            // ... (same validations as in create method)

            servicePackageDAO.updateServicePackage(servicePackage);
            return Response.ok(servicePackage).build();
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error updating service package", e);
            return Response.serverError()
                    .entity(Map.of("message", "Error updating service package"))
                    .build();
        }
    }

    @DELETE
    @Path("/{id}")
    public Response deleteServicePackage(@PathParam("id") int id) {
        try {
            servicePackageDAO.deleteServicePackage(id);
            return Response.noContent().build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting service package", e);
            return Response.serverError()
                    .entity(Map.of("message", "Error deleting service package"))
                    .build();
        }
    }

    @GET
    @Path("/counts")
    public Response getServicePackageCounts() {
        try {
            Map<String, Integer> counts = servicePackageDAO.getServicePackageCountsByType();
            return Response.ok(counts).build();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting package counts", e);
            return Response.serverError()
                    .entity(Map.of("message", "Error retrieving package counts"))
                    .build();
        }
    }
}