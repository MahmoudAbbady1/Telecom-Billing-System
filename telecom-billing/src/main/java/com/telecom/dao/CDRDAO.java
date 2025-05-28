package com.telecom.dao;

import com.telecom.model.CDR;
import com.telecom.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CDRDAO {
    private static final Logger LOGGER = Logger.getLogger(CDRDAO.class.getName());
    private final DBConnection DBConnection = new DBConnection();

    public void saveCDR(CDR cdr) throws SQLException {
        String sql = "INSERT INTO cdrs (filename, processed) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, cdr.getFilename());
            stmt.setBoolean(2, cdr.isProcessed());
            stmt.executeUpdate();
            LOGGER.info("Saved CDR file: " + cdr.getFilename());
        } catch (SQLException e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "Error saving CDR file: " + cdr.getFilename(), e);
            throw e;
        }
    }

    public List<CDR> getAllCDRs() throws SQLException {
        List<CDR> cdrs = new ArrayList<>();
        String sql = "SELECT id, filename, processed FROM cdrs";
        LOGGER.info("Executing query: " + sql);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                CDR cdr = new CDR();
                cdr.setId(rs.getInt("id"));
                cdr.setFilename(rs.getString("filename"));
                cdr.setProcessed(rs.getBoolean("processed"));
                cdrs.add(cdr);
            }
            LOGGER.info("Retrieved " + cdrs.size() + " CDR records");
            return cdrs;
        } catch (SQLException e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "Error retrieving CDR records", e);
            throw e;
        }
    }

    public void processCDRs() throws SQLException {
        String sql = "UPDATE cdrs SET processed = ? WHERE processed = ?";
        LOGGER.info("Executing query: " + sql);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBoolean(1, true);
            stmt.setBoolean(2, false);
            int rowsAffected = stmt.executeUpdate();
            LOGGER.info("Processed " + rowsAffected + " CDR records");
        } catch (SQLException e) {
            e.printStackTrace();
            LOGGER.log(Level.SEVERE, "Error processing CDR records", e);
            throw e;
        }
    }
}