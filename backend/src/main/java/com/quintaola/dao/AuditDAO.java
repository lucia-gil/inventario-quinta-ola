package com.quintaola.dao;

import com.quintaola.model.AuditLog;
import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ════════════════════════════════════════════════════════════════════
 * AuditDAO — Acceso a la tabla audit_log
 * ════════════════════════════════════════════════════════════════════
 *
 * Esta clase NO permite UPDATE ni DELETE. La bitácora es inmutable
 * por diseño. Solo se pueden agregar registros (log) y consultarlos.
 * ════════════════════════════════════════════════════════════════════
 */
public class AuditDAO {

    /**
     * Registra un evento en la bitácora.
     * Se llama desde otros servlets cuando ocurre algo importante.
     */
    public boolean log(int actorId, String action, String entity, int entityId, String details) {
        String sql = """
            INSERT INTO audit_log (actor_id, action, entity, entity_id, details)
            VALUES (?, ?, ?, ?, ?)
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, actorId);
            ps.setString(2, action);
            ps.setString(3, entity);
            ps.setInt   (4, entityId);
            ps.setString(5, details);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // No queremos que un fallo de auditoría tumbe la acción principal.
            // Logueamos a consola y devolvemos false.
            System.err.println("Error al registrar en audit_log: " + e.getMessage());
            return false;
        }
    }

    /**
     * Trae todos los registros de la bitácora, más recientes primero.
     */
    public List<AuditLog> getAll() throws SQLException {
        List<AuditLog> registros = new ArrayList<>();
        String sql = """
            SELECT a.id, a.actor_id, a.action, a.entity, a.entity_id,
                   a.details, a.created_at,
                   u.name AS actor_name, r.name AS actor_role
            FROM audit_log a
            JOIN users u ON a.actor_id = u.id
            JOIN roles r ON u.role_id  = r.id
            ORDER BY a.created_at DESC
            LIMIT 200
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                registros.add(mapRow(rs));
            }
        }
        return registros;
    }

    /**
     * Trae registros filtrados por entidad (ej: solo cambios de USER).
     */
    public List<AuditLog> getByEntity(String entity) throws SQLException {
        List<AuditLog> registros = new ArrayList<>();
        String sql = """
            SELECT a.id, a.actor_id, a.action, a.entity, a.entity_id,
                   a.details, a.created_at,
                   u.name AS actor_name, r.name AS actor_role
            FROM audit_log a
            JOIN users u ON a.actor_id = u.id
            JOIN roles r ON u.role_id  = r.id
            WHERE a.entity = ?
            ORDER BY a.created_at DESC
            LIMIT 200
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, entity);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    registros.add(mapRow(rs));
                }
            }
        }
        return registros;
    }

    private AuditLog mapRow(ResultSet rs) throws SQLException {
        AuditLog a = new AuditLog();
        a.setId       (rs.getInt   ("id"));
        a.setActorId  (rs.getInt   ("actor_id"));
        a.setActorName(rs.getString("actor_name"));
        a.setActorRole(rs.getString("actor_role"));
        a.setAction   (rs.getString("action"));
        a.setEntity   (rs.getString("entity"));
        a.setEntityId (rs.getInt   ("entity_id"));
        a.setDetails  (rs.getString("details"));
        a.setCreatedAt(rs.getString("created_at"));
        return a;
    }
}