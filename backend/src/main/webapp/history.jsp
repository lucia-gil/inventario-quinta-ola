<%--
    ════════════════════════════════════════════════════════════════════
     history.jsp — Vista del historial de transacciones
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>

<%!
    /* Métodos auxiliares de la clase JSP */
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
        if (status == null) return "status-badge bg-gray-100 text-gray-600";
        switch (status.toUpperCase().trim()) {
            case "PENDING":   return "status-pending";
            case "APPROVED":  return "status-approved";
            case "REJECTED":  return "status-rejected";
            case "COMPLETED": return "status-delivered";
            default:          return "status-badge bg-gray-100 text-gray-600";
        }
    }
%>

<%
    /* BLOQUE DE PREPARACIÓN DE DATOS */
    String ctx = request.getContextPath();

    List<Transaction> transacciones = (List<Transaction>) request.getAttribute("transacciones");
    Integer totalTx = (Integer) request.getAttribute("totalTransacciones");
    if (totalTx == null) totalTx = 0;

    String filtroTexto  = (String) request.getAttribute("filtroTexto");
    String filtroStatus = (String) request.getAttribute("filtroStatus");
    if (filtroTexto == null)  filtroTexto = "";
    if (filtroStatus == null) filtroStatus = "";

    // Normalizamos para evitar errores de comparación en los selectores
    filtroStatus = filtroStatus.toUpperCase().trim();

    String error = (String) request.getAttribute("error");

    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    int roleId = roleIdSession != null ? roleIdSession : 0;

    boolean puedeVerAnalisis = (roleId >= 3);
    boolean esViewer = (roleId == 1);

    String pageTitle    = esViewer ? "Mi Historial"                       : "Historial Completo";
    String pageSubtitle = esViewer ? "Todas las solicitudes que has hecho" : "Todas las solicitudes del sistema";
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Historial | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=3" rel="stylesheet" />
</head>

<body class="page-body">

<%-- 🛡️ ENVOLTURA PARA EVITAR EL SOLAPAMIENTO DEL SIDEBAR --%>
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- CABECERA --%>
            <div class="page-header flex justify-between items-center w-full">
                <div>
                    <h1 class="page-title"><%= pageTitle %></h1>
                    <p class="page-subtitle"><%= pageSubtitle %></p>
                </div>

                <% if (puedeVerAnalisis) { %>
                <a href="<%= ctx %>/AnalyticsServlet" class="btn-page-primary flex items-center gap-2">
                    📊 Ver Análisis Visual
                </a>
                <% } %>
            </div>

            <%-- Mensaje de error --%>
            <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3">
                ❌ <%= error %>
            </div>
            <% } %>

            <%-- BARRA DE BÚSQUEDA Y FILTROS --%>
            <form action="<%= ctx %>/HistoryServlet" method="GET" class="search-bar">
                <input type="hidden" name="action" value="lista"/>

                <div class="search-input-wrap">
                    <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
                    <input type="text" name="q"
                           value="<%= filtroTexto %>"
                           placeholder="Buscar por solicitante, material o ID..."
                           class="input-icon"/>
                </div>

                <div class="flex gap-3">
                    <select name="status" class="select-page w-auto">
                        <option value="" <%= filtroStatus.isEmpty() ? "selected" : "" %>>Todos los estados</option>
                        <option value="PENDING" <%= "PENDING".equals(filtroStatus) ? "selected" : "" %>>Pendiente</option>
                        <option value="APPROVED" <%= "APPROVED".equals(filtroStatus) ? "selected" : "" %>>Aprobada</option>
                        <option value="REJECTED" <%= "REJECTED".equals(filtroStatus) ? "selected" : "" %>>Rechazada</option>
                        <option value="COMPLETED" <%= "COMPLETED".equals(filtroStatus) ? "selected" : "" %>>Entregada</option>
                    </select>

                    <button type="submit" class="btn-page-primary">Filtrar</button>
                </div>
            </form>

            <%-- TABLA DE TRANSACCIONES --%>
            <div class="table-panel">
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
                        <% if (transacciones == null || transacciones.isEmpty()) { %>
                        <tr>
                            <td colspan="8" class="py-10 text-center text-gray-400">
                                No hay transacciones que coincidan con tu búsqueda.
                            </td>
                        </tr>
                        <% } else { %>
                        <% for (Transaction tx : transacciones) { %>
                        <tr class="table-row">

                            <td class="td-id">
                                TXN-<%= String.format("%04d", tx.getId()) %>
                            </td>

                            <td class="td">
                                <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                            </td>

                            <td class="td font-medium text-gray-700">
                                <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                            </td>

                            <td class="td-center">
                                <%= tx.getQuantity() %>
                                <% if (tx.getItemUnit() != null) { %>
                                <%= tx.getItemUnit() %>
                                <% } %>
                            </td>

                            <td class="td-center">
                                <% if ("IN".equals(tx.getType())) { %>
                                <span class="type-in">IN</span>
                                <% } else if ("OUT".equals(tx.getType())) { %>
                                <span class="type-out">OUT</span>
                                <% } else { %>
                                <span class="text-xs text-gray-500"><%= tx.getType() %></span>
                                <% } %>
                            </td>

                            <td class="td-light text-xs">
                                <%= tx.getCreatedAt() != null ? tx.getCreatedAt() : "—" %>
                            </td>

                            <td class="td-center">
                                                <span class="<%= claseBadgeStatus(tx.getStatus()) %>">
                                                    <%= traducirStatus(tx.getStatus()) %>
                                                </span>
                            </td>

                            <td class="td-center">
                                <a href="<%= ctx %>/RequestDetailServlet?id=<%= tx.getId() %>"
                                   class="text-accent hover:text-pink-600 font-bold text-sm">
                                    👁️ Ver
                                </a>
                            </td>

                        </tr>
                        <% } %>
                        <% } %>
                        </tbody>

                    </table>
                </div>

                <div class="panel-footer">
                    <p class="panel-count-text">
                        Mostrando <%= transacciones != null ? transacciones.size() : 0 %>
                        de <%= totalTx %> transacciones
                    </p>
                </div>
            </div>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

</body>
</html>