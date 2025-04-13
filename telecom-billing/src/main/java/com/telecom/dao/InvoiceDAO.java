/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.dao;

/**
 *
 * @author mibrahim
 */

import com.telecom.model.Invoice;
import com.telecom.model.InvoiceItem;
import com.telecom.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InvoiceDAO {
    public List<Invoice> getInvoicesForCustomer(int customerId) throws SQLException {
        List<Invoice> invoices = new ArrayList<>();
        String sql = "SELECT * FROM invoices WHERE customer_id = ? ORDER BY invoice_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    invoices.add(extractInvoiceFromResultSet(rs));
                }
            }
        }
        return invoices;
    }

    public int addInvoice(Invoice invoice) throws SQLException {
        String sql = "INSERT INTO invoices (customer_id, invoice_date, due_date, subtotal, tax, total, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, invoice.getCustomerId());
            stmt.setDate(2, new java.sql.Date(invoice.getInvoiceDate().getTime()));
            stmt.setDate(3, new java.sql.Date(invoice.getDueDate().getTime()));
            stmt.setBigDecimal(4, invoice.getSubtotal());
            stmt.setBigDecimal(5, invoice.getTax());
            stmt.setBigDecimal(6, invoice.getTotal());
            stmt.setString(7, invoice.getStatus());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating invoice failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating invoice failed, no ID obtained.");
                }
            }
        }
    }

    public void addInvoiceItem(InvoiceItem item) throws SQLException {
        String sql = "INSERT INTO invoice_items (invoice_id, description, quantity, unit_price, amount) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, item.getInvoiceId());
            stmt.setString(2, item.getDescription());
            stmt.setBigDecimal(3, item.getQuantity());
            stmt.setBigDecimal(4, item.getUnitPrice());
            stmt.setBigDecimal(5, item.getAmount());
            
            stmt.executeUpdate();
        }
    }

    public List<InvoiceItem> getInvoiceItems(int invoiceId) throws SQLException {
        List<InvoiceItem> items = new ArrayList<>();
        String sql = "SELECT * FROM invoice_items WHERE invoice_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, invoiceId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    items.add(extractInvoiceItemFromResultSet(rs));
                }
            }
        }
        return items;
    }

    private Invoice extractInvoiceFromResultSet(ResultSet rs) throws SQLException {
        Invoice invoice = new Invoice();
        invoice.setInvoiceId(rs.getInt("invoice_id"));
        invoice.setCustomerId(rs.getInt("customer_id"));
        invoice.setInvoiceDate(rs.getDate("invoice_date"));
        invoice.setDueDate(rs.getDate("due_date"));
        invoice.setSubtotal(rs.getBigDecimal("subtotal"));
        invoice.setTax(rs.getBigDecimal("tax"));
        invoice.setTotal(rs.getBigDecimal("total"));
        invoice.setStatus(rs.getString("status"));
        return invoice;
    }

    private InvoiceItem extractInvoiceItemFromResultSet(ResultSet rs) throws SQLException {
        InvoiceItem item = new InvoiceItem();
        item.setItemId(rs.getInt("item_id"));
        item.setInvoiceId(rs.getInt("invoice_id"));
        item.setDescription(rs.getString("description"));
        item.setQuantity(rs.getBigDecimal("quantity"));
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        item.setAmount(rs.getBigDecimal("amount"));
        return item;
    }

    public Invoice getInvoice(int invoiceId) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    public List<Invoice> getAllInvoices() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}