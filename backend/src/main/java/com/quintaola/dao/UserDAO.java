package com.quintaola.dao;

import com.quintaola.model.User;
import com.quintaola.util.DatabaseConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class UserDAO {

    public boolean register(User user) throws SQLException {
        String sql = """
            INSERT INTO users (id, email, dni, name, password_hash, role_id, activo)
            VALUES (?, ?, ?, ?, ?, 'role-solicitante', 1)
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, UUID.randomUUID().toString());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getDni());
            ps.setString(4, user.getName());
            ps.setString(5, BCrypt.hashpw(user.getPasswordHash(), BCrypt.gensalt()));
            return ps.executeUpdate() > 0;
        }
    }

    public User login(String email, String password) throws SQLException {
        String sql = """
            SELECT u.*, r.name AS role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.email = ? AND u.activo = 1
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

    public boolean updateRole(String userId, String roleId) throws SQLException {
        String sql = "UPDATE users SET role_id = ? WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, roleId);
            ps.setString(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean disable(String userId) throws SQLException {
        String sql = "UPDATE users SET activo = 0 WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId          (rs.getString ("id"));
        user.setEmail       (rs.getString ("email"));
        user.setDni         (rs.getString ("dni"));
        user.setName        (rs.getString ("name"));
        user.setPasswordHash(rs.getString ("password_hash"));
        user.setRoleId      (rs.getString ("role_id"));
        user.setRoleName    (rs.getString ("role_name"));
        user.setActivo      (rs.getBoolean("activo"));
        user.setCreatedAt   (rs.getString ("created_at"));
        return user;
    }
}