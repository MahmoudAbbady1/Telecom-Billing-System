/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.telecom.util;

import java.sql.Connection;
import java.sql.DriverManager;
/**
 *
 * @author mibrahim
 */


public class DBConnection {
  private static final String URL = "jdbc:postgresql://localhost:5432/billing_prj";
    private static final String USER = "postgres";
    private static final String PASSWORD = "19012001";
    public Connection getConnection(){
    Connection connection =null;
        try {
        Class.forName("org.postgresql.Driver");
        connection=DriverManager.getConnection(URL,USER,PASSWORD);
        
                
                }catch(Exception e)
                {e.printStackTrace();
                }
                return connection;
    }}