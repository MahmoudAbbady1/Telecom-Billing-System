/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.model;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 *
 * @author mibrahim
 */


public class Invoice {
    private int invoiceId;
    private int customerId;
    private Date invoiceDate;
    private Date dueDate;
    private BigDecimal subtotal;
    private BigDecimal tax;
    private BigDecimal total;
    private String status; // PENDING, PAID, OVERDUE
    private List<InvoiceItem> items;
    
    // Constructors
    public Invoice() {}
    
    public Invoice(int customerId, Date invoiceDate, Date dueDate) {
        this.customerId = customerId;
        this.invoiceDate = invoiceDate;
        this.dueDate = dueDate;
        this.status = "PENDING";
        this.subtotal = BigDecimal.ZERO;
        this.tax = BigDecimal.ZERO;
        this.total = BigDecimal.ZERO;
    }
    
    // Getters and Setters
    public int getInvoiceId() { return invoiceId; }
    public void setInvoiceId(int invoiceId) { this.invoiceId = invoiceId; }
    
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    
    public Date getInvoiceDate() { return invoiceDate; }
    public void setInvoiceDate(Date invoiceDate) { this.invoiceDate = invoiceDate; }
    
    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    
    public BigDecimal getTax() { return tax; }
    public void setTax(BigDecimal tax) { this.tax = tax; }
    
    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public List<InvoiceItem> getItems() { return items; }
    public void setItems(List<InvoiceItem> items) { this.items = items; }
    
    @Override
    public String toString() {
        return "Invoice [invoiceId=" + invoiceId + ", customerId=" + customerId + ", total=" + total + "]";
    }
}