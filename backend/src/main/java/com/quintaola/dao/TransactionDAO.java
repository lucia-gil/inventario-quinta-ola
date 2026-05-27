package com.quintaola.dao;

import com.quintaola.model.Transaction;
import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    public List<Transaction> getAll() throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit, i.image_url AS item_img,
                   u.name AS requester_name, a.name AS approver_name
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            ORDER BY t.created_at DESC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public Transaction getById(int id) throws SQLException {
        String sql = """
            SELECT t.*, u.name AS requester_name, a.name AS approver_name,
                   i.name AS item_name, i.unit AS item_unit, i.image_url AS item_img
            FROM transactions t
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            JOIN items i ON t.item_id = i.id
            WHERE t.id = ?
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public List<Transaction> getPending() throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit, i.image_url AS item_img,
                   u.name AS requester_name, a.name AS approver_name
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            WHERE t.status = 'PENDING'
            ORDER BY t.created_at DESC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public List<Transaction> getApproved() throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit, i.image_url AS item_img,
                   u.name AS requester_name, a.name AS approver_name
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            WHERE t.status = 'APPROVED'
            ORDER BY t.created_at ASC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    public List<Transaction> getByUser(int userId) throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit, i.image_url AS item_img,
                   u.name AS requester_name, a.name AS approver_name
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            WHERE t.requester_id = ?
            ORDER BY t.created_at DESC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public boolean create(Transaction t) throws SQLException {
        String sql = """
            INSERT INTO transactions
            (item_id, requester_id, type, quantity, status, notes)
            VALUES (?, ?, 'OUT', ?, 'PENDING', ?)
            """;

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int txId = 0;
                try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt   (1, t.getItemId());
                    ps.setInt   (2, t.getRequesterId());
                    ps.setInt   (3, t.getQuantity());
                    ps.setString(4, t.getNotes());
                    ps.executeUpdate();

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) txId = keys.getInt(1);
                    }
                }

                // Alerta automática para Managers y Administradores
                // role_id 3 = Manager, role_id 4 = Administrador
                String sqlManagers = "SELECT id FROM users WHERE role_id IN (3, 4) AND activo = 1";
                try (PreparedStatement psM = conn.prepareStatement(sqlManagers);
                     ResultSet rsM = psM.executeQuery()) {
                    while (rsM.next()) {
                        int managerId = rsM.getInt("id");
                        if (managerId != t.getRequesterId()) {
                            crearNotificacion(
                                    conn,
                                    managerId,
                                    "new_request",
                                    "Nueva Solicitud Pendiente",
                                    "Se ha registrado un nuevo requerimiento de materiales esperando tu revisión.",
                                    txId
                            );
                        }
                    }
                }

                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean approve(int id, int approverId, String notes) throws SQLException {
        String sql = """
            UPDATE transactions
            SET status = 'APPROVED', approver_id = ?, notes = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND status = 'PENDING'
            """;

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean ok;
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt   (1, approverId);
                    ps.setString(2, notes);
                    ps.setInt   (3, id);
                    ok = ps.executeUpdate() > 0;
                }

                if (ok) {
                    // Obtener solicitante para notificarle la aprobación
                    String sqlGetReq = "SELECT requester_id FROM transactions WHERE id = ?";
                    int requesterId = 0;
                    try (PreparedStatement psR = conn.prepareStatement(sqlGetReq)) {
                        psR.setInt(1, id);
                        try (ResultSet rsR = psR.executeQuery()) {
                            if (rsR.next()) requesterId = rsR.getInt("requester_id");
                        }
                    }

                    if (requesterId > 0) {
                        crearNotificacion(
                                conn,
                                requesterId,
                                "request_approved",
                                "¡Tu solicitud fue Aprobada!",
                                "Tu requerimiento de materiales ha sido aprobado y pasará a preparación.",
                                id
                        );
                    }
                }

                conn.commit();
                return ok;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean reject(int id, int approverId, String notes) throws SQLException {
        String sql = """
            UPDATE transactions
            SET status = 'REJECTED', approver_id = ?, notes = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND status = 'PENDING'
            """;

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                boolean ok;
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt   (1, approverId);
                    ps.setString(2, notes);
                    ps.setInt   (3, id);
                    ok = ps.executeUpdate() > 0;
                }

                if (ok) {
                    // Obtener solicitante para notificarle el rechazo
                    String sqlGetReq = "SELECT requester_id FROM transactions WHERE id = ?";
                    int requesterId = 0;
                    try (PreparedStatement psR = conn.prepareStatement(sqlGetReq)) {
                        psR.setInt(1, id);
                        try (ResultSet rsR = psR.executeQuery()) {
                            if (rsR.next()) requesterId = rsR.getInt("requester_id");
                        }
                    }

                    if (requesterId > 0) {
                        crearNotificacion(
                                conn,
                                requesterId,
                                "request_rejected",
                                "Solicitud Rechazada",
                                "Tu requerimiento ha sido observado o rechazado. Revisa los comentarios.",
                                id
                        );
                    }
                }

                conn.commit();
                return ok;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    public boolean deliver(int id) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection()) {
            try {
                conn.setAutoCommit(false);

                String sqlGet = "SELECT item_id, quantity, type FROM transactions WHERE id = ?";
                int itemId = 0;
                int quantity = 0;
                String type = null;

                try (PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            itemId   = rs.getInt   ("item_id");
                            quantity = rs.getInt   ("quantity");
                            type     = rs.getString("type");
                        }
                    }
                }

                if (itemId == 0) { conn.rollback(); return false; }

                String sqlComplete = """
                    UPDATE transactions
                    SET status = 'COMPLETED', processed_at = CURRENT_TIMESTAMP,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                    """;
                try (PreparedStatement ps = conn.prepareStatement(sqlComplete)) {
                    ps.setInt(1, id);
                    ps.executeUpdate();
                }

                int delta = type.equals("IN") ? quantity : -quantity;
                String sqlStock = """
                    UPDATE items
                    SET cached_quantity = cached_quantity + ?,
                        status = CASE
                            WHEN cached_quantity + ? <= 0            THEN 'UNAVAILABLE'
                            WHEN cached_quantity + ? <= min_quantity THEN 'LOW'
                            ELSE 'OK'
                        END
                    WHERE id = ?
                    """;
                try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
                    ps.setInt(1, delta);
                    ps.setInt(2, delta);
                    ps.setInt(3, delta);
                    ps.setInt(4, itemId);
                    ps.executeUpdate();
                }

                conn.commit();
                return true;

            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private Transaction mapRow(ResultSet rs) throws SQLException {
        Transaction t = new Transaction();
        t.setId           (rs.getInt   ("id"));
        t.setItemId       (rs.getInt   ("item_id"));
        t.setRequesterId  (rs.getInt   ("requester_id"));
        t.setApproverId   (rs.getInt   ("approver_id"));
        t.setType         (rs.getString("type"));
        t.setQuantity     (rs.getInt   ("quantity"));
        t.setStatus       (rs.getString("status"));
        t.setNotes        (rs.getString("notes"));
        t.setCreatedAt    (rs.getString("created_at"));
        t.setProcessedAt  (rs.getString("processed_at"));
        try { t.setItemName     (rs.getString("item_name")); } catch (Exception ignored) {}
        try { t.setItemUnit     (rs.getString("item_unit")); } catch (Exception ignored) {}
        try { t.setItemImg      (rs.getString("item_img"));  } catch (Exception ignored) {}
        try { t.setRequesterName(rs.getString("requester_name")); } catch (Exception ignored) {}
        try { t.setApproverName (rs.getString("approver_name")); } catch (Exception ignored) {}
        return t;
    }

    // Crea una notificación reutilizando la conexión activa (BD genera el id sola)
    private void crearNotificacion(Connection conn, int userId, String type, String title,
                                   String message, int relatedId) throws SQLException {
        String sql = """
            INSERT INTO notifications (user_id, type, title, message, related_id, is_read)
            VALUES (?, ?, ?, ?, ?, 0)
            """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, type);
            ps.setString(3, title);
            ps.setString(4, message);
            ps.setInt   (5, relatedId);
            ps.executeUpdate();
        }
    }
}