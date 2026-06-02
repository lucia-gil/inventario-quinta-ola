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

    // Capturamos el rol del usuario actual para ocultar acciones
    Integer roleId = (Integer) session.getAttribute("roleId");
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

    <%-- 🛡️ AQUÍ EMPIEZA LA MAGIA DE LA ESTRUCTURA --%>
    <div class="layout-wrapper">

        <jsp:include page="includes/navbar.jsp"/>

        <div class="main-content">

            <main class="page-main" style="padding: 2rem;">

                <div class="page-header" style="margin-bottom: 2rem;">
                    <div>
                        <h1 class="page-title" style="font-size: 1.5rem; font-weight: bold; color: #111827;">Gestión de Transacciones</h1>
                        <p class="page-subtitle" style="color: #6b7280;">Aprueba o rechaza las solicitudes de materiales</p>
                    </div>
                    <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="btn-page-primary" style="background-color: #db2777; color: white; padding: 0.5rem 1rem; border-radius: 0.5rem; text-decoration: none; font-weight: bold;">
                        ➕ Nueva Solicitud
                    </a>
                </div>

                <%-- Mensajes de feedback --%>
                <% if (success != null) { %>
                <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3" style="margin-bottom: 1rem; background-color: #ecfdf5; border: 1px solid #a7f3d0; color: #047857; padding: 1rem; border-radius: 0.5rem;">
                    ✅ <%= success %>
                </div>
                <% } %>
                <% if (errParam != null) { %>
                <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3" style="margin-bottom: 1rem; background-color: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; padding: 1rem; border-radius: 0.5rem;">
                    ❌ <%= errParam %>
                </div>
                <% } %>
                <% if (error != null) { %>
                <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3" style="margin-bottom: 1rem; background-color: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; padding: 1rem; border-radius: 0.5rem;">
                    ❌ <%= error %>
                </div>
                <% } %>

                <%-- Filtros rápidos --%>
                <div class="flex gap-3 flex-wrap" style="display: flex; gap: 1rem; margin-bottom: 2rem;">
                    <a href="<%= ctx %>/TransactionServlet?action=lista"
                       class="<%= filtroStatus.isEmpty() ? "btn-page-primary" : "btn-ghost" %>" style="padding: 0.5rem 1rem; border-radius: 0.5rem; text-decoration: none; border: 1px solid #e5e7eb; <%= filtroStatus.isEmpty() ? "background-color: #db2777; color: white;" : "color: #4b5563;" %>">
                        Todas
                    </a>
                    <a href="<%= ctx %>/TransactionServlet?action=lista&status=PENDING"
                       class="<%= "PENDING".equals(filtroStatus) ? "btn-page-primary" : "btn-ghost" %>" style="padding: 0.5rem 1rem; border-radius: 0.5rem; text-decoration: none; border: 1px solid #e5e7eb; <%= "PENDING".equals(filtroStatus) ? "background-color: #db2777; color: white;" : "color: #4b5563;" %>">
                        ⏱️ Pendientes
                    </a>
                    <a href="<%= ctx %>/TransactionServlet?action=lista&status=APPROVED"
                       class="<%= "APPROVED".equals(filtroStatus) ? "btn-page-primary" : "btn-ghost" %>" style="padding: 0.5rem 1rem; border-radius: 0.5rem; text-decoration: none; border: 1px solid #e5e7eb; <%= "APPROVED".equals(filtroStatus) ? "background-color: #db2777; color: white;" : "color: #4b5563;" %>">
                        ✅ Aprobadas
                    </a>
                </div>

                <%-- Tabla de transacciones --%>
                <div class="table-panel" style="background: white; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden;">
                    <div class="table-wrapper">
                        <table class="table" style="width: 100%; border-collapse: collapse;">
                            <thead class="table-head" style="background-color: #f9fafb; border-bottom: 1px solid #e5e7eb;">
                            <tr>
                                <th class="th" style="padding: 1rem; text-align: left; color: #6b7280; font-size: 0.875rem;">ID</th>
                                <th class="th" style="padding: 1rem; text-align: left; color: #6b7280; font-size: 0.875rem;">Solicitante</th>
                                <th class="th" style="padding: 1rem; text-align: left; color: #6b7280; font-size: 0.875rem;">Material</th>
                                <th class="th-center" style="padding: 1rem; text-align: center; color: #6b7280; font-size: 0.875rem;">Cantidad</th>
                                <th class="th" style="padding: 1rem; text-align: left; color: #6b7280; font-size: 0.875rem;">Fecha</th>
                                <th class="th-center" style="padding: 1rem; text-align: center; color: #6b7280; font-size: 0.875rem;">Estado</th>
                                <%-- Solo Manager (3), Admin (4) y SA (5) ven las acciones --%>
                                <% if (roleId != null && roleId >= 3) { %>
                                <th class="th-center" style="padding: 1rem; text-align: center; color: #6b7280; font-size: 0.875rem;">Acciones</th>
                                <% } %>
                            </tr>
                            </thead>
                            <tbody class="table-body">
                            <% if (transacciones == null || transacciones.isEmpty()) { %>
                            <tr>
                                <td colspan="7" class="py-10 text-center text-gray-400" style="padding: 2rem; text-align: center; color: #9ca3af;">
                                    No hay transacciones que mostrar.
                                </td>
                            </tr>
                            <% } else { %>
                            <% for (Transaction tx : transacciones) { %>
                            <tr class="table-row" style="border-bottom: 1px solid #e5e7eb;">
                                <td class="td-id" style="padding: 1rem; font-weight: bold; color: #111827;">TXN-<%= String.format("%04d", tx.getId()) %></td>
                                <td class="td" style="padding: 1rem; color: #4b5563;">
                                    <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                                </td>
                                <td class="td font-medium" style="padding: 1rem; color: #111827; font-weight: 500;">
                                    <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                                </td>
                                <td class="td-center" style="padding: 1rem; text-align: center; color: #4b5563;">
                                    <%= tx.getQuantity() %>
                                    <% if (tx.getItemUnit() != null) { %>
                                    <%= tx.getItemUnit() %>
                                    <% } %>
                                </td>
                                <td class="td-light text-xs" style="padding: 1rem; color: #6b7280; font-size: 0.75rem;">
                                    <%= tx.getCreatedAt() != null ? tx.getCreatedAt() : "—" %>
                                </td>
                                <td class="td-center" style="padding: 1rem; text-align: center;">
                                    <span class="<%= claseBadgeStatus(tx.getStatus()) %>">
                                        <%= traducirStatus(tx.getStatus()) %>
                                    </span>
                                </td>

                                <%-- Solo Manager, Admin y SA pueden interactuar con los botones --%>
                                <% if (roleId != null && roleId >= 3) { %>
                                <td class="td-center" style="padding: 1rem; text-align: center;">
                                    <%-- Si está pendiente, mostrar botones de aprobar/rechazar --%>
                                    <% if ("PENDING".equals(tx.getStatus())) { %>
                                    <div class="flex gap-2 justify-center" style="display: flex; gap: 0.5rem; justify-content: center;">
                                        <%-- Botón Aprobar --%>
                                        <form action="<%= ctx %>/TransactionServlet" method="POST"
                                              onsubmit="return confirm('¿Aprobar esta solicitud?');"
                                              style="margin: 0;">
                                            <input type="hidden" name="action" value="aprobar"/>
                                            <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                                            <input type="hidden" name="notas" value="Aprobado"/>
                                            <button type="submit"
                                                    style="background-color: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; padding: 0.25rem 0.75rem; border-radius: 0.5rem; font-size: 0.75rem; font-weight: bold; cursor: pointer;">
                                                ✅ Aprobar
                                            </button>
                                        </form>
                                        <%-- Botón Rechazar (con prompt para motivo) --%>
                                        <button onclick="rechazarTx(<%= tx.getId() %>)"
                                                style="background-color: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; padding: 0.25rem 0.75rem; border-radius: 0.5rem; font-size: 0.75rem; font-weight: bold; cursor: pointer;">
                                            ❌ Rechazar
                                        </button>
                                    </div>
                                    <% } else { %>
                                    <span class="text-gray-300 text-xs" style="color: #d1d5db; font-size: 0.75rem;">—</span>
                                    <% } %>
                                </td>
                                <% } %>

                            </tr>
                            <% } %>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div class="panel-footer" style="padding: 1rem; background-color: #f9fafb; border-top: 1px solid #e5e7eb; text-align: right;">
                        <p class="panel-count-text" style="color: #6b7280; font-size: 0.875rem; margin: 0;">
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

        </div>
    </div>
</body>
</html>