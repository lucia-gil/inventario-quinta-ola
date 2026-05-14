package com.quintaola.model;

public class Item {

    private String id;
    private String name;
    private String description;
    private String imageUrl;
    private String unit;
    private int cachedQuantity;
    private int minQuantity;
    private String status;
    private boolean activo;
    private String createdAt;

    // Constructor vacío
    public Item() {}

    // Constructor completo
    public Item(String id, String name, String description, String imageUrl,
                String unit, int cachedQuantity, int minQuantity,
                String status, boolean activo, String createdAt) {
        this.id            = id;
        this.name          = name;
        this.description   = description;
        this.imageUrl      = imageUrl;
        this.unit          = unit;
        this.cachedQuantity = cachedQuantity;
        this.minQuantity   = minQuantity;
        this.status        = status;
        this.activo        = activo;
        this.createdAt     = createdAt;
    }

    // Getters y Setters
    public String getId()                     { return id; }
    public void setId(String id)              { this.id = id; }

    public String getName()                   { return name; }
    public void setName(String name)          { this.name = name; }

    public String getDescription()            { return description; }
    public void setDescription(String desc)   { this.description = desc; }

    public String getImageUrl()               { return imageUrl; }
    public void setImageUrl(String imageUrl)  { this.imageUrl = imageUrl; }

    public String getUnit()                   { return unit; }
    public void setUnit(String unit)          { this.unit = unit; }

    public int getCachedQuantity()                        { return cachedQuantity; }
    public void setCachedQuantity(int cachedQuantity)     { this.cachedQuantity = cachedQuantity; }

    public int getMinQuantity()                           { return minQuantity; }
    public void setMinQuantity(int minQuantity)           { this.minQuantity = minQuantity; }

    public String getStatus()                 { return status; }
    public void setStatus(String status)      { this.status = status; }

    public boolean isActivo()                 { return activo; }
    public void setActivo(boolean activo)     { this.activo = activo; }

    public String getCreatedAt()              { return createdAt; }
    public void setCreatedAt(String createdAt){ this.createdAt = createdAt; }

    // Traducción de status para el frontend
    public String getStatusFrontend() {
        return switch (this.status) {
            case "OK"          -> "OK";
            case "LOW"         -> "Stock Bajo";
            case "UNAVAILABLE" -> "Sin Stock";
            default            -> this.status;
        };
    }
}