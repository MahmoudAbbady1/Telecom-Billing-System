package com.telecom.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Invoice {

    private String invoiceId;
    private int customerId;
    private Timestamp invoiceDate;
    private BigDecimal rorUsage;
    private BigDecimal subtotal;
    private BigDecimal tax;
    private BigDecimal total;
    private Timestamp createdAt;
    private Customer customer;

    public Invoice() {
        this.tax = new BigDecimal("10.00"); // Default tax from table
    }

    // Getters and Setters
    public String getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(String invoiceId) {
        this.invoiceId = invoiceId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Timestamp getInvoiceDate() {
        return invoiceDate;
    }

    public void setInvoiceDate(Timestamp invoiceDate) {
        this.invoiceDate = invoiceDate;
    }

    public BigDecimal getRorUsage() {
        return rorUsage;
    }

    public void setRorUsage(BigDecimal rorUsage) {
        this.rorUsage = rorUsage;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public BigDecimal getTax() {
        return tax;
    }

    public void setTax(BigDecimal tax) {
        this.tax = tax;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    @Override
    public String toString() {
        return "Invoice{"
                + "invoiceId='" + invoiceId + '\''
                + ", customerId=" + customerId
                + ", invoiceDate=" + invoiceDate
                + ", rorUsage=" + rorUsage
                + ", subtotal=" + subtotal
                + ", tax=" + tax
                + ", total=" + total
                + ", createdAt=" + createdAt
                + '}';
    }
}
