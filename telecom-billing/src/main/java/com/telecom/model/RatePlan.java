package com.telecom.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class RatePlan {

    private int planId;
    private String planName;
    private String description;
    private boolean cug;
    private BigDecimal basePrice;
    private Date createdAt;
    private int validityDays;
    private List<RatePlanService> services;
    private Integer servicesCount;

    @JsonProperty("isActive")
    private boolean active;

    
    @JsonProperty("isActive")
    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    // Constructors
    public RatePlan() {
    }

    public RatePlan(int planId, String planName, String description, boolean cug,
            BigDecimal basePrice, boolean isActive, Date createdAt, int validityDays) {
        this.planId = planId;
        this.planName = planName;
        this.description = description;
        this.cug = cug;
        this.basePrice = basePrice;
        this.active = isActive;
        this.createdAt = createdAt;
        this.validityDays = validityDays;
    }

    // Getters and Setters
    public int getPlanId() {
        return planId;
    }

    public void setPlanId(int planId) {
        this.planId = planId;
    }

    public String getPlanName() {
        return planName;
    }

    public void setPlanName(String planName) {
        this.planName = planName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isCug() {
        return cug;
    }

    public void setCug(boolean cug) {
        this.cug = cug;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(BigDecimal basePrice) {
        this.basePrice = basePrice;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public int getValidityDays() {
        return validityDays;
    }

    public void setValidityDays(int validityDays) {
        this.validityDays = validityDays;
    }

    public List<RatePlanService> getServices() {
        return services;
    }

    public void setServices(List<RatePlanService> services) {
        this.services = services;
    }

    public Integer getServicesCount() {
        return servicesCount;
    }

    public void setServicesCount(Integer servicesCount) {
        this.servicesCount = servicesCount;
    }

    @Override
    public String toString() {
        return "RatePlan{"
                + "planId=" + planId
                + ", planName='" + planName + '\''
                + ", description='" + description + '\''
                + ", cug=" + cug
                + ", basePrice=" + basePrice
                + ", isActive=" + active
                + ", createdAt=" + createdAt
                + ", validityDays=" + validityDays
                + '}';
    }
}
