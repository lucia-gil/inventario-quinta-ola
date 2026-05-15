// ============================================================
// TRANSACTIONS ANALYTICS DAO
// ============================================================
//
// RETURN CONTRACTS:
//
// VOLUME ANALYSIS
// getTotalTransactionsPerDay()        -> day, total_transactions
// getTotalTransactionsPerWeek()       -> week, total_transactions
// getTransactionVolumeTrend()         -> day, total_transactions
// getPeakTransactionHours()           -> hour, total
//
// FLOW ANALYSIS
// getPendingQueueLengthOverTime()     -> day, pending_count
// getAverageProcessingTime()          -> avg_processing_time
// getBottleneckStages()               -> status, total
//
// TYPE DISTRIBUTION
// getTransactionTypeDistribution()    -> type, total
// getMostCommonTransactionType()      -> type, total
//
// APPROVAL SYSTEM
// getApprovalRateOverTime()           -> day, approval_rate
// getRejectionRateOverTime()          -> day, rejection_rate
// getApprovalDelayDistribution()      -> delay_minutes, total
// getMostStrictApprovers()            -> approver_id, rejections
// getMostLenientApprovers()           -> approver_id, approvals
//
// ITEM IMPACT
// getTransactionsImpactOnStockLevels() -> item_id, net_stock_change
// getStockChangePerTransactionType()   -> type, total_quantity
// getHighImpactTransactions()          -> id, item_id, quantity, type
//
// USER ↔ TRANSACTION RELATIONSHIP
// getTopRequesters()                  -> requester_id, total_requests
// getTopApprovers()                   -> approver_id, total_approvals
// getRequestToApprovalRatioPerUser()  -> requester_id, approval_ratio
//
// SYSTEM HEALTH
// getTransactionBacklog()             -> backlog
// getStalePendingTransactions()       -> full transaction row
// getFailedOrAbandonedTransactions()  -> full transaction row
//
// ============================================================

package com.quintaola.dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TransactionsAnalyticsDAO {

    // ============================================================
    // VOLUME ANALYSIS
    // ============================================================

    public static ResultSet getTotalTransactionsPerDay(Connection conn) throws SQLException {

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

    public static ResultSet getTotalTransactionsPerWeek(Connection conn) throws SQLException {

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

    public static ResultSet getTransactionVolumeTrend(Connection conn) throws SQLException {

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

    public static ResultSet getPeakTransactionHours(Connection conn) throws SQLException {

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

    public static ResultSet getPendingQueueLengthOverTime(Connection conn) throws SQLException {

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

    public static ResultSet getAverageProcessingTime(Connection conn) throws SQLException {

        // Calcula el tiempo promedio entre creación y procesamiento de transacciones.

        String sql = """
                    SELECT AVG(TIMESTAMPDIFF(MINUTE, created_at, processed_at)) AS avg_processing_time
                    FROM transactions
                    WHERE processed_at IS NOT NULL
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getBottleneckStages(Connection conn) throws SQLException {

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

    public static ResultSet getTransactionTypeDistribution(Connection conn) throws SQLException {

        // Distribución de transacciones por tipo (IN, OUT, ADJUST).

        String sql = """
                    SELECT type,
                           COUNT(*) AS total
                    FROM transactions
                    GROUP BY type
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getMostCommonTransactionType(Connection conn) throws SQLException {

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

    public static ResultSet getApprovalRateOverTime(Connection conn) throws SQLException {

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

    public static ResultSet getRejectionRateOverTime(Connection conn) throws SQLException {

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

    public static ResultSet getApprovalDelayDistribution(Connection conn) throws SQLException {

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

    public static ResultSet getMostStrictApprovers(Connection conn) throws SQLException {

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

    public static ResultSet getMostLenientApprovers(Connection conn) throws SQLException {

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

    public static ResultSet getTransactionsImpactOnStockLevels(Connection conn) throws SQLException {

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

    public static ResultSet getStockChangePerTransactionType(Connection conn) throws SQLException {

        // Cambio neto de stock por tipo de transacción.

        String sql = """
                    SELECT type,
                           SUM(quantity) AS total_quantity
                    FROM transactions
                    GROUP BY type
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getHighImpactTransactions(Connection conn) throws SQLException {

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

    public static ResultSet getTopRequesters(Connection conn) throws SQLException {

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

    public static ResultSet getTopApprovers(Connection conn) throws SQLException {

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

    public static ResultSet getRequestToApprovalRatioPerUser(Connection conn) throws SQLException {

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

    public static ResultSet getTransactionBacklog(Connection conn) throws SQLException {

        // Total de transacciones pendientes en el sistema.

        String sql = """
                    SELECT COUNT(*) AS backlog
                    FROM transactions
                    WHERE status = 'PENDING'
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getStalePendingTransactions(Connection conn) throws SQLException {

        // Transacciones pendientes demasiado antiguas.

        String sql = """
                    SELECT *
                    FROM transactions
                    WHERE status = 'PENDING'
                      AND created_at < NOW() - INTERVAL 7 DAY
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getFailedOrAbandonedTransactions(Connection conn) throws SQLException {

        // Transacciones fallidas o abandonadas.

        String sql = """
                    SELECT *
                    FROM transactions
                    WHERE status IN ('REJECTED')
                """;

        return conn.prepareStatement(sql).executeQuery();
    }
}