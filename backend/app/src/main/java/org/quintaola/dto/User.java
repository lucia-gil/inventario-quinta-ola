package org.quintaola.dto;

import java.sql.Timestamp;
import java.sql.SQLException;
import java.sql.ResultSet;

public class User {

    private String id;
    private String email;
    private String dni;
    private String name;
    private String passwordHash;

    private String roleId;
    private boolean activo;

    private Timestamp createdAt;

    // Getters & Setters

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getRoleId() { return roleId; }
    public void setRoleId(String roleId) { this.roleId = roleId; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();

        user.setId(rs.getString("id"));
        user.setEmail(rs.getString("email"));
        user.setDni(rs.getString("dni"));
        user.setName(rs.getString("name"));
        user.setPasswordHash(rs.getString("password_hash"));

        user.setRoleId(rs.getString("role_id"));
        user.setActivo(rs.getBoolean("activo"));

        user.setCreatedAt(rs.getTimestamp("created_at"));

        return user;
    }
}