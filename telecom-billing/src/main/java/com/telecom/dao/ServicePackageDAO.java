package com.telecom.dao;

import com.telecom.model.ServicePackage;
import com.telecom.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ServicePackageDAO {

    private static final Logger LOGGER = Logger.getLogger(ServicePackageDAO.class.getName());

    // Get all service packages
    public List<ServicePackage> getAllServicePackages() throws SQLException {
        List<ServicePackage> packages = new ArrayList<>();
        String sql = "SELECT * FROM service_packages  ORDER BY service_id ";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                packages.add(extractServicePackageFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all service packages", e);
            throw e;
        }
        return packages;
    }

    // Get service package by ID
    public ServicePackage getServicePackageById(int serviceId) throws SQLException {
        String sql = "SELECT * FROM service_packages WHERE service_id = ?";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, serviceId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractServicePackageFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting service package by ID: " + serviceId, e);
            throw e;
        }
        return null;
    }

    public void addServicePackage(ServicePackage servicePackage) throws SQLException {
        String sql = "INSERT INTO service_packages (service_name, service_type, service_network_zone, "
                + "quota, rate_per_unit, unit_description, validity_days, is_free_unit) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, servicePackage.getServiceName());
            stmt.setString(2, servicePackage.getServiceType());
            stmt.setString(3, servicePackage.getServiceNetworkZone());
            stmt.setInt(4, servicePackage.getQuota());
            stmt.setBigDecimal(5, servicePackage.getRatePerUnit());
            stmt.setString(6, servicePackage.getUnitDescription());

            if (servicePackage.getValidityDays() != null) {
                stmt.setInt(7, servicePackage.getValidityDays());
            } else {
                stmt.setNull(7, Types.INTEGER);
            }

            stmt.setBoolean(8, servicePackage.is_free_unit());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating service package failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    servicePackage.setServiceId(generatedKeys.getInt(1));
                }
            }
        }
    }
// Remove the setServicePackageParameters method and update the update method

    public void updateServicePackage(ServicePackage servicePackage) throws SQLException {
        String sql = "UPDATE service_packages SET service_name = ?, service_type = ?, "
                + "service_network_zone = ?, quota = ?, rate_per_unit = ?, "
                + "unit_description = ?, validity_days = ?, is_free_unit = ? "
                + "WHERE service_id = ?";

        DBConnection DBConnection = new DBConnection();

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            // Set parameters
            stmt.setString(1, servicePackage.getServiceName());
            stmt.setString(2, servicePackage.getServiceType());
            stmt.setString(3, servicePackage.getServiceNetworkZone());
            stmt.setInt(4, servicePackage.getQuota());
            stmt.setBigDecimal(5, servicePackage.getRatePerUnit());
            stmt.setString(6, servicePackage.getUnitDescription());

            // Handle nullable validityDays
            if (servicePackage.getValidityDays() != null) {
                stmt.setInt(7, servicePackage.getValidityDays());
            } else {
                stmt.setNull(7, Types.INTEGER);
            }

            stmt.setBoolean(8, servicePackage.is_free_unit());
            stmt.setInt(9, servicePackage.getServiceId());

            // Execute update
            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                String errorMsg = "No service package found with ID: " + servicePackage.getServiceId();
                LOGGER.log(Level.WARNING, errorMsg);
                throw new SQLException(errorMsg);
            }

            LOGGER.log(Level.INFO, "Successfully updated service package ID: {0}",
                    servicePackage.getServiceId());

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating service package ID: "
                    + servicePackage.getServiceId(), e);
            throw e;
        }
    }

    // Delete service package
    public void deleteServicePackage(int serviceId) throws SQLException {
        String sql = "DELETE FROM service_packages WHERE service_id = ?";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, serviceId);
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Deleting service package failed, no rows affected.");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting service package ID: " + serviceId, e);
            throw e;
        }
    }

    public Map<String, Integer> getServicePackageCountsByType() throws SQLException {
        Map<String, Integer> counts = new HashMap<>();
        String sql = "SELECT service_type, COUNT(*) as count FROM service_packages  GROUP BY service_type";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                counts.put(rs.getString("service_type"), rs.getInt("count"));
            }
        }

        sql = "SELECT COUNT(*) as total FROM service_packages ";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                counts.put("TOTAL", rs.getInt("total"));
            }
        }

        return counts;
    }

    // Helper method to extract ServicePackage from ResultSet
    private ServicePackage extractServicePackageFromResultSet(ResultSet rs) throws SQLException {
        ServicePackage servicePackage = new ServicePackage();
        servicePackage.setServiceId(rs.getInt("service_id"));
        servicePackage.setServiceName(rs.getString("service_name"));
        servicePackage.setServiceType(rs.getString("service_type"));
        servicePackage.setServiceNetworkZone(rs.getString("service_network_zone"));
        servicePackage.setQuota(rs.getInt("quota"));
        servicePackage.setRatePerUnit(rs.getBigDecimal("rate_per_unit"));
        servicePackage.setUnitDescription(rs.getString("unit_description"));

        int validityDays = rs.getInt("validity_days");
        String freeUnitValue = rs.getString("is_free_unit");
        boolean isFreeUnit = "t".equalsIgnoreCase(freeUnitValue)
                || "true".equalsIgnoreCase(freeUnitValue)
                || "1".equals(freeUnitValue)
                || (rs.getBoolean("is_free_unit") && !"f".equalsIgnoreCase(freeUnitValue));

        servicePackage.setFreeUnit(isFreeUnit);
        servicePackage.setValidityDays(rs.wasNull() ? null : validityDays);

        return servicePackage;
    }

    // Helper method to set PreparedStatement parameters
    private void setServicePackageParameters(PreparedStatement stmt, ServicePackage servicePackage)
            throws SQLException {
        stmt.setString(1, servicePackage.getServiceName());
        stmt.setString(2, servicePackage.getServiceType());
        stmt.setString(3, servicePackage.getServiceNetworkZone());
        stmt.setInt(4, servicePackage.getQuota());
        stmt.setBigDecimal(5, servicePackage.getRatePerUnit());
        stmt.setString(6, servicePackage.getUnitDescription());
        stmt.setBoolean(8, servicePackage.is_free_unit());

        if (servicePackage.getValidityDays() != null) {
            stmt.setInt(7, servicePackage.getValidityDays());
        } else {
            stmt.setNull(7, Types.INTEGER);
        }

    }

}
