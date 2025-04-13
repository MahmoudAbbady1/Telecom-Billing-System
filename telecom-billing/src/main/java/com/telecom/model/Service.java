/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.model;

/**
 *
 * @author mibrahim
 */

public class Service {
    private int serviceId;
    private String serviceName;
    private String serviceType; // VOICE, SMS, DATA
    private double ratePerUnit;
    private String unitDescription;
    private boolean isRecurring;
    private double monthlyFee;
    
    // Constructors
    public Service() {}
    
    public Service(String serviceName, String serviceType, double ratePerUnit, String unitDescription) {
        this.serviceName = serviceName;
        this.serviceType = serviceType;
        this.ratePerUnit = ratePerUnit;
        this.unitDescription = unitDescription;
        this.isRecurring = false;
    }
    
    // Getters and Setters
    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }
    
    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    
    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }
    
    public double getRatePerUnit() { return ratePerUnit; }
    public void setRatePerUnit(double ratePerUnit) { this.ratePerUnit = ratePerUnit; }
    
    public String getUnitDescription() { return unitDescription; }
    public void setUnitDescription(String unitDescription) { this.unitDescription = unitDescription; }
    
    public boolean isRecurring() { return isRecurring; }
    public void setRecurring(boolean isRecurring) { this.isRecurring = isRecurring; }
    
    public double getMonthlyFee() { return monthlyFee; }
    public void setMonthlyFee(double monthlyFee) { this.monthlyFee = monthlyFee; }
    
    @Override
    public String toString() {
        return "Service [serviceId=" + serviceId + ", serviceName=" + serviceName + ", serviceType=" + serviceType + "]";
    }
}