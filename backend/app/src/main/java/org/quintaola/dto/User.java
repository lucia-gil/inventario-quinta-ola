package org.quintaola.dto;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class User {

    private String id;
    private String email;
    private String dni;
    private String name;
    private String passwordHash;

    private String roleId;
    private boolean activo;

    private Timestamp createdAt;

    public String getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getDni() {
        return dni;
    }

    public String getName() {
        return name;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public String getRoleId() {
        return roleId;
    }

    public String getRoleName() {
        switch (roleId) {
            case "role-admin":
                return "Administrador";
            case "role-manager":
                return "Manager";
            case "role-member":
                return "Miembro";
            case "role-Viewwe":
                return "Espectador";
            default:
                return "None";
        }
    }

    public boolean isActivo() {
        return activo;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public static User mapUser(ResultSet rs) throws SQLException {
        User user = new User();

        user.id = rs.getString("id");
        user.email = rs.getString("email");
        user.dni = rs.getString("dni");
        user.name = rs.getString("name");
        user.passwordHash = rs.getString("password_hash");
        user.roleId = rs.getString("role_id");
        user.activo = rs.getBoolean("activo");
        user.createdAt = rs.getTimestamp("created_at");

        return user;
    }
}