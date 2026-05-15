package org.quintaola.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TransactionDAO {
    private Connection conn;

    public TransactionDAO(Connection connection) {
        this.conn = connection;
    }

    // ============================================================
    // getAll()
    // ============================================================

    public ResultSet getAll() throws SQLException {

        // Devuelve todas las transacciones del sistema sin filtros.
        // Incluye información completa del flujo de la transacción.

        String sql = """
                SELECT
                t.id,
                t.item_id,
                t.requester_id,
                t.approver_id,
                t.type,
                t.quantity,
                t.status,
                t.notes,
                t.created_at,
                t.updated_at,
                t.processed_at
                FROM transactions t
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getByItem(itemId)
    // ============================================================
    public ResultSet getByItem(String itemId) throws SQLException {

        // Devuelve todas las transacciones asociadas a un item específico.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.item_id = ?
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, itemId);

        return ps.executeQuery();
    }

    // ============================================================
    // getByRequester(id)
    // ============================================================
    public ResultSet getByRequester(String userId) throws SQLException {

        // Devuelve todas las transacciones solicitadas por un usuario.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.requester_id = ?
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, userId);

        return ps.executeQuery();
    }

    // ============================================================
    // getByApprover(id)
    // ============================================================
    public ResultSet getByApprover(String userId) throws SQLException {

        // Devuelve todas las transacciones aprobadas por un usuario.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.approver_id = ?
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, userId);
        return ps.executeQuery();
    }

    // ============================================================
    // getPending()
    // ============================================================
    public ResultSet getPending() throws SQLException {

        // Devuelve transacciones en estado PENDING.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.status = 'PENDING'
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getApproved()
    // ============================================================
    public ResultSet getApproved() throws SQLException {

        // Devuelve transacciones aprobadas.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.status = 'APPROVED'
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getRejected()
    // ============================================================
    public ResultSet getRejected() throws SQLException {

        // Devuelve transacciones rechazadas.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.status = 'REJECTED'
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getCompleted()
    // ============================================================
    public ResultSet getCompleted() throws SQLException {

        // Devuelve transacciones completadas.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.status = 'COMPLETED'
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getInbound()
    // ============================================================
    public ResultSet getInbound() throws SQLException {

        // Devuelve transacciones de entrada (IN).

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.type = 'IN'
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getOutbound()
    // ============================================================
    public ResultSet getOutbound() throws SQLException {

        // Devuelve transacciones de salida (OUT).

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.type = 'OUT'
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getAdjustments()
    // ============================================================
    public ResultSet getAdjustments() throws SQLException {

        // Devuelve transacciones de ajuste de inventario.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    WHERE t.type = 'ADJUST'
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getNewest()
    // ============================================================
    public ResultSet getNewest() throws SQLException {

        // Devuelve transacciones ordenadas desde las más recientes.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    ORDER BY t.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getOldest()
    // ============================================================
    public ResultSet getOldest() throws SQLException {

        // Devuelve transacciones ordenadas desde las más antiguas.

        String sql = """
                    SELECT
                        t.id,
                        t.item_id,
                        t.requester_id,
                        t.approver_id,
                        t.type,
                        t.quantity,
                        t.status,
                        t.notes,
                        t.created_at,
                        t.updated_at,
                        t.processed_at
                    FROM transactions t
                    ORDER BY t.created_at ASC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // VOLUME ANALYSIS
    // ============================================================

    public ResultSet getTotalTransactionsPerDay() throws SQLException {

        // Devuelve el total de transacciones agrupadas por día.

        String sql = """
                    SELECT DATE(created_at) AS day,
                           COUNT(*) AS total_transactions
                    FROM transactions
                    GROUP BY DATE(created_at)
                    ORDER BY day ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getTotalTransactionsPerWeek() throws SQLException {

        // Devuelve el total de transacciones agrupadas por semana.

        String sql = """
                    SELECT YEARWEEK(created_at) AS week,
                           COUNT(*) AS total_transactions
                    FROM transactions
                    GROUP BY YEARWEEK(created_at)
                    ORDER BY week ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getTransactionVolumeTrend() throws SQLException {

        // Devuelve la tendencia general del volumen de transacciones en el tiempo.

        String sql = """
                    SELECT DATE(created_at) AS day,
                           COUNT(*) AS total_transactions
                    FROM transactions
                    GROUP BY DATE(created_at)
                    ORDER BY day ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getPeakTransactionHours() throws SQLException {

        // Identifica las horas del día con mayor actividad de transacciones.

        String sql = """
                    SELECT HOUR(created_at) AS hour,
                           COUNT(*) AS total
                    FROM transactions
                    GROUP BY HOUR(created_at)
                    ORDER BY total DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // FLOW ANALYSIS
    // ============================================================

    public ResultSet getPendingQueueLengthOverTime() throws SQLException {

        // Mide la evolución de la cantidad de transacciones pendientes.

        String sql = """
                    SELECT DATE(created_at) AS day,
                           SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS pending_count
                    FROM transactions
                    GROUP BY DATE(created_at)
                    ORDER BY day ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getAverageProcessingTime() throws SQLException {

        // Calcula el tiempo promedio entre creación y procesamiento de transacciones.

        String sql = """
                    SELECT AVG(TIMESTAMPDIFF(MINUTE, created_at, processed_at)) AS avg_processing_time
                    FROM transactions
                    WHERE processed_at IS NOT NULL
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getBottleneckStages() throws SQLException {

        // Identifica posibles cuellos de botella en el flujo de transacciones.

        String sql = """
                    SELECT status,
                           COUNT(*) AS total
                    FROM transactions
                    GROUP BY status
                    ORDER BY total DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // TYPE DISTRIBUTION
    // ============================================================

    public ResultSet getTransactionTypeDistribution() throws SQLException {

        // Distribución de transacciones por tipo (IN, OUT, ADJUST).

        String sql = """
                    SELECT type,
                           COUNT(*) AS total
                    FROM transactions
                    GROUP BY type
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getMostCommonTransactionType() throws SQLException {

        // Identifica el tipo de transacción más frecuente.

        String sql = """
                    SELECT type,
                           COUNT(*) AS total
                    FROM transactions
                    GROUP BY type
                    ORDER BY total DESC
                    LIMIT 1
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // APPROVAL SYSTEM
    // ============================================================

    public ResultSet getApprovalRateOverTime() throws SQLException {

        // Calcula la tasa de aprobación a lo largo del tiempo.

        String sql = """
                    SELECT DATE(created_at) AS day,
                           SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS approval_rate
                    FROM transactions
                    GROUP BY DATE(created_at)
                    ORDER BY day ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getRejectionRateOverTime() throws SQLException {

        // Calcula la tasa de rechazo a lo largo del tiempo.

        String sql = """
                    SELECT DATE(created_at) AS day,
                           SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS rejection_rate
                    FROM transactions
                    GROUP BY DATE(created_at)
                    ORDER BY day ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getApprovalDelayDistribution() throws SQLException {

        // Distribución del tiempo de aprobación de transacciones.

        String sql = """
                    SELECT TIMESTAMPDIFF(MINUTE, created_at, processed_at) AS delay_minutes,
                           COUNT(*) AS total
                    FROM transactions
                    WHERE processed_at IS NOT NULL
                    GROUP BY delay_minutes
                    ORDER BY delay_minutes ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getMostStrictApprovers() throws SQLException {

        // Usuarios que más rechazan transacciones.

        String sql = """
                    SELECT approver_id,
                           COUNT(*) AS rejections
                    FROM transactions
                    WHERE status = 'REJECTED'
                    GROUP BY approver_id
                    ORDER BY rejections DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getMostLenientApprovers() throws SQLException {

        // Usuarios que más aprueban transacciones.

        String sql = """
                    SELECT approver_id,
                           COUNT(*) AS approvals
                    FROM transactions
                    WHERE status = 'APPROVED'
                    GROUP BY approver_id
                    ORDER BY approvals DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // ITEM IMPACT
    // ============================================================

    public ResultSet getTransactionsImpactOnStockLevels() throws SQLException {

        // Impacto de las transacciones en el stock de los items.

        String sql = """
                    SELECT item_id,
                           SUM(CASE WHEN type = 'IN' THEN quantity ELSE -quantity END) AS net_stock_change
                    FROM transactions
                    GROUP BY item_id
                    ORDER BY net_stock_change DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getStockChangePerTransactionType() throws SQLException {

        // Cambio neto de stock por tipo de transacción.

        String sql = """
                    SELECT type,
                           SUM(quantity) AS total_quantity
                    FROM transactions
                    GROUP BY type
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getHighImpactTransactions() throws SQLException {

        // Transacciones con mayor impacto en el inventario.

        String sql = """
                    SELECT id, item_id, quantity, type
                    FROM transactions
                    ORDER BY quantity DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // USER ↔ TRANSACTION RELATIONSHIP
    // ============================================================

    public ResultSet getTopRequesters() throws SQLException {

        // Usuarios que más solicitudes realizan.

        String sql = """
                    SELECT requester_id,
                           COUNT(*) AS total_requests
                    FROM transactions
                    GROUP BY requester_id
                    ORDER BY total_requests DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getTopApprovers() throws SQLException {

        // Usuarios que más aprobaciones realizan.

        String sql = """
                    SELECT approver_id,
                           COUNT(*) AS total_approvals
                    FROM transactions
                    GROUP BY approver_id
                    ORDER BY total_approvals DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getRequestToApprovalRatioPerUser() throws SQLException {

        // Relación entre solicitudes y aprobaciones por usuario.

        String sql = """
                    SELECT requester_id,
                           SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS approval_ratio
                    FROM transactions
                    GROUP BY requester_id
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // SYSTEM HEALTH
    // ============================================================

    public ResultSet getTransactionBacklog() throws SQLException {

        // Total de transacciones pendientes en el sistema.

        String sql = """
                    SELECT COUNT(*) AS backlog
                    FROM transactions
                    WHERE status = 'PENDING'
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getStalePendingTransactions() throws SQLException {

        // Transacciones pendientes demasiado antiguas.

        String sql = """
                    SELECT *
                    FROM transactions
                    WHERE status = 'PENDING'
                      AND created_at < NOW() - INTERVAL 7 DAY
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public ResultSet getFailedOrAbandonedTransactions() throws SQLException {

        // Transacciones fallidas o abandonadas.

        String sql = """
                    SELECT *
                    FROM transactions
                    WHERE status IN ('REJECTED')
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

}