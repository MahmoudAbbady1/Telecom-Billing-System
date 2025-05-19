package com.telecom.controller;

import com.telecom.dao.CustomerDAO;
import com.telecom.dao.RatePlanDAO;
import com.telecom.dao.ServicePackageDAO;
import com.telecom.model.Customer;
import com.telecom.model.RatePlan;
import com.telecom.model.ServicePackage;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Path("/customers")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class CustomerServlet {
    private CustomerDAO customerDAO;
    private ServicePackageDAO servicePackageDAO;
    private RatePlanDAO ratePlanDAO;

    public CustomerServlet() {
        customerDAO = new CustomerDAO();
        servicePackageDAO = new ServicePackageDAO();
        ratePlanDAO = new RatePlanDAO();
    }

    @GET
    public Response getAllCustomers() {
        try {
            List<Customer> customers = customerDAO.getAllCustomers();
            return Response.ok(customers).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving customers: " + e.getMessage())
                    .build();
        }
    }

    @GET
    @Path("/{id}")
    public Response getCustomerById(@PathParam("id") int id) {
        try {
            Customer customer = customerDAO.getCustomerById(id);
            if (customer != null) {
                return Response.ok(customer).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Customer not found with id: " + id)
                        .build();
            }
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving customer: " + e.getMessage())
                    .build();
        }
    }

    @POST
    public Response createCustomer(Customer customer) {
        try {
            // Validate required fields
            if (customer.getName() == null || customer.getName().trim().isEmpty() ||
                customer.getPhone() == null || customer.getPhone().trim().isEmpty() ||
                customer.getNid() == null || customer.getNid().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Name, phone, and NID are required fields")
                        .build();
            }

            // Validate status
            if (customer.getStatus() == null || !Arrays.asList("ACTIVE", "INACTIVE", "SUSPENDED")
                    .contains(customer.getStatus().toUpperCase())) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Invalid status value. Must be ACTIVE, INACTIVE, or SUSPENDED")
                        .build();
            }

            // Check for duplicate phone
            if (customerDAO.phoneNumberExists(customer.getPhone())) {
                return Response.status(Response.Status.CONFLICT)
                        .entity("Phone number already exists")
                        .build();
            }

            // Set default registration date if null
            if (customer.getRegistrationDate() == null) {
                customer.setRegistrationDate(new java.sql.Timestamp(System.currentTimeMillis()));
            }

            customerDAO.addCustomer(customer);
            return Response.status(Response.Status.CREATED)
                    .entity(customer)
                    .build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error creating customer: " + e.getMessage())
                    .build();
        }
    }

    @PUT
    @Path("/{id}")
    public Response updateCustomer(@PathParam("id") int id, Customer customer) {
        try {
            customer.setCustomerId(id);
            
            // Validate required fields
            if (customer.getName() == null || customer.getName().trim().isEmpty() ||
                customer.getPhone() == null || customer.getPhone().trim().isEmpty() ||
                customer.getNid() == null || customer.getNid().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Name, phone, and NID are required fields")
                        .build();
            }

            // Validate status
            if (customer.getStatus() == null || !Arrays.asList("ACTIVE", "INACTIVE", "SUSPENDED")
                    .contains(customer.getStatus().toUpperCase())) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Invalid status value. Must be ACTIVE, INACTIVE, or SUSPENDED")
                        .build();
            }

            // Check for duplicate phone excluding current customer
            if (customerDAO.phoneNumberExists(customer.getPhone(), id)) {
                return Response.status(Response.Status.CONFLICT)
                        .entity("Phone number already exists for another customer")
                        .build();
            }

            customerDAO.updateCustomer(customer);
            return Response.ok(customer).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error updating customer: " + e.getMessage())
                    .build();
        }
    }

    @DELETE
    @Path("/{id}")
    public Response deleteCustomer(@PathParam("id") int id) {
        try {
            customerDAO.deleteCustomer(id);
            return Response.noContent().build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error deleting customer: " + e.getMessage())
                    .build();
        }
    }

    @GET
    @Path("/free-unit-options")
    public Response getFreeUnitOptions() {
        try {
            List<ServicePackage> freeUnits = servicePackageDAO.getFreeUnitOptions();
            return Response.ok(freeUnits).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving free unit options: " + e.getMessage())
                    .build();
        }
    }

    @GET
    @Path("/rate-plan-options")
    public Response getRatePlanOptions() {
        try {
            List<RatePlan> ratePlans = ratePlanDAO.getAllRatePlans();
            return Response.ok(ratePlans).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving rate plan options: " + e.getMessage())
                    .build();
        }
    }

    @GET
    @Path("/search")
    public Response searchCustomers(
            @QueryParam("query") String query,
            @QueryParam("status") String status) {
        try {
            List<Customer> customers = customerDAO.searchCustomers(query, status);
            return Response.ok(customers).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error searching customers: " + e.getMessage())
                    .build();
        }
    }

    @GET
    @Path("/stats")
    public Response getCustomerStats() {
        try {
            Map<String, Integer> stats = customerDAO.getCustomerStats();
            return Response.ok(stats).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving customer stats: " + e.getMessage())
                    .build();
        }
    }

    @GET
    @Path("/check-phone")
    public Response checkPhoneNumber(
            @QueryParam("phone") String phone,
            @QueryParam("excludeId") Integer excludeId) {
        try {
            boolean exists;
            if (excludeId != null) {
                exists = customerDAO.phoneNumberExists(phone, excludeId);
            } else {
                exists = customerDAO.phoneNumberExists(phone);
            }
            return Response.ok().entity(exists).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error checking phone number: " + e.getMessage())
                    .build();
        }
    }
}