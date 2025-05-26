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

        
        // Add these methods to your CustomerDAO class
public RatePlan getRatePlanDetails(int planId) throws SQLException {
    String sql = "SELECT * FROM rate_plan WHERE plan_id = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
        stmt.setInt(1, planId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                RatePlan ratePlan = new RatePlan();
                ratePlan.setPlanId(rs.getInt("plan_id"));
                ratePlan.setPlanName(rs.getString("plan_name"));
                ratePlan.setDescription(rs.getString("description"));
                ratePlan.setMonthlyFee(rs.getBigDecimal("monthly_fee"));
                ratePlan.setCug(rs.getBoolean("is_cug"));
                ratePlan.setMaxCugMembers(rs.getInt("max_cug_members"));
                ratePlan.setCugUnit(rs.getInt("cug_unit"));
                ratePlan.setCreatedAt(rs.getTimestamp("created_at"));
                
                // Get service packages for this rate plan
                ratePlan.setServicePackages(getServicePackagesForPlan(planId));
                return ratePlan;
            }
        }
    }
    return null;
}

public List<ServicePackage> getServicePackagesForPlan(int planId) throws SQLException {
    List<ServicePackage> services = new ArrayList<>();
    String sql = "SELECT sp.* FROM service_package sp " +
                 "JOIN rate_plan_service rps ON sp.service_id = rps.service_id " +
                 "WHERE rps.plan_id = ?";
    
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
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
    if (freeUnitId == null) return null;
    
    String sql = "SELECT * FROM service_package WHERE service_id = ? AND is_free_unite = 't'";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {
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
             "occ_name, occ_price, months_number_installments, cug_numbers) "+
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
    
    // Handle possible NULL for free_unit_id
    int freeUnitId = rs.getInt("free_unit_id");
    customer.setFreeUnitId(rs.wasNull() ? null : freeUnitId);
    
    customer.setPromotionPackage(rs.getInt("promotion_package"));
    customer.setOccName(rs.getString("occ_name"));
    customer.setOccPrice(rs.getInt("occ_price"));
    customer.setMonthsNumberInstallments(rs.getInt("months_number_installments"));

    // Handle cug_numbers array
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
            customer.setCugNumbers(new int[0]);
        }
    } else {
        customer.setCugNumbers(new int[0]);
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
    
    // Handle null freeUnitId
    if (customer.getFreeUnitId() != null) {
        stmt.setInt(10, customer.getFreeUnitId());
    } else {
        stmt.setNull(10, Types.INTEGER);
    }
    
    stmt.setInt(11, customer.getPromotionPackage());
    stmt.setString(12, customer.getOccName());
    stmt.setInt(13, customer.getOccPrice());
    stmt.setInt(14, customer.getMonthsNumberInstallments());
    
    // Handle cug_numbers array
    if (customer.getCugNumbers() != null && customer.getCugNumbers().length > 0) {
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