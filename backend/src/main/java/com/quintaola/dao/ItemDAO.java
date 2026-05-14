package com.quintaola.dao;

import com.quintaola.model.Item;
import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class ItemDAO {

    // ── GET ALL — listar todos los ítems activos ──────────────────
    public List<Item> getAll() throws SQLException {
        List<Item> items = new ArrayList<>();
        String sql = "SELECT * FROM items WHERE activo = 1 ORDER BY created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                items.add(mapRow(rs));
            }
        }
        return items;
    }

    // ── GET ALL ADMIN — listar todos incluyendo inactivos ─────────
    public List<Item> getAllAdmin() throws SQLException {
        List<Item> items = new ArrayList<>();
        String sql = "SELECT * FROM items ORDER BY created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                items.add(mapRow(rs));
            }
        }
        return items;
    }

    // ── GET BY ID ─────────────────────────────────────────────────
    public Item getById(String id) throws SQLException {
        String sql = "SELECT * FROM items WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    // ── CREATE ────────────────────────────────────────────────────
    public boolean create(Item item) throws SQLException {
        String sql = """
            INSERT INTO items (id, name, description, image_url, unit,
                               cached_quantity, min_quantity, status, activo)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, UUID.randomUUID().toString());
            ps.setString(2, item.getName());
            ps.setString(3, item.getDescription());
            ps.setString(4, item.getImageUrl());
            ps.setString(5, item.getUnit());
            ps.setInt   (6, item.getCachedQuantity());
            ps.setInt   (7, item.getMinQuantity());
            ps.setString(8, item.getStatus() != null ? item.getStatus() : "OK");

            return ps.executeUpdate() > 0;
        }
    }

    // ── UPDATE ────────────────────────────────────────────────────
    public boolean update(Item item) throws SQLException {
        String sql = """
            UPDATE items
            SET name = ?, description = ?, image_url = ?,
                unit = ?, min_quantity = ?
            WHERE id = ?
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getName());
            ps.setString(2, item.getDescription());
            ps.setString(3, item.getImageUrl());
            ps.setString(4, item.getUnit());
            ps.setInt   (5, item.getMinQuantity());
            ps.setString(6, item.getId());

            return ps.executeUpdate() > 0;
        }
    }

    // ── DISABLE — deshabilitar en lugar de borrar ─────────────────
    public boolean disable(String id) throws SQLException {
        String sql = "UPDATE items SET activo = 0 WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ── MAP ROW — convierte una fila de BD a objeto Item ──────────
    private Item mapRow(ResultSet rs) throws SQLException {
        Item item = new Item();
        item.setId             (rs.getString   ("id"));
        item.setName           (rs.getString   ("name"));
        item.setDescription    (rs.getString   ("description"));
        item.setImageUrl       (rs.getString   ("image_url"));
        item.setUnit           (rs.getString   ("unit"));
        item.setCachedQuantity (rs.getInt      ("cached_quantity"));
        item.setMinQuantity    (rs.getInt      ("min_quantity"));
        item.setStatus         (rs.getString   ("status"));
        item.setActivo         (rs.getBoolean  ("activo"));
        item.setCreatedAt      (rs.getString   ("created_at"));
        return item;
    }
}