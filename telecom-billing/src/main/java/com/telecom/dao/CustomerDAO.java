package com.telecom.dao;

import com.telecom.model.Customer;
import com.telecom.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomerDAO {
    private static final Logger LOGGER = Logger.getLogger(CustomerDAO.class.getName());
    private DBConnection DBConnection = new DBConnection();

    public boolean phoneNumberExists(String phone) throws SQLException {
        String sql = "SELECT COUNT(*) FROM customers WHERE phone = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, phone);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public boolean phoneNumberExists(String phone, int excludeCustomerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM customers WHERE phone = ? AND customer_id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, phone);
            stmt.setInt(2, excludeCustomerId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public List<Customer> getAllCustomers() throws SQLException {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT * FROM customers ORDER BY customer_id";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                customers.add(extractCustomerFromResultSet(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all customers", e);
            throw e;
        }
        return customers;
    }

    public Customer getCustomerById(int customerId) throws SQLException {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractCustomerFromResultSet(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting customer by ID: " + customerId, e);
            throw e;
        }
        return null;
    }

    public void addCustomer(Customer customer) throws SQLException {
        String sql = "INSERT INTO customers (nid, name, phone, credit_limit, email, address, " +
                     "status, registration_date, plan_id, free_unit_id, promotion_package, " +
                     "occ_name, occ_price, months_number_installments, cug_numbers) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            setCustomerParameters(stmt, customer);
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating customer failed, no rows affected.");
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    customer.setCustomerId(generatedKeys.getInt(1));
                }
            }
        }
    }

    public void updateCustomer(Customer customer) throws SQLException {
        String sql = "UPDATE customers SET nid = ?, name = ?, phone = ?, credit_limit = ?, " +
                     "email = ?, address = ?, status = ?, registration_date = ?, plan_id = ?, " +
                     "free_unit_id = ?, promotion_package = ?, occ_name = ?, occ_price = ?, " +
                     "months_number_installments = ?, cug_numbers = ? WHERE customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            setCustomerParameters(stmt, customer);
            stmt.setInt(16, customer.getCustomerId());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("No customer found with ID: " + customer.getCustomerId());
            }
        }
    }

    public void deleteCustomer(int customerId) throws SQLException {
        String sql = "DELETE FROM customers WHERE customer_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Deleting customer failed, no rows affected.");
            }
        }
    }

    public List<Customer> searchCustomers(String query, String status) throws SQLException {
        List<Customer> customers = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM customers WHERE 1=1");
        
        if (query != null && !query.isEmpty()) {
            sql.append(" AND (name ILIKE ? OR phone ILIKE ? OR email ILIKE ? OR nid ILIKE ?)");
        }
        
        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
        }
        
        sql.append(" ORDER BY customer_id");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (query != null && !query.isEmpty()) {
                String searchPattern = "%" + query + "%";
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
                stmt.setString(paramIndex++, searchPattern);
            }
            
            if (status != null && !status.isEmpty()) {
                stmt.setString(paramIndex, status);
            }
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    customers.add(extractCustomerFromResultSet(rs));
                }
            }
        }
        return customers;
    }

    public Map<String, Integer> getCustomerStats() throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        
        // Count by status
        String sql = "SELECT status, COUNT(*) as count FROM customers GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                stats.put(rs.getString("status"), rs.getInt("count"));
            }
        }
        
        // Total count
        sql = "SELECT COUNT(*) as total FROM customers";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            if (rs.next()) {
                stats.put("TOTAL", rs.getInt("total"));
            }
        }
        
        return stats;
    }


    private Customer extractCustomerFromResultSet(ResultSet rs) throws SQLException {
    Customer customer = new Customer();
    customer.setCustomerId(rs.getInt("customer_id"));
    customer.setNid(rs.getString("nid"));
    customer.setName(rs.getString("name"));
    customer.setPhone(rs.getString("phone"));
    customer.setCreditLimit(rs.getInt("credit_limit"));
    customer.setEmail(rs.getString("email"));
    customer.setAddress(rs.getString("address"));
    customer.setStatus(rs.getString("status"));
    customer.setRegistrationDate(rs.getTimestamp("registration_date"));
    customer.setPlanId(rs.getInt("plan_id"));
    customer.setFreeUnitId(rs.getInt("free_unit_id"));
    customer.setPromotionPackage(rs.getInt("promotion_package"));
    customer.setOccName(rs.getString("occ_name"));
    customer.setOccPrice(rs.getInt("occ_price"));
    customer.setMonthsNumberInstallments(rs.getInt("months_number_installments"));

    // Safer handling for integer[] (PostgreSQL)
    Array cugArray = rs.getArray("cug_numbers");
    if (cugArray != null) {
        Object rawArray = cugArray.getArray();
        if (rawArray instanceof Integer[]) {
            Integer[] integerArray = (Integer[]) rawArray;
            int[] cugNumbers = new int[integerArray.length];
            for (int i = 0; i < integerArray.length; i++) {
                cugNumbers[i] = integerArray[i];
            }
            customer.setCugNumbers(cugNumbers);
        } else if (rawArray instanceof int[]) {
            customer.setCugNumbers((int[]) rawArray);
        } else {
            customer.setCugNumbers(new int[0]); // fallback empty
        }
    } else {
        customer.setCugNumbers(new int[0]); // null safe
    }

    return customer;
}


    private void setCustomerParameters(PreparedStatement stmt, Customer customer) throws SQLException {
        stmt.setString(1, customer.getNid());
        stmt.setString(2, customer.getName());
        stmt.setString(3, customer.getPhone());
        stmt.setInt(4, customer.getCreditLimit());
        stmt.setString(5, customer.getEmail());
        stmt.setString(6, customer.getAddress());
        stmt.setString(7, customer.getStatus());
        stmt.setTimestamp(8, customer.getRegistrationDate());
        stmt.setInt(9, customer.getPlanId());
        stmt.setInt(10, customer.getFreeUnitId());
        stmt.setInt(11, customer.getPromotionPackage());
        stmt.setString(12, customer.getOccName());
        stmt.setInt(13, customer.getOccPrice());
        stmt.setInt(14, customer.getMonthsNumberInstallments());
        
        if (customer.getCugNumbers() != null) {
            stmt.setArray(15, stmt.getConnection().createArrayOf("integer", toObjectArray(customer.getCugNumbers())));
        } else {
            stmt.setNull(15, Types.ARRAY);
        }
    }
    
    private Integer[] toObjectArray(int[] intArray) {
        if (intArray == null) return null;
        Integer[] result = new Integer[intArray.length];
        for (int i = 0; i < intArray.length; i++) {
            result[i] = intArray[i];
        }
        return result;
    }
}