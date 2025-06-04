package com.telecom.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

public class RatePlan {
    private int planId;
    private String planName;
    private String description;
    private BigDecimal monthlyFee;
    private boolean cug;
    private int maxCugMembers;
    private int cugUnit;
    private Timestamp createdAt;
    private List<ServicePackage> servicePackages;

    
    @JsonProperty("isCug")  // Add this annotation
    public boolean isCug() { 
        return cug; 
    }
    // Constructors
    public RatePlan() {
    }

    public RatePlan(int planId, String planName, String description, BigDecimal monthlyFee, 
                   boolean isCug, int maxCugMembers, int cugUnit, Timestamp createdAt) {
        this.planId = planId;
        this.planName = planName;
        this.description = description;
        this.monthlyFee = monthlyFee;
        this.cug = cug;
        this.maxCugMembers = maxCugMembers;
        this.cugUnit = cugUnit;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getPlanId() { return planId; }
    public void setPlanId(int planId) { this.planId = planId; }
    public String getPlanName() { return planName; }
    public void setPlanName(String planName) { this.planName = planName; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getMonthlyFee() { return monthlyFee; }
    public void setMonthlyFee(BigDecimal monthlyFee) { this.monthlyFee = monthlyFee; }
    public boolean cug() { return cug; }
    public void setCug(boolean cug) { this.cug = cug; }
    public int getMaxCugMembers() { return maxCugMembers; }
    public void setMaxCugMembers(int maxCugMembers) { this.maxCugMembers = maxCugMembers; }
    public int getCugUnit() { return cugUnit; }
    public void setCugUnit(int cugUnit) { this.cugUnit = cugUnit; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public List<ServicePackage> getServicePackages() { return servicePackages; }
    public void setServicePackages(List<ServicePackage> servicePackages) { this.servicePackages = servicePackages; }

    @Override
    public String toString() {
        return "RatePlan{" +
                "planId=" + planId +
                ", planName='" + planName + '\'' +
                ", description='" + description + '\'' +
                ", monthlyFee=" + monthlyFee +
                ", isCug=" + cug +
                ", maxCugMembers=" + maxCugMembers +
                ", cugUnit=" + cugUnit +
                ", createdAt=" + createdAt +
                '}';
    }
}
