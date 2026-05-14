package com.quintaola.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    // CONECTAR: cambia estos datos si tu BD tiene usuario/contraseña diferente
    private static final String URL = "jdbc:mysql://localhost:3306/inventorydb?useSSL=false&serverTimezone=America/Lima&allowPublicKeyRetrieval=true";
    private static final String USER     = "root";
    private static final String PASSWORD = "lucia1234"; // tu contraseña de MySQL

    private static Connection connection = null;

    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(URL, USER, PASSWORD);
            } catch (ClassNotFoundException e) {
                throw new SQLException("MySQL Driver no encontrado", e);
            }
        }
        return connection;
    }
}