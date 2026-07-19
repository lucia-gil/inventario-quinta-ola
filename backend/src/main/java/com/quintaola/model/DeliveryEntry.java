package com.quintaola.model;

/**
 * ════════════════════════════════════════════════════════════════════
 * DeliveryEntry — Representa una entrega próxima/programada
 * ════════════════════════════════════════════════════════════════════
 * Usado por el widget "Próximas entregas" del Inicio (home.jsp).
 * No es una entidad de BD propia — es una proyección de campos ya
 * existentes en `transactions` + `items` + `users`, pensada solo
 * para ese widget.
 * ════════════════════════════════════════════════════════════════════
 */
public class DeliveryEntry {

    private int transactionId;
    private String itemName;
    private String itemUnit;
    private int quantity;
    private String requesterName;
    private String estimatedDelivery; // formato "yyyy-MM-dd" tal como viene de la BD
    private String status;            // APPROVED, PENDING, etc.

    public DeliveryEntry() {}

    public int getTransactionId()                     { return transactionId; }
    public void setTransactionId(int transactionId)   { this.transactionId = transactionId; }

    public String getItemName()                       { return itemName; }
    public void setItemName(String itemName)           { this.itemName = itemName; }

    public String getItemUnit()                        { return itemUnit; }
    public void setItemUnit(String itemUnit)            { this.itemUnit = itemUnit; }

    public int getQuantity()                           { return quantity; }
    public void setQuantity(int quantity)              { this.quantity = quantity; }

    public String getRequesterName()                   { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getEstimatedDelivery()                        { return estimatedDelivery; }
    public void setEstimatedDelivery(String estimatedDelivery)  { this.estimatedDelivery = estimatedDelivery; }

    public String getStatus()               { return status; }
    public void setStatus(String status)    { this.status = status; }
}
