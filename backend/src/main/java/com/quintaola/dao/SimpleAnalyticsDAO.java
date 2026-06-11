package com.quintaola.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.quintaola.util.DatabaseConnection;

public class SimpleAnalyticsDAO {
    public void getItemTagDistribution(List<String> names, List<Integer> cantidad) throws SQLException {
        String sql = """
                SELECT t.name, COUNT(i.id) cantidad FROM tags t
                LEFT JOIN item_tags it ON t.id = it.tag_id
                LEFT JOIN items i ON it.item_id = i.id
                GROUP BY t.id;
                """;

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                names.add("'" + rs.getString("name") + "'");
                cantidad.add(rs.getInt("cantidad"));
            }
        }
    }

    public void getTransactionsType(List<Integer> in, List<Integer> out) throws SQLException {
        String sql = """
                WITH RECURSIVE current_week_days AS (
                    -- 1. Start with Monday of the current week
                    SELECT
                        DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) AS week_date,
                        1 AS day_num
                    UNION ALL
                    -- 2. Increment by 1 day until we hit Sunday (7 days total)
                    SELECT
                        DATE_ADD(week_date, INTERVAL 1 DAY),
                        day_num + 1
                    FROM current_week_days
                    WHERE day_num < 7
                )
                -- 3. Left join the virtual days calendar to your transactions table
                SELECT
                    DAYNAME(cwd.week_date) AS day_of_week,
                    COALESCE(COUNT(CASE WHEN t.type = 'IN' THEN 1 END), 0) AS `in`,
                    COALESCE(COUNT(CASE WHEN t.type = 'OUT' THEN 1 END), 0) AS `out`
                FROM current_week_days cwd
                LEFT JOIN transactions t
                    ON DATE(t.created_at) = cwd.week_date
                GROUP BY
                    cwd.day_num,
                    cwd.week_date
                ORDER BY
                    cwd.day_num;
                """;

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                in.add(rs.getInt("in"));
                out.add(rs.getInt("out"));
            }
        }
    }

    public void getTransactionsStatus(
            List<Integer> completeadas,
            List<Integer> pendientes,
            List<Integer> rechazadas) throws SQLException {
        String sql = """
                WITH RECURSIVE current_week_days AS (
                    -- 1. Start with Monday of the current week
                    SELECT
                        DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) AS week_date,
                        1 AS day_num
                    UNION ALL
                    -- 2. Increment by 1 day until we hit Sunday (7 days total)
                    SELECT
                        DATE_ADD(week_date, INTERVAL 1 DAY),
                        day_num + 1
                    FROM current_week_days
                    WHERE day_num < 7
                )
                -- 3. Left join the virtual days calendar to your transactions table
                SELECT
                    DAYNAME(cwd.week_date) AS day_of_week,
                    COALESCE(COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END), 0) AS `completadas`,
                    COALESCE(COUNT(CASE WHEN status = 'PENDING' THEN 1 END), 0) AS `pendientes`,
                    COALESCE(COUNT(CASE WHEN status = 'REJECTED' THEN 1 END), 0) AS `rechazadas`
                FROM current_week_days cwd
                LEFT JOIN transactions t
                    ON DATE(t.created_at) = cwd.week_date
                GROUP BY
                    cwd.day_num,
                    cwd.week_date
                ORDER BY
                    cwd.day_num;
                                """;

        try (Connection conn = DatabaseConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                completeadas.add(rs.getInt("completadas"));
                pendientes.add(rs.getInt("pendientes"));
                rechazadas.add(rs.getInt("rechazadas"));
            }
        }
    }
}