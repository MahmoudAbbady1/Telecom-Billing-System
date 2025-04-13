/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.service;
import com.telecom.dao.*;
import com.telecom.model.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.*;
/**
 *
 * @author mibrahim
 */
public class BillingService {
    private final CustomerDAO customerDAO;
    private final CDRDAO cdrDAO;
    private final InvoiceDAO invoiceDAO;
    private final RatePlanDAO ratePlanDAO;
    private final ServiceDAO serviceDAO;
    
    // Tax rate (10% as specified)
    private static final BigDecimal TAX_RATE = new BigDecimal("0.10");
    
    public BillingService() {
        this.customerDAO = new CustomerDAO();
        this.cdrDAO = new CDRDAO();
        this.invoiceDAO = new InvoiceDAO();
        this.ratePlanDAO = new RatePlanDAO();
        this.serviceDAO = new ServiceDAO();
    }
    
    /**
     * Generates invoices for all active customers
     * @throws java.sql.SQLException
     */
    public void generateMonthlyInvoices() throws SQLException {
        List<Customer> activeCustomers = customerDAO.getActiveCustomers(); //>>>>> implement it  getActiveCustomers
        for (Customer customer : activeCustomers) {
            generateInvoiceForCustomer(customer.getCustomerId());
        }
    }
    
    /**
     * Generates an invoice for a specific customer
     * @param customerId
     * @throws java.sql.SQLException
     */
    public void generateInvoiceForCustomer(int customerId) throws SQLException {
        Customer customer = customerDAO.getCustomer(customerId);
        if (customer == null || !"ACTIVE".equals(customer.getStatus())) {
            return;
        }
        
        // Get all unbilled CDRs for this customer
        List<CDR> unbilledCDRs = cdrDAO.getUnbilledCDRsForCustomer(customerId);
        if (unbilledCDRs.isEmpty()) {
            return; // No usage to bill
        }
        
        // Create a new invoice
        Invoice invoice = new Invoice();
        invoice.setCustomerId(customerId);
        invoice.setInvoiceDate(new Date());
        invoice.setDueDate(Date.from(Instant.now().plus(30, ChronoUnit.DAYS)));
        invoice.setStatus("GENERATED");
        
        // Calculate charges
        calculateCharges(invoice, unbilledCDRs);
        
        // Save the invoice
        int invoiceId = invoiceDAO.addInvoice(invoice);
        invoice.setInvoiceId(invoiceId);
        
        // Mark CDRs as processed
        for (CDR cdr : unbilledCDRs) {
            cdr.setProcessed(true);
            cdrDAO.updateCDR(cdr);//>>>>>>>> need to implmrnt
        }
        
        // Generate PDF invoice
        PDFGenerator.generateInvoicePDF(invoice);
    }
    
    /**
     * Calculates all charges for an invoice
     */
    private void calculateCharges(Invoice invoice, List<CDR> cdrs) throws SQLException {
        BigDecimal subtotal = BigDecimal.ZERO;
        List<InvoiceItem> items = new ArrayList<>();
        
        // 1. Add recurring service charges
        List<Service> recurringServices = serviceDAO.getCustomerRecurringServices(invoice.getCustomerId());
        for (Service service : recurringServices) {
            InvoiceItem item = new InvoiceItem();
            item.setDescription(service.getServiceName() + " (Monthly Fee)");
            item.setQuantity(BigDecimal.ONE);
            item.setUnitPrice(BigDecimal.valueOf(service.getMonthlyFee()));
            item.setAmount(BigDecimal.valueOf(service.getMonthlyFee()));
            
            items.add(item);
            subtotal = subtotal.add(item.getAmount());
        }
        
        // 2. Add usage charges from CDRs
        Map<Integer, BigDecimal> serviceUsage = new HashMap<>();
        for (CDR cdr : cdrs) {
            Service service = serviceDAO.getService(cdr.getServiceId());
            if (service != null) {
                BigDecimal usageCharge = calculateUsageCharge(cdr, service);
                serviceUsage.merge(service.getServiceId(), usageCharge, BigDecimal::add);
            }
        }
        
        // Create invoice items for each service type
        for (Map.Entry<Integer, BigDecimal> entry : serviceUsage.entrySet()) {
            Service service = serviceDAO.getService(entry.getKey());
            InvoiceItem item = new InvoiceItem();
            item.setDescription(service.getServiceName() + " Usage");
            item.setQuantity(BigDecimal.ONE); // Actual usage is in the description
            item.setUnitPrice(entry.getValue());
            item.setAmount(entry.getValue());
            
            items.add(item);
            subtotal = subtotal.add(item.getAmount());
        }
        
        // 3. Calculate tax (10%)
        BigDecimal tax = subtotal.multiply(TAX_RATE).setScale(2, RoundingMode.HALF_UP);
        BigDecimal total = subtotal.add(tax);
        
        // Set invoice totals
        invoice.setSubtotal(subtotal);
        invoice.setTax(tax);
        invoice.setTotal(total);
        invoice.setItems(items);
    }
    
