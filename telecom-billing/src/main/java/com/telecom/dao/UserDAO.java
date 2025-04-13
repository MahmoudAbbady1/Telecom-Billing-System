package com.telecom.dao;

import com.telecom.model.User;
import com.telecom.util.DBConnection;
import java.sql.*;
import java.util.Base64;
import java.security.MessageDigest;

public class UserDAO {
    public User authenticate(String username, String password) throws Exception {
        String sql = "SELECT * FROM users WHERE username = ? AND active = true";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    // Verify password
                    String storedHash = rs.getString("password");
                    String inputHash = hashPassword(password);
                    
                    if (storedHash.equals(inputHash)) {
                        User user = new User();
                        user.setUserId(rs.getInt("user_id"));
                        user.setUsername(rs.getString("username"));
                        user.setEmail(rs.getString("email"));
                        user.setRole(rs.getString("role"));
                        user.setLastLogin(rs.getTimestamp("last_login"));
                        
                        // Update last login
                        updateLastLogin(user.getUserId());
                        
                        return user;
                    }
                }
            }
        }
        return null;
    }
    
    private void updateLastLogin(int userId) throws SQLException {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        }
    }
    
    private String hashPassword(String password) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes());
        return Base64.getEncoder().encodeToString(hash);
    }
}