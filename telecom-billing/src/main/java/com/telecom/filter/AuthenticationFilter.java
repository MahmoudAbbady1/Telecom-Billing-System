/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.telecom.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebFilter({
    "/jsp/*",             // Protect all JSPs under /jsp
    "/protected/*",       // Protect any other protected paths
    "/secured/*"          // Add any other paths you want to protect
})
public class AuthenticationFilter implements Filter {

    // List of allowed paths without authentication
    private static final String[] ALLOWED_PATHS = {
        "/index.jsp",
        "/login",
        "/logout",
        "/css/",
        "/js/",
        "/images/"
    };

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        
        String path = req.getRequestURI().substring(req.getContextPath().length());
        
        // Check if the path is allowed
        if (isAllowed(path)) {
            chain.doFilter(request, response);
            return;
        }
        
        HttpSession session = req.getSession(false);
        
        if (session == null || session.getAttribute("username") == null) {
            // Redirect to login page with original URL for redirect after login
            String redirectUrl = req.getRequestURI();
            if (req.getQueryString() != null) {
                redirectUrl += "?" + req.getQueryString();
            }
            session = req.getSession(true);
            session.setAttribute("redirectUrl", redirectUrl);
            
            res.sendRedirect(req.getContextPath() + "/index.jsp");
        } else {
            chain.doFilter(request, response);
        }
    }

    private boolean isAllowed(String path) {
        for (String allowedPath : ALLOWED_PATHS) {
            if (path.startsWith(allowedPath)) {
                return true;
            }
        }
        return false;
    }

    public void init(FilterConfig fConfig) throws ServletException {}
    public void destroy() {}
}