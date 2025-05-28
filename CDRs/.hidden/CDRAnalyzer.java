import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.InputStreamReader;

/**
 * Enhanced CDR Analyzer - Calculates service usage statistics from CDR files
 * and compares with customer plans for billing purposes using API data
 */
class CDRAnalyzer {

    // Service types
    private static final int VOICE_SERVICE = 1;
    private static final int SMS_SERVICE = 2;
    private static final int DATA_SERVICE = 3;
    
    // Service zone types
    private static final String LOCAL = "LOCAL";
    private static final String ROAMING = "ROAMING";
    private static final String NET = "NET";

    // API endpoint
    private static final String API_URL = "http://localhost:8080/telecom-billing/api/customers";

    // Overage rates in EGP
    private static final double LOCAL_VOICE_RATE = 0.25; // EGP per minute
    private static final double ROAMING_VOICE_RATE = 1.5; // EGP per minute
    private static final double SMS_RATE = 0.25; // EGP per message
    private static final double DATA_RATE = 0.5; // EGP per MB

    /**
     * Customer profile class to store customer data and plan information
     */
    static class CustomerProfile {
        String phoneNumber;
        int customerId;
        String name;
        double creditLimit; // in EGP
        String status;
        int planId;
        String planName;
        double monthlyFee; // in EGP
        boolean isCug;
        int maxCugMembers;
        int cugUnit;
        Set<String> cugNumbers = new HashSet<>();
        
        // Service allowances (service ID -> package)
        Map<Integer, ServicePackage> services = new HashMap<>();
        
        // Current usage tracking
        long localVoiceSeconds = 0; // in seconds
        long roamingVoiceSeconds = 0; // in seconds
        long smsUsage = 0;
        long dataUsage = 0; // in bytes

        @Override
        public String toString() {
            return "Customer: " + name + " (" + phoneNumber + "), Plan: " + planName;
        }
    }
    
    /**
     * Service package information
     */
    static class ServicePackage {
        int serviceId;
        String serviceName;
        String serviceType;
        String networkZone;
        long quota; // in minutes for VOICE, messages for SMS, MB for DATA
        String unitDescription;
        boolean isFreeUnit;
        double freeUnitMonthlyFee; // in EGP
        
        // Usage tracking
        long used = 0; // same unit as quota
        
        public long getRemaining() {
            return quota - used;
        }
        
        @Override
        public String toString() {
            return serviceName + " (" + quota + " " + unitDescription + ")";
        }
    }
    
    /**
     * CDR Record class to store parsed CDR data
     */
    private static class CDRRecord {
        String phoneNumber;
        String destination;
        int serviceType;
        long amount;
        String timestamp;
        int extraParam;
        
        boolean isDataService() {
            return serviceType == DATA_SERVICE;
        }
        
        boolean isVoiceService() {
            return serviceType == VOICE_SERVICE;
        }
        
        boolean isSmsService() {
            return serviceType == SMS_SERVICE;
        }
        
        boolean isRoaming() {
            return destination.startsWith("+") && !destination.startsWith("+201");
        }
        
        boolean isSocialMedia() {
            return destination.contains("facebook") || 
                   destination.contains("twitter") || 
                   destination.contains("instagram") ||
                   destination.contains("whatsapp");
        }
        
        String getNetworkZone() {
            if (isDataService()) {
                if (isSocialMedia()) {
                    return NET;
                }
                return LOCAL;
            } 
            
            if (isRoaming()) {
                return ROAMING;
            }
            
            return LOCAL;
        }
    }
    
