// ============================================================
// ITEMS ANALYTICS DAO
// ============================================================
//
// RETURN CONTRACTS:
//
// MOVEMENT / USAGE
// getMostRequestedItems()        -> id, name, total_requests
// getLeastRequestedItems()       -> id, name, total_requests
// getTrendingItems(days)         -> id, name, recent_requests
// getDecliningItems(days)        -> id, name, recent_requests
//
// CONSUMPTION PATTERNS
// getAverageConsumptionPerDay()  -> id, name, avg_daily_out
// getAverageConsumptionPerWeek() -> id, name, avg_weekly_out
//
// LIFECYCLE INSIGHTS
// getRecentlyCreatedItems()      -> id, name, created_at
// getOldUnusedItems()            -> id, name, created_at
// getNeverRequestedItems()       -> id, name
//
// TAG / CATEGORY INTELLIGENCE
// getMostCommonTags()            -> tag, usage_count
// getTagsWithHighestConsumption() -> tag, total_consumption
// getItemsGroupedByTagUsage()    -> tag, item_count
//
// EFFICIENCY METRICS
// getReorderFrequencyPerItem()   -> id, name, reorder_count
// getStockTurnoverRate()         -> id, name, turnover_rate
// getWasteRiskItems()            -> id, name, activity_score
//
// ============================================================

package com.quintaola.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ItemsAnalyticsDAO {

    // ============================================================
    // MOVEMENT / USAGE
    // ============================================================

    public static ResultSet getMostRequestedItems(Connection conn) throws SQLException {

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

    public static ResultSet getLeastRequestedItems(Connection conn) throws SQLException {

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

    public static ResultSet getTrendingItems(Connection conn, int days) throws SQLException {

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

    public static ResultSet getDecliningItems(Connection conn, int days) throws SQLException {

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

    public static ResultSet getAverageConsumptionPerDay(Connection conn) throws SQLException {

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

    public static ResultSet getAverageConsumptionPerWeek(Connection conn) throws SQLException {

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

    public static ResultSet getRecentlyCreatedItems(Connection conn) throws SQLException {

        // Devuelve los items más recientemente creados.

        String sql = """
                    SELECT id, name, created_at
                    FROM items
                    ORDER BY created_at DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getOldUnusedItems(Connection conn) throws SQLException {

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

    public static ResultSet getNeverRequestedItems(Connection conn) throws SQLException {

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

    public static ResultSet getMostCommonTags(Connection conn) throws SQLException {

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

    public static ResultSet getTagsWithHighestConsumption(Connection conn) throws SQLException {

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

    public static ResultSet getItemsGroupedByTagUsage(Connection conn) throws SQLException {

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

    public static ResultSet getReorderFrequencyPerItem(Connection conn) throws SQLException {

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

    public static ResultSet getStockTurnoverRate(Connection conn) throws SQLException {

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

    public static ResultSet getWasteRiskItems(Connection conn) throws SQLException {

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