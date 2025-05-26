<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.*, java.net.*, org.json.*, java.util.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Select and Add Service</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding-top: 30px;
        }
        select, input[type=button] {
            font-size: 16px;
            padding: 8px;
            margin: 10px;
        }
        table {
            border-collapse: collapse;
            width: 80%;
            margin: 30px auto;
        }
        th, td {
            border: 1px solid #888;
            padding: 8px;
            text-align: center;
        }
        th {
            background-color: #eee;
        }
    </style>
</head>
<body>
<h2>Select and Add Service</h2>

<%
    String apiUrl = "http://localhost:8080/telecom-billing/api/rate-plans/services/available";
    StringBuilder result = new StringBuilder();
    JSONArray jsonArray = null;

    try {
        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String line;
        while ((line = rd.readLine()) != null) {
            result.append(line);
        }
        rd.close();

        jsonArray = new JSONArray(result.toString());
    } catch (Exception e) {
%>
    <p style="color:red;">Error fetching services: <%= e.getMessage() %></p>
<%
    }
%>

<form onsubmit="return false;">
    <label for="services">Choose a service:</label><br>
    <select id="servicesDropdown">
        <option value="">-- Select a service --</option>
        <% 
            if (jsonArray != null) {
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject service = jsonArray.getJSONObject(i);
                    int id = service.getInt("serviceId");
                    String name = service.getString("serviceName");
                    String type = service.getString("serviceType");
        %>
        <option value="<%= id %>" data-name="<%= name %>" data-type="<%= type %>">
            <%= name %> - <%= type %>
        </option>
        <% 
                }
            }
        %>
    </select>

    <input type="button" value="Add Service" onclick="addServiceToTable()">
</form>

<table id="selectedServicesTable" style="display:none;">
    <thead>
        <tr>
            <th>Service ID</th>
            <th>Service Name</th>
            <th>Service Type</th>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>

<script>
    const addedServiceIds = new Set();
function addServiceToTable() {
    const dropdown = document.getElementById("servicesDropdown");
    const selectedOption = dropdown.options[dropdown.selectedIndex];

    if (!selectedOption.value) {
        alert("Please select a service.");
        return;
    }

    const serviceId = selectedOption.value;
    const serviceName = selectedOption.getAttribute("data-name");
    const serviceType = selectedOption.getAttribute("data-type");

    if (addedServiceIds.has(serviceId)) {
        alert("Service already added.");
        return;
    }

    const table = document.getElementById("selectedServicesTable");
    const tbody = table.querySelector("tbody");
    
    // Create row and cells using DOM methods instead of innerHTML
    const row = tbody.insertRow();
    
    const cell1 = row.insertCell(0);
    const cell2 = row.insertCell(1);
    const cell3 = row.insertCell(2);
    
    cell1.textContent = serviceId;
    cell2.textContent = serviceName;
    cell3.textContent = serviceType;

    table.style.display = "table";
    addedServiceIds.add(serviceId);
}
</script>

</body>
</html>
