package com.quintaola.model;

public class Transaction {

    private int id;
    private int itemId;
    private int requesterId;
    private int approverId;        // 0 = sin aprobador asignado todavía
    private String type;
    private int quantity;
    private String status;
    private String notes;
    private String createdAt;
    private String updatedAt;
    private String processedAt;
    private String deliveredAt;
    private String deliveryNotes;  // Nota del encargado de depósito al momento de entregar (imprevistos)

    // Campos extra para el frontend (JOINs)
    private String itemName;
    private String itemUnit;
    private String itemImg;
    private String requesterName;
    private String approverName;
    private String estimatedDelivery;

    public Transaction() {}

    public int getId()                          { return id; }
    public void setId(int id)                   { this.id = id; }

    public int getItemId()                      { return itemId; }
    public void setItemId(int itemId)           { this.itemId = itemId; }

    public int getRequesterId()                 { return requesterId; }
    public void setRequesterId(int requesterId) { this.requesterId = requesterId; }

    public int getApproverId()                  { return approverId; }
    public void setApproverId(int approverId)   { this.approverId = approverId; }

    public String getType()                     { return type; }
    public void setType(String type)            { this.type = type; }

    public int getQuantity()                    { return quantity; }
    public void setQuantity(int quantity)       { this.quantity = quantity; }

    public String getStatus()                   { return status; }
    public void setStatus(String status)        { this.status = status; }

    public String getNotes()                    { return notes; }
    public void setNotes(String notes)          { this.notes = notes; }

    public String getCreatedAt()                { return createdAt; }
    public void setCreatedAt(String createdAt)  { this.createdAt = createdAt; }

    public String getUpdatedAt()                { return updatedAt; }
    public void setUpdatedAt(String updatedAt)  { this.updatedAt = updatedAt; }

    public String getProcessedAt()                  { return processedAt; }
    public void setProcessedAt(String processedAt)  { this.processedAt = processedAt; }

    // ⬅️ NUEVO: getter/setter de deliveredAt
    public String getDeliveredAt()                  { return deliveredAt; }
    public void setDeliveredAt(String deliveredAt)  { this.deliveredAt = deliveredAt; }

    // ⬅️ NUEVO: getter/setter de deliveryNotes
    public String getDeliveryNotes()                    { return deliveryNotes; }
    public void setDeliveryNotes(String deliveryNotes)  { this.deliveryNotes = deliveryNotes; }

    public String getItemName()                 { return itemName; }
    public void setItemName(String itemName)    { this.itemName = itemName; }

    public String getItemUnit()                 { return itemUnit; }
    public void setItemUnit(String itemUnit)    { this.itemUnit = itemUnit; }

    public String getItemImg()                  { return itemImg; }
    public void setItemImg(String itemImg)      { this.itemImg = itemImg; }

    public String getRequesterName()                       { return requesterName; }
    public void setRequesterName(String requesterName)     { this.requesterName = requesterName; }

    public String getApproverName()                        { return approverName; }
    public void setApproverName(String approverName)       { this.approverName = approverName; }

    public String getStatusFrontend() {
        if (this.status == null) return "Pendiente";
        return switch (this.status) {
            case "PENDING"         -> "Pendiente";
            case "APPROVED"        -> "Aprobada";
            case "REJECTED"        -> "Rechazada";
            case "COMPLETED"       -> "Entregada";
            case "WAITING_CHANGES" -> "En Revisión";
            default                -> this.status;
        };
    }

    public String getEstimatedDelivery() { return estimatedDelivery; }
    public void setEstimatedDelivery(String estimatedDelivery) { this.estimatedDelivery = estimatedDelivery; }
}