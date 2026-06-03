package com.quintaola.dao;

import com.quintaola.model.Notification;
import com.quintaola.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    // 1. Obtener TODAS las notificaciones de un usuario (leídas y no leídas)
    public List<Notification> getByUserId(int userId) throws SQLException {
        List<Notification> list = new ArrayList<>();
        // Quitamos "AND is_read = 0" para que el JSP pueda pintar las leídas de gris
        String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Notification n = new Notification();
                    n.setId(rs.getInt("id"));
                    n.setUserId(rs.getInt("user_id"));
                    n.setType(rs.getString("type"));
                    n.setTitle(rs.getString("title"));
                    n.setMessage(rs.getString("message"));
                    n.setRelatedId(rs.getInt("related_id"));
                    n.setIsRead(rs.getInt("is_read")); // El JSP leerá esto para saber si ponerlo gris
                    n.setCreatedAt(rs.getString("created_at"));
                    list.add(n);
                }
            }
        }
        return list;
    }

    // 2. MeTODO NUEVO: Marcar una notificación específica como leída (is_read = 1)
    public boolean markAsRead(int notifId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, notifId);
            int filasAfectadas = ps.executeUpdate();

            return filasAfectadas > 0; // Retorna true si se actualizó correctamente
        }
    }

    // 3. Obtener el número de notificaciones NO leídas de un usuario
    public int getUnreadCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
}