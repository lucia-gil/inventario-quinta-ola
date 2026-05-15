package com.quintaola.model;

import java.sql.Timestamp;
import java.sql.SQLException;
import java.sql.ResultSet;

public class Transaction {

    private String id;

    private String itemId;
    private String requesterId;
    private String approverId;

    private String type; // IN, OUT, ADJUST
    private int quantity;

    private String status; // PENDING, APPROVED, etc.

    private String notes;

    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp processedAt;

    // Getters & Setters

    public String getId() {
        return id;
    }

    public String getItemId() {
        return itemId;
    }

    public String getRequesterId() {
        return requesterId;
    }

    public String getApproverId() {
        return approverId;
    }

    public String getType() {
        return type;
    }

    public int getQuantity() {
        return quantity;
    }

    public String getStatus() {
        return status;
    }

    public String getNotes() {
        return notes;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public Timestamp getProcessedAt() {
        return processedAt;
    }

    public static Transaction mapTransaction(ResultSet rs) throws SQLException {
        Transaction tx = new Transaction();

        tx.id = rs.getString("id");

        tx.itemId = rs.getString("item_id");
        tx.requesterId = rs.getString("requester_id");
        tx.approverId = rs.getString("approver_id");

        tx.type = rs.getString("type");
        tx.quantity = rs.getInt("quantity");

        tx.status = rs.getString("status");

        tx.notes = rs.getString("notes");

        tx.createdAt = rs.getTimestamp("created_at");
        tx.updatedAt = rs.getTimestamp("updated_at");
        tx.processedAt = rs.getTimestamp("processed_at");

        return tx;
    }
}