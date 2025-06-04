package com.telecom.controller;

import com.telecom.dao.CustomerDAO;
import com.telecom.dao.InvoiceDAO;
import com.telecom.dao.RatePlanDAO;
import com.telecom.dao.ServicePackageDAO;
import com.telecom.model.Customer;
import com.telecom.model.CustomerDetailsDTO;
import com.telecom.model.Invoice;
import com.telecom.model.InvoiceDetailsDTO;
import com.telecom.model.RatePlan;
import com.telecom.model.ServicePackage;
import java.math.BigDecimal;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Path("/invoices")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class InvoiceServlet {

    private final CustomerDAO customerDAO;
    private final RatePlanDAO ratePlanDAO;
    private final ServicePackageDAO servicePackageDAO;
    private final InvoiceDAO invoiceDAO;

    public InvoiceServlet() {
        this.customerDAO = new CustomerDAO();
        this.ratePlanDAO = new RatePlanDAO();
        this.servicePackageDAO = new ServicePackageDAO();
        this.invoiceDAO = new InvoiceDAO();
    }

    // Existing endpoint for single customer invoice
    @POST
    public Response createInvoice(@QueryParam("customerId") int customerId) {
        try {
            if (customerId <= 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Invalid customer ID")
                        .build();
            }

            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer == null) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("Customer not found with ID: " + customerId)
                        .build();
            }

            RatePlan ratePlan = ratePlanDAO.getRatePlanWithServices(customer.getPlanId());
            if (ratePlan == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("Rate plan not found for customer ID: " + customerId)
                        .build();
            }

            ServicePackage freeUnit = customerDAO.getFreeUnitDetails(customer.getFreeUnitId());
            CustomerDetailsDTO customerDetails = new CustomerDetailsDTO(customer, ratePlan, freeUnit);
            // Pass empty CSV content for single invoice (fallback to zero usage)
            invoiceDAO.createInvoice(customerDetails, "");

            return Response.status(Response.Status.CREATED)
                    .entity("Invoice created successfully for customer ID: " + customerId)
                    .build();
        } catch (SQLException e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Database error: " + e.getMessage())
                    .build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error creating invoice: " + e.getMessage())
                    .build();
        }
    }

    // Updated endpoint to process invoices for specific customers with CSV content
    @POST
    @Path("/process-all")
    public Response processAllInvoices(Map<String, String> customerCsvMap) {
        try {
            if (customerCsvMap == null || customerCsvMap.isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("No customer IDs or CSV content provided")
                        .build();
            }

            int successCount = 0;
            int failureCount = 0;

            for (Map.Entry<String, String> entry : customerCsvMap.entrySet()) {
                try {
                    int customerId = Integer.parseInt(entry.getKey());
                    String csvContent = entry.getValue();

                    Customer customer = customerDAO.getCustomerById(customerId);
                    if (customer == null) {
                        failureCount++;
                        System.out.println("Customer not found for ID: " + customerId);
                        continue;
                    }

                    RatePlan ratePlan = ratePlanDAO.getRatePlanWithServices(customer.getPlanId());
                    if (ratePlan == null) {
                        failureCount++;
                        System.out.println("Rate plan not found for customer ID: " + customerId);
                        continue;
                    }

                    ServicePackage freeUnit = customerDAO.getFreeUnitDetails(customer.getFreeUnitId());
                    CustomerDetailsDTO customerDetails = new CustomerDetailsDTO(customer, ratePlan, freeUnit);
                    invoiceDAO.createInvoice(customerDetails, csvContent);
                    successCount++;
                } catch (SQLException e) {
                    failureCount++;
                    System.out.println("Error creating invoice for customer ID: " + entry.getKey() + ": " + e.getMessage());
                } catch (NumberFormatException e) {
                    failureCount++;
                    System.out.println("Invalid customer ID format: " + entry.getKey());
                }
            }

            String responseMessage = String.format("Processed invoices: %d successful, %d failed", successCount, failureCount);
            return Response.status(Response.Status.OK)
                    .entity(responseMessage)
                    .build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error processing invoices: " + e.getMessage())
                    .build();
        }
    }

    @DELETE
    public Response deleteAllInvoices() {
        try {
            invoiceDAO.deleteAllInvoices();
            return Response.status(Response.Status.OK)
                    .entity("All invoices deleted successfully")
                    .build();
        } catch (SQLException e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error deleting invoices: " + e.getMessage())
                    .build();
        }
    }

    @GET
    public Response getAllInvoicesWithCustomerName() {
        try {
            List<Invoice> invoices = invoiceDAO.getAllInvoicesWithCustomerName();
            return Response.status(Response.Status.OK)
                    .entity(invoices)
                    .build();
        } catch (SQLException e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving invoices: " + e.getMessage())
                    .build();
        }
    }
@GET
@Path("/{id}")
@Produces(MediaType.APPLICATION_JSON)
public Response getInvoiceById(@PathParam("id") String invoiceId) {
    try {
        Invoice invoice = invoiceDAO.getInvoiceById(invoiceId);
        if (invoice == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Invoice not found with ID: " + invoiceId)
                    .build();
        }

        Customer customer = customerDAO.getCustomerById(invoice.getCustomerId());
        if (customer == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("Customer not found for invoice ID: " + invoiceId)
                    .build();
        }

        // Use getRatePlanWithServices to get the full rate plan with service packages
        RatePlan ratePlan = ratePlanDAO.getRatePlanWithServices(customer.getPlanId());
        
        // Get the free unit details
        ServicePackage freeUnit = customerDAO.getFreeUnitDetails(customer.getFreeUnitId());

        InvoiceDetailsDTO dto = new InvoiceDetailsDTO(invoice, customer, ratePlan, freeUnit);
        return Response.ok(dto).build();

    } catch (Exception e) {
        e.printStackTrace();
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity("Error retrieving invoice: " + e.getMessage())
                .build();
    }
}


@GET
@Path("/all")
    public Response getAllInvoicesWithDetails() {
        try {
            List<InvoiceDetailsDTO> invoices = invoiceDAO.getAllInvoicesWithDetails();
            return Response.status(Response.Status.OK)
                    .entity(invoices)
                    .build();
        } catch (SQLException e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("Error retrieving invoices: " + e.getMessage())
                    .build();
        }
    }
@GET
@Path("/total-revenue")
public Response getTotalRevenue() {
    try {
        BigDecimal totalRevenue = invoiceDAO.getTotalRevenue();
        return Response.status(Response.Status.OK)
                .entity(totalRevenue)
                .build();
    } catch (SQLException e) {
        e.printStackTrace();
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity("Error calculating total revenue: " + e.getMessage())
                .build();
    }
}
}
