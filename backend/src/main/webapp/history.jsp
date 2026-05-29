<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    List<Transaction> transacciones = (List<Transaction>) request.getAttribute("transacciones");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Historial | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main">

        <div class="flex justify-between items-center flex-wrap gap-3">
            <div>
                <h1 class="page-title">Historial de Transacciones</h1>
                <p class="page-subtitle">Registro de todas las solicitudes y movimientos.</p>
            </div>
            <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="btn-page-primary">
                ➕ Nueva Transacción
            </a>
        </div>

        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3">
                ❌ <%= error %>
            </div>
        <% } %>

        <%-- TABLA --%>
        <div class="table-panel">
            <div class="table-wrapper">
                <table class="table">
                    <thead class="table-head">
                        <tr>
                            <th class="th">ID</th>
                            <th class="th">Solicitante</th>
                            <th class="th">Item</th>
                            <th class="th-center">Cantidad</th>
                            <th class="th-center">Tipo</th>
                            <th class="th">Fecha</th>
                            <th class="th-center">Estado</th>
                        </tr>
                    </thead>
                    <tbody class="table-body">
                        <% if (transacciones == null || transacciones.isEmpty()) { %>
                            <tr>
                                <td colspan="7" class="py-10 text-center text-gray-400">
                                    Sin transacciones registradas todavía.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Transaction tx : transacciones) { %>
                                <tr class="table-row">
                                    <td class="td-id">TXN-<%= String.format("%04d", tx.getId()) %></td>
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
                                        <%
                                            String status = tx.getStatus();
                                            String badgeClass;
                                            String badgeText;
                                            if ("APPROVED".equals(status)) {
                                                badgeClass = "status-approved";
                                                badgeText = "Aprobada";
                                            } else if ("PENDING".equals(status)) {
                                                badgeClass = "status-pending";
                                                badgeText = "Pendiente";
                                            } else if ("REJECTED".equals(status)) {
                                                badgeClass = "status-rejected";
                                                badgeText = "Rechazada";
                                            } else if ("COMPLETED".equals(status)) {
                                                badgeClass = "status-delivered";
                                                badgeText = "Entregada";
                                            } else {
                                                badgeClass = "status-badge bg-gray-100 text-gray-600";
                                                badgeText = status;
                                            }
                                        %>
                                        <span class="<%= badgeClass %>"><%= badgeText %></span>
                                    </td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <div class="panel-footer">
                <p class="panel-count-text">
                    Mostrando <%= transacciones != null ? transacciones.size() : 0 %> transacciones
                </p>
            </div>
        </div>

    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>