package com.telecom.dao;

import com.telecom.model.Customer;
import com.telecom.model.RatePlan;
import com.telecom.model.ServicePackage;
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
    private final DBConnection DBConnection = new DBConnection();

    public boolean phoneNumberExists(String phone) throws SQLException {
        String sql = "SELECT COUNT(*) FROM customers WHERE phone = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, phone);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public List<RatePlan> getAllRatePlans() throws SQLException {
        List<RatePlan> ratePlans = new ArrayList<>();
        String sql = "SELECT plan_id, plan_name, monthly_fee, is_cug, max_cug_members FROM rate_plan ORDER BY plan_id";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                RatePlan ratePlan = new RatePlan();
                ratePlan.setPlanId(rs.getInt("plan_id"));
                ratePlan.setPlanName(rs.getString("plan_name"));
                ratePlan.setCug(rs.getBoolean("is_cug"));
                ratePlan.setMaxCugMembers(rs.getInt("max_cug_members"));
                ratePlans.add(ratePlan);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching rate plans: " + e.getMessage());
            throw e;
        }
        return ratePlans;
    }

    public boolean phoneNumberExists(String phone, int excludeCustomerId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM customers WHERE phone = ? AND customer_id != ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
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

    public List<ServicePackage> getServicePackagesForPlan(int planId) throws SQLException {
        List<ServicePackage> services = new ArrayList<>();
        String sql = "SELECT sp.* FROM service_package sp "
                + "JOIN rate_plan_service rps ON sp.service_id = rps.service_id "
                + "WHERE rps.plan_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    services.add(extractServicePackageFromResultSet(rs));
                }
            }
        }
        return services;
    }

    public ServicePackage getFreeUnitDetails(Integer freeUnitId) throws SQLException {
        if (freeUnitId == null) {
            return null;
        }

        String sql = "SELECT * FROM service_package WHERE service_id = ? AND is_free_unite = 't'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, freeUnitId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractServicePackageFromResultSet(rs);
                }
            }
        }
        return null;
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

    public Customer getCustomerById(int customerId) throws SQLException {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
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

    public List<Customer> getAllCustomers() throws SQLException {
        List<Customer> customers = new ArrayList<>();
        String sql = "SELECT customer_id, nid, name, phone, credit_limit, email, address, "
                + "status, registration_date, plan_id, free_unit_id, occ_name, occ_price, "
                + "months_number_installments, cug_numbers, promotion_package, occ_mon_counter "
                + "FROM customers ORDER BY customer_id";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Customer customer = extractCustomerFromResultSet(rs);
                customers.add(customer);
            }
        } catch (SQLException e) {
            LOGGER.severe("Error fetching all customers: " + e.getMessage());
            throw e;
        }
        return customers;
    }

    public void addCustomer(Customer customer) throws SQLException {
        // Validate critical fields
        if (customer.getCreditLimit() <= 0) {
            throw new IllegalArgumentException("Credit limit must be positive");
        }
        if (customer.getOccPrice() > 0 && customer.getMonthsNumberInstallments() <= 0) {
            throw new IllegalArgumentException("Months number of installments must be positive when OCC price is greater than 0");
        }
        if (customer.getMonthsNumberInstallments() == 0) {
            customer.setOccPrice(0);
        }
        if (customer.getFreeUnitId() != null && customer.getFreeUnitId() <= 0) {
            customer.setFreeUnitId(null);
        }

        String sql = "INSERT INTO customers (nid, name, phone, credit_limit, email, address, "
                + "status, registration_date, plan_id, free_unit_id, "
                + "occ_name, occ_price, months_number_installments, cug_numbers, occ_mon_counter) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, customer.getNid());
            stmt.setString(2, customer.getName());
            stmt.setString(3, customer.getPhone());
            stmt.setInt(4, customer.getCreditLimit());
            stmt.setString(5, customer.getEmail());
            stmt.setString(6, customer.getAddress());
            stmt.setString(7, customer.getStatus());
            stmt.setTimestamp(8, customer.getRegistrationDate());
            stmt.setInt(9, customer.getPlanId());
            if (customer.getFreeUnitId() != null && customer.getFreeUnitId() > 0) {
                stmt.setInt(10, customer.getFreeUnitId());
            } else {
                stmt.setNull(10, Types.INTEGER);
            }
            stmt.setString(11, customer.getOccName());
            stmt.setInt(12, customer.getOccPrice());
            stmt.setInt(13, customer.getMonthsNumberInstallments());
            if (customer.getCugNumbers() != null && customer.getCugNumbers().length > 0) {
                stmt.setArray(14, conn.createArrayOf("VARCHAR", customer.getCugNumbers()));
            } else {
                stmt.setNull(14, Types.ARRAY);
            }
            if (customer.getOccMonCounter() != null) {
                stmt.setInt(15, customer.getOccMonCounter());
            } else {
                stmt.setNull(15, Types.INTEGER);
            }

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
        Customer existingCustomer = getCustomerById(customer.getCustomerId());
        if (customer.getRegistrationDate() == null && existingCustomer != null) {
            customer.setRegistrationDate(existingCustomer.getRegistrationDate());
        }

        String sql = "UPDATE customers SET nid = ?, name = ?, phone = ?, credit_limit = ?, "
                + "email = ?, address = ?, status = ?, registration_date = ?, plan_id = ?, "
                + "free_unit_id = ?, occ_name = ?, occ_price = ?, "
                + "months_number_installments = ?, cug_numbers = ?, promotion_package = ?, occ_mon_counter = ? "
                + "WHERE customer_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, customer.getNid());
            stmt.setString(2, customer.getName());
            stmt.setString(3, customer.getPhone());
            stmt.setInt(4, customer.getCreditLimit());
            stmt.setString(5, customer.getEmail());
            stmt.setString(6, customer.getAddress());
            stmt.setString(7, customer.getStatus());
            stmt.setTimestamp(8, customer.getRegistrationDate());
            stmt.setInt(9, customer.getPlanId());
            if (customer.getFreeUnitId() != null && customer.getFreeUnitId() > 0) {
                stmt.setInt(10, customer.getFreeUnitId());
            } else {
                stmt.setNull(10, Types.INTEGER);
            }
            stmt.setString(11, customer.getOccName());
            stmt.setInt(12, customer.getOccPrice());
            stmt.setInt(13, customer.getMonthsNumberInstallments());
            if (customer.getCugNumbers() != null && customer.getCugNumbers().length > 0) {
                stmt.setArray(14, conn.createArrayOf("VARCHAR", customer.getCugNumbers()));
            } else {
                stmt.setNull(14, Types.ARRAY);
            }
            stmt.setInt(15, customer.getPromotionPackage());
            if (customer.getOccMonCounter() != null) {
                stmt.setInt(16, customer.getOccMonCounter());
            } else {
                stmt.setNull(16, Types.INTEGER);
            }
            stmt.setInt(17, customer.getCustomerId());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("No customer found with ID: " + customer.getCustomerId());
            }
        }
    }

    public void deleteCustomer(int customerId) throws SQLException {
        String sql = "DELETE FROM customers WHERE customer_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
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

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
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
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                stats.put(rs.getString("status"), rs.getInt("count"));
            }
        }

        // Total count
        sql = "SELECT COUNT(*) as total FROM customers";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
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
    int freeUnitId = rs.getInt("free_unit_id");
    customer.setFreeUnitId(rs.wasNull() ? null : freeUnitId);
    customer.setOccName(rs.getString("occ_name"));
    customer.setOccPrice(rs.getInt("occ_price"));
    customer.setMonthsNumberInstallments(rs.getInt("months_number_installments"));
    customer.setPromotionPackage(rs.getInt("promotion_package"));
    int occMonCounter = rs.getInt("occ_mon_counter");
    customer.setOccMonCounter(rs.wasNull() ? null : occMonCounter);

    Array cugArray = rs.getArray("cug_numbers");
    if (cugArray != null) {
        customer.setCugNumbers((String[]) cugArray.getArray());
    } else {
        customer.setCugNumbers(new String[0]);
    }

    // Calculate price_occ_per_month if needed
    if (customer.getOccPrice() > 0 && customer.getMonthsNumberInstallments() > 0) {
        customer.setPrice_occ_per_month((float) customer.getOccPrice() / customer.getMonthsNumberInstallments());
    } else {
        customer.setPrice_occ_per_month(0.0f);
    }

    return customer;
}
}