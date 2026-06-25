package com.quintaola.dao;

import com.quintaola.model.User;
import com.quintaola.util.DatabaseConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserDAO {

    public boolean register(User user) throws SQLException {
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

    // ─── DISABLE: desactiva un usuario (soft-delete con activo = 0) ───
    public boolean disable(int userId) throws SQLException {
        String sql = "UPDATE users SET activo = 0 WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── ENABLE: reactiva un usuario previamente desactivado ───
    public boolean enable(int userId) throws SQLException {
        String sql = "UPDATE users SET activo = 1 WHERE id = ?";
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

    /**
     * ─── distinguir "pendiente" vs "desactivado" ───
     *
     * Ambos casos tienen activo = 0 en BD, pero conceptualmente son distintos:
     *   - Pendiente: nunca fue aprobado tras su registro.
     *   - Desactivado: estuvo activo, pero un SuperAdmin lo deshabilitó.
     *
     * Para distinguirlos, miramos audit_log: si el último evento sobre ese
     * usuario es DESACTIVAR_USUARIO, está desactivado. En cualquier otro caso
     * (sin eventos, o último evento es APROBAR/RECHAZAR/CREAR), lo tratamos
     * como pendiente.
     *
     * Devuelve un Map<userId, "DEACTIVATED" | "PENDING"> solo para los
     * usuarios con activo = 0.
     */
    public Map<Integer, String> getInactiveUsersStatus() throws SQLException {
        Map<Integer, String> result = new HashMap<>();

        String sql = """
            SELECT u.id,
                   (SELECT action FROM audit_log
                    WHERE entity = 'USER' AND entity_id = u.id
                    ORDER BY created_at DESC LIMIT 1) AS last_action
            FROM users u
            WHERE u.activo = 0
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int userId = rs.getInt("id");
                String lastAction = rs.getString("last_action");
                if ("DESACTIVAR_USUARIO".equals(lastAction)) {
                    result.put(userId, "DEACTIVATED");
                } else {
                    result.put(userId, "PENDING");
                }
            }
        }
        return result;
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
        user.setActivo      (rs.getInt    ("activo"));
        user.setCreatedAt   (rs.getString ("created_at"));
        try { user.setAvatarUrl(rs.getString("avatar_url")); } catch (Exception ignored) {}
        return user;
    }

    public User getById(int id) throws SQLException {
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
            ps.setString(4, user.getPasswordHash());
            ps.setInt   (5, roleId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean changeRole(int userId, int newRoleId) throws SQLException {
        String sql = "UPDATE users SET role_id = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newRoleId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

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

    public boolean updatePassword(int userId, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, BCrypt.hashpw(newPassword, BCrypt.gensalt()));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * ─── getApprovers: lista aprobadores activos ───
     *
     * Devuelve todos los usuarios activos con rol Manager (3) o Administrador (4).
     * Se usa para notificarles por email cuando se crea una nueva solicitud.
     *
     * NOTA: No incluye SuperAdmin (5) porque por política, el SA solo audita,
     * no aprueba transacciones.
     */
    public List<User> getApprovers() throws SQLException {
        List<User> approvers = new ArrayList<>();
        String sql = """
            SELECT u.*, r.name AS role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.role_id IN (3, 4)
              AND u.activo = 1
            ORDER BY u.name ASC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                approvers.add(mapRow(rs));
            }
        }
        return approvers;
    }

}