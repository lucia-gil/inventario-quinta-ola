package org.quintaola.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ItemDAO {
    public static ResultSet getMostRequested() throws SQLException {

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

                    GROUP_CONCAT(
                        DISTINCT tg.name
                        ORDER BY tg.name ASC
                        SEPARATOR ', '
                    ) AS tags

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
                    i.id,
                    i.name,
                    i.description,
                    i.image_url,
                    i.unit,
                    i.cached_quantity,
                    i.min_quantity,
                    i.status,
                    i.activo,
                    i.created_at

                ORDER BY total_requests DESC,
                         i.name ASC
                """;

        String url = "jdbc:mysql://localhost:3306/inventario_db";
        String user = "root";
        String password = "admin123";

        Connection conn = DriverManager.getConnection(url, user, password);
        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }
}