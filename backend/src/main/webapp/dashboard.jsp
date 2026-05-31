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
    <link href="<%= ctx %>/css/style.css?v=6" rel="stylesheet"/>
</head>
<body class="page-body">

    <div class="layout-wrapper">

        <jsp:include page="includes/navbar.jsp"/>

        <div class="main-content">

            <main class="page-main" style="padding: 2rem;">

                <%-- 🌸 1. BANNER ROSADO HORIZONTAL --%>
                <div style="background-color: #fdf2f8; border-left: 6px solid #db2777; padding: 1.5rem 2rem; border-radius: 0.5rem; margin-bottom: 2rem; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                    <h1 style="color: #db2777; font-size: 1.5rem; font-weight: 700; margin-bottom: 0.25rem;">Bienvenida al Sistema</h1>
                    <p style="color: #4b5563; font-size: 0.95rem; margin: 0;">
                        Hola <strong><%= userName %></strong>, este es el resumen general del inventario en tiempo real.
                    </p>
                </div>

                <%-- 📊 2. STAT CARDS (OBLIGADAS A ESTAR EN FILA CON FLEXBOX) --%>
                <div style="display: flex; gap: 1.5rem; margin-bottom: 2rem; flex-wrap: wrap;">

                    <div class="stat-card" style="flex: 1 1 20%; min-width: 200px;">
                        <div>
                            <p class="stat-card-label">Total Materiales</p>
                            <p class="stat-card-value"><%= totalItems != null ? totalItems : 0 %></p>
                        </div>
                        <div class="stat-card-icon stat-icon-blue">📦</div>
                    </div>

                    <div class="stat-card" style="flex: 1 1 20%; min-width: 200px;">
                        <div>
                            <p class="stat-card-label">Bajo Stock</p>
                            <p class="stat-card-value"><%= totalLowStock != null ? totalLowStock : 0 %></p>
                        </div>
                        <div class="stat-card-icon stat-icon-orange">⚠️</div>
                    </div>

                    <div class="stat-card" style="flex: 1 1 20%; min-width: 200px;">
                        <div>
                            <p class="stat-card-label">Pendientes</p>
                            <p class="stat-card-value"><%= totalPendientes != null ? totalPendientes : 0 %></p>
                        </div>
                        <div class="stat-card-icon stat-icon-yellow">⏱️</div>
                    </div>

                    <div class="stat-card" style="flex: 1 1 20%; min-width: 200px;">
                        <div>
                            <p class="stat-card-label">Aprobadas</p>
                            <p class="stat-card-value"><%= totalAprobadas != null ? totalAprobadas : 0 %></p>
                        </div>
                        <div class="stat-card-icon stat-icon-green">✅</div>
                    </div>

                </div>

                <%-- 📋 3. TABLA DE ÚLTIMOS MOVIMIENTOS --%>
                <div class="panel">
                    <div class="panel-header">
                        <div>
                            <h2 class="panel-header-title">Últimos movimientos</h2>
                            <p class="panel-header-sub">Actividad reciente del inventario</p>
                        </div>
                        <a href="<%= ctx %>/HistoryServlet" class="text-sm font-semibold" style="color: #db2777; text-decoration: none;">Ver todo →</a>
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

        </div>
    </div>

</body>
</html>