    /**
     * Main entry point
     */
    public static void main(String[] args) {
        String inputPath = "."; // Default to current directory
        
        if (args.length > 0) {
            inputPath = args[0];
        }
        
        try {
            // Load customer profiles from API
            Map<String, CustomerProfile> customers = loadCustomerProfiles();
            
            if (customers.isEmpty()) {
                System.out.println("No customer profiles loaded. Please check API connection.");
                return;
            }
            
            System.out.println("Loaded " + customers.size() + " customer profiles");
            
            // Process CDR files
            File input = new File(inputPath);
            if (input.isDirectory()) {
                File[] cdrFiles = input.listFiles((dir, name) -> name.startsWith("CDR_") && name.endsWith(".txt"));
                if (cdrFiles != null && cdrFiles.length > 0) {
                    System.out.println("Found " + cdrFiles.length + " CDR files to process");
                    for (File cdrFile : cdrFiles) {
                        try {
                            System.out.println("Processing file: " + cdrFile.getPath());
                            processCDRFile(cdrFile.getPath(), customers);
                        } catch (Exception e) {
                            System.err.println("Error processing file " + cdrFile.getPath() + ": " + e.getMessage());
                            e.printStackTrace();
                        }
                    }
                } else {
                    System.out.println("No CDR files found in directory: " + inputPath);
                }
            } else {
                processCDRFile(inputPath, customers);
            }
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Loads customer profiles from the API
     */
    private static Map<String, CustomerProfile> loadCustomerProfiles() throws IOException {
        Map<String, CustomerProfile> customers = new HashMap<>();
        
        // Make HTTP request to API
        URL url = URI.create(API_URL).toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Accept", "application/json");
        
        int responseCode = conn.getResponseCode();
        if (responseCode != 200) {
            throw new IOException("Failed to fetch customers from API, status code: " + responseCode);
        }
        
        // Read response
        StringBuilder response = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
        }
        conn.disconnect();
        
        // Parse JSON response
        JSONArray jsonArray;
        try {
            jsonArray = new JSONArray(response.toString());
        } catch (Exception e) {
            JSONObject singleObject = new JSONObject(response.toString());
            jsonArray = new JSONArray();
            jsonArray.put(singleObject);
        }
        
        // Process each customer
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject jsonCustomerObj = jsonArray.getJSONObject(i);
            JSONObject jsonCustomer = jsonCustomerObj.getJSONObject("customer");
            JSONObject jsonRatePlan = jsonCustomerObj.getJSONObject("ratePlan");
            
            CustomerProfile customer = new CustomerProfile();
            customer.customerId = jsonCustomer.getInt("customerId");
            customer.name = jsonCustomer.getString("name");
            customer.phoneNumber = normalizePhoneNumber(jsonCustomer.getString("phone"));
            customer.creditLimit = jsonCustomer.getDouble("creditLimit"); // in EGP
            customer.status = jsonCustomer.getString("status");
            customer.planId = jsonCustomer.getInt("planId");
            customer.planName = jsonRatePlan.getString("planName");
            customer.monthlyFee = jsonRatePlan.getDouble("monthlyFee"); // in EGP
            customer.isCug = jsonRatePlan.getBoolean("isCug");
            customer.maxCugMembers = jsonRatePlan.getInt("maxCugMembers");
            customer.cugUnit = jsonRatePlan.getInt("cugUnit");
            
            // Parse CUG numbers
            JSONArray cugNumbers = jsonCustomer.getJSONArray("cugNumbers");
            for (int j = 0; j < cugNumbers.length(); j++) {
                customer.cugNumbers.add(cugNumbers.getString(j));
            }
            
            // Load service packages
            JSONArray servicePackages = jsonRatePlan.getJSONArray("servicePackages");
            for (int j = 0; j < servicePackages.length(); j++) {
                JSONObject serviceJson = servicePackages.getJSONObject(j);
                ServicePackage service = new ServicePackage();
                service.serviceId = serviceJson.getInt("serviceId");
                service.serviceName = serviceJson.getString("serviceName");
                service.serviceType = serviceJson.getString("serviceType");
                service.networkZone = serviceJson.getString("serviceNetworkZone");
                service.quota = serviceJson.getInt("qouta"); // Fixed to match API
                service.unitDescription = serviceJson.getString("unitDescription");
                service.isFreeUnit = serviceJson.getBoolean("freeUnite"); // Fixed to match API
                service.freeUnitMonthlyFee = serviceJson.getDouble("freeUnitMonthlyFee"); // in EGP
                
                customer.services.put(service.serviceId, service);
            }
            
            // Load free unit if present
            if (!jsonCustomerObj.isNull("freeUnit")) {
                JSONObject freeUnitJson = jsonCustomerObj.getJSONObject("freeUnit");
                ServicePackage freeUnit = new ServicePackage();
                freeUnit.serviceId = freeUnitJson.getInt("serviceId");
                freeUnit.serviceName = freeUnitJson.getString("serviceName");
                freeUnit.serviceType = freeUnitJson.getString("serviceType");
                freeUnit.networkZone = freeUnitJson.getString("serviceNetworkZone");
                freeUnit.quota = freeUnitJson.getInt("qouta"); // Fixed to match API
                freeUnit.unitDescription = freeUnitJson.getString("unitDescription");
                freeUnit.isFreeUnit = freeUnitJson.getBoolean("freeUnite"); // Fixed to match API
                freeUnit.freeUnitMonthlyFee = freeUnitJson.getDouble("freeUnitMonthlyFee"); // in EGP
                
                // Only add free unit if it doesn't duplicate an existing service
                boolean serviceExists = false;
                for (ServicePackage existingService : customer.services.values()) {
                    if (existingService.serviceId == freeUnit.serviceId || 
                        (existingService.serviceType.equals(freeUnit.serviceType) && 
                         existingService.networkZone.equals(freeUnit.networkZone))) {
                        serviceExists = true;
                        break;
                    }
                }
                if (!serviceExists) {
                    customer.services.put(freeUnit.serviceId, freeUnit);
                }
            }
            
            customers.put(customer.phoneNumber, customer);
        }
        
        return customers;
    }
    
