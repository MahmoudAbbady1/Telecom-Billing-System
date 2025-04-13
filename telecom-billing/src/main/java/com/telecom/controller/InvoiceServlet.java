/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.telecom.controller;

import com.telecom.dao.InvoiceDAO;
import com.telecom.model.Invoice;
import com.telecom.service.BillingService;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
/**
 *
 * @author mibrahim
 */


@WebServlet(name = "InvoiceServlet", urlPatterns = {"/invoices"})
public class InvoiceServlet extends HttpServlet {
    private InvoiceDAO invoiceDAO;
    private BillingService billingService;

    @Override
    public void init() {
        invoiceDAO = new InvoiceDAO();
        billingService = new BillingService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if (null == action) {
                String customerIdParam = request.getParameter("customerId");
                if (customerIdParam != null) {
                    int customerId = Integer.parseInt(customerIdParam);
                    listCustomerInvoices(request, response, customerId);
                } else {
                    listAllInvoices(request, response);
                }
            } else switch (action) {
                case "generate":
                    generateInvoices(request, response);
                    break;
                case "view":
                    viewInvoice(request, response);
                    break;
                case "download":
                    downloadInvoice(request, response);
                    break;
                default:
                    break;
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listAllInvoices(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<Invoice> invoices = invoiceDAO.getAllInvoices();
        request.setAttribute("invoices", invoices);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/invoice/list.jsp");
        dispatcher.forward(request, response);
    }

    private void listCustomerInvoices(HttpServletRequest request, HttpServletResponse response, int customerId)
            throws SQLException, ServletException, IOException {
        List<Invoice> invoices = invoiceDAO.getInvoicesForCustomer(customerId);
        request.setAttribute("invoices", invoices);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/invoice/list.jsp");
        dispatcher.forward(request, response);
    }

    private void generateInvoices(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String customerIdParam = request.getParameter("customerId");
        if (customerIdParam != null) {
            int customerId = Integer.parseInt(customerIdParam);
            billingService.generateInvoiceForCustomer(customerId);
            response.sendRedirect("invoices?customerId=" + customerId + "&message=Invoice generated successfully");
        } else {
            billingService.generateMonthlyInvoices(); //------->>>>>  check it also
            response.sendRedirect("invoices?message=All invoices generated successfully");
        }
    }

    private void viewInvoice(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int invoiceId = Integer.parseInt(request.getParameter("id"));
        Invoice invoice = invoiceDAO.getInvoice(invoiceId); //--->>>> also this implemnt invoiceDAO.getInvoice
        request.setAttribute("invoice", invoice);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/invoice/view.jsp");
        dispatcher.forward(request, response);
    }

    private void downloadInvoice(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int invoiceId = Integer.parseInt(request.getParameter("id"));
        // This would stream the PDF file to the response
        response.sendRedirect("invoices?message=Invoice downloaded successfully");
    }
}