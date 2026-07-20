package com.quintaola.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    // Cambiar para desplegar en cad auna de sus laptops de manera local
    //private static final String URL = "jdbc:mysql://localhost:3306/inventorydb?useSSL=false&serverTimezone=America/Lima&allowPublicKeyRetrieval=true";

    //private static final String USER = "usuario";
    //private static final String PASSWORD = "contrasena";

    // Para despliegue descomentar EC2 de lucia
    private static final String URL = "jdbc:mysql://inventario-bd.czzl6s6jv6rq.us-east-1.rds.amazonaws.com:3306/inventorydb?useSSL=false&serverTimezone=America/Lima&allowPublicKeyRetrieval=true";
    private static final String USER="admin";
    private static final String PASSWORD="telecom2022";

    static {
        // Cargar el driver UNA sola vez al iniciar la clase
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL Driver no encontrado", e);
        }
    }

    /**
     * Devuelve una conexión NUEVA cada vez.
     * El que llama es responsable de cerrarla (try-with-resources lo hace).
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}