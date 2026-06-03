package com.quintaola.dao;

import com.quintaola.model.User;
import com.quintaola.util.DatabaseConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public boolean register(User user) throws SQLException {
        // Ahora toma el role_id y el activo directamente del objeto User (seteado en el Servlet)
        String sql = """
            INSERT INTO users (email, dni, name, password_hash, role_id, activo)
            VALUES (?, ?, ?, ?, ?, ?)
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getDni());
            ps.setString(3, user.getName());
            ps.setString(4, BCrypt.hashpw(user.getPasswordHash(), BCrypt.gensalt()));
            ps.setInt(5, user.getRoleId());
            ps.setInt(6, user.getActivo());
            return ps.executeUpdate() > 0;
        }
    }

    public User login(String email, String password) throws SQLException {
        // Quitamos "AND u.activo = 1" para que el Servlet pueda atrapar a los pendientes (activo = 0)
        String sql = """
            SELECT u.*, r.name AS role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.email = ?
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");
                    if (BCrypt.checkpw(password, storedHash)) {
                        return mapRow(rs);
                    }
                }
            }
        }
        return null;
    }

    public List<User> getAll() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = """
            SELECT u.*, r.name AS role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            ORDER BY u.created_at DESC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(mapRow(rs));
            }
        }
        return users;
    }

    public boolean updateRole(int userId, int roleId) throws SQLException {
        String sql = "UPDATE users SET role_id = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean disable(int userId) throws SQLException {
        String sql = "UPDATE users SET activo = 0 WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── APPROVE: aprueba un usuario pendiente (activo = 1) ───
    public boolean approve(int userId) throws SQLException {
        String sql = "UPDATE users SET activo = 1 WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId          (rs.getInt    ("id"));
        user.setEmail       (rs.getString ("email"));
        user.setDni         (rs.getString ("dni"));
        user.setName        (rs.getString ("name"));
        user.setPasswordHash(rs.getString ("password_hash"));
        user.setRoleId      (rs.getInt    ("role_id"));
        user.setRoleName    (rs.getString ("role_name"));
        user.setActivo      (rs.getInt    ("activo")); // Cambiado de getBoolean a getInt
        user.setCreatedAt   (rs.getString ("created_at"));
        try { user.setAvatarUrl(rs.getString("avatar_url")); } catch (Exception ignored) {}
        return user;
    }

    public User getById(int id) throws SQLException {
        // Quitamos "AND u.activo = 1" para que el Admin pueda ver perfiles de usuarios pendientes
        String sql = """
            SELECT u.*, r.name AS role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id = ?
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public boolean updateAvatar(int userId, String avatarUrl) throws SQLException {
        String sql = "UPDATE users SET avatar_url = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, avatarUrl);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── CREATE: registra un usuario nuevo con rol asignado ───
    // Lo usa el SuperAdmin desde admin-users
    public boolean createWithRole(User user, int roleId) throws SQLException {
        String sql = """
        INSERT INTO users (email, dni, name, password_hash, role_id, activo)
        VALUES (?, ?, ?, ?, ?, 1)
        """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getEmail());
            ps.setString(2, user.getDni());
            ps.setString(3, user.getName());
            ps.setString(4, user.getPasswordHash()); // ya viene hasheado
            ps.setInt   (5, roleId);

            return ps.executeUpdate() > 0;
        }
    }

    // ─── CHANGE ROLE: actualiza solo el rol de un usuario ───
    public boolean changeRole(int userId, int newRoleId) throws SQLException {
        String sql = "UPDATE users SET role_id = ? WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, newRoleId);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        }
    }

    // ─── NUEVO: Crea notificaciones en lote para los Administradores ───
    public void createAdminNotification(String type, String title, String message) throws SQLException {
        String sql = """
            INSERT INTO notifications (user_id, type, title, message)
            SELECT id, ?, ?, ? FROM users WHERE role_id IN (4, 5)
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type);
            ps.setString(2, title);
            ps.setString(3, message);
            ps.executeUpdate();
        }
    }
}