    /**
     * Processes a single CDR file and generates a billing report
     */
    private static void processCDRFile(String filePath, Map<String, CustomerProfile> customers) throws IOException {
        String fileName = new File(filePath).getName();
        String phoneNumber = "+" + fileName.replace("CDR_", "").replace(".txt", "");
        phoneNumber = normalizePhoneNumber(phoneNumber);
        
        CustomerProfile customer = customers.get(phoneNumber);
        if (customer == null) {
            System.out.println("No customer profile found for phone number: " + phoneNumber + " in file: " + filePath);
            return;
        }
        
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            int lineCount = 0;
            int processedRecords = 0;
            
            while ((line = reader.readLine()) != null) {
                lineCount++;
                
                try {
                    CDRRecord record = parseCDRRecord(line);
                    if (record.phoneNumber.equals(customer.phoneNumber)) {
                        processCustomerRecord(customer, record);
                        processedRecords++;
                    }
                } catch (Exception e) {
                    System.err.println("Error processing line " + lineCount + " in file " + filePath + ": " + e.getMessage());
                }
            }
            
            System.out.println("Processed " + processedRecords + " records for " + customer.phoneNumber + " in file: " + filePath);
            
            generateCustomerBillingReport(customer);
        }
    }
    
    /**
     * Parses a CDR record from a text line
     */
    private static CDRRecord parseCDRRecord(String line) {
        String[] fields = line.split(",");
        
        if (fields.length < 6) {
            throw new IllegalArgumentException("Invalid CDR record format: " + line);
        }
        
        CDRRecord record = new CDRRecord();
        record.phoneNumber = normalizePhoneNumber(fields[0]);
        record.destination = fields[1];
        record.serviceType = Integer.parseInt(fields[2]);
        record.amount = Long.parseLong(fields[3]);
        record.timestamp = fields[4];
        record.extraParam = Integer.parseInt(fields[5]);
        
        return record;
    }
    
    /**
     * Normalizes phone numbers to start with '+20' instead of '01'
     */
    private static String normalizePhoneNumber(String phoneNumber) {
        if (phoneNumber.startsWith("01")) {
            return "+2" + phoneNumber;
        } else if (phoneNumber.startsWith("2")) {
            return "+" + phoneNumber;
        }
        return phoneNumber;
    }
    
    /**
     * Processes a CDR record for a specific customer
     */
    private static void processCustomerRecord(CustomerProfile customer, CDRRecord record) {
        boolean isCugCommunication = false;
        if (customer.isCug && (record.serviceType == VOICE_SERVICE || record.serviceType == SMS_SERVICE)) {
            String destinationShort = record.destination.replace("+", "");
            for (String cugNumber : customer.cugNumbers) {
                // Check if destination ends with or matches CUG number
                if (destinationShort.endsWith(cugNumber) || destinationShort.equals(cugNumber)) {
                    isCugCommunication = true;
                    break;
                }
            }
        }
        
        // Update usage counters
        if (!isCugCommunication) {
            switch (record.serviceType) {
                case VOICE_SERVICE:
                    if (record.isRoaming()) {
                        customer.roamingVoiceSeconds += record.amount;
                    } else {
                        customer.localVoiceSeconds += record.amount;
                    }
                    break;
                case SMS_SERVICE:
                    customer.smsUsage += record.amount;
                    break;
                case DATA_SERVICE:
                    customer.dataUsage += record.amount; // bytes
                    break;
            }
        }
        
        if (isCugCommunication) {
            return;
        }
        
        // Update service usage
        String recordZone = record.getNetworkZone();
        ServicePackage matchingService = null;
        for (ServicePackage service : customer.services.values()) {
            boolean zoneMatch = service.networkZone.equals(recordZone) ||
                               (service.networkZone.equals(NET) && (recordZone.equals(LOCAL) || recordZone.equals(ROAMING) || record.isSocialMedia()));
            if ((record.serviceType == VOICE_SERVICE && service.serviceType.equals("VOICE") && zoneMatch) ||
                (record.serviceType == SMS_SERVICE && service.serviceType.equals("SMS") && zoneMatch) ||
                (record.serviceType == DATA_SERVICE && service.serviceType.equals("DATA") && zoneMatch)) {
                matchingService = service;
                break;
            }
        }
        
        if (matchingService != null) {
            if (record.serviceType == VOICE_SERVICE) {
                matchingService.used += record.amount / 60; // seconds to minutes
            } else if (record.serviceType == SMS_SERVICE) {
                matchingService.used += record.amount;
            } else if (record.serviceType == DATA_SERVICE) {
                matchingService.used += record.amount / (1024 * 1024); // bytes to MB
            }
        }
    }
    
    /**
     * Balances usage across services to minimize overage charges
     */
    private static void balanceUsage(CustomerProfile customer) {
        // Collect services
        Map<Integer, ServicePackage> services = new HashMap<>();
        for (ServicePackage service : customer.services.values()) {
            services.put(service.serviceId, service);
        }
        
        if (services.size() < 2) {
            return;
        }
        
        // Calculate total overage in EGP
        double totalOverageCost = 0;
        Map<Integer, Long> overages = new HashMap<>();
        long localVoiceOverage = 0;
        long roamingVoiceOverage = 0;
        
        for (ServicePackage service : services.values()) {
            long overage = service.used - service.quota;
            if (overage > 0) {
                overages.put(service.serviceId, overage);
                if (service.serviceType.equals("VOICE") && service.networkZone.equals(NET)) {
                    long totalVoiceMinutes = (customer.localVoiceSeconds + customer.roamingVoiceSeconds) / 60;
                    long localVoiceMinutes = customer.localVoiceSeconds / 60;
                    long roamingVoiceMinutes = customer.roamingVoiceSeconds / 60;
                    if (totalVoiceMinutes > service.quota) {
                        long voiceOverage = totalVoiceMinutes - service.quota;
                        double roamingFraction = (double)roamingVoiceMinutes / totalVoiceMinutes;
                        roamingVoiceOverage = (long)(voiceOverage * roamingFraction);
                        localVoiceOverage = voiceOverage - roamingVoiceOverage; // Fixed typo
                        totalOverageCost += localVoiceOverage * LOCAL_VOICE_RATE + roamingVoiceOverage * ROAMING_VOICE_RATE;
                    }
                } else if (service.serviceType.equals("SMS")) {
                    totalOverageCost += overage * SMS_RATE;
                } else if (service.serviceType.equals("DATA")) {
                    totalOverageCost += overage * DATA_RATE;
                }
                service.used = service.quota; // Reset to quota
            }
        }
        
        if (totalOverageCost == 0) {
            return;
        }
        
        // Redistribute based on cost efficiency
        while (totalOverageCost > 0) {
            ServicePackage bestService = null;
            double bestCostPerUnit = Double.MAX_VALUE;
            long bestRemaining = 0;
            boolean isRoamingVoice = false;
            
            for (ServicePackage service : services.values()) {
                long remaining = service.quota - service.used;
                if (remaining > 0) {
                    double costPerUnit;
                    if (service.serviceType.equals("VOICE") && service.networkZone.equals(NET)) {
                        costPerUnit = LOCAL_VOICE_RATE;
                    } else if (service.serviceType.equals("SMS")) {
                        costPerUnit = SMS_RATE;
                    } else if (service.serviceType.equals("DATA")) {
                        costPerUnit = DATA_RATE;
                    } else {
                        continue;
                    }
                    if (costPerUnit < bestCostPerUnit || (costPerUnit == bestCostPerUnit && remaining > bestRemaining)) {
                        bestService = service;
                        bestCostPerUnit = costPerUnit;
                        bestRemaining = remaining;
                        isRoamingVoice = false;
                    }
                }
            }
            
            // Check for roaming voice if local options are exhausted
            if (bestService == null || roamingVoiceOverage > 0) {
                for (ServicePackage service : services.values()) {
                    if (service.serviceType.equals("VOICE") && service.networkZone.equals(NET)) {
                        long remaining = service.quota - service.used;
                        if (remaining > 0) {
                            double costPerUnit = ROAMING_VOICE_RATE;
                            if (costPerUnit < bestCostPerUnit || bestService == null) {
                                bestService = service;
                                bestCostPerUnit = costPerUnit;
                                bestRemaining = remaining;
                                isRoamingVoice = true;
                            }
                        }
                    }
                }
            }
            
            if (bestService == null) {
                break; // No service can take more usage
            }
            
            // Convert cost to units
            double rate = isRoamingVoice ? ROAMING_VOICE_RATE : 
                         bestService.serviceType.equals("VOICE") ? LOCAL_VOICE_RATE :
                         bestService.serviceType.equals("SMS") ? SMS_RATE : DATA_RATE;
            long unitsToAdd = (long)(totalOverageCost / rate);
            unitsToAdd = Math.min(unitsToAdd, bestRemaining);
            bestService.used += unitsToAdd;
            totalOverageCost -= unitsToAdd * rate;
        }
    }
    
    /**
     * Generates a billing report for a single customer
     */
    private static void generateCustomerBillingReport(CustomerProfile customer) {
        ensureDefaultServices(customer);
        
        // Balance usage to minimize overage
        balanceUsage(customer);
        
        System.out.println("\n" + customer);
        System.out.println("--------------------------------------------------");

        double monthlyFeeEGP = customer.monthlyFee; // Already in EGP
        double totalCharge = monthlyFeeEGP;
        System.out.printf("Base Plan Fee: %.2f EGP\n", monthlyFeeEGP);

        double overageCharge = 0;

        System.out.println("\nService Usage:");
        System.out.println("--------------------------------------------------");
        System.out.printf("%-25s %-10s %-10s %-10s %-10s\n", 
            "Service", "Quota", "Used", "Overage", "Charge (EGP)");

        // Process each service
        for (ServicePackage service : customer.services.values()) {
            long used = service.used;
            long overage = 0;
            double charge = 0;
            
            if (service.serviceType.equals("VOICE") && service.networkZone.equals(NET)) {
                long totalVoiceMinutes = (customer.localVoiceSeconds + customer.roamingVoiceSeconds) / 60;
                long localVoiceMinutes = customer.localVoiceSeconds / 60;
                long roamingVoiceMinutes = customer.roamingVoiceSeconds / 60;
                used = totalVoiceMinutes;
                if (used > service.quota) {
                    overage = used - service.quota;
                    double roamingFraction = roamingVoiceMinutes > 0 ? (double)roamingVoiceMinutes / totalVoiceMinutes : 0;
                    long roamingOverage = (long)(overage * roamingFraction);
                    long localOverage = overage - roamingOverage;
                    charge = localOverage * LOCAL_VOICE_RATE + roamingOverage * ROAMING_VOICE_RATE;
                }
            } else if (service.serviceType.equals("VOICE") && service.networkZone.equals(ROAMING)) {
                long roamingVoiceMinutes = customer.roamingVoiceSeconds / 60;
                used = roamingVoiceMinutes;
                overage = Math.max(0, used - service.quota);
                charge = overage * ROAMING_VOICE_RATE;
            } else if (service.serviceType.equals("SMS")) {
                used = customer.smsUsage;
                overage = Math.max(0, used - service.quota);
                charge = overage * SMS_RATE;
            } else if (service.serviceType.equals("DATA")) {
                used = customer.dataUsage / (1024 * 1024); // bytes to MB
                overage = Math.max(0, used - service.quota);
                charge = overage * DATA_RATE;
            }
            
            overageCharge += charge;
            
            System.out.printf("%-25s %-10d %-10d %-10d %-10.2f\n",
                service.serviceName, service.quota, used, overage, charge);
        }

        totalCharge += overageCharge;

        // Display usage summary
        int totalVoiceMinutes = (int)((customer.localVoiceSeconds + customer.roamingVoiceSeconds) / 60);
        int localVoiceMinutes = (int)(customer.localVoiceSeconds / 60);
        int roamingVoiceMinutes = (int)(customer.roamingVoiceSeconds / 60);
        System.out.printf("\nTotal Voice usage: %d minutes (Local: %d, Roaming: %d)\n", 
            totalVoiceMinutes, localVoiceMinutes, roamingVoiceMinutes);
        System.out.printf("Total SMS usage: %d messages\n", customer.smsUsage);
        double dataMB = customer.dataUsage / (1024.0 * 1024.0);
        if (dataMB > 0 && hasDataService(customer)) {
            System.out.printf("Total Data usage: %.2f MB\n", dataMB);
        }

        System.out.printf("\nOverage Charges: %.2f EGP\n", overageCharge);
        System.out.printf("Total Estimated Bill: %.2f EGP\n", totalCharge);
        System.out.printf("Credit Limit: %.2f EGP\n", customer.creditLimit); // Already in EGP

        if (totalCharge > customer.creditLimit) {
            double overLimit = totalCharge - customer.creditLimit;
            System.out.printf("⛔ CRITICAL: Exceeds credit limit by %.2f EGP (%.0f%%)\n",
                overLimit, (overLimit/customer.creditLimit)*100);
        }
    }

    /**
     * Ensures default services exist in customer profile
     */
    private static void ensureDefaultServices(CustomerProfile customer) {
        boolean hasVoice = false, hasSms = false, hasData = false;
        for (ServicePackage service : customer.services.values()) {
            if (service.serviceType.equals("VOICE") && service.networkZone.equals(NET)) {
                hasVoice = true;
            } else if (service.serviceType.equals("SMS")) {
                hasSms = true;
            } else if (service.serviceType.equals("DATA")) {
                hasData = true;
            }
        }

        if (!hasVoice) {
            addService(customer, createDefaultService("Voice 100", "VOICE", NET, 100, "minutes", false, 0.0));
        }
        if (!hasSms) {
            addService(customer, createDefaultService("SMS 500", "SMS", NET, 500, "messages", false, 0.0));
        }
        if (!hasData && hasDataService(customer)) {
            addService(customer, createDefaultService("Data 1GB", "DATA", NET, 1024, "MB", false, 0.0));
        }
    }

    private static boolean hasService(CustomerProfile customer, String serviceType, String zone) {
        for (ServicePackage service : customer.services.values()) {
            if (service.serviceType.equals(serviceType) && service.networkZone.equals(zone)) {
                return true;
            }
        }
        return false;
    }

    private static boolean hasDataService(CustomerProfile customer) {
        for (ServicePackage service : customer.services.values()) {
            if (service.serviceType.equals("DATA")) {
                return true;
            }
        }
        return false;
    }

    private static void addService(CustomerProfile customer, ServicePackage service) {
        service.serviceId = -Math.abs(service.serviceName.hashCode());
        customer.services.put(service.serviceId, service);
    }

    private static ServicePackage createDefaultService(String name, String type, String zone, 
                                                     long quota, String unit, boolean isFree, double rate) {
        ServicePackage service = new ServicePackage();
        service.serviceName = name;
        service.serviceType = type;
        service.networkZone = zone;
        service.quota = quota;
        service.unitDescription = unit;
        service.isFreeUnit = isFree;
        service.freeUnitMonthlyFee = rate;
        return service;
    }
}
