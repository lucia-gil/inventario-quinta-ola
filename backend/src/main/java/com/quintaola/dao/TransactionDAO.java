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

    // ============================================================
    // MÉTODOS NUEVOS: Filtro de exclusión de auto-aprobación
    // ============================================================

    public List<Transaction> getAllExcludingSelf(int currentUserId) throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit, i.image_url AS item_img,
                   u.name AS requester_name, a.name AS approver_name
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            WHERE t.requester_id != ? OR ? = 0
            ORDER BY t.created_at DESC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            ps.setInt(2, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public List<Transaction> getPendingExcludingSelf(int currentUserId) throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit, i.image_url AS item_img,
                   u.name AS requester_name, a.name AS approver_name
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            WHERE t.status = 'PENDING' AND (t.requester_id != ? OR ? = 0)
            ORDER BY t.estimated_delivery IS NULL, t.estimated_delivery ASC, t.created_at DESC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            ps.setInt(2, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public List<Transaction> getApprovedExcludingSelf(int currentUserId) throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit, i.image_url AS item_img,
                   u.name AS requester_name, a.name AS approver_name
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            WHERE t.status = 'APPROVED' AND (t.requester_id != ? OR ? = 0)
            ORDER BY t.created_at ASC
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, currentUserId);
            ps.setInt(2, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    // ============================================================
    // CREATE — Crea solicitud validando stock disponible
    // ============================================================
    // Verifica que (stock_actual - reservado_en_pendientes_y_aprobadas)
    // sea suficiente para la nueva solicitud.
    public boolean create(Transaction t) throws SQLException {

        String sqlCheck = """
            SELECT i.cached_quantity,
                   COALESCE(SUM(CASE
                       WHEN tx.status IN ('PENDING', 'APPROVED')
                            AND tx.type = 'OUT'
                       THEN tx.quantity ELSE 0 END), 0) AS reservado
            FROM items i
            LEFT JOIN transactions tx ON tx.item_id = i.id
            WHERE i.id = ? AND i.activo = 1
            GROUP BY i.id
            """;

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {

                // 1. Validar stock disponible (real - reservado)
                int stockActual = 0;
                int reservado = 0;
                try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                    psCheck.setInt(1, t.getItemId());
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next()) {
                            stockActual = rs.getInt("cached_quantity");
                            reservado = rs.getInt("reservado");
                        }
                    }
                }

                int disponibleReal = stockActual - reservado;
                if (t.getQuantity() > disponibleReal) {
                    conn.rollback();
                    throw new SQLException(
                            "Stock insuficiente. Disponible real: " + disponibleReal +
                                    " (stock " + stockActual + " - reservado " + reservado + ")"
                    );
                }

                // 2. Crear la transacción (CON estimated_delivery del novio)
                String sql = """
                    INSERT INTO transactions
                    (item_id, requester_id, type, quantity, status, notes, estimated_delivery)
                    VALUES (?, ?, 'OUT', ?, 'PENDING', ?, ?)
                    """;

                int txId = 0;
                try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt   (1, t.getItemId());
                    ps.setInt   (2, t.getRequesterId());
                    ps.setInt   (3, t.getQuantity());
                    ps.setString(4, t.getNotes());
                    if (t.getEstimatedDelivery() != null && !t.getEstimatedDelivery().trim().isEmpty()) {
                        ps.setDate(5, java.sql.Date.valueOf(t.getEstimatedDelivery()));
                    } else {
                        ps.setNull(5, java.sql.Types.DATE);
                    }
                    ps.executeUpdate();

                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) txId = keys.getInt(1);
                    }
                }

                // 3. Notificar a Managers y Administradores
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

    // ============================================================
    // APPROVE — Aprueba + descuenta stock atomicamente
    // ============================================================
    public boolean approve(int id, int approverId, String notes) throws SQLException {

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {

                // 1. Traer datos de la transacción
                String sqlGet = """
                    SELECT item_id, quantity, requester_id, status, type
                    FROM transactions
                    WHERE id = ?
                    """;
                int itemId = 0, quantity = 0, requesterId = 0;
                String currentStatus = null, type = null;

                try (PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            itemId        = rs.getInt   ("item_id");
                            quantity      = rs.getInt   ("quantity");
                            requesterId   = rs.getInt   ("requester_id");
                            currentStatus = rs.getString("status");
                            type          = rs.getString("type");
                        }
                    }
                }

                // 2. Validar estado: solo PENDING
                if (!"PENDING".equals(currentStatus)) {
                    conn.rollback();
                    throw new SQLException("La solicitud ya fue procesada (estado: " + currentStatus + ")");
                }

                // 3. Validar stock disponible (solo para OUT)
                if ("OUT".equals(type)) {
                    String sqlStock = "SELECT cached_quantity FROM items WHERE id = ? AND activo = 1";
                    int stockActual = 0;

                    try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
                        ps.setInt(1, itemId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) stockActual = rs.getInt("cached_quantity");
                        }
                    }

                    if (quantity > stockActual) {
                        conn.rollback();
                        throw new SQLException(
                                "Stock insuficiente. Solicitado: " + quantity +
                                        " | Disponible: " + stockActual
                        );
                    }
                }

                // 4. Cambiar status a APPROVED
                String sqlUpdate = """
                    UPDATE transactions
                    SET status = 'APPROVED', approver_id = ?, notes = ?,
                        processed_at = CURRENT_TIMESTAMP,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ? AND status = 'PENDING'
                    """;
                boolean ok;
                try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                    ps.setInt   (1, approverId);
                    ps.setString(2, notes);
                    ps.setInt   (3, id);
                    ok = ps.executeUpdate() > 0;
                }

                if (!ok) {
                    conn.rollback();
                    return false;
                }

                // 5. DESCONTAR el stock (solo si es OUT)
                if ("OUT".equals(type)) {
                    String sqlStock = """
                        UPDATE items
                        SET cached_quantity = cached_quantity - ?,
                            status = CASE
                                WHEN cached_quantity - ? <= 0            THEN 'UNAVAILABLE'
                                WHEN cached_quantity - ? <= min_quantity THEN 'LOW'
                                ELSE 'OK'
                            END
                        WHERE id = ?
                        """;
                    try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
                        ps.setInt(1, quantity);
                        ps.setInt(2, quantity);
                        ps.setInt(3, quantity);
                        ps.setInt(4, itemId);
                        ps.executeUpdate();
                    }
                }

                // 6. Notificar al solicitante
                if (requesterId > 0) {
                    crearNotificacion(
                            conn,
                            requesterId,
                            "request_approved",
                            "¡Tu solicitud fue Aprobada!",
                            "Tu requerimiento ha sido aprobado. Stock reservado para tu pedido.",
                            id
                    );
                }

                // 7. Notificar al encargado de Depósito (role_id = 2)
                String sqlDeposito = "SELECT id FROM users WHERE role_id = 2 AND activo = 1";
                try (PreparedStatement psD = conn.prepareStatement(sqlDeposito);
                     ResultSet rsD = psD.executeQuery()) {
                    while (rsD.next()) {
                        int depositoId = rsD.getInt("id");
                        crearNotificacion(
                                conn,
                                depositoId,
                                "ready_to_deliver",
                                "Pedido aprobado listo para entregar",
                                "Una solicitud fue aprobada y está esperando ser entregada.",
                                id
                        );
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

    // ============================================================
    // DELIVER — Marca como ENTREGADO sin tocar stock
    // ============================================================
    // El stock YA se descontó al aprobar. Solo cambiamos status.
    public boolean deliver(int id) throws SQLException {

        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {

                // 1. Validar que está APPROVED
                String sqlGet = "SELECT status, requester_id FROM transactions WHERE id = ?";
                String currentStatus = null;
                int requesterId = 0;

                try (PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            currentStatus = rs.getString("status");
                            requesterId   = rs.getInt   ("requester_id");
                        }
                    }
                }

                if (!"APPROVED".equals(currentStatus)) {
                    conn.rollback();
                    throw new SQLException(
                            "Solo se pueden entregar solicitudes APROBADAS. Estado actual: " + currentStatus
                    );
                }

                // 2. Cambiar a COMPLETED (sin tocar stock)
                String sqlComplete = """
                    UPDATE transactions
                    SET status = 'COMPLETED',
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ? AND status = 'APPROVED'
                    """;
                boolean ok;
                try (PreparedStatement ps = conn.prepareStatement(sqlComplete)) {
                    ps.setInt(1, id);
                    ok = ps.executeUpdate() > 0;
                }

                if (!ok) {
                    conn.rollback();
                    return false;
                }

                // 3. Notificar al solicitante
                if (requesterId > 0) {
                    crearNotificacion(
                            conn,
                            requesterId,
                            "request_delivered",
                            "¡Materiales entregados!",
                            "Tu pedido ha sido entregado físicamente.",
                            id
                    );
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
        t.setEstimatedDelivery(rs.getString("estimated_delivery"));
        try { t.setItemName     (rs.getString("item_name")); } catch (Exception ignored) {}
        try { t.setItemUnit     (rs.getString("item_unit")); } catch (Exception ignored) {}
        try { t.setItemImg      (rs.getString("item_img"));  } catch (Exception ignored) {}
        try { t.setRequesterName(rs.getString("requester_name")); } catch (Exception ignored) {}
        try { t.setApproverName (rs.getString("approver_name")); } catch (Exception ignored) {}
        return t;
    }

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