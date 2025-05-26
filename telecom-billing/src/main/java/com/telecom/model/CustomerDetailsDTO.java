package com.telecom.model;

public class CustomerDetailsDTO {
    private Customer customer;
    private RatePlan ratePlan;  // This already contains servicePackages
    private ServicePackage freeUnit;  // Only the selected free unit

    // Constructors
    public CustomerDetailsDTO() {}

    public CustomerDetailsDTO(Customer customer, RatePlan ratePlan, ServicePackage freeUnit) {
        this.customer = customer;
        this.ratePlan = ratePlan;
        this.freeUnit = freeUnit;
    }

    // Getters and setters
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