package com.telecom.dao;

import com.telecom.model.RatePlan;
import com.telecom.model.ServicePackage;
import com.telecom.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class RatePlanDAO {

    private static final Logger LOGGER = Logger.getLogger(RatePlanDAO.class.getName());
    private final DBConnection dbConnection;

    public RatePlanDAO() {
        this.dbConnection = new DBConnection();
    }

//    public List<RatePlan> getAllRatePlans() throws SQLException {
//        List<RatePlan> ratePlans = new ArrayList<>();
//        String sql = "SELECT * FROM rate_plan ORDER BY plan_id";
//
//        try (Connection conn = dbConnection.getConnection();
//             PreparedStatement stmt = conn.prepareStatement(sql);
//             ResultSet rs = stmt.executeQuery()) {
//
//            while (rs.next()) {
//                ratePlans.add(extractRatePlanFromResultSet(rs));
//            }
//        }
//        return ratePlans;
//    }

    
    public List<RatePlan> getAllRatePlans() throws SQLException {
    List<RatePlan> ratePlans = new ArrayList<>();
    String sql = "SELECT plan_id, plan_name, monthly_fee, is_cug, max_cug_members, cug_unit FROM rate_plan ORDER BY plan_id";
    try (Connection conn = dbConnection.getConnection(); 
         PreparedStatement stmt = conn.prepareStatement(sql); 
         ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
            RatePlan ratePlan = new RatePlan();
            ratePlan.setPlanId(rs.getInt("plan_id"));
            ratePlan.setPlanName(rs.getString("plan_name"));
            ratePlan.setMonthlyFee(rs.getBigDecimal("monthly_fee")); // Add this line
            ratePlan.setCug(rs.getBoolean("is_cug"));
            ratePlan.setMaxCugMembers(rs.getInt("max_cug_members"));
            ratePlan.setCugUnit(rs.getInt("cug_unit")); // Include cug_unit
            ratePlans.add(ratePlan);
        }
    } catch (SQLException e) {
        LOGGER.severe("Error fetching rate plans: " + e.getMessage());
        throw e;
    }
    return ratePlans;
}

    public List<RatePlan> getAllRatePlansWithServices() throws SQLException {
        List<RatePlan> ratePlans = getAllRatePlans();
        for (RatePlan plan : ratePlans) {
            plan.setServicePackages(getServicesForRatePlan(plan.getPlanId()));
        }
        return ratePlans;
    }

    public RatePlan getRatePlanById(int planId) throws SQLException {
        String sql = "SELECT * FROM rate_plan WHERE plan_id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractRatePlanFromResultSet(rs);
                }
            }
        }
        return null;
    }

    public RatePlan getRatePlanWithServices(int planId) throws SQLException {
        RatePlan ratePlan = getRatePlanById(planId);
        if (ratePlan != null) {
            ratePlan.setServicePackages(getServicesForRatePlan(planId));
        }
        return ratePlan;
    }

    public int addRatePlan(RatePlan ratePlan) throws SQLException {
        String sql = "INSERT INTO rate_plan (plan_name, description, monthly_fee, is_cug, max_cug_members, cug_unit) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            setRatePlanParameters(stmt, ratePlan);
            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Creating rate plan failed, no rows affected.");
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating rate plan failed, no ID obtained.");
                }
            }
        }
    }

    public void updateRatePlan(RatePlan ratePlan) throws SQLException {
        String sql = "UPDATE rate_plan SET plan_name = ?, description = ?, monthly_fee = ?, "
                + "is_cug = ?, max_cug_members = ?, cug_unit = ? WHERE plan_id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            setRatePlanParameters(stmt, ratePlan);
            stmt.setInt(7, ratePlan.getPlanId());
            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No rate plan found with ID: " + ratePlan.getPlanId());
            }
        }
    }

    public void deleteRatePlan(int planId) throws SQLException {
        String sql = "DELETE FROM rate_plan WHERE plan_id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            int affectedRows = stmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("Deleting rate plan failed, no rows affected.");
            }
        }
    }

    public void addServiceToRatePlan(int planId, int serviceId) throws SQLException {
        String sql = "INSERT INTO rate_plan_service (plan_id, service_id) VALUES (?, ?)";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            stmt.setInt(2, serviceId);
            stmt.executeUpdate();
        }
    }

    public void removeServiceFromRatePlan(int planId, int serviceId) throws SQLException {
        String sql = "DELETE FROM rate_plan_service WHERE plan_id = ? AND service_id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            stmt.setInt(2, serviceId);
            stmt.executeUpdate();
        }
    }

    public List<ServicePackage> getServicesForRatePlan(int planId) throws SQLException {
        List<ServicePackage> services = new ArrayList<>();
        String sql = "SELECT sp.* FROM service_package sp "
                + "JOIN rate_plan_service rps ON sp.service_id = rps.service_id "
                + "WHERE rps.plan_id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    services.add(extractServicePackageFromResultSet(rs));
                }
            }
        }
        return services;
    }

    public void removeAllServicesFromRatePlan(int planId) throws SQLException {
        String sql = "DELETE FROM rate_plan_service WHERE plan_id = ?";

        try (Connection conn = dbConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            stmt.executeUpdate();
        }
    }

    private RatePlan extractRatePlanFromResultSet(ResultSet rs) throws SQLException {
        RatePlan ratePlan = new RatePlan();
        ratePlan.setPlanId(rs.getInt("plan_id"));
        ratePlan.setPlanName(rs.getString("plan_name"));
        ratePlan.setDescription(rs.getString("description"));
        BigDecimal monthlyFee = rs.getBigDecimal("monthly_fee");
        ratePlan.setMonthlyFee(monthlyFee != null ? monthlyFee : BigDecimal.ZERO); // Default to 0.00 if null

        String cugValue = rs.getString("is_cug");
        boolean isCug = "t".equalsIgnoreCase(cugValue) || "true".equalsIgnoreCase(cugValue)
                || (rs.getBoolean("is_cug") && !"f".equalsIgnoreCase(cugValue));
        ratePlan.setCug(isCug);

        ratePlan.setMaxCugMembers(rs.getInt("max_cug_members"));
        ratePlan.setCugUnit(rs.getInt("cug_unit"));
        ratePlan.setCreatedAt(rs.getTimestamp("created_at"));
        return ratePlan;
    }

    private ServicePackage extractServicePackageFromResultSet(ResultSet rs) throws SQLException {
        ServicePackage service = new ServicePackage();
        service.setServiceId(rs.getInt("service_id"));
        service.setServiceName(rs.getString("service_name"));
        service.setServiceType(rs.getString("service_type"));
        service.setServiceNetworkZone(rs.getString("service_network_zone"));
        service.setQouta(rs.getInt("qouta"));
        service.setUnitDescription(rs.getString("unit_description"));
        service.setFreeUnite(rs.getBoolean("is_free_unite"));
        service.setFreeUnitMonthlyFee(rs.getBigDecimal("free_unit_monthly_fee"));
        service.setCreatedAt(rs.getTimestamp("created_at"));
        return service;
    }

    private void setRatePlanParameters(PreparedStatement stmt, RatePlan ratePlan) throws SQLException {
        stmt.setString(1, ratePlan.getPlanName());
        stmt.setString(2, ratePlan.getDescription());
        stmt.setBigDecimal(3, ratePlan.getMonthlyFee());
        stmt.setBoolean(4, ratePlan.isCug());
        stmt.setInt(5, ratePlan.isCug() ? ratePlan.getMaxCugMembers() : 0);
        stmt.setInt(6, ratePlan.isCug() ? ratePlan.getCugUnit() : 0);
    }
}
