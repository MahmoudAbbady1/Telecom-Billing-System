package com.telecom.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public class RatePlanService {
    private int planId;
    private int serviceId;
    private String serviceName;
    private String serviceType;
    private String unitDescription;
    private int includedUnits;

    @JsonProperty("unlimited") // Accept "unlimited" from JSON
    private boolean isUnlimited;
    


    // Constructors
    public RatePlanService() {
    }

    public RatePlanService(int planId, int serviceId, int includedUnits, boolean isUnlimited) {
        this.planId = planId;
        this.serviceId = serviceId;
        this.includedUnits = includedUnits;
        this.isUnlimited = isUnlimited;
    }

    // Getters and Setters
    public int getPlanId() {
        return planId;
    }

    public void setPlanId(int planId) {
        this.planId = planId;
    }

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

    public String getUnitDescription() {
        return unitDescription;
    }

    public void setUnitDescription(String unitDescription) {
        this.unitDescription = unitDescription;
    }

    public int getIncludedUnits() {
        return includedUnits;
    }

    public void setIncludedUnits(int includedUnits) {
        this.includedUnits = includedUnits;
    }


        public boolean isUnlimited() {
        return isUnlimited;
    }
        
            public void setUnlimited(boolean unlimited) {
        isUnlimited = unlimited;
    }

    @Override
    public String toString() {
        return "RatePlanService{" +
                "planId=" + planId +
                ", serviceId=" + serviceId +
                ", includedUnits=" + includedUnits +
                ", isUnlimited=" + isUnlimited +
                '}';
    }
}