/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.model;
import java.sql.Timestamp;

/**
 *
 * @author mibrahim
 */


public class CDR {
    private int cdrId;
    private String dialA;
    private String dialB;
    private int serviceId;
    private double quantity; // seconds for voice, count for SMS, bytes for data
    private Timestamp startTime;
    private double externalCharges;
    private boolean processed;
    
    // Constructors
    public CDR() {}
    
    public CDR(String dialA, String dialB, int serviceId, double quantity, Timestamp startTime) {
        this.dialA = dialA;
        this.dialB = dialB;
        this.serviceId = serviceId;
        this.quantity = quantity;
        this.startTime = startTime;
        this.externalCharges = 0;
        this.processed = false;
    }
    
    // Getters and Setters
    public int getCdrId() { return cdrId; }
    public void setCdrId(int cdrId) { this.cdrId = cdrId; }
    
    public String getDialA() { return dialA; }
    public void setDialA(String dialA) { this.dialA = dialA; }
    
    public String getDialB() { return dialB; }
    public void setDialB(String dialB) { this.dialB = dialB; }
    
    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }
    
    public double getQuantity() { return quantity; }
    public void setQuantity(double quantity) { this.quantity = quantity; }
    
    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }
    
    public double getExternalCharges() { return externalCharges; }
    public void setExternalCharges(double externalCharges) { this.externalCharges = externalCharges; }
    
    public boolean isProcessed() { return processed; }
    public void setProcessed(boolean processed) { this.processed = processed; }
    
    @Override
    public String toString() {
        return "CDR [cdrId=" + cdrId + ", dialA=" + dialA + ", dialB=" + dialB + ", serviceId=" + serviceId + "]";
    }
}