    /**
     * Calculates the charge for a single CDR based on service type
     */
    private BigDecimal calculateUsageCharge(CDR cdr, Service service) {
        BigDecimal charge = BigDecimal.ZERO;
        
        switch (service.getServiceType()) {
            case "VOICE":
                // Convert seconds to minutes (round up)
                BigDecimal minutes = BigDecimal.valueOf(Math.ceil(cdr.getQuantity() / 60.0));
                charge = minutes.multiply(BigDecimal.valueOf(service.getRatePerUnit()));
                break;
            case "SMS":
                charge = BigDecimal.valueOf(cdr.getQuantity())
                                 .multiply(BigDecimal.valueOf(service.getRatePerUnit()));
                break;
            case "DATA":
                // Convert bytes to MB
                BigDecimal megabytes = BigDecimal.valueOf(cdr.getQuantity() / (1024.0 * 1024.0));
                charge = megabytes.multiply(BigDecimal.valueOf(service.getRatePerUnit()));
                break;
        }
        
        // Add any external charges
        charge = charge.add(BigDecimal.valueOf(cdr.getExternalCharges()));
        
        return charge.setScale(2, RoundingMode.HALF_UP);
    }
    
    /**
     * Applies a rate plan to a customer
     */
/**
 * Applies a rate plan to a customer
 * @param customerId The ID of the customer
 * @param planId The ID of the rate plan to apply
 * @return true if the rate plan was successfully applied, false otherwise
 * @throws SQLException if there's a database error
 */
public boolean applyRatePlanToCustomer(int customerId, int planId) throws SQLException {
    // 1. Get the customer and rate plan from the database
    Customer customer = customerDAO.getCustomer(customerId);
    RatePlan ratePlan = ratePlanDAO.getRatePlan(planId);
    
    // 2. Validate that both customer and rate plan exist and are active
    if (customer == null || !"ACTIVE".equals(customer.getStatus())) {
        throw new IllegalArgumentException("Customer not found or inactive");
    }
    if (ratePlan == null || !ratePlan.isActive()) {
        throw new IllegalArgumentException("Rate plan not found or inactive");
    }
    
    // 3. Get all services included in this rate plan
    List<Service> planServices = serviceDAO.getServicesByRatePlan(planId);
    if (planServices.isEmpty()) {
        throw new IllegalStateException("Rate plan has no services assigned");
    }
    
    // 4. Remove any existing services not in the new rate plan
    List<Service> currentServices = serviceDAO.getCustomerServices(customerId);
    for (Service existingService : currentServices) {
        if (!planServices.contains(existingService)) {
            serviceDAO.removeCustomerService(customerId, existingService.getServiceId());
        }
    }
    
    // 5. Add any new services from the rate plan
    for (Service newService : planServices) {
        if (!currentServices.contains(newService)) {
            serviceDAO.addCustomerService(customerId, newService.getServiceId(), 
                                         newService.isRecurring(), newService.getMonthlyFee());
        }
    }
    
    // 6. Update customer's rate plan reference
    return customerDAO.updateCustomerRatePlan(customerId, planId);
}
}