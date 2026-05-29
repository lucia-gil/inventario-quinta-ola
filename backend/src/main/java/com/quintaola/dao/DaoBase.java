package com.quintaola.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Clase abstracta padre de todos los DAOs.
 * Centraliza la conexión a MySQL (Clase 8.1 del curso).
 * Todos los DAOs heredan de esta clase.
 */
public abstract class DaoBase {

    private static final String URL  = "jdbc:mysql://127.0.0.1:3306/inventorydb";
    private static final String USER = "root";
    private static final String PASS = "lucia1234";

    protected Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
