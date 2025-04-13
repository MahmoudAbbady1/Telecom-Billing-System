/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.model;

/**
 *
 * @author mibrahim
 */

public class RatePlan {
    private int planId;
    private String planName;
    private String description;
    private double basePrice;
    private boolean isActive;
    
    // Constructors
    public RatePlan() {}
    
    public RatePlan(String planName, String description, double basePrice) {
        this.planName = planName;
        this.description = description;
        this.basePrice = basePrice;
        this.isActive = true;
    }
    
    // Getters and Setters
    public int getPlanId() { return planId; }
    public void setPlanId(int planId) { this.planId = planId; }
    
    public String getPlanName() { return planName; }
    public void setPlanName(String planName) { this.planName = planName; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public double getBasePrice() { return basePrice; }
    public void setBasePrice(double basePrice) { this.basePrice = basePrice; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean isActive) { this.isActive = isActive; }
    
    @Override
    public String toString() {
        return "RatePlan [planId=" + planId + ", planName=" + planName + ", basePrice=" + basePrice + "]";
    }
}