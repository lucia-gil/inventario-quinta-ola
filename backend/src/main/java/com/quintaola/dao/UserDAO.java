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
            ps.setInt   (5, user.getRoleId());
            ps.setInt   (6, user.getActivo());
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
                    if (BCrypt.checkpw(password, storedHash)) return mapRow(rs);
                }
            }
        }
        return null;
    }

    // ─── getByEmail: busca un usuario por correo, SIN validar contraseña ───
    //     Usado en el flujo de "Olvidé mi contraseña" para verificar si
    //     la cuenta existe antes de generar el token de reseteo.
    public User getByEmail(String email) throws SQLException {
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
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    // ─── getAll: todos los usuarios sin filtros (uso interno / otras vistas) ──
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
            while (rs.next()) users.add(mapRow(rs));
        }
        return users;
    }

    // ─── getPage: página sin filtros (se mantiene por compatibilidad) ─────────
    public List<User> getPage(int offset, int limit) throws SQLException {
        return getPageFiltered(offset, limit, "", 0);
    }

    // ─── getPageFiltered: página con búsqueda y filtro de rol ─────────────────
    //
    // search    → busca en el nombre completo (LIKE %texto%)
    //             una sola letra filtra por inicial de nombre O apellido
    // roleFilter→ 0 = todos los roles; >0 = filtra exactamente ese role_id
    // Orden     → apellido (última palabra del nombre) A-Z
    //
    public List<User> getPageFiltered(int offset, int limit,
                                      String search, int roleFilter) throws SQLException {
        List<User> users = new ArrayList<>();

        boolean hasSearch = search != null && !search.trim().isEmpty();
        boolean hasRole   = roleFilter > 0;

        StringBuilder sql = new StringBuilder("""
            SELECT u.*, r.name AS role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE 1=1
            """);

        if (hasSearch) sql.append("AND u.name LIKE ? ");
        if (hasRole)   sql.append("AND u.role_id = ? ");

        // Orden por apellido: SUBSTRING_INDEX extrae la última palabra del nombre
        sql.append("ORDER BY SUBSTRING_INDEX(u.name, ' ', 1) ASC ");
        sql.append("LIMIT ? OFFSET ?");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (hasSearch) ps.setString(i++, "%" + search.trim() + "%");
            if (hasRole)   ps.setInt   (i++, roleFilter);
            ps.setInt(i++, limit);
            ps.setInt(i,   offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) users.add(mapRow(rs));
            }
        }
        return users;
    }

    // ─── countAll: total sin filtros ──────────────────────────────────────────
    public int countAll() throws SQLException {
        return countFiltered("", 0);
    }

    // ─── countFiltered: total respetando los mismos filtros que getPageFiltered ─
    public int countFiltered(String search, int roleFilter) throws SQLException {
        boolean hasSearch = search != null && !search.trim().isEmpty();
        boolean hasRole   = roleFilter > 0;

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM users u WHERE 1=1 "
        );
        if (hasSearch) sql.append("AND u.name LIKE ? ");
        if (hasRole)   sql.append("AND u.role_id = ? ");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int i = 1;
            if (hasSearch) ps.setString(i++, "%" + search.trim() + "%");
            if (hasRole)   ps.setInt   (i,   roleFilter);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
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

    public boolean enable(int userId) throws SQLException {
        String sql = "UPDATE users SET activo = 1 WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean approve(int userId) throws SQLException {
        String sql = "UPDATE users SET activo = 1 WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Distingue usuarios "pendiente" de "desactivado" (ambos tienen activo=0).
     * Revisa el último evento en audit_log: si fue DESACTIVAR_USUARIO → DEACTIVATED,
     * cualquier otro caso → PENDING.
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
                int    userId     = rs.getInt   ("id");
                String lastAction = rs.getString("last_action");
                result.put(userId, "DESACTIVAR_USUARIO".equals(lastAction) ? "DEACTIVATED" : "PENDING");
            }
        }
        return result;
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId          (rs.getInt   ("id"));
        user.setEmail       (rs.getString("email"));
        user.setDni         (rs.getString("dni"));
        user.setName        (rs.getString("name"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setRoleId      (rs.getInt   ("role_id"));
        user.setRoleName    (rs.getString("role_name"));
        user.setActivo      (rs.getInt   ("activo"));
        user.setCreatedAt   (rs.getString("created_at"));
        try { user.setAvatarUrl(rs.getString("avatar_url")); } catch (Exception ignored) {}
        try { user.setRequirePasswordChange(rs.getInt("require_password_change")); } catch (Exception ignored) {}
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
            ps.setInt   (2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─── createWithRole: marca require_password_change=1 y devuelve el ID generado ───
    public int createWithRole(User user, int roleId) throws SQLException {
        String sql = """
            INSERT INTO users (email, dni, name, password_hash, role_id, activo, require_password_change)
            VALUES (?, ?, ?, ?, ?, 1, 1)
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getDni());
            ps.setString(3, user.getName());
            ps.setString(4, user.getPasswordHash());
            ps.setInt   (5, roleId);
            int filas = ps.executeUpdate();
            if (filas == 0) return 0;
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
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

    // ─── updatePassword: también apaga require_password_change ───
    public boolean updatePassword(int userId, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password_hash = ?, require_password_change = 0 WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, BCrypt.hashpw(newPassword, BCrypt.gensalt()));
            ps.setInt   (2, userId);
            return ps.executeUpdate() > 0;
        }
    }

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
            while (rs.next()) approvers.add(mapRow(rs));
        }
        return approvers;
    }
}