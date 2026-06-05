package com.quintaola.model;

/**
 * ════════════════════════════════════════════════════════════════════
 * AuditLog — Modelo de la bitácora de auditoría
 * ════════════════════════════════════════════════════════════════════
 *
 * Cada cambio crítico del sistema (creación de usuario, cambio de rol,
 * aprobación/rechazo de solicitud) se registra como una entrada
 * inmutable en audit_log. El SuperAdmin puede ver toda esta historia.
 * ════════════════════════════════════════════════════════════════════
 */
public class AuditLog {

    private int    id;
    private int    actorId;
    private String actorName;   // viene del JOIN con users
    private String actorRole;   // viene del JOIN con roles
    private String action;      // ej: CAMBIO_ROL, CREAR_USUARIO, APROBAR
    private String entity;      // ej: USER, TRANSACTION, ITEM
    private int    entityId;
    private String details;     // mensaje legible
    private String createdAt;

    public AuditLog() {}

    public int    getId()         { return id; }
    public void   setId(int id)   { this.id = id; }

    public int    getActorId()              { return actorId; }
    public void   setActorId(int actorId)   { this.actorId = actorId; }

    public String getActorName()              { return actorName; }
    public void   setActorName(String n)      { this.actorName = n; }

    public String getActorRole()              { return actorRole; }
    public void   setActorRole(String r)      { this.actorRole = r; }

    public String getAction()             { return action; }
    public void   setAction(String a)     { this.action = a; }

    public String getEntity()             { return entity; }
    public void   setEntity(String e)     { this.entity = e; }

    public int    getEntityId()           { return entityId; }
    public void   setEntityId(int id)     { this.entityId = id; }

    public String getDetails()            { return details; }
    public void   setDetails(String d)    { this.details = d; }

    public String getCreatedAt()          { return createdAt; }
    public void   setCreatedAt(String c)  { this.createdAt = c; }
}