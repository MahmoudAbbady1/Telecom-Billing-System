package com.telecom.model;

public class InvoiceDetailsDTO {
    private Invoice invoice;
    private Customer customer;
    private RatePlan ratePlan;
    private ServicePackage freeUnit;

    public InvoiceDetailsDTO() {}

    public InvoiceDetailsDTO(Invoice invoice, Customer customer, RatePlan ratePlan, ServicePackage freeUnit) {
        this.invoice = invoice;
        this.customer = customer;
        this.ratePlan = ratePlan;
        this.freeUnit = freeUnit;
    }

    // Getters and setters
    public Invoice getInvoice() {
        return invoice;
    }

    public void setInvoice(Invoice invoice) {
        this.invoice = invoice;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public RatePlan getRatePlan() {
        return ratePlan;
    }

    public void setRatePlan(RatePlan ratePlan) {
        this.ratePlan = ratePlan;
    }

    public ServicePackage getFreeUnit() {
        return freeUnit;
    }

    public void setFreeUnit(ServicePackage freeUnit) {
        this.freeUnit = freeUnit;
    }
}