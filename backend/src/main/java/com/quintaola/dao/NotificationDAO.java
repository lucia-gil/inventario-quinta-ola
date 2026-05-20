package com.quintaola.dao;

import com.quintaola.model.Notification;
import com.quintaola.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    // Obtener notificaciones activas de un usuario específico
    public List<Notification> getByUserId(String userId) throws SQLException {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ? AND is_read = 0 ORDER BY created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getString("id"));
                    n.setUserId(rs.getString("user_id"));
                    n.setType(rs.getString("type"));
                    n.setTitle(rs.getString("title"));
                    n.setMessage(rs.getString("message"));
                    n.setRelatedId(rs.getString("related_id"));
                    n.setIsRead(rs.getInt("is_read"));
                    n.setCreatedAt(rs.getString("created_at"));
                    list.add(n);
                }
            }
        }
        return list;
    }
}