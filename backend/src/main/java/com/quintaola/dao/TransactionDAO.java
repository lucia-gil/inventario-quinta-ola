// ============================================================
// TRANSACTION DAO SUMMARY (CORE FUNCTIONS ONLY)
// ============================================================
//
// getAll()            - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at, updated_at, processed_at
// getById(id)         - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at, updated_at, processed_at
// getByItem(itemId)   - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at, updated_at, processed_at
// getByRequester(id)  - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at, updated_at, processed_at
// getByApprover(id)   - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at, updated_at, processed_at
//
// getPending()        - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at
// getApproved()       - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at
// getRejected()       - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at
// getCompleted()      - id, item_id, requester_id, approver_id, type, quantity, status, notes, created_at
//
// getInbound()        - id, item_id, requester_id, approver_id, type(IN), quantity, status, created_at
// getOutbound()       - id, item_id, requester_id, approver_id, type(OUT), quantity, status, created_at
// getAdjustments()    - id, item_id, requester_id, approver_id, type(ADJUST), quantity, status, created_at
//
// getToday()          - id, item_id, requester_id, approver_id, type, quantity, status, created_at
// getThisWeek()       - id, item_id, requester_id, approver_id, type, quantity, status, created_at
// getThisMonth()      - id, item_id, requester_id, approver_id, type, quantity, status, created_at
//
// getNewest()         - id, item_id, requester_id, approver_id, type, quantity, status, created_at
// getOldest()         - id, item_id, requester_id, approver_id, type, quantity, status, created_at
//
// create(tx)          - boolean (insert transaction)
// approve(id)         - boolean (set APPROVED + approver_id + processed_at)
// reject(id)          - boolean (set REJECTED + approver_id + processed_at)
// updateStatus()      - boolean (generic status update)
// ============================================================

package com.quintaola.dao;

