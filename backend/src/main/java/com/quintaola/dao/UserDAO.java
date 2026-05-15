// ============================================================
// USER DAO SUMMARY (CORE FUNCTIONS ONLY)
// ============================================================
//
// getAll()            - id, email, dni, name, role_id, activo, created_at
// getActive()         - id, email, dni, name, role_id, activo, created_at
// getInactive()       - id, email, dni, name, role_id, activo, created_at
// getById(id)         - id, email, dni, name, role_id, activo, created_at
// findByEmail(email)  - id, email, dni, name, role_id, activo, created_at
// findByDni(dni)      - id, email, dni, name, role_id, activo, created_at
// getByRole(roleId)   - id, email, dni, name, role_id, activo, created_at
// getNewest()         - id, email, dni, name, role_id, activo, created_at
// getOldest()         - id, email, dni, name, role_id, activo, created_at
// ============================================================

package com.quintaola.dao;

import com.quintaola.model.User;
import com.quintaola.util.DatabaseConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class UserDAO {

    // ── REGISTER — crear nuevo usuario ───────────────────────────
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
            // Hashear la contraseña antes de guardar
            ps.setString(5, BCrypt.hashpw(user.getPasswordHash(), BCrypt.gensalt()));

            return ps.executeUpdate() > 0;
        }
    }

    // ── LOGIN — verificar credenciales ───────────────────────────
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

                    // Verificar contraseña con BCrypt
                    if (BCrypt.checkpw(password, storedHash)) {
                        return User.mapUser(rs);
                    }
                }
            }
        }
        return null; // credenciales incorrectas
    }

    // ── GET ALL — listar todos los usuarios ──────────────────────
    public List<User> getAllUsers() throws SQLException {
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
                users.add(User.mapUser(rs));
            }
        }
        return users;
    }

    // ── UPDATE ROLE — cambiar rol de un usuario ──────────────────
    public boolean updateRole(String userId, String roleId) throws SQLException {
        String sql = "UPDATE users SET role_id = ? WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, roleId);
            ps.setString(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── DISABLE — deshabilitar usuario ───────────────────────────
    public boolean disable(String userId) throws SQLException {
        String sql = "UPDATE users SET activo = 0 WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            return ps.executeUpdate() > 0;
        }
    }

    // ============================================================
    // getAll()
    // ============================================================
    public ResultSet getAll() throws SQLException {

        // Devuelve todos los usuarios sin filtros.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getActive()
    // ============================================================
    public ResultSet getActive() throws SQLException {

        // Devuelve solo usuarios activos.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.activo = 1
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getInactive()
    // ============================================================
    public ResultSet getInactive() throws SQLException {

        // Devuelve solo usuarios inactivos.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.activo = 0
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getById(id)
    // ============================================================
    public ResultSet getById(String id) throws SQLException {

        // Devuelve un usuario por ID.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.id = ?
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, id);

        return ps.executeQuery();
    }

    // ============================================================
    // findByEmail(email)
    // ============================================================
    public ResultSet findByEmail(String email) throws SQLException {

        // Busca usuario por email.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.email = ?
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, email);

        return ps.executeQuery();
    }

    // ============================================================
    // findByDni(dni)
    // ============================================================
    public ResultSet findByDni(String dni) throws SQLException {

        // Busca usuario por DNI.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.dni = ?
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, dni);

        return ps.executeQuery();
    }

    // ============================================================
    // getByRole(roleId)
    // ============================================================
    public ResultSet getByRole(String roleId) throws SQLException {

        // Devuelve usuarios filtrados por rol.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.role_id = ?
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, roleId);

        return ps.executeQuery();
    }

    // ============================================================
    // getNewest()
    // ============================================================
    public ResultSet getNewest() throws SQLException {

        // Usuarios ordenados del más reciente al más antiguo.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    ORDER BY u.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getOldest()
    // ============================================================
    public ResultSet getOldest() throws SQLException {

        // Usuarios ordenados del más antiguo al más reciente.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    ORDER BY u.created_at ASC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }
}