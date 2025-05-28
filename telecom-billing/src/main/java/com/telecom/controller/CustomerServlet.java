package com.telecom.controller;

import com.telecom.dao.CustomerDAO;
import com.telecom.dao.RatePlanDAO;
import com.telecom.dao.ServicePackageDAO;
import com.telecom.model.Customer;
import com.telecom.model.CustomerDetailsDTO;
import com.telecom.model.RatePlan;
import com.telecom.model.ServicePackage;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
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
    @Path("/{id}")
    public Response getCustomerById(@PathParam("id") int id) {
        try {
            Customer customer = customerDAO.getCustomerById(id);
            if (customer != null) {
                RatePlan ratePlan = ratePlanDAO.getRatePlanWithServices(customer.getPlanId());
                ServicePackage freeUnit = customerDAO.getFreeUnitDetails(customer.getFreeUnitId());
                CustomerDetailsDTO customerDetails = new CustomerDetailsDTO(customer, ratePlan, freeUnit);
                return Response.ok(customerDetails).build();
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

    @GET
    public Response getAllCustomers() {
        try {
            List<Customer> customers = customerDAO.getAllCustomers();
            List<CustomerDetailsDTO> customerDetailsList = new ArrayList<>();
            for (Customer customer : customers) {
                RatePlan ratePlan = ratePlanDAO.getRatePlanWithServices(customer.getPlanId());
                ServicePackage freeUnit = customerDAO.getFreeUnitDetails(customer.getFreeUnitId());
                customerDetailsList.add(new CustomerDetailsDTO(customer, ratePlan, freeUnit));
            }
            return Response.ok(customerDetailsList).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving customers: " + e.getMessage())
                    .build();
        }
    }

    @POST
    public Response createCustomer(Customer customer) {
        try {
            System.out.println("Received customer data: " + customer.toString());
            if (customer.getName() == null || customer.getName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Name is required")
                        .build();
            }
            if (customer.getPhone() == null || customer.getPhone().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Phone is required")
                        .build();
            }
            if (!customer.getPhone().matches("\\+2016\\d{8}")) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Phone number must start with +2016 followed by 8 digits")
                        .build();
            }
            if (customer.getNid() == null || customer.getNid().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("National ID is required")
                        .build();
            }
            if (customer.getOccPrice() > 0 && customer.getMonthsNumberInstallments() <= 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Months number of installments must be positive when OCC price is greater than 0")
                        .build();
            }
            if (customer.getCugNumbers() != null) {
                for (String cugNumber : customer.getCugNumbers()) {
                    if (cugNumber == null || !cugNumber.matches("\\+2016\\d{8}")) {
                        return Response.status(Response.Status.BAD_REQUEST)
                                .entity("Invalid CUG number format: " + cugNumber + ". Must start with +2016 followed by 8 digits.")
                                .build();
                    }
                }
            }
            if (customer.getPromotionPackage() < 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Promotion package value cannot be negative")
                        .build();
            }
            if (customer.getStatus() == null) {
                customer.setStatus("ACTIVE");
            }
            if (customer.getCreditLimit() <= 0) {
                customer.setCreditLimit(0);
            }
            if (customer.getRegistrationDate() == null) {
                customer.setRegistrationDate(new Timestamp(System.currentTimeMillis()));
            }
            if (customer.getFreeUnitId() != null && customer.getFreeUnitId() <= 0) {
                customer.setFreeUnitId(null);
            }
            if (customerDAO.phoneNumberExists(customer.getPhone())) {
                return Response.status(Response.Status.CONFLICT)
                        .entity("Phone number already exists")
                        .build();
            }
            customerDAO.addCustomer(customer);
            return Response.status(Response.Status.CREATED)
                    .entity(customer)
                    .build();
        } catch (SQLException e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Database error: " + e.getMessage())
                    .build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error creating customer: " + e.getMessage())
                    .build();
        }
    }

    @PUT
    @Path("/{id}")
    public Response updateCustomer(@PathParam("id") int id, Customer updateData) {
        try {
            System.out.println("Received updateData: " + updateData.toString());
            Customer existingCustomer = customerDAO.getCustomerById(id);
            if (existingCustomer == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Customer not found with id: " + id)
                        .build();
            }

            Customer customer = new Customer();
            customer.setCustomerId(id);
            customer.setNid(updateData.getNid() != null ? updateData.getNid() : existingCustomer.getNid());
            customer.setName(updateData.getName() != null ? updateData.getName() : existingCustomer.getName());
            customer.setPhone(updateData.getPhone() != null ? updateData.getPhone() : existingCustomer.getPhone());
            customer.setCreditLimit(updateData.getCreditLimit() > 0 ? updateData.getCreditLimit() : existingCustomer.getCreditLimit());
            customer.setEmail(updateData.getEmail() != null ? updateData.getEmail() : existingCustomer.getEmail());
            customer.setAddress(updateData.getAddress() != null ? updateData.getAddress() : existingCustomer.getAddress());
            customer.setStatus(updateData.getStatus() != null ? updateData.getStatus() : existingCustomer.getStatus());
            customer.setRegistrationDate(existingCustomer.getRegistrationDate());
            customer.setPlanId(updateData.getPlanId() > 0 ? updateData.getPlanId() : existingCustomer.getPlanId());
            customer.setFreeUnitId(updateData.getFreeUnitId() != null ? updateData.getFreeUnitId() : existingCustomer.getFreeUnitId());
            customer.setOccName(updateData.getOccName() != null ? updateData.getOccName() : existingCustomer.getOccName());
            customer.setOccPrice(updateData.getOccPrice() >= 0 ? updateData.getOccPrice() : existingCustomer.getOccPrice());
            customer.setMonthsNumberInstallments(updateData.getMonthsNumberInstallments() >= 0 ? updateData.getMonthsNumberInstallments() : existingCustomer.getMonthsNumberInstallments());
            customer.setCugNumbers(updateData.getCugNumbers() != null ? updateData.getCugNumbers() : existingCustomer.getCugNumbers());
            customer.setPromotionPackage(updateData.getPromotionPackage() >= 0 ? updateData.getPromotionPackage() : existingCustomer.getPromotionPackage());
            System.out.println("Constructed customer for update: " + customer.toString());

            // Validation
            if (customer.getName() == null || customer.getName().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Name is required")
                        .build();
            }
            if (customer.getPhone() == null || customer.getPhone().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Phone is required")
                        .build();
            }
            if (!customer.getPhone().matches("\\+2016\\d{8}")) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Phone number must start with +2016 followed by 8 digits")
                        .build();
            }
            if (customer.getNid() == null || customer.getNid().trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("National ID is required")
                        .build();
            }
            if (customer.getOccPrice() > 0 && customer.getMonthsNumberInstallments() <= 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Months number of installments must be positive when OCC price is greater than 0")
                        .build();
            }
            if (customer.getCugNumbers() != null) {
                for (String cugNumber : customer.getCugNumbers()) {
                    if (cugNumber == null || !cugNumber.matches("\\+2016\\d{8}")) {
                        return Response.status(Response.Status.BAD_REQUEST)
                                .entity("Invalid CUG number format: " + cugNumber + ". Must start with +2016 followed by 8 digits.")
                                .build();
                    }
                }
                if (customer.getPlanId() > 0) {
                    RatePlan ratePlan = ratePlanDAO.getRatePlanById(customer.getPlanId());
                    if (ratePlan != null && ratePlan.isCug() && customer.getCugNumbers().length > ratePlan.getMaxCugMembers()) {
                        return Response.status(Response.Status.BAD_REQUEST)
                                .entity("CUG numbers exceed the maximum allowed (" + ratePlan.getMaxCugMembers() + ") for this plan")
                                .build();
                    }
                }
            }

            if (customerDAO.phoneNumberExists(customer.getPhone(), id)) {
                return Response.status(Response.Status.CONFLICT)
                        .entity("Phone number already exists")
                        .build();
            }

            customerDAO.updateCustomer(customer);
            Customer updatedCustomer = customerDAO.getCustomerById(id);
            System.out.println("Updated customer from DB: " + updatedCustomer.toString());
            RatePlan ratePlan = ratePlanDAO.getRatePlanWithServices(updatedCustomer.getPlanId());
            ServicePackage freeUnit = customerDAO.getFreeUnitDetails(updatedCustomer.getFreeUnitId());
            CustomerDetailsDTO customerDetails = new CustomerDetailsDTO(updatedCustomer, ratePlan, freeUnit);
            return Response.ok(customerDetails).build();
        } catch (SQLException e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Database error: " + e.getMessage())
                    .build();
        } catch (Exception e) {
            e.printStackTrace();
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
