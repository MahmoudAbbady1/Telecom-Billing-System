/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.dao;

/**
 *
 * @author mibrahim
 */

import com.telecom.model.RatePlan;
import com.telecom.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RatePlanDAO {
    public List<RatePlan> getAllRatePlans() throws SQLException {
        List<RatePlan> ratePlans = new ArrayList<>();
        String sql = "SELECT * FROM rate_plans";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                ratePlans.add(extractRatePlanFromResultSet(rs));
            }
        }
        return ratePlans;
    }

    public RatePlan getRatePlan(int planId) throws SQLException {
        String sql = "SELECT * FROM rate_plans WHERE plan_id = ?";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractRatePlanFromResultSet(rs);
                }
            }
        }
        return null;
    }

    public boolean addRatePlan(RatePlan ratePlan) throws SQLException {
        String sql = "INSERT INTO rate_plans (plan_name, description, base_price) VALUES (?, ?, ?)";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, ratePlan.getPlanName());
            stmt.setString(2, ratePlan.getDescription());
            stmt.setDouble(3, ratePlan.getBasePrice());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                return false;
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    ratePlan.setPlanId(generatedKeys.getInt(1));
                }
            }
            return true;
        }
    }

    public boolean updateRatePlan(RatePlan ratePlan) throws SQLException {
        String sql = "UPDATE rate_plans SET plan_name = ?, description = ?, base_price = ? WHERE plan_id = ?";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, ratePlan.getPlanName());
            stmt.setString(2, ratePlan.getDescription());
            stmt.setDouble(3, ratePlan.getBasePrice());
            stmt.setInt(4, ratePlan.getPlanId());
            
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean deleteRatePlan(int planId) throws SQLException {
        String sql = "DELETE FROM rate_plans WHERE plan_id = ?";
        DBConnection DBConnection = new DBConnection();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, planId);
            return stmt.executeUpdate() > 0;
        }
    }

    private RatePlan extractRatePlanFromResultSet(ResultSet rs) throws SQLException {
        RatePlan ratePlan = new RatePlan();
        ratePlan.setPlanId(rs.getInt("plan_id"));
        ratePlan.setPlanName(rs.getString("plan_name"));
        ratePlan.setDescription(rs.getString("description"));
        ratePlan.setBasePrice(rs.getDouble("base_price"));
        return ratePlan;
    }
}