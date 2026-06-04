<%--
    ============================================================
     deposit.jsp
    ============================================================
     Vista del encargado de deposito.
     Lista las solicitudes APROBADAS que ya pueden ser entregadas.
     Al marcar una como entregada, el stock se descuenta solo.

     Recibe del DepositServlet:
     - "solicitudes" (List<Transaction>): aprobadas pendientes de entrega
    ============================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    List<Transaction> solicitudes = (List<Transaction>) request.getAttribute("solicitudes");
    String error = (String) request.getAttribute("error");
    String errParam = request.getParameter("error");
    String success = request.getParameter("success");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>Depósito | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=3" rel="stylesheet" />
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main">

        <%-- Cabecera --%>
        <div class="page-header">
            <div>
                <h1 class="page-title">📦 Gestión de Depósito</h1>
                <p class="page-subtitle">
                    Solicitudes aprobadas listas para entrega física.
                </p>
            </div>
            <a href="<%= ctx %>/HistoryServlet" class="btn-ghost">
                Ver historial completo →
            </a>
        </div>

        <%-- Mensajes --%>
        <% if (success != null) { %>
            <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3">
                ✅ <%= success %>
            </div>
        <% } %>
        <% if (errParam != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3">
                ❌ <%= errParam %>
            </div>
        <% } %>
        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3">
                ❌ <%= error %>
            </div>
        <% } %>

        <%-- Info importante --%>
        <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 flex items-start gap-3">
            <span class="text-2xl">ℹ️</span>
            <div>
                <p class="text-sm font-semibold text-blue-800">
                    Recuerda
                </p>
                <p class="text-sm text-blue-700 mt-1">
                    Cuando marques una solicitud como entregada, el stock del material se
                    descontará automáticamente del inventario. Asegúrate de haber entregado
                    físicamente el material antes de confirmar.
                </p>
            </div>
        </div>

        <%-- Tabla de solicitudes aprobadas --%>
        <div class="table-panel">
            <div class="table-wrapper">
                <table class="table">
                    <thead class="table-head">
                        <tr>
                            <th class="th">ID</th>
                            <th class="th">Solicitante</th>
                            <th class="th">Material</th>
                            <th class="th-center">Cantidad</th>
                            <th class="th">Aprobada por</th>
                            <th class="th">Fecha aprobación</th>
                            <th class="th-center">Acción</th>
                        </tr>
                    </thead>
                    <tbody class="table-body">

                        <% if (solicitudes == null || solicitudes.isEmpty()) { %>
                            <tr>
                                <td colspan="7" class="py-12 text-center text-gray-400">
                                    🎉 No hay solicitudes pendientes de entrega.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Transaction tx : solicitudes) { %>
                                <tr class="table-row">
                                    <td class="td-id">
                                        TXN-<%= String.format("%04d", tx.getId()) %>
                                    </td>
                                    <td class="td">
                                        <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                                    </td>
                                    <td class="td font-medium">
                                        <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                                    </td>
                                    <td class="td-center font-semibold text-gray-700">
                                        <%= tx.getQuantity() %>
                                        <%= tx.getItemUnit() != null ? tx.getItemUnit() : "" %>
                                    </td>
                                    <td class="td">
                                        <%= tx.getApproverName() != null ? tx.getApproverName() : "—" %>
                                    </td>
                                    <td class="td-light text-xs">
                                        <%= tx.getCreatedAt() != null ? tx.getCreatedAt() : "—" %>
                                    </td>
                                    <td class="td-center">

                                        <%-- Boton para marcar como entregada --%>
                                        <%-- Es un form POST con confirm para evitar accidentes --%>
                                        <form action="<%= ctx %>/DepositServlet" method="POST"
                                              onsubmit="return confirm('¿Confirmas que entregaste físicamente este material? Esto descontará del stock.');"
                                              style="display:inline;">
                                            <input type="hidden" name="action" value="entregar"/>
                                            <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                                            <button type="submit"
                                                    class="bg-purple-500 hover:bg-purple-600 text-white px-4 py-1.5 rounded-lg text-xs font-bold shadow-sm">
                                                📦 Marcar Entregada
                                            </button>
                                        </form>

                                        <%-- Link al detalle --%>
                                        <a href="<%= ctx %>/RequestDetailServlet?id=<%= tx.getId() %>"
                                           class="ml-2 text-gray-400 hover:text-accent text-xs">
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
                    <%= solicitudes != null ? solicitudes.size() : 0 %> solicitudes pendientes de entrega
                </p>
            </div>
        </div>

    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>