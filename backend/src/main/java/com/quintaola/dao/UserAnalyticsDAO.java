// ============================================================
// USERS ANALYTICS DAO
// ============================================================
//
// RETURN CONTRACTS:
//
// ACTIVITY LEVEL
// getMostActiveUsers()              -> id, name, total_transactions
// getLeastActiveUsers()             -> id, name, total_transactions
// getInactiveUsersOverTime(days)    -> id, name, inactivity_days
//
// TRANSACTION BEHAVIOR
// getUsersWithMostRequests()        -> id, name, request_count
// getUsersWithMostApprovals()       -> id, name, approval_count
// getUsersWithMostRejections()      -> id, name, rejection_count
// getApprovalRatePerUser()          -> id, name, approval_rate
// getRejectionRatePerUser()         -> id, name, rejection_rate
//
// WORKFLOW SPEED
// getFastestApprovers()             -> id, name, avg_time
// getSlowestApprovers()             -> id, name, avg_time
// getAverageApprovalTimePerUser()   -> id, name, avg_time
//
// RELIABILITY / QUALITY
// getUsersWithHighestApprovalSuccessRate() -> id, name, success_rate
// getUsersWithMostFailedRequests()  -> id, name, failed_requests
//
// ENGAGEMENT PATTERNS
// getUsersMostActiveByTimeOfDay()   -> id, hour, activity_count
// getUsersMostActiveByDayOfWeek()   -> id, day_of_week, activity_count
// getUserActivityTrends(userId)     -> date, activity_count
//
// ============================================================

