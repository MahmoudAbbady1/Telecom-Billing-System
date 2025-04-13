/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.telecom.controller;

import com.telecom.dao.CDRDAO;
import com.telecom.model.CDR;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import javax.servlet.annotation.MultipartConfig;
import java.io.*;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.List;
/**
 *
 * @author mibrahim
 */



@WebServlet(name = "CDRServlet", urlPatterns = {"/cdrs"})
@MultipartConfig(fileSizeThreshold = 1024 * 1024,
                 maxFileSize = 1024 * 1024 * 5,
                 maxRequestSize = 1024 * 1024 * 5 * 5)
public class CDRServlet extends HttpServlet {
    private CDRDAO cdrDAO;
    private SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    @Override
    public void init() {
        cdrDAO = new CDRDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if (action == null) {
                listCDRs(request, response);
            } else if (action.equals("process")) {
                processCDRs(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if (action == null) {
                uploadCDRFile(request, response);
            } else if (action.equals("manual")) {
                addManualCDR(request, response);
            }
        } catch (SQLException | ParseException ex) {
            throw new ServletException(ex);
        }
    }

    private void listCDRs(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<CDR> cdrs = cdrDAO.getRecentCDRs(100);
        request.setAttribute("cdrs", cdrs);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/cdr/list.jsp");
        dispatcher.forward(request, response);
    }

    private void uploadCDRFile(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException, ParseException {
        Part filePart = request.getPart("cdrFile");
        InputStream fileContent = filePart.getInputStream();
        BufferedReader reader = new BufferedReader(new InputStreamReader(fileContent));

        String line;
        while ((line = reader.readLine()) != null) {
            String[] parts = line.split(",");
            if (parts.length == 6) {
                CDR cdr = new CDR();
                cdr.setDialA(parts[0].trim());
                cdr.setDialB(parts[1].trim());
                cdr.setServiceId(Integer.parseInt(parts[2].trim()));
                cdr.setQuantity(Double.parseDouble(parts[3].trim()));
                cdr.setStartTime(new Timestamp(dateFormat.parse(parts[4].trim()).getTime()));
                cdr.setExternalCharges(Double.parseDouble(parts[5].trim()));
                
                cdrDAO.addCDR(cdr);
            }
        }
        reader.close();
        response.sendRedirect("cdrs?message=CDR file uploaded successfully");
    }

    private void addManualCDR(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ParseException {
        String dialA = request.getParameter("dialA");
        String dialB = request.getParameter("dialB");
        int serviceId = Integer.parseInt(request.getParameter("serviceId"));
        double quantity = Double.parseDouble(request.getParameter("quantity"));
        Timestamp startTime = new Timestamp(dateFormat.parse(request.getParameter("startTime")).getTime());
        double externalCharges = Double.parseDouble(request.getParameter("externalCharges"));

        CDR cdr = new CDR(dialA, dialB, serviceId, quantity, startTime);
        cdr.setExternalCharges(externalCharges);
        cdrDAO.addCDR(cdr);
        response.sendRedirect("cdrs?message=Manual CDR added successfully");
    }

    private void processCDRs(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        // This would typically call a billing service to process CDRs
        response.sendRedirect("cdrs?message=CDRs processed successfully");
    }
}