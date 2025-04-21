package com.telecom.controller;

import com.telecom.dao.ServicePackageDAO;
import com.telecom.model.ServicePackage;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Path("/service-packages")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class ServicePackageServlet {
    private ServicePackageDAO servicePackageDAO;

    public ServicePackageServlet() {
        servicePackageDAO = new ServicePackageDAO();
    }

    @GET
    public Response getAllServicePackages() {
        try {
            List<ServicePackage> packages = servicePackageDAO.getAllServicePackages();
            return Response.ok(packages).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving service packages: " + e.getMessage())
                    .build();
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
                        .entity("Service package not found with id: " + id)
                        .build();
            }
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving service package: " + e.getMessage())
                    .build();
        }
    }

    @POST
    public Response createServicePackage(ServicePackage servicePackage) {
        try {
            servicePackageDAO.addServicePackage(servicePackage);
            return Response.status(Response.Status.CREATED)
                    .entity(servicePackage)
                    .build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error creating service package: " + e.getMessage())
                    .build();
        }
    }

    @PUT
    @Path("/{id}")
    public Response updateServicePackage(@PathParam("id") int id, ServicePackage servicePackage) {
        try {
            servicePackage.setServiceId(id);
            servicePackageDAO.updateServicePackage(servicePackage);
            return Response.ok(servicePackage).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error updating service package: " + e.getMessage())
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
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error deleting service package: " + e.getMessage())
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
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity("Error retrieving package counts: " + e.getMessage())
                .build();
    }
}
}