package org.quintaola.dto;

import java.sql.Timestamp;
import java.sql.SQLException;
import java.sql.ResultSet;
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

    // Getters & Setters

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public int getCachedQuantity() {
        return cachedQuantity;
    }

    public void setCachedQuantity(int cachedQuantity) {
        this.cachedQuantity = cachedQuantity;
    }

    public int getMinQuantity() {
        return minQuantity;
    }

    public void setMinQuantity(int minQuantity) {
        this.minQuantity = minQuantity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    private Item mapItem(ResultSet rs) throws SQLException {
        Item item = new Item();

        item.setId(rs.getString("id"));
        item.setName(rs.getString("name"));
        item.setDescription(rs.getString("description"));
        item.setImageUrl(rs.getString("image_url"));
        item.setUnit(rs.getString("unit"));

        item.setCachedQuantity(rs.getInt("cached_quantity"));
        item.setMinQuantity(rs.getInt("min_quantity"));

        item.setStatus(rs.getString("status"));
        item.setActivo(rs.getBoolean("activo"));

        item.setCreatedAt(rs.getTimestamp("created_at"));

        return item;
    }
}