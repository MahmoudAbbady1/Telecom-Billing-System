package com.telecom.model;

import java.sql.Timestamp;
import java.util.Arrays;

public class Customer {
    private int customerId;
    private String nid;
    private String name;
    private String phone;
    private int creditLimit;
    private String email;
    private String address;
    private String status;
    private Timestamp registrationDate;
    private int planId;
    private Integer freeUnitId;
    private int promotionPackage;
    private String occName;
    private int occPrice;
    private int monthsNumberInstallments;
    private String[] cugNumbers;
    private Integer occMonCounter;
    private float price_occ_per_month;

    public Customer() {
    }

    public Customer(int customerId, String nid, String name, String phone, int creditLimit,
                    String email, String address, String status, Timestamp registrationDate,
                    int planId, Integer freeUnitId, int promotionPackage, String occName,
                    int occPrice, int monthsNumberInstallments, String[] cugNumbers, Integer occMonCounter) {
        this.customerId = customerId;
        this.nid = nid;
        this.name = name;
        this.phone = phone;
        this.creditLimit = creditLimit;
        this.email = email;
        this.address = address;
        this.status = status;
        this.registrationDate = registrationDate;
        this.planId = planId;
        this.freeUnitId = freeUnitId;
        this.promotionPackage = promotionPackage;
        this.occName = occName;
        this.occPrice = occPrice;
        this.monthsNumberInstallments = monthsNumberInstallments;
        this.cugNumbers = cugNumbers;
        this.occMonCounter = occMonCounter;
    }

    public Integer getFreeUnitId() {
        return freeUnitId;
    }

    public void setFreeUnitId(Integer freeUnitId) {
        this.freeUnitId = freeUnitId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getNid() {
        return nid;
    }

    public void setNid(String nid) {
        this.nid = nid;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getCreditLimit() {
        return creditLimit;
    }

    public void setCreditLimit(int creditLimit) {
        this.creditLimit = creditLimit;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status != null ? status.toUpperCase() : null;
    }

    public Timestamp getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(Timestamp registrationDate) {
        this.registrationDate = registrationDate;
    }

    public int getPlanId() {
        return planId;
    }

    public void setPlanId(int planId) {
        this.planId = planId;
    }

    public int getPromotionPackage() {
        return promotionPackage;
    }

    public void setPromotionPackage(int promotionPackage) {
        this.promotionPackage = promotionPackage;
    }

    public String getOccName() {
        return occName;
    }

    public void setOccName(String occName) {
        this.occName = occName;
    }

    public int getOccPrice() {
        return occPrice;
    }

    public void setOccPrice(int occPrice) {
        this.occPrice = occPrice;
    }

    public int getMonthsNumberInstallments() {
        return monthsNumberInstallments;
    }

    public void setMonthsNumberInstallments(int monthsNumberInstallments) {
        this.monthsNumberInstallments = monthsNumberInstallments;
    }

    public String[] getCugNumbers() {
        return cugNumbers;
    }

    public void setCugNumbers(String[] cugNumbers) {
        this.cugNumbers = cugNumbers;
    }

    public Integer getOccMonCounter() {
        return occMonCounter;
    }

    public void setOccMonCounter(Integer occMonCounter) {
        this.occMonCounter = occMonCounter;
    }

    public float getPrice_occ_per_month() {
        return price_occ_per_month;
    }

    public void setPrice_occ_per_month(float price_occ_per_month) {
        this.price_occ_per_month = price_occ_per_month;
    }
    
    

    @Override
    public String toString() {
        return "Customer{" +
                "customerId=" + customerId +
                ", nid='" + nid + '\'' +
                ", name='" + name + '\'' +
                ", phone='" + phone + '\'' +
                ", creditLimit=" + creditLimit +
                ", email='" + email + '\'' +
                ", address='" + address + '\'' +
                ", status='" + status + '\'' +
                ", registrationDate=" + registrationDate +
                ", planId=" + planId +
                ", freeUnitId=" + freeUnitId +
                ", promotionPackage=" + promotionPackage +
                ", occName='" + occName + '\'' +
                ", occPrice=" + occPrice +
                ", monthsNumberInstallments=" + monthsNumberInstallments +
                ", cugNumbers=" + Arrays.toString(cugNumbers) +
                ", occMonCounter=" + occMonCounter +
                '}';
    }
}