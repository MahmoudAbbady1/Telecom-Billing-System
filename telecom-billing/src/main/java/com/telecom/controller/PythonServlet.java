package com.telecom.controller;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.File;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@Path("/api")
@Produces(MediaType.TEXT_PLAIN)
@Consumes(MediaType.APPLICATION_JSON)
public class PythonServlet {
    private static final Logger LOGGER = Logger.getLogger(PythonServlet.class.getName());
    private static final String PYTHON_SCRIPT_PATH = System.getProperty("python.script.path", 
        "/home/mibrahim/ITI_Projects/billingV2/Telecom-Billing-System/telecom-billing/src/main/webapp/CDR-Gen/CDR-Generator.py");

    public PythonServlet() {
        // Constructor for potential dependency injection
    }

    @POST
    @Path("/run-python")
    public Response runPythonScript(PythonRequest request) {
        try {
            // Log the script path for debugging
            LOGGER.log(Level.INFO, "Python script path: {0}", new File(PYTHON_SCRIPT_PATH).getAbsolutePath());

            // Execute the Python script
            ProcessBuilder processBuilder = new ProcessBuilder("python3", PYTHON_SCRIPT_PATH);
            processBuilder.redirectErrorStream(true);
            LOGGER.log(Level.INFO, "Executing command: python3 {0}", PYTHON_SCRIPT_PATH);
            Process process = processBuilder.start();

            // Capture output and errors
            StringBuilder output = new StringBuilder();
            StringBuilder errorOutput = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                }
            }
            try (BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()))) {
                String line;
 
                while ((line = errorReader.readLine()) != null) {
                    errorOutput.append(line).append("\n");
                }
            }

            int exitCode = process.waitFor();
            if (exitCode == 0) {
                String result = output.length() > 0 ? output.toString() : "Python script executed successfully!";
                LOGGER.log(Level.INFO, "Python script output: {0}", result);
                return Response.ok(result).build();
            } else {
                String errorMsg = "Error running Python script: Exit code " + exitCode + "\nOutput: " + output.toString() + "\nError: " + errorOutput.toString();
                LOGGER.log(Level.SEVERE, errorMsg);
                return errorResponse(errorMsg, new Exception(errorMsg));
            }
        } catch (Exception e) {
            String errorMsg = "Exception running Python script: " + e.getMessage();
            LOGGER.log(Level.SEVERE, errorMsg, e);
            return errorResponse(errorMsg, e);
        }
    }

    // Validation removed since customerCsvMap is not used by the script
    private Response validateRequest(PythonRequest request) {
        // If the Python script needs customerCsvMap, implement validation or pass it as an argument
        return null;
    }

    private Response errorResponse(String message, Exception e) {
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(message + ": " + e.getMessage())
                .build();
    }

    public static class PythonRequest {
        @JsonProperty("customerCsvMap")
        private Map<String, String> customerCsvMap;

        public Map<String, String> getCustomerCsvMap() {
            return customerCsvMap;
        }

        public void setCustomerCsvMap(Map<String, String> customerCsvMap) {
            this.customerCsvMap = customerCsvMap;
        }
    }
}