package com.quintaola.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserAnalyticsDAO {

    // ============================================================
    // ACTIVITY LEVEL
    // ============================================================

    public static ResultSet getMostActiveUsers(Connection conn) throws SQLException {

        // Devuelve los usuarios con mayor cantidad de transacciones totales.

        String sql = """
                    SELECT u.id, u.name, COUNT(t.id) AS total_transactions
                    FROM users u
                    LEFT JOIN transactions t ON t.requester_id = u.id
                    GROUP BY u.id, u.name
                    ORDER BY total_transactions DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getLeastActiveUsers(Connection conn) throws SQLException {

        // Devuelve los usuarios con menor actividad en el sistema.

        String sql = """
                    SELECT u.id, u.name, COUNT(t.id) AS total_transactions
                    FROM users u
                    LEFT JOIN transactions t ON t.requester_id = u.id
                    GROUP BY u.id, u.name
                    ORDER BY total_transactions ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getInactiveUsersOverTime(Connection conn, int days) throws SQLException {

        // Devuelve usuarios que no han tenido actividad en los últimos N días.

        String sql = """
                    SELECT u.id, u.name,
                           DATEDIFF(NOW(), MAX(t.created_at)) AS inactivity_days
                    FROM users u
                    LEFT JOIN transactions t ON t.requester_id = u.id
                    GROUP BY u.id, u.name
                    HAVING inactivity_days >= ?
                    ORDER BY inactivity_days DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, days);

        return ps.executeQuery();
    }

    // ============================================================
    // TRANSACTION BEHAVIOR
    // ============================================================

    public static ResultSet getUsersWithMostRequests(Connection conn) throws SQLException {

        // Devuelve usuarios con mayor número de solicitudes realizadas.

        String sql = """
                    SELECT u.id, u.name, COUNT(t.id) AS request_count
                    FROM users u
                    LEFT JOIN transactions t ON t.requester_id = u.id
                    GROUP BY u.id, u.name
                    ORDER BY request_count DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getUsersWithMostApprovals(Connection conn) throws SQLException {

        // Devuelve usuarios con mayor número de aprobaciones realizadas.

        String sql = """
                    SELECT u.id, u.name, COUNT(t.id) AS approval_count
                    FROM users u
                    LEFT JOIN transactions t ON t.approver_id = u.id
                    WHERE t.status = 'APPROVED'
                    GROUP BY u.id, u.name
                    ORDER BY approval_count DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getUsersWithMostRejections(Connection conn) throws SQLException {

        // Devuelve usuarios que más rechazos han realizado.

        String sql = """
                    SELECT u.id, u.name, COUNT(t.id) AS rejection_count
                    FROM users u
                    LEFT JOIN transactions t ON t.approver_id = u.id
                    WHERE t.status = 'REJECTED'
                    GROUP BY u.id, u.name
                    ORDER BY rejection_count DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getApprovalRatePerUser(Connection conn) throws SQLException {

        // Calcula la tasa de aprobación por usuario.

        String sql = """
                    SELECT u.id, u.name,
                           SUM(CASE WHEN t.status = 'APPROVED' THEN 1 ELSE 0 END) * 1.0 / COUNT(t.id) AS approval_rate
                    FROM users u
                    LEFT JOIN transactions t ON t.requester_id = u.id
                    GROUP BY u.id, u.name
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getRejectionRatePerUser(Connection conn) throws SQLException {

        // Calcula la tasa de rechazo por usuario.

        String sql = """
                    SELECT u.id, u.name,
                           SUM(CASE WHEN t.status = 'REJECTED' THEN 1 ELSE 0 END) * 1.0 / COUNT(t.id) AS rejection_rate
                    FROM users u
                    LEFT JOIN transactions t ON t.requester_id = u.id
                    GROUP BY u.id, u.name
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // WORKFLOW SPEED
    // ============================================================

    public static ResultSet getFastestApprovers(Connection conn) throws SQLException {

        // Devuelve usuarios con menor tiempo promedio de aprobación.

        String sql = """
                    SELECT u.id, u.name,
                           AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.processed_at)) AS avg_time
                    FROM users u
                    JOIN transactions t ON t.approver_id = u.id
                    WHERE t.processed_at IS NOT NULL
                    GROUP BY u.id, u.name
                    ORDER BY avg_time ASC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getSlowestApprovers(Connection conn) throws SQLException {

        // Devuelve usuarios con mayor tiempo promedio de aprobación.

        String sql = """
                    SELECT u.id, u.name,
                           AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.processed_at)) AS avg_time
                    FROM users u
                    JOIN transactions t ON t.approver_id = u.id
                    WHERE t.processed_at IS NOT NULL
                    GROUP BY u.id, u.name
                    ORDER BY avg_time DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getAverageApprovalTimePerUser(Connection conn) throws SQLException {

        // Devuelve el tiempo promedio de aprobación por usuario.

        String sql = """
                    SELECT u.id, u.name,
                           AVG(TIMESTAMPDIFF(MINUTE, t.created_at, t.processed_at)) AS avg_time
                    FROM users u
                    JOIN transactions t ON t.approver_id = u.id
                    WHERE t.processed_at IS NOT NULL
                    GROUP BY u.id, u.name
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // RELIABILITY / QUALITY
    // ============================================================

    public static ResultSet getUsersWithHighestApprovalSuccessRate(Connection conn) throws SQLException {

        // Devuelve usuarios con mayor tasa de éxito en aprobaciones.

        String sql = """
                    SELECT u.id, u.name,
                           SUM(CASE WHEN t.status = 'APPROVED' THEN 1 ELSE 0 END) * 1.0 / COUNT(t.id) AS success_rate
                    FROM users u
                    LEFT JOIN transactions t ON t.requester_id = u.id
                    GROUP BY u.id, u.name
                    ORDER BY success_rate DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getUsersWithMostFailedRequests(Connection conn) throws SQLException {

        // Devuelve usuarios con mayor cantidad de solicitudes fallidas o rechazadas.

        String sql = """
                    SELECT u.id, u.name,
                           SUM(CASE WHEN t.status IN ('REJECTED','FAILED') THEN 1 ELSE 0 END) AS failed_requests
                    FROM users u
                    LEFT JOIN transactions t ON t.requester_id = u.id
                    GROUP BY u.id, u.name
                    ORDER BY failed_requests DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    // ============================================================
    // ENGAGEMENT PATTERNS
    // ============================================================

    public static ResultSet getUsersMostActiveByTimeOfDay(Connection conn) throws SQLException {

        // Devuelve actividad de usuarios agrupada por hora del día.

        String sql = """
                    SELECT HOUR(t.created_at) AS hour,
                           u.id,
                           u.name,
                           COUNT(t.id) AS activity_count
                    FROM users u
                    JOIN transactions t ON t.requester_id = u.id
                    GROUP BY hour, u.id, u.name
                    ORDER BY activity_count DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getUsersMostActiveByDayOfWeek(Connection conn) throws SQLException {

        // Devuelve actividad de usuarios agrupada por día de la semana.

        String sql = """
                    SELECT DAYOFWEEK(t.created_at) AS day_of_week,
                           u.id,
                           u.name,
                           COUNT(t.id) AS activity_count
                    FROM users u
                    JOIN transactions t ON t.requester_id = u.id
                    GROUP BY day_of_week, u.id, u.name
                    ORDER BY activity_count DESC
                """;

        return conn.prepareStatement(sql).executeQuery();
    }

    public static ResultSet getUserActivityTrends(Connection conn, String userId) throws SQLException {

        // Devuelve la evolución de actividad de un usuario específico en el tiempo.

        String sql = """
                    SELECT DATE(t.created_at) AS date,
                           COUNT(t.id) AS activity_count
                    FROM transactions t
                    WHERE t.requester_id = ?
                    GROUP BY DATE(t.created_at)
                    ORDER BY date ASC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, userId);

        return ps.executeQuery();
    }
}