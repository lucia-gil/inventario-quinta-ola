package com.quintaola.dao;

import com.quintaola.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * ════════════════════════════════════════════════════════════════════
 * ReportDAO — Consultas SQL agrupadas para reportes exportables
 * ════════════════════════════════════════════════════════════════════
 *
 * Cada método devuelve una lista de Map<String, Object> donde la KEY
 * es el nombre de la columna y el VALUE es el dato. Usamos LinkedHashMap
 * para preservar el ORDEN de las columnas tal como vienen del query.
 *
 * Esta estructura "agnóstica" permite que ReportServlet pueda volcar
 * los datos tanto a CSV como a XLSX sin cambiar nada.
 *
 * Reportes generados:
 *   1. salidasDelPeriodo  — transacciones COMPLETED entre 2 fechas
 *   2. consumoPorMaterial — total consumido por item en un período
 *   3. inventarioActual   — snapshot de stock actual
 * ════════════════════════════════════════════════════════════════════
 */
public class ReportDAO {

    /**
     * REPORTE 1 — SALIDAS DEL PERÍODO
     * Lo que la cliente actualmente envía a mano cada mes.
     * Lista todas las transacciones COMPLETED (entregadas) en el rango dado.
     */
    public List<Map<String, Object>> salidasDelPeriodo(String fromDate, String toDate) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = """
            SELECT
                t.id                AS `ID Solicitud`,
                t.delivered_at      AS `Fecha de entrega`,
                t.created_at        AS `Fecha de solicitud`,
                u.name              AS `Solicitante`,
                r.name              AS `Rol`,
                i.name              AS `Material`,
                GROUP_CONCAT(DISTINCT tg.name SEPARATOR ', ') AS `Categoría`,
                t.quantity          AS `Cantidad`,
                i.unit              AS `Unidad`,
                a.name              AS `Aprobado por`,
                t.notes             AS `Notas`
            FROM transactions t
            JOIN items i  ON t.item_id      = i.id
            JOIN users u  ON t.requester_id = u.id
            JOIN roles r  ON u.role_id      = r.id
            LEFT JOIN users a       ON t.approver_id = a.id
            LEFT JOIN item_tags it  ON it.item_id    = i.id
            LEFT JOIN tags tg       ON tg.id         = it.tag_id
            WHERE t.status = 'COMPLETED'
              AND DATE(t.delivered_at) BETWEEN ? AND ?
            GROUP BY t.id
            ORDER BY t.delivered_at DESC
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fromDate);
            ps.setString(2, toDate);
            try (ResultSet rs = ps.executeQuery()) {
                rows.addAll(mapearFilas(rs));
            }
        }
        return rows;
    }

    /**
     * REPORTE 2 — CONSUMO POR MATERIAL
     * Cuánto se ha consumido de cada item en el período dado.
     */
    public List<Map<String, Object>> consumoPorMaterial(String fromDate, String toDate) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = """
            SELECT
                i.name                  AS `Material`,
                GROUP_CONCAT(DISTINCT tg.name SEPARATOR ', ') AS `Categoría`,
                i.unit                  AS `Unidad`,
                COALESCE(SUM(t.quantity), 0) AS `Total consumido`,
                COUNT(t.id)             AS `Número de salidas`,
                MAX(t.delivered_at)     AS `Última salida`,
                i.cached_quantity       AS `Stock actual`,
                i.min_quantity          AS `Stock mínimo`
            FROM items i
            LEFT JOIN transactions t
                   ON t.item_id = i.id
                  AND t.status = 'COMPLETED'
                  AND DATE(t.delivered_at) BETWEEN ? AND ?
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags tg      ON tg.id      = it.tag_id
            WHERE i.activo = 1
            GROUP BY i.id
            ORDER BY `Total consumido` DESC, i.name ASC
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fromDate);
            ps.setString(2, toDate);
            try (ResultSet rs = ps.executeQuery()) {
                rows.addAll(mapearFilas(rs));
            }
        }
        return rows;
    }

    /**
     * REPORTE 3 — INVENTARIO ACTUAL
     * Snapshot del estado actual del inventario. Sin filtros.
     */
    public List<Map<String, Object>> inventarioActual() throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = """
            SELECT
                i.id                AS `ID`,
                i.name              AS `Material`,
                GROUP_CONCAT(DISTINCT tg.name SEPARATOR ', ') AS `Categoría`,
                i.cached_quantity   AS `Stock actual`,
                i.min_quantity      AS `Stock mínimo`,
                i.unit              AS `Unidad`,
                CASE i.status
                    WHEN 'OK'          THEN 'Disponible'
                    WHEN 'LOW'         THEN 'Stock bajo'
                    WHEN 'UNAVAILABLE' THEN 'Sin stock'
                    ELSE i.status
                END                 AS `Estado`,
                i.created_at        AS `Fecha de alta`
            FROM items i
            LEFT JOIN item_tags it ON it.item_id = i.id
            LEFT JOIN tags tg      ON tg.id      = it.tag_id
            WHERE i.activo = 1
            GROUP BY i.id
            ORDER BY i.name ASC
            """;

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            rows.addAll(mapearFilas(rs));
        }
        return rows;
    }

    /**
     * Convierte el ResultSet en lista de Map ordenado.
     * Preserva el orden de columnas usando LinkedHashMap.
     */
    private List<Map<String, Object>> mapearFilas(ResultSet rs) throws SQLException {
        List<Map<String, Object>> rows = new ArrayList<>();
        ResultSetMetaData meta = rs.getMetaData();
        int columnCount = meta.getColumnCount();

        while (rs.next()) {
            Map<String, Object> fila = new LinkedHashMap<>();
            for (int i = 1; i <= columnCount; i++) {
                String columnName = meta.getColumnLabel(i);
                Object value = rs.getObject(i);
                fila.put(columnName, value != null ? value : "");
            }
            rows.add(fila);
        }
        return rows;
    }
}