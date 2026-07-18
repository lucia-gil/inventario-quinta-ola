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

    // ── GET ALL INACTIVE — listar SOLO los materiales desactivados ─────────────
    // Usado para el filtro "Desactivados" en la Lista de Materiales.
    public List<Item> getAllInactive() throws SQLException {
        List<Item> items = new ArrayList<>();
        String sql = """
            SELECT i.*, GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags t ON t.id = it.tag_id
            WHERE i.activo = 0
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

    // ── REACTIVATE — volver a habilitar un material desactivado ───
    // Espejo de disable(): mismo patrón, misma forma de uso desde el servlet.
    // NOTA: no reactiva el status (OK/LOW/UNAVAILABLE) — ese se recalcula solo
    // según cached_quantity vs min_quantity la próxima vez que se consulte/actualice.
    public boolean reactivate(int id) throws SQLException {
        String sql = "UPDATE items SET activo = 1 WHERE id = ?";

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

    // ============================================================
    // getAvailableStock — Obtener cantidad disponible de un item
    // ============================================================
    // Usado para validar si hay stock suficiente antes de aprobar
    // una solicitud (o al momento de crearla).

    public int getAvailableStock(int itemId) throws SQLException {
        String sql = "SELECT cached_quantity FROM items WHERE id = ? AND activo = 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, itemId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cached_quantity");
                }
            }
        }
        return 0;  // Si el item no existe o está inactivo
    }

    /**
     * Devuelve todos los tags únicos existentes en la BD,
     * ordenados alfabéticamente. Se usa para llenar selects
     * y filtros sin hardcodear las opciones.
     */
    public java.util.List<String> getAllTagNames() throws java.sql.SQLException {
        java.util.List<String> tags = new java.util.ArrayList<>();
        String sql = "SELECT name FROM tags ORDER BY name ASC";
        try (java.sql.Connection conn = com.quintaola.util.DatabaseConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                tags.add(rs.getString("name"));
            }
        }
        return tags;
    }

    /**
     * Asigna un tag a un item por nombre.
     * Si el tag no existe en la tabla 'tags', lo crea.
     * Inserta la relación en 'item_tags'.
     */
    public void assignTag(int itemId, String tagName, int createdBy) throws SQLException {
        if (tagName == null || tagName.trim().isEmpty()) return;
        tagName = tagName.trim();

        try (Connection conn = DatabaseConnection.getConnection()) {

            // 1. Buscar si el tag ya existe
            int tagId = 0;
            String sqlFind = "SELECT id FROM tags WHERE name = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlFind)) {
                ps.setString(1, tagName);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) tagId = rs.getInt("id");
                }
            }

            // 2. Si no existe, crearlo
            if (tagId == 0) {
                String sqlInsert = "INSERT INTO tags (name, created_by) VALUES (?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, tagName);
                    ps.setInt(2, createdBy);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) tagId = keys.getInt(1);
                    }
                }
            }

            // 3. Insertar la relación item-tag (IGNORE para no duplicar)
            if (tagId > 0) {
                String sqlRel = "INSERT IGNORE INTO item_tags (item_id, tag_id) VALUES (?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sqlRel)) {
                    ps.setInt(1, itemId);
                    ps.setInt(2, tagId);
                    ps.executeUpdate();
                }
            }
        }
    }

    /**
     * Borra todas las relaciones item-tag de un item.
     * Útil al actualizar: borrar todos y volver a asignar.
     */
    public void clearTags(int itemId) throws SQLException {
        String sql = "DELETE FROM item_tags WHERE item_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ps.executeUpdate();
        }
    }
}