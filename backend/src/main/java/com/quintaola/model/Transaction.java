package com.quintaola.model;

public class Transaction {

    private String id;
    private String itemId;
    private String requesterId;
    private String approverId;
    private String type;
    private int quantity;
    private String status;
    private String notes;
    private String createdAt;
    private String updatedAt;
    private String processedAt;

    // Campos extra para el frontend (JOINs)
    private String itemName;
    private String itemUnit;
    private String requesterName;
    private String approverName;

    public Transaction() {}

    public String getId()                      { return id; }
    public void setId(String id)               { this.id = id; }

    public String getItemId()                  { return itemId; }
    public void setItemId(String itemId)       { this.itemId = itemId; }

    public String getRequesterId()                     { return requesterId; }
    public void setRequesterId(String requesterId)     { this.requesterId = requesterId; }

    public String getApproverId()                      { return approverId; }
    public void setApproverId(String approverId)       { this.approverId = approverId; }

    public String getType()                    { return type; }
    public void setType(String type)           { this.type = type; }

    public int getQuantity()                   { return quantity; }
    public void setQuantity(int quantity)      { this.quantity = quantity; }

    public String getStatus()                  { return status; }
    public void setStatus(String status)       { this.status = status; }

    public String getNotes()                   { return notes; }
    public void setNotes(String notes)         { this.notes = notes; }

    public String getCreatedAt()               { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getUpdatedAt()               { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }

    public String getProcessedAt()                     { return processedAt; }
    public void setProcessedAt(String processedAt)     { this.processedAt = processedAt; }

    public String getItemName()                        { return itemName; }
    public void setItemName(String itemName)           { this.itemName = itemName; }

    public String getItemUnit()                        { return itemUnit; }
    public void setItemUnit(String itemUnit)           { this.itemUnit = itemUnit; }

    public String getRequesterName()                           { return requesterName; }
    public void setRequesterName(String requesterName)         { this.requesterName = requesterName; }

    public String getApproverName()                            { return approverName; }
    public void setApproverName(String approverName)           { this.approverName = approverName; }

    public String getStatusFrontend() {
        return switch (this.status) {
            case "PENDING"         -> "Pendiente";
            case "APPROVED"        -> "Aprobada";
            case "REJECTED"        -> "Rechazada";
            case "COMPLETED"       -> "Entregada";
            case "WAITING_CHANGES" -> "En Revisión";
            default                -> this.status;
        };
    }
}