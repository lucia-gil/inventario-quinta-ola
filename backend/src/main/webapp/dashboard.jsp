<%--
    ════════════════════════════════════════════════════════════════════
     dashboard.jsp — Panel analítico del sistema (con permisos por rol)
    ════════════════════════════════════════════════════════════════════
     Reglas de visibilidad:
     - Stock crítico, "Bajo stock" KPI y "Requieren reposición":
         SOLO Member (depósito), Manager, Administrador, SuperAdmin.
         NO lo ve el Viewer (Solicitante), ni  aprobador
     - Distribución de solicitudes + últimos movimientos:
         Todos los roles.
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    Integer roleId = (Integer) session.getAttribute("roleId");
    if (roleId == null) roleId = 0;

    // Viewer = 1 (solicitante). Todos los demás ven stock.
    boolean puedeVerStock = (roleId == 2 || roleId == 4 || roleId == 5);

    Integer totalItems       = (Integer) request.getAttribute("totalItems");
    Integer totalLowStock    = (Integer) request.getAttribute("totalLowStock");
    Integer totalPendientes  = (Integer) request.getAttribute("totalPendientes");
    Integer totalAprobadas   = (Integer) request.getAttribute("totalAprobadas");
    List<Transaction> ultimas = (List<Transaction>) request.getAttribute("ultimasTransacciones");

    Integer totalRechazadas = (Integer) request.getAttribute("totalRechazadas");
    Integer totalEntregadas = (Integer) request.getAttribute("totalEntregadas");
    if (totalRechazadas == null) totalRechazadas = 0;
    if (totalEntregadas == null) totalEntregadas = 0;
    if (totalItems == null) totalItems = 0;
    if (totalLowStock == null) totalLowStock = 0;
    if (totalPendientes == null) totalPendientes = 0;
    if (totalAprobadas == null) totalAprobadas = 0;

    int totalSolicitudes = totalPendientes + totalAprobadas + totalRechazadas + totalEntregadas;
    int pctPendientes = totalSolicitudes > 0 ? (totalPendientes * 100 / totalSolicitudes) : 0;
    int pctAprobadas  = totalSolicitudes > 0 ? (totalAprobadas  * 100 / totalSolicitudes) : 0;
    int pctRechazadas = totalSolicitudes > 0 ? (totalRechazadas * 100 / totalSolicitudes) : 0;
    int pctEntregadas = totalSolicitudes > 0 ? (totalEntregadas * 100 / totalSolicitudes) : 0;

    request.setAttribute("activeMenu", "dashboard");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Dashboard | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=12" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(<%= puedeVerStock ? 4 : 3 %>, 1fr);
            gap: 1.25rem;
            margin-bottom: 1.5rem;
        }
        @media (max-width: 1024px) { .kpi-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 540px)  { .kpi-grid { grid-template-columns: 1fr; } }

        .dashboard-grid {
            display: grid;
            grid-template-columns: 1.4fr 1fr;
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }
        @media (max-width: 1024px) { .dashboard-grid { grid-template-columns: 1fr; } }

        .dash-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .dash-card-header {
            padding: 1.1rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
            background: var(--gray-50);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .dash-card-title {
            display: flex; align-items: center; gap: 0.6rem;
            font-size: 0.95rem; font-weight: 700; color: var(--purple);
        }
        .dash-card-title i { width: 18px; height: 18px; color: var(--pink); }
        .dash-card-body { padding: 1.5rem; }

        .status-row {
            display: flex; align-items: center; gap: 1rem;
            padding: 0.85rem 0; border-bottom: 1px solid var(--gray-100);
        }
        .status-row:last-child { border-bottom: none; }
        .status-row-label {
            display: flex; align-items: center; gap: 0.6rem;
            min-width: 140px; font-size: 0.85rem; font-weight: 700; color: var(--gray-700);
        }
        .status-row-label i { width: 16px; height: 16px; }
        .status-row-bar-wrap {
            flex: 1; height: 8px; background: var(--gray-100);
            border-radius: var(--radius-full); overflow: hidden;
        }
        .status-row-bar { height: 100%; border-radius: var(--radius-full); transition: width 0.6s ease; }
        .status-row-count {
            min-width: 80px; text-align: right;
            font-size: 0.85rem; font-weight: 700; color: var(--gray-800);
        }
        .status-row-count small {
            font-size: 0.72rem; color: var(--gray-500); font-weight: 600; margin-left: 0.35rem;
        }

        .bar-pending  { background: linear-gradient(90deg, var(--yellow) 0%, var(--orange) 100%); }
        .bar-approved { background: linear-gradient(90deg, var(--green) 0%, var(--green-dark) 100%); }
        .bar-rejected { background: linear-gradient(90deg, #F87171 0%, var(--red) 100%); }
        .bar-delivered{ background: linear-gradient(90deg, var(--blue) 0%, var(--blue-dark) 100%); }

        .status-icon-pending  { color: var(--orange-dark); }
        .status-icon-approved { color: var(--green-dark); }
        .status-icon-rejected { color: var(--red-dark); }
        .status-icon-delivered{ color: var(--blue-dark); }

        .alert-card {
            background: linear-gradient(135deg, var(--yellow-bg) 0%, var(--orange-bg) 100%);
            border: 1px solid #FCD34D;
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            display: flex; align-items: center; gap: 1rem;
            margin-bottom: 1.5rem;
        }
        .alert-card-icon {
            display: flex; align-items: center; justify-content: center;
            width: 48px; height: 48px; border-radius: 50%;
            background: var(--orange); color: var(--white); flex-shrink: 0;
        }
        .alert-card-icon i { width: 24px; height: 24px; }
        .alert-card-content { flex: 1; }
        .alert-card-title { font-size: 0.95rem; font-weight: 800; color: var(--orange-dark); margin-bottom: 0.2rem; }
        .alert-card-desc { font-size: 0.85rem; color: var(--gray-700); line-height: 1.5; }
        .alert-card-action {
            display: inline-flex; align-items: center; gap: 0.4rem;
            background: var(--orange-dark); color: var(--white);
            padding: 0.5rem 1rem; border-radius: var(--radius-full);
            font-size: 0.78rem; font-weight: 700; text-decoration: none;
            transition: all var(--transition); flex-shrink: 0;
        }
        .alert-card-action:hover { background: var(--gray-900); transform: translateY(-1px); }
        .alert-card-action i { width: 13px; height: 13px; }

        .mini-metric {
            display: flex; align-items: center; justify-content: space-between;
            padding: 1rem 0; border-bottom: 1px solid var(--gray-100);
        }
        .mini-metric:last-child { border-bottom: none; }
        .mini-metric-label {
            display: flex; align-items: center; gap: 0.6rem;
            font-size: 0.85rem; color: var(--gray-600); font-weight: 600;
        }
        .mini-metric-label i { width: 16px; height: 16px; color: var(--purple); }
        .mini-metric-value { font-size: 1.15rem; font-weight: 800; color: var(--gray-800); }
        .mini-metric-value.accent { color: var(--pink); }

        .compact-table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
        .compact-table th {
            padding: 0.7rem 1.5rem; background: var(--gray-50);
            font-size: 0.7rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 0.5px; color: var(--gray-500);
            border-bottom: 1px solid var(--gray-200); text-align: left;
        }
        .compact-table td { padding: 0.85rem 1.5rem; border-bottom: 1px solid var(--gray-100); color: var(--gray-700); }
        .compact-table tr:hover td { background: var(--gray-50); }
        .compact-table tr:last-child td { border-bottom: none; }
        .compact-table .tx-id {
            font-family: 'Courier New', monospace; font-weight: 700;
            color: var(--purple); font-size: 0.8rem;
        }
        .empty-row td {
            padding: 3rem 1.5rem !important; text-align: center;
            color: var(--gray-400); font-style: italic;
        }

        .view-all-link {
            display: inline-flex; align-items: center; gap: 0.3rem;
            color: var(--pink); font-size: 0.82rem; font-weight: 700;
            text-decoration: none; transition: all var(--transition);
        }
        .view-all-link:hover { color: var(--purple); gap: 0.5rem; }
        .view-all-link i { width: 14px; height: 14px; }
    </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- Header --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="bar-chart-3" style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        Dashboard
                    </h1>
                    <p class="page-subtitle">Análisis y métricas del sistema en tiempo real</p>
                </div>
            </div>

            <%-- Alerta de stock crítico SOLO para roles operativos --%>
            <% if (puedeVerStock && totalLowStock > 0) { %>
            <div class="alert-card">
                <div class="alert-card-icon">
                    <i data-lucide="alert-triangle"></i>
                </div>
                <div class="alert-card-content">
                    <div class="alert-card-title">Atención: stock crítico</div>
                    <div class="alert-card-desc">
                        Hay <strong><%= totalLowStock %></strong> material<%= totalLowStock != 1 ? "es" : "" %>
                        con stock bajo el mínimo. Revisa el inventario para reponer.
                    </div>
                </div>
                <a href="<%= ctx %>/InventoryServlet" class="alert-card-action">
                    Ver inventario
                    <i data-lucide="arrow-right"></i>
                </a>
            </div>
            <% } %>

            <%-- KPIs principales --%>
            <div class="kpi-grid">

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label">Total Materiales</p>
                        <p class="stat-card-value"><%= totalItems %></p>
                    </div>
                    <div class="stat-card-icon stat-icon-blue">
                        <i data-lucide="package"></i>
                    </div>
                </div>

                <%-- KPI Bajo Stock SOLO para roles operativos --%>
                <% if (puedeVerStock) { %>
                <div class="stat-card">
                    <div>
                        <p class="stat-card-label">Bajo Stock</p>
                        <p class="stat-card-value"><%= totalLowStock %></p>
                    </div>
                    <div class="stat-card-icon stat-icon-orange">
                        <i data-lucide="alert-triangle"></i>
                    </div>
                </div>
                <% } %>

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label">Pendientes</p>
                        <p class="stat-card-value"><%= totalPendientes %></p>
                    </div>
                    <div class="stat-card-icon stat-icon-yellow">
                        <i data-lucide="clock"></i>
                    </div>
                </div>

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label">Aprobadas</p>
                        <p class="stat-card-value"><%= totalAprobadas %></p>
                    </div>
                    <div class="stat-card-icon stat-icon-green">
                        <i data-lucide="check-circle"></i>
                    </div>
                </div>

            </div>

            <%-- Grid de análisis --%>
            <div class="dashboard-grid">

                <%-- Distribución de solicitudes --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <div class="dash-card-title">
                            <i data-lucide="pie-chart"></i>
                            Distribución de solicitudes
                        </div>
                        <a href="<%= ctx %>/HistoryServlet" class="view-all-link">
                            Ver historial <i data-lucide="arrow-right"></i>
                        </a>
                    </div>
                    <div class="dash-card-body">

                        <% if (totalSolicitudes == 0) { %>
                        <p style="text-align: center; color: var(--gray-400); padding: 2rem 0; font-style: italic;">
                            Aún no hay solicitudes registradas.
                        </p>
                        <% } else { %>

                        <div class="status-row">
                            <div class="status-row-label">
                                <i data-lucide="clock" class="status-icon-pending"></i>
                                Pendientes
                            </div>
                            <div class="status-row-bar-wrap">
                                <div class="status-row-bar bar-pending" style="width: <%= pctPendientes %>%;"></div>
                            </div>
                            <div class="status-row-count">
                                <%= totalPendientes %><small><%= pctPendientes %>%</small>
                            </div>
                        </div>

                        <div class="status-row">
                            <div class="status-row-label">
                                <i data-lucide="check-circle" class="status-icon-approved"></i>
                                Aprobadas
                            </div>
                            <div class="status-row-bar-wrap">
                                <div class="status-row-bar bar-approved" style="width: <%= pctAprobadas %>%;"></div>
                            </div>
                            <div class="status-row-count">
                                <%= totalAprobadas %><small><%= pctAprobadas %>%</small>
                            </div>
                        </div>

                        <div class="status-row">
                            <div class="status-row-label">
                                <i data-lucide="x-circle" class="status-icon-rejected"></i>
                                Rechazadas
                            </div>
                            <div class="status-row-bar-wrap">
                                <div class="status-row-bar bar-rejected" style="width: <%= pctRechazadas %>%;"></div>
                            </div>
                            <div class="status-row-count">
                                <%= totalRechazadas %><small><%= pctRechazadas %>%</small>
                            </div>
                        </div>

                        <div class="status-row">
                            <div class="status-row-label">
                                <i data-lucide="truck" class="status-icon-delivered"></i>
                                Entregadas
                            </div>
                            <div class="status-row-bar-wrap">
                                <div class="status-row-bar bar-delivered" style="width: <%= pctEntregadas %>%;"></div>
                            </div>
                            <div class="status-row-count">
                                <%= totalEntregadas %><small><%= pctEntregadas %>%</small>
                            </div>
                        </div>

                        <% } %>

                    </div>
                </div>

                <%-- Resumen operativo --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <div class="dash-card-title">
                            <i data-lucide="activity"></i>
                            Resumen operativo
                        </div>
                    </div>
                    <div class="dash-card-body" style="padding: 0 1.5rem;">

                        <div class="mini-metric">
                            <div class="mini-metric-label">
                                <i data-lucide="layers"></i>
                                Total de solicitudes
                            </div>
                            <div class="mini-metric-value"><%= totalSolicitudes %></div>
                        </div>

                        <div class="mini-metric">
                            <div class="mini-metric-label">
                                <i data-lucide="trending-up"></i>
                                Tasa de aprobación
                            </div>
                            <div class="mini-metric-value accent">
                                <%= (totalAprobadas + totalEntregadas) > 0 && totalSolicitudes > 0
                                        ? ((totalAprobadas + totalEntregadas) * 100 / totalSolicitudes) + "%"
                                        : "—" %>
                            </div>
                        </div>

                        <div class="mini-metric">
                            <div class="mini-metric-label">
                                <i data-lucide="box"></i>
                                Items en sistema
                            </div>
                            <div class="mini-metric-value"><%= totalItems %></div>
                        </div>

                        <%-- "Requieren reposición" SOLO para roles operativos --%>
                        <% if (puedeVerStock) { %>
                        <div class="mini-metric">
                            <div class="mini-metric-label">
                                <i data-lucide="alert-octagon"></i>
                                Requieren reposición
                            </div>
                            <div class="mini-metric-value <%= totalLowStock > 0 ? "accent" : "" %>">
                                <%= totalLowStock %>
                            </div>
                        </div>
                        <% } %>

                    </div>
                </div>

            </div>

            <%-- Últimos movimientos --%>
            <div class="dash-card">
                <div class="dash-card-header">
                    <div class="dash-card-title">
                        <i data-lucide="history"></i>
                        Últimos movimientos
                    </div>
                    <a href="<%= ctx %>/HistoryServlet" class="view-all-link">
                        Ver todo <i data-lucide="arrow-right"></i>
                    </a>
                </div>

                <table class="compact-table">
                    <thead>
                    <tr>
                        <th>ID</th>
                        <th>Solicitante</th>
                        <th>Material</th>
                        <th style="text-align: center;">Cantidad</th>
                        <th style="text-align: center;">Estado</th>
                    </tr>
                    </thead>
                    <tbody>
                    <% if (ultimas == null || ultimas.isEmpty()) { %>
                    <tr class="empty-row">
                        <td colspan="5">Sin movimientos recientes</td>
                    </tr>
                    <% } else {
                        int count = 0;
                        for (Transaction tx : ultimas) {
                            if (count >= 8) break;
                            count++;
                            String status = tx.getStatus();
                            String bc, bt;
                            if ("APPROVED".equals(status))       { bc = "status-approved";  bt = "Aprobada"; }
                            else if ("PENDING".equals(status))   { bc = "status-pending";   bt = "Pendiente"; }
                            else if ("REJECTED".equals(status))  { bc = "status-rejected";  bt = "Rechazada"; }
                            else if ("COMPLETED".equals(status)) { bc = "status-delivered"; bt = "Entregada"; }
                            else { bc = "status-badge"; bt = status; }
                    %>
                    <tr>
                        <td><span class="tx-id">TXN-<%= String.format("%04d", tx.getId()) %></span></td>
                        <td><%= tx.getRequesterName() %></td>
                        <td style="font-weight: 600; color: var(--gray-800);"><%= tx.getItemName() %></td>
                        <td style="text-align: center;"><%= tx.getQuantity() %> <%= tx.getItemUnit() %></td>
                        <td style="text-align: center;"><span class="<%= bc %>"><%= bt %></span></td>
                    </tr>
                    <% }
                    } %>
                    </tbody>
                </table>
            </div>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });
</script>

</body>
</html>