package com.telecom.dao;

import com.telecom.model.RatePlan;
import com.telecom.model.RatePlanService;
import com.telecom.model.ServicePackage;
import com.telecom.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class RatePlanDAO {

    private static final Logger LOGGER = Logger.getLogger(RatePlanDAO.class.getName());
    DBConnection DBConnection = new DBConnection();

    // Get all rate plans
    public List<RatePlan> getAllRatePlans() throws SQLException {
        List<RatePlan> ratePlans = new ArrayList<>();
        System.out.println("Attempting to get all rate plans"); // Debug log

        String sql = "SELECT rp.*, COUNT(rps.service_id) as services_count "
                + "FROM rate_plans rp "
                + "LEFT JOIN rate_plan_services rps ON rp.plan_id = rps.plan_id "
                + "GROUP BY rp.plan_id "
                + "ORDER BY rp.plan_id";

        try (Connection conn = DBConnection.getConnection()) {
            System.out.println("Connection established: " + conn); // Debug log

            try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {

                System.out.println("Query executed"); // Debug log

                while (rs.next()) {
                    ratePlans.add(extractRatePlanFromResultSet(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getAllRatePlans: " + e.getMessage()); // Debug log
            e.printStackTrace();
            throw e;
        }

        System.out.println("Retrieved " + ratePlans.size() + " rate plans"); // Debug log
        return ratePlans;
    }

    // Get rate plan by ID
    public RatePlan getRatePlanById(int planId) throws SQLException {
        String sql = "SELECT * FROM rate_plans WHERE plan_id = ?";
        RatePlan ratePlan = null;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    ratePlan = extractRatePlanFromResultSet(rs);
                    // Load services for this plan
                    List<RatePlanService> services = getServicesForPlan(planId);
                    ratePlan.setServices(services != null ? services : new ArrayList<>());
                    ratePlan.setServicesCount(services != null ? services.size() : 0);
                }
            }
        }
        return ratePlan;
    }

    // Add new rate plan
    public int addRatePlan(RatePlan ratePlan) throws SQLException {
        String sql = "INSERT INTO rate_plans (plan_name, description, cug, base_price, is_active, validity_days) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        int generatedId = -1;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, ratePlan.getPlanName());
            stmt.setString(2, ratePlan.getDescription());
            stmt.setBoolean(3, ratePlan.isCug());
            stmt.setBigDecimal(4, ratePlan.getBasePrice());
            stmt.setBoolean(5, ratePlan.isActive());
            stmt.setInt(6, ratePlan.getValidityDays());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating rate plan failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    generatedId = generatedKeys.getInt(1);
                    ratePlan.setPlanId(generatedId);
                } else {
                    throw new SQLException("Creating rate plan failed, no ID obtained.");
                }
            }

            // Add services if any
            if (ratePlan.getServices() != null && !ratePlan.getServices().isEmpty()) {
                addServicesToPlan(generatedId, ratePlan.getServices());
            }
        }
        return generatedId;
    }

    // Update rate plan
    public void updateRatePlan(RatePlan ratePlan) throws SQLException {
        String sql = "UPDATE rate_plans SET plan_name = ?, description = ?, cug = ?, "
                + "base_price = ?, is_active = ?, validity_days = ? "
                + "WHERE plan_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, ratePlan.getPlanName());
            stmt.setString(2, ratePlan.getDescription());
            stmt.setBoolean(3, ratePlan.isCug());
            stmt.setBigDecimal(4, ratePlan.getBasePrice());
            stmt.setBoolean(5, ratePlan.isActive());
            stmt.setInt(6, ratePlan.getValidityDays());
            stmt.setInt(7, ratePlan.getPlanId());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("No rate plan found with ID: " + ratePlan.getPlanId());
            }

            // Update services - first delete all existing, then add new ones
            deleteServicesForPlan(ratePlan.getPlanId());
            if (ratePlan.getServices() != null && !ratePlan.getServices().isEmpty()) {
                addServicesToPlan(ratePlan.getPlanId(), ratePlan.getServices());
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating rate plan ID: " + ratePlan.getPlanId(), e);
            throw e;
        }
    }

    // Delete rate plan
    public void deleteRatePlan(int planId) throws SQLException {
        // First delete services (due to ON DELETE CASCADE in the database, this might not be necessary)
        deleteServicesForPlan(planId);

        String sql = "DELETE FROM rate_plans WHERE plan_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("No rate plan found with ID: " + planId);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting rate plan ID: " + planId, e);
            throw e;
        }
    }

    // Get service counts by type
    public Map<String, Integer> getRatePlanCounts() throws SQLException {
        Map<String, Integer> counts = new HashMap<>();

        // Total count
        String sql = "SELECT COUNT(*) as total FROM rate_plans";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                counts.put("TOTAL", rs.getInt("total"));
            }
        }

        // Active count
        sql = "SELECT COUNT(*) as active FROM rate_plans WHERE is_active = true";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                counts.put("ACTIVE", rs.getInt("active"));
            }
        }

        // CUG count
        sql = "SELECT COUNT(*) as cug FROM rate_plans WHERE cug = true";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                counts.put("CUG", rs.getInt("cug"));
            }
        }

        // Average price
        sql = "SELECT AVG(base_price) as avg_price FROM rate_plans";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                counts.put("AVG_PRICE", rs.getInt("avg_price"));
            }
        }

        return counts;
    }

    // Helper methods for services
    private List<RatePlanService> getServicesForPlan(int planId) throws SQLException {
        List<RatePlanService> services = new ArrayList<>();
        String sql = "SELECT rps.*, sp.service_name, sp.service_type, sp.unit_description "
                + "FROM rate_plan_services rps "
                + "JOIN service_packages sp ON rps.service_id = sp.service_id "
                + "WHERE rps.plan_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    RatePlanService service = new RatePlanService();
                    service.setPlanId(rs.getInt("plan_id"));
                    service.setServiceId(rs.getInt("service_id"));
                    service.setServiceName(rs.getString("service_name"));
                    service.setServiceType(rs.getString("service_type"));
                    service.setUnitDescription(rs.getString("unit_description"));
                    service.setIncludedUnits(rs.getInt("included_units"));
                    service.setUnlimited(rs.getBoolean("is_unlimited"));
                    services.add(service);
                }
            }
        }
        return services;
    }

    private void addServicesToPlan(int planId, List<RatePlanService> services) throws SQLException {
        String sql = "INSERT INTO rate_plan_services (plan_id, service_id, included_units, is_unlimited) "
                + "VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            for (RatePlanService service : services) {
                stmt.setInt(1, planId);
                stmt.setInt(2, service.getServiceId());
                stmt.setInt(3, service.getIncludedUnits());
                stmt.setBoolean(4, service.isUnlimited());
                stmt.addBatch();
            }
            stmt.executeBatch();
        }
    }

    private void deleteServicesForPlan(int planId) throws SQLException {
        String sql = "DELETE FROM rate_plan_services WHERE plan_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            stmt.executeUpdate();
        }
    }

    // Helper method to extract RatePlan from ResultSet
    private RatePlan extractRatePlanFromResultSet(ResultSet rs) throws SQLException {
        RatePlan ratePlan = new RatePlan();
        ratePlan.setPlanId(rs.getInt("plan_id"));
        ratePlan.setPlanName(rs.getString("plan_name"));
        ratePlan.setDescription(rs.getString("description"));
        ratePlan.setCug(rs.getBoolean("cug"));
        ratePlan.setBasePrice(rs.getBigDecimal("base_price"));
        ratePlan.setActive(rs.getBoolean("is_active"));
        ratePlan.setCreatedAt(rs.getTimestamp("created_at"));
        ratePlan.setValidityDays(rs.getInt("validity_days"));

        try {
            ratePlan.setServicesCount(rs.getInt("services_count"));
        } catch (SQLException e) {
            // Column might not exist in all queries
        }

        return ratePlan;
    }
}
