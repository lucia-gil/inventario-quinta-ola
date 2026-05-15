package com.quintaola.model;

public class User {

    private String id;
    private String email;
    private String dni;
    private String name;
    private String passwordHash;
    private String roleId;
    private String roleName;
    private boolean activo;
    private String createdAt;

    public User() {}

    public String getId()                      { return id; }
    public void setId(String id)               { this.id = id; }

    public String getEmail()                   { return email; }
    public void setEmail(String email)         { this.email = email; }

    public String getDni()                     { return dni; }
    public void setDni(String dni)             { this.dni = dni; }

    public String getName()                    { return name; }
    public void setName(String name)           { this.name = name; }

    public String getPasswordHash()            { return passwordHash; }
    public void setPasswordHash(String hash)   { this.passwordHash = hash; }

    public String getRoleId()                  { return roleId; }
    public void setRoleId(String roleId)       { this.roleId = roleId; }

    public String getRoleName()                { return roleName; }
    public void setRoleName(String roleName)   { this.roleName = roleName; }

    public boolean isActivo()                  { return activo; }
    public void setActivo(boolean activo)      { this.activo = activo; }

    public String getCreatedAt()               { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}