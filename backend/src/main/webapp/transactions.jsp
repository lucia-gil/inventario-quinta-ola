<%--
    transactions.jsp — Vista de gestión de transacciones (para Manager/Admin/SA)
    Recibe del TransactionServlet:
    - transacciones (List<Transaction>): lista para mostrar
    - filtroStatus (String): el filtro aplicado (PENDING/APPROVED/"")
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    List<Transaction> transacciones = (List<Transaction>) request.getAttribute("transacciones");
    String filtroStatus = (String) request.getAttribute("filtroStatus");
    if (filtroStatus == null) filtroStatus = "";

    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");
    String errParam = request.getParameter("error");
%>
<%!
    private String traducirStatus(String s) {
        if (s == null) return "—";
        switch (s) {
            case "PENDING":   return "Pendiente";
            case "APPROVED":  return "Aprobada";
            case "REJECTED":  return "Rechazada";
            case "COMPLETED": return "Entregada";
            default:          return s;
        }
    }

    private String claseBadgeStatus(String s) {
        if (s == null) return "status-badge bg-gray-100 text-gray-600";
        switch (s) {
            case "PENDING":   return "status-pending";
            case "APPROVED":  return "status-approved";
            case "REJECTED":  return "status-rejected";
            case "COMPLETED": return "status-delivered";
            default:          return "status-badge bg-gray-100 text-gray-600";
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>Transacciones | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>
<body class="page-body">

<jsp:include page="includes/navbar.jsp"/>

<main class="page-main">

    <div class="page-header">
        <div>
            <h1 class="page-title">Gestión de Transacciones</h1>
            <p class="page-subtitle">Aprueba o rechaza las solicitudes de materiales</p>
        </div>
        <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="btn-page-primary">
            ➕ Nueva Solicitud
        </a>
    </div>

    <%-- Mensajes de feedback --%>
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

    <%-- Filtros rápidos --%>
    <div class="flex gap-3 flex-wrap">
        <a href="<%= ctx %>/TransactionServlet?action=lista"
           class="<%= filtroStatus.isEmpty() ? "btn-page-primary" : "btn-ghost" %>">
            Todas
        </a>
        <a href="<%= ctx %>/TransactionServlet?action=lista&status=PENDING"
           class="<%= "PENDING".equals(filtroStatus) ? "btn-page-primary" : "btn-ghost" %>">
            ⏱️ Pendientes
        </a>
        <a href="<%= ctx %>/TransactionServlet?action=lista&status=APPROVED"
           class="<%= "APPROVED".equals(filtroStatus) ? "btn-page-primary" : "btn-ghost" %>">
            ✅ Aprobadas
        </a>
    </div>

    <%-- Tabla de transacciones --%>
    <div class="table-panel">
        <div class="table-wrapper">
            <table class="table">
                <thead class="table-head">
                <tr>
                    <th class="th">ID</th>
                    <th class="th">Solicitante</th>
                    <th class="th">Material</th>
                    <th class="th-center">Cantidad</th>
                    <th class="th">Fecha</th>
                    <th class="th-center">Estado</th>
                    <th class="th-center">Acciones</th>
                </tr>
                </thead>
                <tbody class="table-body">
                <% if (transacciones == null || transacciones.isEmpty()) { %>
                <tr>
                    <td colspan="7" class="py-10 text-center text-gray-400">
                        No hay transacciones que mostrar.
                    </td>
                </tr>
                <% } else { %>
                <% for (Transaction tx : transacciones) { %>
                <tr class="table-row">
                    <td class="td-id">TXN-<%= String.format("%04d", tx.getId()) %></td>
                    <td class="td">
                        <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                    </td>
                    <td class="td font-medium">
                        <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                    </td>
                    <td class="td-center">
                        <%= tx.getQuantity() %>
                        <% if (tx.getItemUnit() != null) { %>
                        <%= tx.getItemUnit() %>
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
                        <%-- Si está pendiente, mostrar botones de aprobar/rechazar --%>
                        <% if ("PENDING".equals(tx.getStatus())) { %>
                        <div class="flex gap-2 justify-center">
                            <%-- Botón Aprobar --%>
                            <form action="<%= ctx %>/TransactionServlet" method="POST"
                                  onsubmit="return confirm('¿Aprobar esta solicitud?');"
                                  style="display:inline;">
                                <input type="hidden" name="action" value="aprobar"/>
                                <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                                <input type="hidden" name="notas" value="Aprobado"/>
                                <button type="submit"
                                        class="bg-green-50 text-green-600 hover:bg-green-100 px-3 py-1.5 rounded-lg text-xs font-bold">
                                    ✅ Aprobar
                                </button>
                            </form>
                            <%-- Botón Rechazar (con prompt para motivo) --%>
                            <button onclick="rechazarTx(<%= tx.getId() %>)"
                                    class="bg-red-50 text-red-600 hover:bg-red-100 px-3 py-1.5 rounded-lg text-xs font-bold">
                                ❌ Rechazar
                            </button>
                        </div>
                        <% } else { %>
                        <span class="text-gray-300 text-xs">—</span>
                        <% } %>
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

<%-- Formulario oculto para rechazar (se llena con JS y se envía) --%>
<form id="rejectForm" action="<%= ctx %>/TransactionServlet" method="POST" style="display:none;">
    <input type="hidden" name="action" value="rechazar"/>
    <input type="hidden" name="id" id="rejectTxId"/>
    <input type="hidden" name="notas" id="rejectNotas"/>
</form>

<%-- ÚNICO JavaScript permitido: prompt para pedir motivo de rechazo y enviar formulario --%>
<%-- No es lógica de negocio, solo UX. La validación real está en el servlet. --%>
<script>
    function rechazarTx(id) {
        const motivo = prompt('Motivo del rechazo (obligatorio):');
        if (motivo && motivo.trim() !== '') {
            document.getElementById('rejectTxId').value = id;
            document.getElementById('rejectNotas').value = motivo;
            document.getElementById('rejectForm').submit();
        } else if (motivo !== null) {
            alert('El motivo es obligatorio.');
        }
    }
</script>

<jsp:include page="includes/footer.jsp"/>

</body>
</html>