package org.quintaola.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {
    private Connection conn;

    public UserDAO(Connection connection) {
        this.conn = connection;
    }

    // ============================================================
    // getAll()
    // ============================================================
    public ResultSet getAll() throws SQLException {

        // Devuelve todos los usuarios sin filtros.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getActive()
    // ============================================================
    public ResultSet getActive() throws SQLException {

        // Devuelve solo usuarios activos.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.activo = 1
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getInactive()
    // ============================================================
    public ResultSet getInactive() throws SQLException {

        // Devuelve solo usuarios inactivos.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.activo = 0
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getById(id)
    // ============================================================
    public ResultSet getById(String id) throws SQLException {

        // Devuelve un usuario por ID.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.id = ?
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, id);

        return ps.executeQuery();
    }

    // ============================================================
    // findByEmail(email)
    // ============================================================
    public ResultSet findByEmail(String email) throws SQLException {

        // Busca usuario por email.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.email = ?
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, email);

        return ps.executeQuery();
    }

    // ============================================================
    // findByDni(dni)
    // ============================================================
    public ResultSet findByDni(String dni) throws SQLException {

        // Busca usuario por DNI.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.dni = ?
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, dni);

        return ps.executeQuery();
    }

    // ============================================================
    // getByRole(roleId)
    // ============================================================
    public ResultSet getByRole(String roleId) throws SQLException {

        // Devuelve usuarios filtrados por rol.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    WHERE u.role_id = ?
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        ps.setString(1, roleId);

        return ps.executeQuery();
    }

    // ============================================================
    // getNewest()
    // ============================================================
    public ResultSet getNewest() throws SQLException {

        // Usuarios ordenados del más reciente al más antiguo.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    ORDER BY u.created_at DESC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // getOldest()
    // ============================================================
    public ResultSet getOldest() throws SQLException {

        // Usuarios ordenados del más antiguo al más reciente.

        String sql = """
                    SELECT
                        u.id,
                        u.email,
                        u.dni,
                        u.name,
                        u.role_id,
                        u.activo,
                        u.created_at
                    FROM users u
                    ORDER BY u.created_at ASC
                """;

        PreparedStatement ps = conn.prepareStatement(sql);

        return ps.executeQuery();
    }

    // ============================================================
    // ACTIVITY LEVEL
    // ============================================================

    public ResultSet getMostActiveUsers() throws SQLException {

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

    public ResultSet getLeastActiveUsers() throws SQLException {

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

    public ResultSet getInactiveUsersOverTime(int days) throws SQLException {

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

    public ResultSet getUsersWithMostRequests() throws SQLException {

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

    public ResultSet getUsersWithMostApprovals() throws SQLException {

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

    public ResultSet getUsersWithMostRejections() throws SQLException {

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

    public ResultSet getApprovalRatePerUser() throws SQLException {

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

    public ResultSet getRejectionRatePerUser() throws SQLException {

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

    public ResultSet getFastestApprovers() throws SQLException {

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

    public ResultSet getSlowestApprovers() throws SQLException {

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

    public ResultSet getAverageApprovalTimePerUser() throws SQLException {

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

    public ResultSet getUsersWithHighestApprovalSuccessRate() throws SQLException {

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

    public ResultSet getUsersWithMostFailedRequests() throws SQLException {

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

    public ResultSet getUsersMostActiveByTimeOfDay() throws SQLException {

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

    public ResultSet getUsersMostActiveByDayOfWeek() throws SQLException {

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

    public ResultSet getUserActivityTrends(String userId) throws SQLException {

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