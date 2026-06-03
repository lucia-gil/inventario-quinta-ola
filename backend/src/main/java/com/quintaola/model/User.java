package com.quintaola.model;

public class User {

    private int id;
    private String email;
    private String dni;
    private String name;
    private String passwordHash;
    private int roleId;
    private String roleName;
    private int activo; // <-- Cambiado a int para coincidir con el Servlet y la BD (0 o 1)
    private String createdAt;
    private String avatarUrl;

    public User() {}

    public int getId()                         { return id; }
    public void setId(int id)                  { this.id = id; }

    public String getEmail()                   { return email; }
    public void setEmail(String email)         { this.email = email; }

    public String getDni()                     { return dni; }
    public void setDni(String dni)             { this.dni = dni; }

    public String getName()                    { return name; }
    public void setName(String name)           { this.name = name; }

    public String getPasswordHash()            { return passwordHash; }
    public void setPasswordHash(String hash)   { this.passwordHash = hash; }

    public int getRoleId()                     { return roleId; }
    public void setRoleId(int roleId)          { this.roleId = roleId; }

    public String getRoleName()                { return roleName; }
    public void setRoleName(String roleName)   { this.roleName = roleName; }

    // 👇 Métodos actualizados para la propiedad activo
    public int getActivo()                     { return activo; }
    public void setActivo(int activo)          { this.activo = activo; }

    public String getCreatedAt()               { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getAvatarUrl()               { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }
}