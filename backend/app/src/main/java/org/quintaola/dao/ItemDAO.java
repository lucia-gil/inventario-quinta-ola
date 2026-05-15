package org.quintaola.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ItemDAO {
    private Connection conn;

    public ItemDAO(Connection connection) {
        this.conn = connection;
    }

    // ============================================================
    // getAll()
    // ============================================================

    public ResultSet getAll() throws SQLException {

        // Devuelve todos los items del sistema (activos e inactivos),
        // incluyendo sus tags concatenados en una sola columna.
        // No aplica filtros ni orden específico.

        String sql = """
                SELECT
                i.id,
                i.name,
                i.description,
                i.image_url,
                i.unit,
                i.cached_quantity,
                i.min_quantity,
                i.status,
                i.activo,
                i.created_at,
                GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
                FROM items i
                LEFT JOIN item_tags it ON it.item_id = i.id
                LEFT JOIN tags t ON t.id = it.tag_id
                GROUP BY
                i.id, i.name, i.description, i.image_url,
                i.unit, i.cached_quantity, i.min_quantity,
                i.status, i.activo, i.created_at
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // getLowStock()
    // ============================================================
    public ResultSet getLowStock() throws SQLException {

        // Devuelve los items cuyo stock actual es menor o igual
        // al stock mínimo definido (cached_quantity <= min_quantity).
        // Solo incluye items activos.

        String sql = """
                    SELECT
                        i.id,
                        i.name,
                        i.description,
                        i.image_url,
                        i.unit,
                        i.cached_quantity,
                        i.min_quantity,
                        i.status,
                        i.activo,
                        i.created_at,
                        GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
                    FROM items i
                    LEFT JOIN item_tags it ON it.item_id = i.id
                    LEFT JOIN tags t ON t.id = it.tag_id
                    WHERE i.cached_quantity <= i.min_quantity
                    AND i.activo = 1
                    GROUP BY
                        i.id, i.name, i.description, i.image_url,
                        i.unit, i.cached_quantity, i.min_quantity,
                        i.status, i.activo, i.created_at
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // getOkStock()
    // ============================================================
    public ResultSet getOkStock() throws SQLException {

        // Devuelve los items con stock suficiente,
        // es decir cuando cached_quantity es mayor al min_quantity.
        // Solo incluye items activos.

        String sql = """
                    SELECT
                        i.id,
                        i.name,
                        i.description,
                        i.image_url,
                        i.unit,
                        i.cached_quantity,
                        i.min_quantity,
                        i.status,
                        i.activo,
                        i.created_at,
                        GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
                    FROM items i
                    LEFT JOIN item_tags it ON it.item_id = i.id
                    LEFT JOIN tags t ON t.id = it.tag_id
                    WHERE i.cached_quantity > i.min_quantity
                    AND i.activo = 1
                    GROUP BY
                        i.id, i.name, i.description, i.image_url,
                        i.unit, i.cached_quantity, i.min_quantity,
                        i.status, i.activo, i.created_at
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // getUnavailable()
    // ============================================================
    public ResultSet getUnavailable() throws SQLException {

        // Devuelve los items que están marcados como no disponibles
        // o desactivados en el sistema.
        // También puede incluir items con status UNAVAILABLE.

        String sql = """
                    SELECT
                        i.id,
                        i.name,
                        i.description,
                        i.image_url,
                        i.unit,
                        i.cached_quantity,
                        i.min_quantity,
                        i.status,
                        i.activo,
                        i.created_at,
                        GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
                    FROM items i
                    LEFT JOIN item_tags it ON it.item_id = i.id
                    LEFT JOIN tags t ON t.id = it.tag_id
                    WHERE i.status = 'UNAVAILABLE'
                    OR i.activo = 0
                    GROUP BY
                        i.id, i.name, i.description, i.image_url,
                        i.unit, i.cached_quantity, i.min_quantity,
                        i.status, i.activo, i.created_at
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // getNewest()
    // ============================================================
    public ResultSet getNewest() throws SQLException {

        // Devuelve los items ordenados desde el más reciente al más antiguo
        // según su fecha de creación (created_at DESC).

        String sql = """
                    SELECT
                        i.id,
                        i.name,
                        i.description,
                        i.image_url,
                        i.unit,
                        i.cached_quantity,
                        i.min_quantity,
                        i.status,
                        i.activo,
                        i.created_at,
                        GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
                    FROM items i
                    LEFT JOIN item_tags it ON it.item_id = i.id
                    LEFT JOIN tags t ON t.id = it.tag_id
                    GROUP BY
                        i.id, i.name, i.description, i.image_url,
                        i.unit, i.cached_quantity, i.min_quantity,
                        i.status, i.activo, i.created_at
                    ORDER BY i.created_at DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // getOldest()
    // ============================================================
    public ResultSet getOldest() throws SQLException {

        // Devuelve los items ordenados desde el más antiguo al más reciente
        // según su fecha de creación (created_at ASC).

        String sql = """
                    SELECT
                        i.id,
                        i.name,
                        i.description,
                        i.image_url,
                        i.unit,
                        i.cached_quantity,
                        i.min_quantity,
                        i.status,
                        i.activo,
                        i.created_at,
                        GROUP_CONCAT(DISTINCT t.name SEPARATOR ', ') AS tags
                    FROM items i
                    LEFT JOIN item_tags it ON it.item_id = i.id
                    LEFT JOIN tags t ON t.id = it.tag_id
                    GROUP BY
                        i.id, i.name, i.description, i.image_url,
                        i.unit, i.cached_quantity, i.min_quantity,
                        i.status, i.activo, i.created_at
                    ORDER BY i.created_at ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // getMostRequested()
    // ============================================================
    public ResultSet getMostRequested() throws SQLException {

        // Devuelve los items ordenados por mayor cantidad de solicitudes de salida
        // (OUT).
        // Se usa COUNT(t.id) para medir cuántas veces fue solicitado cada item.

        String sql = """
                    SELECT
                        i.id,
                        i.name,
                        i.description,
                        i.image_url,
                        i.unit,
                        i.cached_quantity,
                        i.min_quantity,
                        i.status,
                        i.activo,
                        i.created_at,

                        COUNT(t.id) AS total_requests,

                        GROUP_CONCAT(DISTINCT tg.name SEPARATOR ', ') AS tags

                    FROM items i

                    LEFT JOIN transactions t
                        ON t.item_id = i.id
                    AND t.type = 'OUT'

                    LEFT JOIN item_tags it
                        ON it.item_id = i.id

                    LEFT JOIN tags tg
                        ON tg.id = it.tag_id

                    WHERE i.activo = 1

                    GROUP BY
                        i.id, i.name, i.description, i.image_url,
                        i.unit, i.cached_quantity, i.min_quantity,
                        i.status, i.activo, i.created_at

                    ORDER BY total_requests DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // MOVEMENT / USAGE
    // ============================================================

    public ResultSet getMostRequestedItems() throws SQLException {

        // Devuelve los items con mayor cantidad de transacciones OUT,
        // ordenados por demanda total.

        String sql = """
                    SELECT i.id, i.name, COUNT(t.id) AS total_requests
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id AND t.type = 'OUT'
                    GROUP BY i.id, i.name
                    ORDER BY total_requests DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getLeastRequestedItems() throws SQLException {

        // Devuelve los items con menor cantidad de uso (OUT transactions).

        String sql = """
                    SELECT i.id, i.name, COUNT(t.id) AS total_requests
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id AND t.type = 'OUT'
                    GROUP BY i.id, i.name
                    ORDER BY total_requests ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getTrendingItems(int days) throws SQLException {

        // Devuelve los items con mayor actividad reciente en los últimos días.

        String sql = """
                    SELECT i.id, i.name, COUNT(t.id) AS recent_requests
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id
                     AND t.type = 'OUT'
                     AND t.created_at >= NOW() - INTERVAL ? DAY
                    GROUP BY i.id, i.name
                    ORDER BY recent_requests DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, days);

        return ps.executeQuery();
    }

    public ResultSet getDecliningItems(int days) throws SQLException {

        // Devuelve items con baja actividad reciente comparada con su histórico.

        String sql = """
                    SELECT i.id, i.name, COUNT(t.id) AS recent_requests
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id
                     AND t.type = 'OUT'
                     AND t.created_at >= NOW() - INTERVAL ? DAY
                    GROUP BY i.id, i.name
                    ORDER BY recent_requests ASC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, days);

        return ps.executeQuery();
    }

    // ============================================================
    // CONSUMPTION PATTERNS
    // ============================================================

    public ResultSet getAverageConsumptionPerDay() throws SQLException {

        // Calcula el consumo promedio diario por item.

        String sql = """
                    SELECT i.id, i.name,
                           COUNT(t.id) / GREATEST(DATEDIFF(NOW(), MIN(t.created_at)), 1) AS avg_daily_out
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id AND t.type = 'OUT'
                    GROUP BY i.id, i.name
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getAverageConsumptionPerWeek() throws SQLException {

        // Calcula el consumo promedio semanal por item.

        String sql = """
                    SELECT i.id, i.name,
                           COUNT(t.id) / GREATEST(TIMESTAMPDIFF(WEEK, MIN(t.created_at), NOW()), 1) AS avg_weekly_out
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id AND t.type = 'OUT'
                    GROUP BY i.id, i.name
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // LIFECYCLE INSIGHTS
    // ============================================================

    public ResultSet getRecentlyCreatedItems() throws SQLException {

        // Devuelve los items más recientemente creados.

        String sql = """
                    SELECT id, name, created_at
                    FROM items
                    ORDER BY created_at DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getOldUnusedItems() throws SQLException {

        // Devuelve items antiguos con poca o ninguna actividad.

        String sql = """
                    SELECT i.id, i.name, i.created_at
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id AND t.type = 'OUT'
                    WHERE t.id IS NULL
                       OR i.created_at < NOW() - INTERVAL 90 DAY
                    GROUP BY i.id, i.name, i.created_at
                    ORDER BY i.created_at ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getNeverRequestedItems() throws SQLException {

        // Devuelve items que nunca han sido usados en transacciones OUT.

        String sql = """
                    SELECT i.id, i.name
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id AND t.type = 'OUT'
                    WHERE t.id IS NULL
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // TAG / CATEGORY INTELLIGENCE
    // ============================================================

    public ResultSet getMostCommonTags() throws SQLException {

        // Devuelve los tags más usados en el sistema.

        String sql = """
                    SELECT tg.name AS tag, COUNT(it.item_id) AS usage_count
                    FROM tags tg
                    LEFT JOIN item_tags it ON it.tag_id = tg.id
                    GROUP BY tg.name
                    ORDER BY usage_count DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getTagsWithHighestConsumption() throws SQLException {

        // Devuelve tags asociados a items con mayor consumo.

        String sql = """
                    SELECT tg.name AS tag,
                           SUM(CASE WHEN t.type='OUT' THEN t.quantity ELSE 0 END) AS total_consumption
                    FROM tags tg
                    JOIN item_tags it ON it.tag_id = tg.id
                    JOIN transactions t ON t.item_id = it.item_id
                    GROUP BY tg.name
                    ORDER BY total_consumption DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getItemsGroupedByTagUsage() throws SQLException {

        // Devuelve cuántos items están asociados a cada tag.

        String sql = """
                    SELECT tg.name AS tag, COUNT(it.item_id) AS item_count
                    FROM tags tg
                    LEFT JOIN item_tags it ON it.tag_id = tg.id
                    GROUP BY tg.name
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // EFFICIENCY METRICS
    // ============================================================

    public ResultSet getReorderFrequencyPerItem() throws SQLException {

        // Estima cuántas veces un item necesita reposición.

        String sql = """
                    SELECT i.id, i.name, COUNT(t.id) AS reorder_count
                    FROM items i
                    LEFT JOIN transactions t
                      ON t.item_id = i.id AND t.type = 'IN'
                    GROUP BY i.id, i.name
                    ORDER BY reorder_count DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getStockTurnoverRate() throws SQLException {

        // Calcula la tasa de rotación de inventario por item.

        String sql = """
                    SELECT i.id, i.name,
                           COUNT(CASE WHEN t.type='OUT' THEN 1 END) /
                           GREATEST(COUNT(CASE WHEN t.type='IN' THEN 1 END), 1) AS turnover_rate
                    FROM items i
                    LEFT JOIN transactions t ON t.item_id = i.id
                    GROUP BY i.id, i.name
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getWasteRiskItems() throws SQLException {

        // Identifica items con riesgo de desperdicio por baja actividad.

        String sql = """
                    SELECT i.id, i.name,
                           COUNT(t.id) AS activity_score
                    FROM items i
                    LEFT JOIN transactions t ON t.item_id = i.id
                    GROUP BY i.id, i.name
                    HAVING activity_score < 3
                    ORDER BY activity_score ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

}