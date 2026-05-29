<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    Integer totalItems = (Integer) request.getAttribute("totalItems");
    Integer totalLowStock = (Integer) request.getAttribute("totalLowStock");
    Integer totalPendientes = (Integer) request.getAttribute("totalPendientes");
    Integer totalAprobadas = (Integer) request.getAttribute("totalAprobadas");
    List<Transaction> ultimas = (List<Transaction>) request.getAttribute("ultimasTransacciones");
    String userName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Dashboard | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main">

        <div>
            <h1 class="page-title">Bienvenida al Sistema</h1>
            <p class="page-subtitle">
                Hola <%= userName %>, este es el resumen general del inventario.
            </p>
        </div>

        <%-- STAT CARDS --%>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">

            <div class="stat-card">
                <div>
                    <p class="stat-card-label">Total Materiales</p>
                    <p class="stat-card-value"><%= totalItems != null ? totalItems : 0 %></p>
                </div>
                <div class="stat-card-icon stat-icon-blue">📦</div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-card-label">Bajo Stock</p>
                    <p class="stat-card-value"><%= totalLowStock != null ? totalLowStock : 0 %></p>
                </div>
                <div class="stat-card-icon stat-icon-orange">⚠️</div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-card-label">Pendientes</p>
                    <p class="stat-card-value"><%= totalPendientes != null ? totalPendientes : 0 %></p>
                </div>
                <div class="stat-card-icon stat-icon-yellow">⏱️</div>
            </div>

            <div class="stat-card">
                <div>
                    <p class="stat-card-label">Aprobadas</p>
                    <p class="stat-card-value"><%= totalAprobadas != null ? totalAprobadas : 0 %></p>
                </div>
                <div class="stat-card-icon stat-icon-green">✅</div>
            </div>

        </div>

        <%-- ÚLTIMOS MOVIMIENTOS --%>
        <div class="panel">
            <div class="panel-header">
                <div>
                    <h2 class="panel-header-title">Últimos movimientos</h2>
                    <p class="panel-header-sub">Actividad reciente del inventario</p>
                </div>
                <a href="<%= ctx %>/HistoryServlet"
                   class="text-sm font-semibold text-accent">Ver todo →</a>
            </div>

            <div class="table-wrapper">
                <table class="table">
                    <thead class="table-head">
                        <tr>
                            <th class="th">ID</th>
                            <th class="th">Solicitante</th>
                            <th class="th">Material</th>
                            <th class="th-center">Cantidad</th>
                            <th class="th-center">Estado</th>
                        </tr>
                    </thead>
                    <tbody class="table-body">
                        <% if (ultimas == null || ultimas.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="py-10 text-center text-gray-400">
                                    Sin movimientos recientes
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Transaction tx : ultimas) { %>
                                <tr class="table-row">
                                    <td class="td-id">TXN-<%= String.format("%04d", tx.getId()) %></td>
                                    <td class="td"><%= tx.getRequesterName() %></td>
                                    <td class="td font-medium text-gray-700">
                                        <%= tx.getItemName() %>
                                    </td>
                                    <td class="td-center">
                                        <%= tx.getQuantity() %> <%= tx.getItemUnit() %>
                                    </td>
                                    <td class="td-center">
                                        <%
                                            String status = tx.getStatus();
                                            String bc, bt;
                                            if ("APPROVED".equals(status))      { bc = "status-approved";  bt = "Aprobada"; }
                                            else if ("PENDING".equals(status))   { bc = "status-pending";   bt = "Pendiente"; }
                                            else if ("REJECTED".equals(status))  { bc = "status-rejected";  bt = "Rechazada"; }
                                            else if ("COMPLETED".equals(status)) { bc = "status-delivered"; bt = "Entregada"; }
                                            else { bc = "status-badge bg-gray-100 text-gray-600"; bt = status; }
                                        %>
                                        <span class="<%= bc %>"><%= bt %></span>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>