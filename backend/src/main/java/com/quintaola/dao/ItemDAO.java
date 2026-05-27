// ============================================================
// ITEM DAO METHODS (SIGNATURE + OUTPUT CONTRACT)
// ============================================================
//
// getAll()            - id, name, description, image_url, unit, cached_quantity, min_quantity, status, activo, created_at, tags
// getAllAdmin()       - id, name, description, image_url, unit, cached_quantity, min_quantity, status, activo, created_at, tags
// getById(id)         - id, name, description, image_url, unit, cached_quantity, min_quantity, status, activo, created_at, tags
// create(item)        - boolean
// update(item)        - boolean
// disable(id)         - boolean
//
// getLowStock()       - ResultSet
// getOkStock()        - ResultSet
// getUnavailable()    - ResultSet
// getNewest()         - ResultSet
// getOldest()         - ResultSet
// getMostRequested()  - ResultSet
// ============================================================

package com.quintaola.dao;

import com.quintaola.model.Item;
import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ItemDAO {

    // ── GET ALL — listar todos los ítems activos con sus TAGS ──────────────────
    public List<Item> getAll() throws SQLException {
        List<Item> items = new ArrayList<>();
        String sql = """
            SELECT i.*, GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            WHERE i.activo = 1
            GROUP BY i.id
            ORDER BY i.created_at DESC
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                items.add(mapRow(rs));
            }
        }
        return items;
    }

    // ── GET ALL ADMIN — listar todos incluyendo inactivos con sus TAGS ─────────
    public List<Item> getAllAdmin() throws SQLException {
        List<Item> items = new ArrayList<>();
        String sql = """
            SELECT i.*, GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            GROUP BY i.id
            ORDER BY i.created_at DESC
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                items.add(mapRow(rs));
            }
        }
        return items;
    }

    // ── GET BY ID con sus TAGS ─────────────────────────────────────────────────
    public Item getById(int id) throws SQLException {
        String sql = """
            SELECT i.*, GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            WHERE i.id = ?
            GROUP BY i.id
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        }
        return null;
    }

    // ── CREATE ────────────────────────────────────────────────────
    // Inserta el item y devuelve el ID generado por la BD (para usarlo en item_tags)
    public int create(Item item) throws SQLException {
        String sql = """
            INSERT INTO items (name, description, image_url, unit,
                               cached_quantity, min_quantity, status, activo)
            VALUES (?, ?, ?, ?, ?, ?, ?, 1)
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, item.getName());
            ps.setString(2, item.getDescription());
            ps.setString(3, item.getImageUrl());
            ps.setString(4, item.getUnit());
            ps.setInt   (5, item.getCachedQuantity());
            ps.setInt   (6, item.getMinQuantity());
            ps.setString(7, item.getStatus() != null ? item.getStatus() : "OK");

            int rows = ps.executeUpdate();
            if (rows == 0) return 0;

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int newId = keys.getInt(1);
                    item.setId(newId);
                    return newId;
                }
            }
        }
        return 0;
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
            ps.setInt   (6, item.getId());

            return ps.executeUpdate() > 0;
        }
    }

    // ── DISABLE — deshabilitar en lugar de borrar ─────────────────
    public boolean disable(int id) throws SQLException {
        String sql = "UPDATE items SET activo = 0 WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ── MAP ROW — convierte una fila de BD a objeto Item (soporta lista de Tags) ──
    private Item mapRow(ResultSet rs) throws SQLException {
        Item item = new Item();
        item.setId             (rs.getInt      ("id"));
        item.setName           (rs.getString   ("name"));
        item.setDescription    (rs.getString   ("description"));
        item.setImageUrl       (rs.getString   ("image_url"));
        item.setUnit           (rs.getString   ("unit"));
        item.setCachedQuantity (rs.getInt      ("cached_quantity"));
        item.setMinQuantity    (rs.getInt      ("min_quantity"));
        item.setStatus         (rs.getString   ("status"));
        item.setActivo         (rs.getBoolean  ("activo"));
        item.setCreatedAt      (rs.getString   ("created_at"));

        // Procesar los TAGS de la consulta combinada
        List<String> listaTags = new ArrayList<>();
        try {
            String tagsString = rs.getString("tags");
            if (tagsString != null && !tagsString.isBlank()) {
                for (String tag : tagsString.split(", ")) {
                    listaTags.add(tag.trim());
                }
            }
        } catch (SQLException e) {
            // Si el query no trae la columna 'tags', no truena
        }
        item.setTags(listaTags);

        return item;
    }

    // ============================================================
    // getLowStock()
    // ============================================================
    public ResultSet getLowStock() throws SQLException {
        String sql = """
            SELECT
                i.id, i.name, i.description, i.image_url, i.unit,
                i.cached_quantity, i.min_quantity, i.status, i.activo, i.created_at,
                GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            WHERE i.cached_quantity <= i.min_quantity AND i.activo = 1
            GROUP BY i.id
        """;
        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);
        return ps.executeQuery();
    }

    // ============================================================
    // getOkStock()
    // ============================================================
    public ResultSet getOkStock() throws SQLException {
        String sql = """
            SELECT
                i.id, i.name, i.description, i.image_url, i.unit,
                i.cached_quantity, i.min_quantity, i.status, i.activo, i.created_at,
                GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            WHERE i.cached_quantity > i.min_quantity AND i.activo = 1
            GROUP BY i.id
        """;
        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);
        return ps.executeQuery();
    }

    // ============================================================
    // getUnavailable()
    // ============================================================
    public ResultSet getUnavailable() throws SQLException {
        String sql = """
            SELECT
                i.id, i.name, i.description, i.image_url, i.unit,
                i.cached_quantity, i.min_quantity, i.status, i.activo, i.created_at,
                GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            WHERE i.status = 'UNAVAILABLE' OR i.activo = 0
            GROUP BY i.id
        """;
        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);
        return ps.executeQuery();
    }

    // ============================================================
    // getNewest()
    // ============================================================
    public ResultSet getNewest() throws SQLException {
        String sql = """
            SELECT
                i.id, i.name, i.description, i.image_url, i.unit,
                i.cached_quantity, i.min_quantity, i.status, i.activo, i.created_at,
                GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            GROUP BY i.id
            ORDER BY i.created_at DESC
        """;
        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);
        return ps.executeQuery();
    }

    // ============================================================
    // getOldest()
    // ============================================================
    public ResultSet getOldest() throws SQLException {
        String sql = """
            SELECT
                i.id, i.name, i.description, i.image_url, i.unit,
                i.cached_quantity, i.min_quantity, i.status, i.activo, i.created_at,
                GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            GROUP BY i.id
            ORDER BY i.created_at ASC
        """;
        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);
        return ps.executeQuery();
    }

    // ============================================================
    // getMostRequested()
    // ============================================================
    public ResultSet getMostRequested() throws SQLException {
        String sql = """
            SELECT
                i.id, i.name, i.description, i.image_url, i.unit,
                i.cached_quantity, i.min_quantity, i.status, i.activo, i.created_at,
                COUNT(t.id) AS total_requests,
                GROUP_CONCAT(DISTINCT tg.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN transactions t ON t.item_id = i.id AND t.type = 'OUT'
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags tg ON tg.id = it.tag_id
            WHERE i.activo = 1
            GROUP BY i.id
            ORDER BY total_requests DESC
        """;
        Connection conn = DatabaseConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(sql);
        return ps.executeQuery();
    }
}