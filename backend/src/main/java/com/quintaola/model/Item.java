package com.quintaola.model;

import java.util.List;

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
    private List<String> tags;

    public Item() {}

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

    public int getCachedQuantity()                    { return cachedQuantity; }
    public void setCachedQuantity(int cachedQuantity) { this.cachedQuantity = cachedQuantity; }

    public int getMinQuantity()                       { return minQuantity; }
    public void setMinQuantity(int minQuantity)       { this.minQuantity = minQuantity; }

    public String getStatus()                 { return status; }
    public void setStatus(String status)      { this.status = status; }

    public boolean isActivo()                 { return activo; }
    public void setActivo(boolean activo)     { this.activo = activo; }

    public String getCreatedAt()              { return createdAt; }
    public void setCreatedAt(String createdAt){ this.createdAt = createdAt; }

    public List<String> getTags()             { return tags; }
    public void setTags(List<String> tags)    { this.tags = tags; }

    public String getStatusFrontend() {
        return switch (this.status) {
            case "OK"          -> "OK";
            case "LOW"         -> "Stock Bajo";
            case "UNAVAILABLE" -> "Sin Stock";
            default            -> this.status;
        };
    }
}