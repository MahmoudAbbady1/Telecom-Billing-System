package com.telecom.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class ServicePackage {
    private int serviceId;
    private String serviceName;
    private String serviceType;
    private String serviceNetworkZone;
    private int qouta;
    private String unitDescription;

    @JsonProperty("freeUnite")
    private boolean freeUnite;

    @JsonProperty("freeUnitMonthlyFee")
    private BigDecimal freeUnitMonthlyFee;

    private Timestamp createdAt;

    public ServicePackage() {
        this.freeUnitMonthlyFee = BigDecimal.ZERO;
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

    public int getQouta() {
        return qouta;
    }

    public void setQouta(int qouta) {
        this.qouta = qouta;
    }

    public String getUnitDescription() {
        return unitDescription;
    }

    public void setUnitDescription(String unitDescription) {
        this.unitDescription = unitDescription;
    }

    public boolean isFreeUnite() {
        return freeUnite;
    }

    public void setFreeUnite(boolean freeUnite) {
        this.freeUnite = freeUnite;
    }

    public BigDecimal getFreeUnitMonthlyFee() {
        return freeUnitMonthlyFee;
    }

    public void setFreeUnitMonthlyFee(BigDecimal freeUnitMonthlyFee) {
        this.freeUnitMonthlyFee = freeUnitMonthlyFee;
    }

    public void setFreeUnitMonthlyFee(double fee) {
        this.freeUnitMonthlyFee = BigDecimal.valueOf(fee);
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "ServicePackage{" +
                "serviceId=" + serviceId +
                ", serviceName='" + serviceName + '\'' +
                ", serviceType='" + serviceType + '\'' +
                ", serviceNetworkZone='" + serviceNetworkZone + '\'' +
                ", qouta=" + qouta +
                ", unitDescription='" + unitDescription + '\'' +
                ", freeUnite=" + freeUnite +
                ", freeUnitMonthlyFee=" + freeUnitMonthlyFee +
                ", createdAt=" + createdAt +
                '}';
    }
}
