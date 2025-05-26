package com.telecom.dao;

import com.telecom.model.ServicePackage;
import com.telecom.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ServicePackageDAO {

    private static final Logger LOGGER = Logger.getLogger(ServicePackageDAO.class.getName());
    DBConnection DBConnection = new DBConnection();

    public List<ServicePackage> getAllServicePackages() throws SQLException {
        List<ServicePackage> packages = new ArrayList<>();
        String sql = "SELECT * FROM service_package where is_free_unite = 'f' ORDER BY service_id";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql); 
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                packages.add(extractServicePackageFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all service packages", e);
            throw e;
        }
        return packages;
    }

    public List<ServicePackage> getAllServicePackagesAndFreeUnit() throws SQLException {
        List<ServicePackage> packages = new ArrayList<>();
        String sql = "SELECT * FROM service_package ORDER BY service_id";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql); 
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                packages.add(extractServicePackageFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all service packages", e);
            throw e;
        }
        return packages;
    }

    public List<ServicePackage> getFreeUnitOptions() throws SQLException {
        List<ServicePackage> freeUnits = new ArrayList<>();
        String sql = "SELECT * FROM service_package WHERE is_free_unite = 't' ORDER BY service_name";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql); 
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                freeUnits.add(extractServicePackageFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting free unit options", e);
            throw e;
        }
        return freeUnits;
    }

    public ServicePackage getServicePackageById(int serviceId) throws SQLException {
        String sql = "SELECT * FROM service_package WHERE service_id = ?";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

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
    String sql = "INSERT INTO service_package (service_name, service_type, service_network_zone, "
            + "qouta, unit_description, is_free_unite, free_unit_monthly_fee) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?)";

    try (Connection conn = DBConnection.getConnection(); 
         PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

        LOGGER.log(Level.INFO, "Adding new service package: {0}", servicePackage.toString());

        stmt.setString(1, servicePackage.getServiceName());
        stmt.setString(2, servicePackage.getServiceType());
        stmt.setString(3, servicePackage.getServiceNetworkZone());
        stmt.setInt(4, servicePackage.getQouta());
        stmt.setString(5, servicePackage.getUnitDescription());
        stmt.setBoolean(6, servicePackage.isFreeUnite());
        stmt.setBigDecimal(7, servicePackage.getFreeUnitMonthlyFee() != null ? 
            servicePackage.getFreeUnitMonthlyFee() : BigDecimal.ZERO);

        int affectedRows = stmt.executeUpdate();
        if (affectedRows == 0) {
            throw new SQLException("Creating service package failed, no rows affected.");
        }

        try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
            if (generatedKeys.next()) {
                servicePackage.setServiceId(generatedKeys.getInt(1));
                LOGGER.log(Level.INFO, "Successfully created service package with ID: {0}", servicePackage.getServiceId());
            } else {
                throw new SQLException("Creating service package failed, no ID obtained.");
            }
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error adding service package: " + servicePackage.toString(), e);
        throw e;
    }
}

    public void updateServicePackage(ServicePackage servicePackage) throws SQLException {
        String sql = "UPDATE service_package SET service_name = ?, service_type = ?, "
                + "service_network_zone = ?, qouta = ?, unit_description = ?, "
                + "is_free_unite = ?, free_unit_monthly_fee = ? "
                + "WHERE service_id = ?";

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, servicePackage.getServiceName());
            stmt.setString(2, servicePackage.getServiceType());
            stmt.setString(3, servicePackage.getServiceNetworkZone());
            stmt.setInt(4, servicePackage.getQouta());
            stmt.setString(5, servicePackage.getUnitDescription());
            stmt.setBoolean(6, servicePackage.isFreeUnite());

            if (servicePackage.getFreeUnitMonthlyFee() != null) {
                stmt.setBigDecimal(7, servicePackage.getFreeUnitMonthlyFee());
            } else {
                stmt.setBigDecimal(7, BigDecimal.ZERO);
            }

            stmt.setInt(8, servicePackage.getServiceId());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("No service package found with ID: " + servicePackage.getServiceId());
            }
        }
    }

    public void deleteServicePackage(int serviceId) throws SQLException {
        String sql = "DELETE FROM service_package WHERE service_id = ?";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, serviceId);
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Deleting service package failed, no rows affected.");
            }
        }
    }

    public Map<String, Integer> getServicePackageCountsByType() throws SQLException {
        Map<String, Integer> counts = new HashMap<>();
        String sql = "SELECT service_type, COUNT(*) as count FROM service_package GROUP BY service_type";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql); 
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                counts.put(rs.getString("service_type"), rs.getInt("count"));
            }
        }

        sql = "SELECT COUNT(*) as total FROM service_package";
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql); 
             ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                counts.put("TOTAL", rs.getInt("total"));
            }
        }

        return counts;
    }

    private ServicePackage extractServicePackageFromResultSet(ResultSet rs) throws SQLException {
        ServicePackage servicePackage = new ServicePackage();
        servicePackage.setServiceId(rs.getInt("service_id"));
        servicePackage.setServiceName(rs.getString("service_name"));
        servicePackage.setServiceType(rs.getString("service_type"));
        servicePackage.setServiceNetworkZone(rs.getString("service_network_zone"));
        servicePackage.setQouta(rs.getInt("qouta"));
        servicePackage.setUnitDescription(rs.getString("unit_description"));
        servicePackage.setFreeUnite(rs.getString("is_free_unite").equals("t"));
        servicePackage.setFreeUnitMonthlyFee(rs.getBigDecimal("free_unit_monthly_fee"));
        servicePackage.setCreatedAt(rs.getTimestamp("created_at"));
        return servicePackage;
    }
}