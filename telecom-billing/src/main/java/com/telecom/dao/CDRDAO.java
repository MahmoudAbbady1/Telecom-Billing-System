/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.dao;

/**
 *
 * @author mibrahim
 */

import com.telecom.model.CDR;
import com.telecom.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CDRDAO {
    public List<CDR> getRecentCDRs(int limit) throws SQLException {
        List<CDR> cdrs = new ArrayList<>();
        String sql = "SELECT * FROM cdr_records ORDER BY start_time DESC LIMIT ?";
        DBConnection dbConnection = new DBConnection();
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    cdrs.add(extractCDRFromResultSet(rs));
                }
            }
        }
        return cdrs;
    }

    public List<CDR> getUnbilledCDRsForCustomer(int customerId) throws SQLException {
        List<CDR> cdrs = new ArrayList<>();
        String sql = "SELECT c.* FROM cdr_records c " +
                     "JOIN customer_services cs ON c.service_id = cs.service_id " +
                     "WHERE cs.customer_id = ? AND c.processed = false";
        
        DBConnection dbConnection = new DBConnection();
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    cdrs.add(extractCDRFromResultSet(rs));
                }
            }
        }
        return cdrs;
    }

    public boolean addCDR(CDR cdr) throws SQLException {
        String sql = "INSERT INTO cdr_records (dial_a, dial_b, service_id, quantity, start_time, external_charges) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        DBConnection dbConnection = new DBConnection();
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, cdr.getDialA());
            stmt.setString(2, cdr.getDialB());
            stmt.setInt(3, cdr.getServiceId());
            stmt.setDouble(4, cdr.getQuantity());
            stmt.setTimestamp(5, cdr.getStartTime());
            stmt.setDouble(6, cdr.getExternalCharges());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                return false;
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    cdr.setCdrId(generatedKeys.getInt(1));
                }
            }
            return true;
        }
    }

    public boolean markAsProcessed(int cdrId) throws SQLException {
        String sql = "UPDATE cdr_records SET processed = true WHERE cdr_id = ?";
        DBConnection dbConnection = new DBConnection();
        try (Connection conn = dbConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, cdrId);
            return stmt.executeUpdate() > 0;
        }
    }

    private CDR extractCDRFromResultSet(ResultSet rs) throws SQLException {
        CDR cdr = new CDR();
        cdr.setCdrId(rs.getInt("cdr_id"));
        cdr.setDialA(rs.getString("dial_a"));
        cdr.setDialB(rs.getString("dial_b"));
        cdr.setServiceId(rs.getInt("service_id"));
        cdr.setQuantity(rs.getDouble("quantity"));
        cdr.setStartTime(rs.getTimestamp("start_time"));
        cdr.setExternalCharges(rs.getDouble("external_charges"));
        cdr.setProcessed(rs.getBoolean("processed"));
        return cdr;
    }

    public void updateCDR(CDR cdr) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
