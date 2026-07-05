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

    private static final String URL = "jdbc:mysql://inventario-bd.czzl6s6jv6rq.us-east-1.rds.amazonaws.com:3306/inventorydb";

    private static final String USER="admin";

    private static final String PASS="telecom2022";;

    protected Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
