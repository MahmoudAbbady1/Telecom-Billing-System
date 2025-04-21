package com.telecom.model;

import java.math.BigDecimal;

public class ServicePackage {
    private int serviceId;
    private String serviceName;
    private String serviceType;
    private String serviceNetworkZone;
    private int quota;
    private BigDecimal ratePerUnit;
    private String unitDescription;
    private Integer validityDays;
    private boolean isActive;

    // Constructors
    public ServicePackage() {
    }

    public ServicePackage(int serviceId, String serviceName, String serviceType, String serviceNetworkZone, 
                        int quota, BigDecimal ratePerUnit, String unitDescription, 
                        Integer validityDays, boolean isActive) {
        this.serviceId = serviceId;
        this.serviceName = serviceName;
        this.serviceType = serviceType;
        this.serviceNetworkZone = serviceNetworkZone;
        this.quota = quota;
        this.ratePerUnit = ratePerUnit;
        this.unitDescription = unitDescription;
        this.validityDays = validityDays;
        this.isActive = isActive;
    }

    // Getters and Setters
    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getServiceType() {
        return serviceType;
    }

    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }

    public String getServiceNetworkZone() {
        return serviceNetworkZone;
    }

    public void setServiceNetworkZone(String serviceNetworkZone) {
        this.serviceNetworkZone = serviceNetworkZone;
    }

    public int getQuota() {
        return quota;
    }

    public void setQuota(int quota) {
        this.quota = quota;
    }

    public BigDecimal getRatePerUnit() {
        return ratePerUnit;
    }

    public void setRatePerUnit(BigDecimal ratePerUnit) {
        this.ratePerUnit = ratePerUnit;
    }

    public String getUnitDescription() {
        return unitDescription;
    }

    public void setUnitDescription(String unitDescription) {
        this.unitDescription = unitDescription;
    }

    public Integer getValidityDays() {
        return validityDays;
    }

    public void setValidityDays(Integer validityDays) {
        this.validityDays = validityDays;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    @Override
    public String toString() {
        return "ServicePackage{" +
                "serviceId=" + serviceId +
                ", serviceName='" + serviceName + '\'' +
                ", serviceType='" + serviceType + '\'' +
                ", serviceNetworkZone='" + serviceNetworkZone + '\'' +
                ", quota=" + quota +
                ", ratePerUnit=" + ratePerUnit +
                ", unitDescription='" + unitDescription + '\'' +
                ", validityDays=" + validityDays +
                ", isActive=" + isActive +
                '}';
    }
}