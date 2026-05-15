package com.quintaola.model;

import java.sql.Timestamp;
import java.sql.SQLException;
import java.sql.ResultSet;

public class Transaction {

    private String id;

    private String itemId;
    private String requesterId;
    private String approverId;

    private String type;     // IN, OUT, ADJUST
    private int quantity;

    private String status;   // PENDING, APPROVED, etc.

    private String notes;

    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Timestamp processedAt;

    // Getters & Setters

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getItemId() { return itemId; }
    public void setItemId(String itemId) { this.itemId = itemId; }

    public String getRequesterId() { return requesterId; }
    public void setRequesterId(String requesterId) { this.requesterId = requesterId; }

    public String getApproverId() { return approverId; }
    public void setApproverId(String approverId) { this.approverId = approverId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Timestamp getProcessedAt() { return processedAt; }
    public void setProcessedAt(Timestamp processedAt) { this.processedAt = processedAt; }

    private Transaction mapTransaction(ResultSet rs) throws SQLException {
        Transaction tx = new Transaction();

        tx.setId(rs.getString("id"));

        tx.setItemId(rs.getString("item_id"));
        tx.setRequesterId(rs.getString("requester_id"));
        tx.setApproverId(rs.getString("approver_id"));

        tx.setType(rs.getString("type"));
        tx.setQuantity(rs.getInt("quantity"));

        tx.setStatus(rs.getString("status"));

        tx.setNotes(rs.getString("notes"));

        tx.setCreatedAt(rs.getTimestamp("created_at"));
        tx.setUpdatedAt(rs.getTimestamp("updated_at"));
        tx.setProcessedAt(rs.getTimestamp("processed_at"));

        return tx;
    }
}