import com.quintaola.model.Transaction;
import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class TransactionDAO {

    // ── GET ALL ───────────────────────────────────────────────────
    public List<Transaction> getAll() throws SQLException {
        List<Transaction> list = new ArrayList<>();

        String sql = "SELECT * FROM transactions ORDER BY created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(Transaction.mapTransaction(rs));
            }
        }

        return list;
    }

    // // ── GET BY ID ─────────────────────────────────────────────────
    public Transaction getById(String id) throws SQLException {

        String sql = "SELECT * FROM transactions WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return Transaction.mapTransaction(rs);
            }
        }

        return null;
    }

    // ── GET BY ITEM ───────────────────────────────────────────────
    public List<Transaction> getByItemId(String itemId) throws SQLException {
        List<Transaction> list = new ArrayList<>();

        String sql = """
                    SELECT * FROM transactions
                    WHERE item_id = ?
                    ORDER BY created_at DESC
                """;

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, itemId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(Transaction.mapTransaction(rs));
                }
            }
        }

        return list;
    }

    // ── CREATE TRANSACTION ───────────────────────────────────────
    public boolean create(Transaction tx) throws SQLException {

        String sql = """
                    INSERT INTO transactions (
                        id, item_id, requester_id, approver_id,
                        type, quantity, status, notes,
                        created_at, updated_at, processed_at
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), NULL)
                """;

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, UUID.randomUUID().toString());
            ps.setString(2, tx.getItemId());
            ps.setString(3, tx.getRequesterId());
            ps.setString(4, tx.getApproverId());

            ps.setString(5, tx.getType()); // IN / OUT / ADJUST
            ps.setInt(6, tx.getQuantity());

            ps.setString(7, tx.getStatus() != null ? tx.getStatus() : "PENDING");
            ps.setString(8, tx.getNotes());

            return ps.executeUpdate() > 0;
        }
    }

    // ── UPDATE STATUS ─────────────────────────────────────────────
    public boolean updateStatus(String id, String status, String approverId) throws SQLException {

        String sql = """
                    UPDATE transactions
                    SET status = ?,
                        approver_id = ?,
                        processed_at = NOW(),
                        updated_at = NOW()
                    WHERE id = ?
                """;

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, approverId);
            ps.setString(3, id);

            return ps.executeUpdate() > 0;
        }
    }

    // ── DELETE (optional soft safety) ─────────────────────────────
    public boolean delete(String id) throws SQLException {

        String sql = "DELETE FROM transactions WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ============================================================
    // getAll()
    // ============================================================

    // public ResultSet getAll() throws SQLException {

    // // Devuelve todas las transacciones del sistema sin filtros.
    // // Incluye información completa del flujo de la transacción.

    // String sql = """
    // SELECT
    // t.id,
    // t.item_id,
    // t.requester_id,
    // t.approver_id,
    // t.type,
    // t.quantity,
    // t.status,
    // t.notes,
    // t.created_at,
    // t.updated_at,
    // t.processed_at
    // FROM transactions t
    // """;

    // Connection conn = DatabaseConnection.getConnection();
    // PreparedStatement ps = conn.prepareStatement(sql);

    // return ps.executeQuery();
    // }

    // // ============================================================
    // // getById(id)
    // // ============================================================
    // public ResultSet getById(String id) throws SQLException {

    // // Devuelve una transacción específica por ID.

    // String sql = """
    // SELECT
    // t.id,
    // t.item_id,
    // t.requester_id,
    // t.approver_id,
    // t.type,
    // t.quantity,
    // t.status,
    // t.notes,
    // t.created_at,
    // t.updated_at,
    // t.processed_at
    // FROM transactions t
    // WHERE t.id = ?
    // """;

    // Connection conn = DatabaseConnection.getConnection();
    // PreparedStatement ps = conn.prepareStatement(sql);

    // ps.setString(1, id);

    // return ps.executeQuery();
    // }

    // ============================================================
    // getByItem(itemId)
    // ============================================================
    public ResultSet getByItem(String itemId) throws SQLException {

        // Devuelve todas las transacciones asociadas a un item específico.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.item_id = ?
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, itemId);

        return ps.executeQuery();
    }

    // ============================================================
    // getByRequester(id)
    // ============================================================
    public ResultSet getByRequester(String userId) throws SQLException {

        // Devuelve todas las transacciones solicitadas por un usuario.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.requester_id = ?
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, userId);

        return ps.executeQuery();
    }

    // ============================================================
    // getByApprover(id)
    // ============================================================
    public ResultSet getByApprover(String userId) throws SQLException {

        // Devuelve todas las transacciones aprobadas por un usuario.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.approver_id = ?
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, userId);

        return ps.executeQuery();
    }

    // ============================================================
    // getPending()
    // ============================================================
    public ResultSet getPending() throws SQLException {

        // Devuelve transacciones en estado PENDING.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.status = 'PENDING'
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getApproved()
    // ============================================================
    public ResultSet getApproved() throws SQLException {

        // Devuelve transacciones aprobadas.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.status = 'APPROVED'
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getRejected()
    // ============================================================
    public ResultSet getRejected() throws SQLException {

        // Devuelve transacciones rechazadas.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.status = 'REJECTED'
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getCompleted()
    // ============================================================
    public ResultSet getCompleted() throws SQLException {

        // Devuelve transacciones completadas.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.status = 'COMPLETED'
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getInbound()
    // ============================================================
    public ResultSet getInbound() throws SQLException {

        // Devuelve transacciones de entrada (IN).

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.type = 'IN'
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getOutbound()
    // ============================================================
    public ResultSet getOutbound() throws SQLException {

        // Devuelve transacciones de salida (OUT).

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.type = 'OUT'
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getAdjustments()
    // ============================================================
    public ResultSet getAdjustments() throws SQLException {

        // Devuelve transacciones de ajuste de inventario.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.type = 'ADJUST'
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getNewest()
    // ============================================================
    public ResultSet getNewest() throws SQLException {

        // Devuelve transacciones ordenadas desde las más recientes.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    ORDER BY t.created_at DESC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getOldest()
    // ============================================================
    public ResultSet getOldest() throws SQLException {

        // Devuelve transacciones ordenadas desde las más antiguas.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    ORDER BY t.created_at ASC
                """;

        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }
}