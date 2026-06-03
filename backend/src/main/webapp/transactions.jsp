<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    List<Transaction> transacciones = (List<Transaction>) request.getAttribute("transacciones");

    // Variables de paginación enviadas por el Servlet
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");

    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (totalRecords == null) totalRecords = 0;

    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");
    String errParam = request.getParameter("error");

    Integer roleId = (Integer) session.getAttribute("roleId");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>Bandeja de Aprobaciones | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>
<body class="page-body">

<div class="layout-wrapper">
    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <main class="page-main" style="padding: 2rem;">

            <div class="page-header" style="margin-bottom: 2rem;">
                <div>
                    <h1 class="page-title" style="font-size: 1.5rem; font-weight: bold; color: #111827;">Bandeja de Aprobaciones</h1>
                    <p class="page-subtitle" style="color: #6b7280;">Solicitudes pendientes que requieren tu atención</p>
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
            <% if (errParam != null || error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3" style="margin-bottom: 1rem; background-color: #fef2f2; border: 1px solid #fecaca; color: #b91c1c; padding: 1rem; border-radius: 0.5rem;">
                ❌ <%= errParam != null ? errParam : error %>
            </div>
            <% } %>

            <%-- Tabla de transacciones PENDIENTES --%>
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
                            <th class="th-center" style="padding: 1rem; text-align: center; color: #6b7280; font-size: 0.875rem;">Detalle</th>
                            <% if (roleId != null && roleId >= 3) { %>
                            <th class="th-center" style="padding: 1rem; text-align: center; color: #6b7280; font-size: 0.875rem;">Acciones</th>
                            <% } %>
                        </tr>
                        </thead>
                        <tbody class="table-body">
                        <% if (transacciones == null || transacciones.isEmpty()) { %>
                        <tr>
                            <td colspan="7" class="py-10 text-center text-gray-400" style="padding: 4rem; text-align: center; color: #9ca3af;">
                                🎉 ¡Todo al día! No tienes solicitudes pendientes por aprobar.
                            </td>
                        </tr>
                        <% } else { %>
                        <% for (Transaction tx : transacciones) { %>
                        <tr class="table-row" style="border-bottom: 1px solid #e5e7eb; transition: background-color 0.2s;" onmouseover="this.style.backgroundColor='#f9fafb';" onmouseout="this.style.backgroundColor='transparent';">
                            <td class="td-id" style="padding: 1rem; font-weight: bold; color: #111827;">TXN-<%= String.format("%04d", tx.getId()) %></td>
                            <td class="td" style="padding: 1rem; color: #4b5563;">
                                <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                            </td>
                            <td class="td font-medium" style="padding: 1rem; color: #111827; font-weight: 500;">
                                <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                            </td>
                            <td class="td-center" style="padding: 1rem; text-align: center; color: #4b5563;">
                                <%= tx.getQuantity() %> <%= tx.getItemUnit() != null ? tx.getItemUnit() : "" %>
                            </td>
                            <td class="td-light text-xs" style="padding: 1rem; color: #6b7280; font-size: 0.75rem;">
                                <%= tx.getCreatedAt() != null ? tx.getCreatedAt() : "—" %>
                            </td>

                            <%-- Nuevo Botón de DETALLE (Reemplaza al Estado) --%>
                            <td class="td-center" style="padding: 1rem; text-align: center;">
                                <a href="<%= ctx %>/TransactionServlet?action=detalle&id=<%= tx.getId() %>"
                                   style="color: #db2777; text-decoration: none; font-weight: 600; font-size: 0.875rem; display: inline-flex; align-items: center; gap: 0.25rem;">
                                    👁️ Ver
                                </a>
                            </td>

                            <%-- Botones de Acción directos --%>
                            <% if (roleId != null && roleId >= 3) { %>
                            <td class="td-center" style="padding: 1rem; text-align: center;">
                                <div class="flex gap-2 justify-center" style="display: flex; gap: 0.5rem; justify-content: center;">
                                    <form action="<%= ctx %>/TransactionServlet" method="POST" onsubmit="return confirm('¿Aprobar esta solicitud?');" style="margin: 0;">
                                        <input type="hidden" name="action" value="aprobar"/>
                                        <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                                        <input type="hidden" name="notas" value="Aprobado"/>
                                        <button type="submit" style="background-color: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; padding: 0.25rem 0.75rem; border-radius: 0.5rem; font-size: 0.75rem; font-weight: bold; cursor: pointer; transition: 0.2s;" onmouseover="this.style.backgroundColor='#d1fae5'" onmouseout="this.style.backgroundColor='#ecfdf5'">
                                            ✅ Aprobar
                                        </button>
                                    </form>
                                    <button onclick="rechazarTx(<%= tx.getId() %>)" style="background-color: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; padding: 0.25rem 0.75rem; border-radius: 0.5rem; font-size: 0.75rem; font-weight: bold; cursor: pointer; transition: 0.2s;" onmouseover="this.style.backgroundColor='#fee2e2'" onmouseout="this.style.backgroundColor='#fef2f2'">
                                        ❌ Rechazar
                                    </button>
                                </div>
                            </td>
                            <% } %>
                        </tr>
                        <% } %>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <%-- 📄 FOOTER CON PAGINACIÓN --%>
                <div class="panel-footer flex justify-between items-center" style="padding: 1rem 1.5rem; background-color: #f9fafb; border-top: 1px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center;">
                    <p class="text-sm" style="color: #6b7280; margin: 0; font-size: 0.875rem;">
                        Mostrando <span style="font-weight: 600; color: #111827;"><%= transacciones != null ? transacciones.size() : 0 %></span> de <span style="font-weight: 600; color: #111827;"><%= totalRecords %></span> pendientes
                    </p>

                    <% if (totalPages > 1) { %>
                    <div style="display: flex; gap: 0.5rem; align-items: center;">
                        <% if (currentPage > 1) { %>
                        <a href="<%= ctx %>/TransactionServlet?action=lista&page=<%= currentPage - 1 %>" style="padding: 0.25rem 0.75rem; border: 1px solid #d1d5db; border-radius: 0.375rem; background: white; color: #374151; text-decoration: none; font-size: 0.875rem;">Anterior</a>
                        <% } %>

                        <span style="padding: 0.25rem 0.75rem; background: #f3f4f6; border-radius: 0.375rem; color: #374151; font-size: 0.875rem; font-weight: 500;">
                                Pág <%= currentPage %> de <%= totalPages %>
                            </span>

                        <% if (currentPage < totalPages) { %>
                        <a href="<%= ctx %>/TransactionServlet?action=lista&page=<%= currentPage + 1 %>" style="padding: 0.25rem 0.75rem; border: 1px solid #d1d5db; border-radius: 0.375rem; background: white; color: #374151; text-decoration: none; font-size: 0.875rem;">Siguiente</a>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </div>

        </main>

        <%-- Form oculto JS --%>
        <form id="rejectForm" action="<%= ctx %>/TransactionServlet" method="POST" style="display:none;">
            <input type="hidden" name="action" value="rechazar"/>
            <input type="hidden" name="id" id="rejectTxId"/>
            <input type="hidden" name="notas" id="rejectNotas"/>
        </form>

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