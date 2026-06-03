package com.quintaola.model;

/* ============================================================
   Role.java
   ============================================================
   Bean simple que representa un rol del sistema.
   Los 5 roles son fijos (Viewer, Member, Manager, Administrador,
   SuperAdmin), no se crean ni eliminan, solo se LISTAN para
   poder asignar usuarios a ellos.

   Campos:
   - id, name, description: lo basico
   - userCount: cuantos usuarios tiene este rol (calculado por JOIN)
   ============================================================ */
public class Role {

    private int id;
    private String name;
    private String description;
    private int userCount;

    public Role() {}

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public String getName()                     { return name; }
    public void setName(String name)            { this.name = name; }

    public String getDescription()              { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getUserCount()                   { return userCount; }
    public void setUserCount(int userCount)     { this.userCount = userCount; }
}