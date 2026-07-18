<%--
    ════════════════════════════════════════════════════════════════════
     history.jsp — Historial de transacciones (rediseño Quinta Ola)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>

<%!
    private String traducirStatus(String status) {
        if (status == null) return "—";
        switch (status.toUpperCase().trim()) {
            case "PENDING":   return "Pendiente";
            case "APPROVED":  return "Aprobada";
            case "REJECTED":  return "Rechazada";
            case "COMPLETED": return "Entregada";
            default:          return status;
        }
    }

    private String claseBadgeStatus(String status) {
        if (status == null) return "status-badge";
        switch (status.toUpperCase().trim()) {
            case "PENDING":   return "status-pending";
            case "APPROVED":  return "status-approved";
            case "REJECTED":  return "status-rejected";
            case "COMPLETED": return "status-delivered";
            default:          return "status-badge";
        }
    }

    private String formatearFecha(Object fechaObj) {
        if (fechaObj == null) return "—";
        try {
            if (fechaObj instanceof java.util.Date) {
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MM-yyyy HH:mm");
                return sdf.format((java.util.Date) fechaObj);
            } else if (fechaObj instanceof java.time.LocalDateTime) {
                java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm");
                return ((java.time.LocalDateTime) fechaObj).format(dtf);
            }

            String fechaStr = fechaObj.toString();
            if (fechaStr.matches("\\d{4}-\\d{2}-\\d{2}.*")) {
                java.time.LocalDateTime ldt = java.time.LocalDateTime.parse(fechaStr.replace(" ", "T").substring(0, 19));
                return ldt.format(java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm"));
            }
            return fechaStr;
        } catch (Exception e) {
            return fechaObj.toString();
        }
    }
%>

<%
    String ctx = request.getContextPath();

    List<Transaction> transacciones = (List<Transaction>) request.getAttribute("transacciones");
    Integer totalTx = (Integer) request.getAttribute("totalTransacciones");
    if (totalTx == null) totalTx = 0;

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;

    String filtroTexto  = (String) request.getAttribute("filtroTexto");
    String filtroStatus = (String) request.getAttribute("filtroStatus");
    if (filtroTexto == null)  filtroTexto = "";
    if (filtroStatus == null) filtroStatus = "";
    filtroStatus = filtroStatus.toUpperCase().trim();

    String error = (String) request.getAttribute("error");

    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    int roleId = roleIdSession != null ? roleIdSession : 0;

    boolean puedeVerAnalisis = (roleId >= 3);
    boolean esViewer = (roleId == 1);

    String pageTitle    = esViewer ? "Mi Historial"                       : "Historial Completo";
    String pageSubtitle = esViewer ? "Todas las solicitudes que has hecho" : "Todas las solicitudes del sistema";

    request.setAttribute("activeMenu", "history");

    String baseUrlPaginacion = ctx + "/HistoryServlet?action=lista";
    if (!filtroTexto.isEmpty()) {
        baseUrlPaginacion += "&q=" + java.net.URLEncoder.encode(filtroTexto, "UTF-8");
    }
    if (!filtroStatus.isEmpty()) {
        baseUrlPaginacion += "&status=" + java.net.URLEncoder.encode(filtroStatus, "UTF-8");
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Historial | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=12" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Filtros ═════ */
        .filter-bar {
            display: flex;
            gap: 0.75rem;
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: 1rem;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--gray-100);
            flex-wrap: wrap;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .filter-search { position: relative; flex-grow: 1; min-width: 250px; display: flex; align-items: center; }
        .filter-search svg, .filter-search i {
            position: absolute; left: 1rem; top: 50%; transform: translateY(-50%);
            color: var(--gray-400); width: 18px !important; height: 18px !important;
            pointer-events: none; z-index: 2;
        }
        .filter-search input {
            width: 100%; border: 1.5px solid var(--gray-200); border-radius: var(--radius-full);
            padding: 0.65rem 1rem 0.65rem 2.85rem; font-size: 0.875rem; outline: none;
            transition: all var(--transition); background: var(--gray-50); font-family: inherit;
            color: var(--gray-800); height: 42px; box-sizing: border-box;
        }
        .filter-search input::placeholder { color: var(--gray-400); font-weight: 500; }
        .filter-search input:focus { border-color: var(--purple); background: var(--white); box-shadow: 0 0 0 4px rgba(91, 31, 168, 0.08); }

        .filter-select {
            border: 1.5px solid var(--gray-200); border-radius: var(--radius-full);
            padding: 0.65rem 1.25rem; font-size: 0.875rem; background: var(--gray-50);
            color: var(--gray-700); font-family: inherit; cursor: pointer; outline: none;
            transition: all var(--transition); min-width: 180px; height: 42px; box-sizing: border-box;
        }
        .filter-select:hover { border-color: var(--purple); background: var(--white); }
        .filter-select:focus { border-color: var(--purple); background: var(--white); box-shadow: 0 0 0 4px rgba(91, 31, 168, 0.08); }
        .filter-actions { display: flex; gap: 0.5rem; align-items: center; }

        /* ═════ Badges de Tipo ═════ */
        .type-badge {
            display: inline-flex; align-items: center; gap: 0.3rem; padding: 0.3rem 0.65rem;
            border-radius: var(--radius-full); font-size: 0.7rem; font-weight: 700; letter-spacing: 0.4px;
        }
        .type-badge i { width: 12px; height: 12px; }
        .type-in  { background: var(--green-bg); color: var(--green-dark); }
        .type-out { background: var(--blue-bg);  color: var(--blue-dark); }

        /* ═════ Link Ver detalle ═════ */
        .detail-link {
            display: inline-flex; align-items: center; gap: 0.3rem; color: var(--pink);
            font-weight: 700; font-size: 0.82rem; text-decoration: none; transition: color var(--transition);
        }
        .detail-link:hover { color: var(--purple); }
        .detail-link i { width: 14px; height: 14px; }

        /* Paginación: ver componente global ".pager" en style.css */

        /* ═════ Empty state ═════ */
        .empty-state { padding: 4rem 2rem; text-align: center; }
        .empty-state-icon {
            display: inline-flex; align-items: center; justify-content: center; width: 64px; height: 64px;
            background: var(--purple-bg); color: var(--purple); border-radius: 50%; margin-bottom: 1rem;
        }
        .empty-state-icon i { width: 30px; height: 30px; }
        .empty-state-title { font-size: 1.05rem; font-weight: 700; color: var(--gray-700); margin-bottom: 0.4rem; }
        .empty-state-desc { font-size: 0.88rem; color: var(--gray-500); }

        /* ═════ Alertas ═════ */
        .alert {
            display: flex; align-items: center; gap: 0.6rem; padding: 0.9rem 1.1rem; border-radius: var(--radius-sm);
            font-size: 0.88rem; font-weight: 600; margin-bottom: 1.25rem; border: 1px solid var(--red-bg);
            background: var(--red-bg); color: var(--red-dark); border-color: #FECACA;
        }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }
    </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="history" style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        <%= pageTitle %>
                    </h1>
                    <p class="page-subtitle"><%= pageSubtitle %></p>
                </div>

                <% if (puedeVerAnalisis) { %>
                <a href="<%= ctx %>/AnalyticsServlet" class="btn-page-primary btn-icon">
                    <i data-lucide="bar-chart-3"></i>
                    Ver Análisis Visual
                </a>
                <% } %>
            </div>

            <% if (error != null) { %>
            <div class="alert">
                <i data-lucide="alert-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <form action="<%= ctx %>/HistoryServlet" method="GET" class="filter-bar">
                <input type="hidden" name="action" value="lista"/>

                <div class="filter-search">
                    <i data-lucide="search"></i>
                    <input type="text" name="q" value="<%= filtroTexto %>" placeholder="Buscar por solicitante, material o ID..."/>
                </div>

                <div class="filter-actions">
                    <select name="status" class="filter-select">
                        <option value=""           <%= filtroStatus.isEmpty()              ? "selected" : "" %>>Todos los estados</option>
                        <option value="PENDING"    <%= "PENDING".equals(filtroStatus)      ? "selected" : "" %>>Pendiente</option>
                        <option value="APPROVED"   <%= "APPROVED".equals(filtroStatus)     ? "selected" : "" %>>Aprobada</option>
                        <option value="REJECTED"   <%= "REJECTED".equals(filtroStatus)     ? "selected" : "" %>>Rechazada</option>
                        <option value="COMPLETED"  <%= "COMPLETED".equals(filtroStatus)    ? "selected" : "" %>>Entregada</option>
                    </select>
                    <button type="submit" class="btn-page-primary btn-icon">
                        <i data-lucide="filter"></i>
                        Filtrar
                    </button>
                </div>
            </form>

            <div class="table-panel">

                <% if (transacciones == null || transacciones.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i data-lucide="inbox"></i>
                    </div>
                    <p class="empty-state-title">Sin resultados</p>
                    <p class="empty-state-desc">No hay transacciones que coincidan con tu búsqueda.</p>
                </div>
                <% } else { %>

                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th">ID</th>
                            <th class="th">Solicitante</th>
                            <th class="th">Material</th>
                            <th class="th-center">Cantidad</th>
                            <th class="th-center">Tipo</th>
                            <th class="th">Fecha</th>
                            <th class="th-center">Estado</th>
                            <th class="th-center">Detalle</th>
                        </tr>
                        </thead>

                        <tbody class="table-body">
                        <% for (Transaction tx : transacciones) { %>
                        <tr class="table-row">
                            <td class="td-id">TXN-<%= String.format("%04d", tx.getId()) %></td>
                            <td class="td"><%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %></td>
                            <td class="td" style="font-weight: 600; color: var(--gray-800);"><%= tx.getItemName() != null ? tx.getItemName() : "—" %></td>
                            <td class="td-center">
                                <%= tx.getQuantity() %>
                                <% if (tx.getItemUnit() != null) { %><%= tx.getItemUnit() %><% } %>
                            </td>
                            <td class="td-center">
                                <% if ("IN".equals(tx.getType())) { %>
                                <span class="type-badge type-in"><i data-lucide="arrow-down-circle"></i> ENTRADA</span>
                                <% } else if ("OUT".equals(tx.getType())) { %>
                                <span class="type-badge type-out"><i data-lucide="arrow-up-circle"></i> SALIDA</span>
                                <% } else { %>
                                <span class="type-badge" style="background: var(--gray-100); color: var(--gray-600);"><%= tx.getType() %></span>
                                <% } %>
                            </td>
                            <td class="td-light" style="font-family: inherit; font-size: 0.85rem; color: var(--gray-600);">
                                <%= formatearFecha(tx.getCreatedAt()) %>
                            </td>
                            <td class="td-center">
                                <span class="<%= claseBadgeStatus(tx.getStatus()) %>"><%= traducirStatus(tx.getStatus()) %></span>
                            </td>
                            <td class="td-center">
                                <a href="<%= ctx %>/TransactionServlet?action=detalle&id=<%= tx.getId() %>&origen=historial" class="detail-link">
                                    <i data-lucide="eye"></i> Ver
                                </a>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <%-- Footer con paginación --%>
                <%
                    // Cálculos de variables para el snippet exacto
                    int _page = currentPage;
                    int _total = totalPages;
                    int _count = totalTx;
                    int _from = (_count == 0) ? 0 : ((_page - 1) * 15) + 1;
                    int _to = Math.min(_page * 15, _count);
                    String _pUrl = baseUrlPaginacion;

                    // Lógica para la ventana (win) de botones visibles (máximo 5)
                    int _winS = Math.max(1, _page - 2);
                    int _winE = Math.min(_total, _winS + 4);
                    if (_winE - _winS < 4) {
                        _winS = Math.max(1, _winE - 4);
                    }
                %>

                <div class="pager">

                    <div class="pager-info">
                        <span>
                            Mostrando
                            <strong><%= _from %>–<%= _to %></strong>
                            de
                            <strong><%= _count %></strong>
                            solicitudes
                        </span>

                        <span class="pager-info-badge"><i data-lucide="waves"></i> ≈ 15 por ola</span>
                    </div>

                    <% if (_total > 1) { %>

                    <div class="pager-nav">

                        <% if (_page > 1) { %>
                        <a href="<%= _pUrl %>&page=<%= _page-1 %>" class="pager-btn">
                            <i data-lucide="chevron-left"></i>
                        </a>
                        <% } else { %>
                        <span class="pager-btn pager-btn--disabled">
                            <i data-lucide="chevron-left"></i>
                        </span>
                        <% } %>


                        <% if (_winS > 1) { %>

                        <a href="<%= _pUrl %>&page=1" class="pager-btn">1</a>

                        <% if (_winS > 2) { %>
                        <span class="pager-dots"><span></span><span></span><span></span></span>
                        <% } %>

                        <% } %>


                        <% for(int _p = _winS; _p <= _winE; _p++){ %>

                        <% if(_p == _page){ %>

                        <span class="pager-btn pager-btn--active">
                            <%= _p %>
                        </span>

                        <% }else{ %>

                        <a href="<%= _pUrl %>&page=<%= _p %>" class="pager-btn">
                            <%= _p %>
                        </a>

                        <% } %>

                        <% } %>


                        <% if (_winE < _total) { %>

                        <% if (_winE < _total-1) { %>
                        <span class="pager-dots"><span></span><span></span><span></span></span>
                        <% } %>

                        <a href="<%= _pUrl %>&page=<%= _total %>" class="pager-btn">
                            <%= _total %>
                        </a>

                        <% } %>


                        <% if (_page < _total) { %>

                        <a href="<%= _pUrl %>&page=<%= _page+1 %>" class="pager-btn">
                            <i data-lucide="chevron-right"></i>
                        </a>

                        <% } else { %>

                        <span class="pager-btn pager-btn--disabled">
                            <i data-lucide="chevron-right"></i>
                        </span>

                        <% } %>

                    </div>

                    <% } %>

                </div>

                <% } %>

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