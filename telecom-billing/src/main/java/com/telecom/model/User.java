package com.telecom.model;

import java.util.Date;

public class User {
    private int userId;
    private String username;
    private String password;
    private String email;
    private String role; // ADMIN, OPERATOR, etc.
    private Date lastLogin;
    private boolean active;
    
    // Constructors, Getters and Setters
    public User() {}
    
    public User(String username, String password, String role) {
        this.username = username;
        this.password = password;
        this.role = role;
        this.active = true;
    }
    
    // Getters and setters for all properties
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public Date getLastLogin() { return lastLogin; }
    public void setLastLogin(Date lastLogin) { this.lastLogin = lastLogin; }
    
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}