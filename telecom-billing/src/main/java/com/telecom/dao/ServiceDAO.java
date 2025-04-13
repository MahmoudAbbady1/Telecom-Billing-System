package com.telecom.dao;

import com.telecom.model.Service;
import com.telecom.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ServiceDAO {
    public List<Service> getAllServices() throws SQLException {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT * FROM services";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                services.add(extractServiceFromResultSet(rs));
            }
        }
        return services;
    }

    public Service getService(int serviceId) throws SQLException {
        String sql = "SELECT * FROM services WHERE service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, serviceId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractServiceFromResultSet(rs);
                }
            }
        }
        return null;
    }

    public List<Service> getServicesByRatePlan(int planId) throws SQLException {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT s.* FROM services s " +
                     "JOIN rate_plan_services rps ON s.service_id = rps.service_id " +
                     "WHERE rps.plan_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    services.add(extractServiceFromResultSet(rs));
                }
            }
        }
        return services;
    }

    public List<Service> getCustomerServices(int customerId) throws SQLException {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT s.* FROM services s " +
                     "JOIN customer_services cs ON s.service_id = cs.service_id " +
                     "WHERE cs.customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    services.add(extractServiceFromResultSet(rs));
                }
            }
        }
        return services;
    }

    public List<Service> getCustomerRecurringServices(int customerId) throws SQLException {
        List<Service> services = new ArrayList<>();
        String sql = "SELECT s.* FROM services s " +
                     "JOIN customer_services cs ON s.service_id = cs.service_id " +
                     "WHERE cs.customer_id = ? AND cs.is_recurring = true";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    services.add(extractServiceFromResultSet(rs));
                }
            }
        }
        return services;
    }

    public boolean addService(Service service) throws SQLException {
        String sql = "INSERT INTO services (service_name, service_type, rate_per_unit, unit_description, is_recurring, monthly_fee) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, service.getServiceName());
            stmt.setString(2, service.getServiceType());
            stmt.setDouble(3, service.getRatePerUnit());
            stmt.setString(4, service.getUnitDescription());
            stmt.setBoolean(5, service.isRecurring());
            stmt.setDouble(6, service.getMonthlyFee());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                return false;
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    service.setServiceId(generatedKeys.getInt(1));
                }
            }
            return true;
        }
    }

    public boolean updateService(Service service) throws SQLException {
        String sql = "UPDATE services SET service_name = ?, service_type = ?, rate_per_unit = ?, " +
                     "unit_description = ?, is_recurring = ?, monthly_fee = ? WHERE service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, service.getServiceName());
            stmt.setString(2, service.getServiceType());
            stmt.setDouble(3, service.getRatePerUnit());
            stmt.setString(4, service.getUnitDescription());
            stmt.setBoolean(5, service.isRecurring());
            stmt.setDouble(6, service.getMonthlyFee());
            stmt.setInt(7, service.getServiceId());
            
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean deleteService(int serviceId) throws SQLException {
        String sql = "DELETE FROM services WHERE service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, serviceId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean addCustomerService(int customerId, int serviceId, boolean isRecurring, double monthlyFee) 
        throws SQLException {
        String sql = "INSERT INTO customer_services (customer_id, service_id, is_recurring, monthly_fee) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            stmt.setInt(2, serviceId);
            stmt.setBoolean(3, isRecurring);
            stmt.setDouble(4, monthlyFee);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean removeCustomerService(int customerId, int serviceId) throws SQLException {
        String sql = "DELETE FROM customer_services WHERE customer_id = ? AND service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            stmt.setInt(2, serviceId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean addServiceToRatePlan(int planId, int serviceId) throws SQLException {
        String sql = "INSERT INTO rate_plan_services (plan_id, service_id) VALUES (?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, planId);
            stmt.setInt(2, serviceId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean removeServiceFromRatePlan(int planId, int serviceId) throws SQLException {
        String sql = "DELETE FROM rate_plan_services WHERE plan_id = ? AND service_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, planId);
            stmt.setInt(2, serviceId);
            return stmt.executeUpdate() > 0;
        }
    }

    private Service extractServiceFromResultSet(ResultSet rs) throws SQLException {
        Service service = new Service();
        service.setServiceId(rs.getInt("service_id"));
        service.setServiceName(rs.getString("service_name"));
        service.setServiceType(rs.getString("service_type"));
        service.setRatePerUnit(rs.getDouble("rate_per_unit"));
        service.setUnitDescription(rs.getString("unit_description"));
        service.setRecurring(rs.getBoolean("is_recurring"));
        service.setMonthlyFee(rs.getDouble("monthly_fee"));
        return service;
    }
}