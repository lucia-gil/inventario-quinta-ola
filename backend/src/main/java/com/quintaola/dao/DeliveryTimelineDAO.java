package com.quintaola.dao;

import com.quintaola.model.DeliveryEntry;
import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ════════════════════════════════════════════════════════════════════
 * DeliveryTimelineDAO — Widget "Próximas entregas" del Inicio
 * ════════════════════════════════════════════════════════════════════
 * DAO independiente y de solo-lectura: no modifica ninguna tabla,
 * solo consulta `transactions` (ya existente) para armar la franja
 * de 7 días del home.jsp. No requiere ningún cambio de esquema.
 * ════════════════════════════════════════════════════════════════════
 */
public class DeliveryTimelineDAO {

    /**
     * Devuelve las entregas APROBADAS con fecha estimada dentro de los
     * próximos `dias` días (incluye hoy).
     *
     * @param requesterId si no es null, filtra solo las entregas de ESE
     *                    solicitante (útil para el rol Viewer, que solo
     *                    debe ver sus propias entregas). Si es null,
     *                    trae las de TODO el sistema (para roles
     *                    operativos: Depósito, Manager, Admin, SuperAdmin).
     * @param dias         tamaño de la ventana hacia adelante (ej. 7).
     */
    public List<DeliveryEntry> getUpcomingDeliveries(Integer requesterId, int dias) throws SQLException {
        List<DeliveryEntry> entregas = new ArrayList<>();

        StringBuilder sql = new StringBuilder("""
            SELECT t.id, t.quantity, t.estimated_delivery, t.status,
                   i.name AS item_name, i.unit AS item_unit,
                   u.name AS requester_name
            FROM transactions t
            JOIN items i ON i.id = t.item_id
            JOIN users u ON u.id = t.requester_id
            WHERE t.status = 'APPROVED'
              AND t.estimated_delivery IS NOT NULL
              AND t.estimated_delivery >= CURDATE()
              AND t.estimated_delivery <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
            """);

        if (requesterId != null) {
            sql.append(" AND t.requester_id = ? ");
        }
        sql.append(" ORDER BY t.estimated_delivery ASC ");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            ps.setInt(idx++, dias);
            if (requesterId != null) {
                ps.setInt(idx++, requesterId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DeliveryEntry e = new DeliveryEntry();
                    e.setTransactionId(rs.getInt("id"));
                    e.setQuantity(rs.getInt("quantity"));
                    e.setEstimatedDelivery(rs.getString("estimated_delivery"));
                    e.setStatus(rs.getString("status"));
                    e.setItemName(rs.getString("item_name"));
                    e.setItemUnit(rs.getString("item_unit"));
                    e.setRequesterName(rs.getString("requester_name"));
                    entregas.add(e);
                }
            }
        }
        return entregas;
    }
}