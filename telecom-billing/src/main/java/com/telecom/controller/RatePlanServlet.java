package com.telecom.controller;

import com.telecom.dao.RatePlanDAO;
import com.telecom.model.RatePlan;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "RatePlanServlet", urlPatterns = {"/rateplans"})
public class RatePlanServlet extends HttpServlet {
    private RatePlanDAO ratePlanDAO;

    @Override
    public void init() {
        ratePlanDAO = new RatePlanDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if (action == null) {
                listRatePlans(request, response);
            } else {
                switch (action) {
                    case "new":
                        showNewForm(request, response);
                        break;
                    case "edit":
                        showEditForm(request, response);
                        break;
                    case "delete":
                        deleteRatePlan(request, response);
                        break;
                    default:
                        listRatePlans(request, response);
                        break;
                }
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
                insertRatePlan(request, response);
            } else if (action.equals("update")) {
                updateRatePlan(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listRatePlans(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<RatePlan> ratePlans = ratePlanDAO.getAllRatePlans();
        request.setAttribute("ratePlans", ratePlans);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/rateplan/list.jsp");
        dispatcher.forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/rateplan/form.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        RatePlan ratePlan = ratePlanDAO.getRatePlan(id);
        request.setAttribute("ratePlan", ratePlan);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/rateplan/form.jsp");
        dispatcher.forward(request, response);
    }

    private void insertRatePlan(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String planName = request.getParameter("planName");
        String description = request.getParameter("description");
        double basePrice = Double.parseDouble(request.getParameter("basePrice"));
        boolean isActive = request.getParameter("isActive") != null;

        RatePlan newRatePlan = new RatePlan(planName, description, basePrice);
        newRatePlan.setActive(isActive);
        ratePlanDAO.addRatePlan(newRatePlan);
        response.sendRedirect("rateplans");
    }

    private void updateRatePlan(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String planName = request.getParameter("planName");
        String description = request.getParameter("description");
        double basePrice = Double.parseDouble(request.getParameter("basePrice"));
        boolean isActive = request.getParameter("isActive") != null;

        RatePlan ratePlan = new RatePlan(planName, description, basePrice);
        ratePlan.setPlanId(id);
        ratePlan.setActive(isActive);
        ratePlanDAO.updateRatePlan(ratePlan);
        response.sendRedirect("rateplans");
    }

    private void deleteRatePlan(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        ratePlanDAO.deleteRatePlan(id);
        response.sendRedirect("rateplans");
    }
}