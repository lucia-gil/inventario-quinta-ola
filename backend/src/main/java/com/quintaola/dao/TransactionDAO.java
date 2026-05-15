package com.quintaola.dao;

import com.quintaola.model.Transaction;
import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class TransactionDAO {

    public List<Transaction> getAll() throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit,
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

    public Transaction getById(String id) throws SQLException {
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit,
                   u.name AS requester_name, a.name AS approver_name
            FROM transactions t
            JOIN items i ON t.item_id = i.id
            JOIN users u ON t.requester_id = u.id
            LEFT JOIN users a ON t.approver_id = a.id
            WHERE t.id = ?
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    public List<Transaction> getPending() throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit,
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
            SELECT t.*, i.name AS item_name, i.unit AS item_unit,
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

    public List<Transaction> getByUser(String userId) throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = """
            SELECT t.*, i.name AS item_name, i.unit AS item_unit,
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
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        }
        return list;
    }

    public boolean create(Transaction t) throws SQLException {
        String sql = """
            INSERT INTO transactions
            (id, item_id, requester_id, type, quantity, status, notes)
            VALUES (?, ?, ?, 'OUT', ?, 'PENDING', ?)
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, UUID.randomUUID().toString());
            ps.setString(2, t.getItemId());
            ps.setString(3, t.getRequesterId());
            ps.setInt   (4, t.getQuantity());
            ps.setString(5, t.getNotes());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean approve(String id, String approverId, String notes) throws SQLException {
        String sql = """
            UPDATE transactions
            SET status = 'APPROVED', approver_id = ?, notes = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND status = 'PENDING'
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, approverId);
            ps.setString(2, notes);
            ps.setString(3, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean reject(String id, String approverId, String notes) throws SQLException {
        String sql = """
            UPDATE transactions
            SET status = 'REJECTED', approver_id = ?, notes = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ? AND status = 'PENDING'
            """;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, approverId);
            ps.setString(2, notes);
            ps.setString(3, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deliver(String id) throws SQLException {
        Connection conn = DatabaseConnection.getConnection();
        try {
            conn.setAutoCommit(false);

            String sqlGet = "SELECT item_id, quantity, type FROM transactions WHERE id = ?";
            String itemId = null;
            int quantity  = 0;
            String type   = null;

            try (PreparedStatement ps = conn.prepareStatement(sqlGet)) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        itemId   = rs.getString("item_id");
                        quantity = rs.getInt("quantity");
                        type     = rs.getString("type");
                    }
                }
            }

            if (itemId == null) { conn.rollback(); return false; }

            String sqlComplete = """
                UPDATE transactions
                SET status = 'COMPLETED', processed_at = CURRENT_TIMESTAMP,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id = ?
                """;
            try (PreparedStatement ps = conn.prepareStatement(sqlComplete)) {
                ps.setString(1, id);
                ps.executeUpdate();
            }

            int delta = type.equals("IN") ? quantity : -quantity;
            String sqlStock = """
                UPDATE items
                SET cached_quantity = cached_quantity + ?,
                    status = CASE
                        WHEN cached_quantity + ? <= 0           THEN 'UNAVAILABLE'
                        WHEN cached_quantity + ? <= min_quantity THEN 'LOW'
                        ELSE 'OK'
                    END
                WHERE id = ?
                """;
            try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
                ps.setInt   (1, delta);
                ps.setInt   (2, delta);
                ps.setInt   (3, delta);
                ps.setString(4, itemId);
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

    private Transaction mapRow(ResultSet rs) throws SQLException {
        Transaction t = new Transaction();
        t.setId           (rs.getString("id"));
        t.setItemId       (rs.getString("item_id"));
        t.setRequesterId  (rs.getString("requester_id"));
        t.setApproverId   (rs.getString("approver_id"));
        t.setType         (rs.getString("type"));
        t.setQuantity     (rs.getInt   ("quantity"));
        t.setStatus       (rs.getString("status"));
        t.setNotes        (rs.getString("notes"));
        t.setCreatedAt    (rs.getString("created_at"));
        t.setProcessedAt  (rs.getString("processed_at"));
        try { t.setItemName     (rs.getString("item_name")); } catch (Exception ignored) {}
        try { t.setItemUnit     (rs.getString("item_unit")); } catch (Exception ignored) {}
        try { t.setRequesterName(rs.getString("requester_name")); } catch (Exception ignored) {}
        try { t.setApproverName (rs.getString("approver_name")); } catch (Exception ignored) {}
        return t;
    }
}