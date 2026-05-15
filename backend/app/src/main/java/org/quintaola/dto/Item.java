package org.quintaola.dto;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
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

    private Timestamp createdAt;

    private List<String> tags;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public String getUnit() {
        return unit;
    }

    public int getCachedQuantity() {
        return cachedQuantity;
    }

    public int getMinQuantity() {
        return minQuantity;
    }

    public String getStatus() {
        return status;
    }

    public boolean isActivo() {
        return activo;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public List<String> getTags() {
        return tags;
    }

    public String getStatusName() {
        return switch (this.status) {
            case "OK" -> "OK";
            case "LOW" -> "Stock Bajo";
            case "UNAVAILABLE" -> "Sin Stock";
            default -> this.status;
        };
    }

    public static Item mapItem(ResultSet rs) throws SQLException {
        Item item = new Item();

        item.id = rs.getString("id");
        item.name = rs.getString("name");
        item.description = rs.getString("description");
        item.imageUrl = rs.getString("image_url");
        item.unit = rs.getString("unit");

        item.cachedQuantity = rs.getInt("cached_quantity");
        item.minQuantity = rs.getInt("min_quantity");

        item.status = rs.getString("status");
        item.activo = rs.getBoolean("activo");

        item.createdAt = rs.getTimestamp("created_at");

        return item;
    }
}