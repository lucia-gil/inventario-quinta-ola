package com.quintaola.dao;

import com.quintaola.util.DatabaseConnection;

import java.security.SecureRandom;
import java.sql.*;
import java.time.LocalDateTime;

public class PasswordResetDAO {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    /**
     * Genera un token único, lo guarda con expiración de 30 minutos
     * y lo devuelve para incluirlo en el link del correo.
     */
    public String generarToken(int userId) throws SQLException {
        String token = generarCadenaAleatoria(48);

        String sql = "INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, token);
            ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now().plusMinutes(30)));
            ps.executeUpdate();
        }
        return token;
    }

    /**
     * Valida el token: debe existir, no estar usado y no haber expirado.
     * Devuelve el userId asociado, o 0 si el token no es válido.
     */
    public int validarToken(String token) throws SQLException {
        String sql = "SELECT user_id, expires_at, used FROM password_reset_tokens WHERE token = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return 0;
                if (rs.getInt("used") == 1) return 0;
                if (rs.getTimestamp("expires_at").toLocalDateTime().isBefore(LocalDateTime.now())) return 0;
                return rs.getInt("user_id");
            }
        }
    }

    /**
     * Marca el token como usado, para que no pueda reutilizarse.
     */
    public boolean marcarUsado(String token) throws SQLException {
        String sql = "UPDATE password_reset_tokens SET used = 1 WHERE token = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            return ps.executeUpdate() > 0;
        }
    }

    private String generarCadenaAleatoria(int longitud) {
        StringBuilder sb = new StringBuilder(longitud);
        for (int i = 0; i < longitud; i++) {
            sb.append(CHARS.charAt(RANDOM.nextInt(CHARS.length())));
        }
        return sb.toString();
    }
}