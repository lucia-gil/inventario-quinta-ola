package com.quintaola.dao;

import com.quintaola.model.Role;
import com.quintaola.model.User;
import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/* ============================================================
   RoleDAO.java
   ============================================================
   Acceso a la tabla roles. Como los roles son fijos, solo
   necesitamos LEER, no crear/editar/eliminar.

   Metodos:
   - getAll()             -> los 5 roles con conteo de usuarios activos
   - getById(int)         -> un rol concreto
   - getUsersByRole(int)  -> TODOS los usuarios de ese rol (activos,
                             pendientes y desactivados). El JSP decide
                             cómo pintarlos.
   ============================================================ */
public class RoleDAO {

    // ─── GET ALL: los 5 roles con count de usuarios activos ───
    public List<Role> getAll() throws SQLException {
        List<Role> list = new ArrayList<>();

        String sql = """
            SELECT r.*, COUNT(u.id) AS user_count
            FROM roles r
            LEFT JOIN users u ON u.role_id = r.id AND u.activo = 1
            WHERE r.activo = 1
            GROUP BY r.id
            ORDER BY r.id ASC
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ─── GET BY ID ───
    public Role getById(int id) throws SQLException {
        String sql = "SELECT * FROM roles WHERE id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Role r = new Role();
                    r.setId(rs.getInt("id"));
                    r.setName(rs.getString("name"));
                    r.setDescription(rs.getString("description"));
                    return r;
                }
            }
        }
        return null;
    }

    /**
     * ─── GET USERS BY ROLE ───
     * Devuelve TODOS los usuarios con ese rol, sin filtrar por activo.
     * El SuperAdmin necesita ver también a los desactivados para poder
     * reactivarlos desde la vista de gestión de roles.
     *
     * Orden: activos primero, luego pendientes/desactivados, alfabético.
     */
    public List<User> getUsersByRole(int roleId) throws SQLException {
        List<User> list = new ArrayList<>();

        String sql = """
            SELECT u.id, u.name, u.email, u.dni, u.role_id, u.avatar_url,
                   u.created_at, u.activo, r.name AS role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.role_id = ?
            ORDER BY u.activo DESC, u.name ASC
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setName(rs.getString("name"));
                    u.setEmail(rs.getString("email"));
                    u.setDni(rs.getString("dni"));
                    u.setRoleId(rs.getInt("role_id"));
                    u.setAvatarUrl(rs.getString("avatar_url"));
                    u.setCreatedAt(rs.getString("created_at"));
                    u.setRoleName(rs.getString("role_name"));
                    u.setActivo(rs.getInt("activo"));  // ← CLAVE: ahora sí seteamos activo
                    list.add(u);
                }
            }
        }
        return list;
    }

    // ─── MAP ROW ───
    private Role mapRow(ResultSet rs) throws SQLException {
        Role role = new Role();
        role.setId(rs.getInt("id"));
        role.setName(rs.getString("name"));
        role.setDescription(rs.getString("description"));
        try {
            role.setUserCount(rs.getInt("user_count"));
        } catch (SQLException ignored) {
            role.setUserCount(0);
        }
        return role;
    }
}