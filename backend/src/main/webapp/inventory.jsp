<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();
    List<Item> items = (List<Item>) request.getAttribute("items");
    String error = (String) request.getAttribute("error");
    String roleName = (String) session.getAttribute("roleName");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Inventario | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main">

        <%-- CABECERA --%>
        <div class="page-header">
            <div>
                <h1 class="page-title">Lista de Materiales</h1>
                <p class="page-subtitle">Listado de materiales y stock actual en tiempo real.</p>
            </div>
            <%-- Solo Admin y SuperAdmin pueden añadir material --%>
            <% if ("Administrador".equals(roleName) || "SuperAdmin".equals(roleName)) { %>
                <a href="<%= ctx %>/AdminItemServlet?action=formCrear" class="btn-page-primary">
                    ➕ Añadir Material
                </a>
            <% } %>
        </div>

        <%-- Mensajes --%>
        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3">
                ❌ <%= error %>
            </div>
        <% } %>

        <%-- TABLA DE INVENTARIO --%>
        <div class="table-panel">
            <div class="table-wrapper">
                <table class="table">
                    <thead class="table-head">
                        <tr>
                            <th class="th">Material</th>
                            <th class="th">Tags</th>
                            <th class="th-center">Stock</th>
                            <th class="th-center">Mínimo</th>
                            <th class="th-center">Estado</th>
                        </tr>
                    </thead>
                    <tbody class="table-body">
                        <% if (items == null || items.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="py-10 text-center text-gray-400">
                                    No hay materiales registrados todavía.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (Item item : items) { %>
                                <tr class="table-row">
                                    <td class="td">
                                        <div class="flex items-center gap-3">
                                            <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) { %>
                                                <img src="<%= item.getImageUrl() %>"
                                                     alt="<%= item.getName() %>"
                                                     class="w-10 h-10 rounded-lg object-cover border border-gray-100 shadow-sm"
                                                     onerror="this.style.display='none'"/>
                                            <% } else { %>
                                                <div class="w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center text-gray-400">
                                                    📦
                                                </div>
                                            <% } %>
                                            <span class="font-semibold text-gray-800">
                                                <%= item.getName() %>
                                            </span>
                                        </div>
                                    </td>
                                    <td class="td">
                                        <%-- Las tags vienen como String separadas por coma desde el DAO --%>
                                        <div class="flex gap-1 flex-wrap">
                                            <% if (item.getTags() != null && !item.getTags().isEmpty()) {
                                                for (String tag : item.getTags()) { %>
                                                <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-gray-100 text-gray-600 uppercase">
                                                    <%= tag %>
                                                </span>
                                            <% }
                                            } else { %>
                                                <span class="text-gray-300 text-xs">—</span>
                                            <% } %>
                                        </div>
                                    </td>
                                    <td class="td-center text-gray-700 font-semibold">
                                        <%= item.getCachedQuantity() %> <%= item.getUnit() %>
                                    </td>
                                    <td class="td-center text-gray-600">
                                        <%= item.getMinQuantity() %>
                                    </td>
                                    <td class="td-center">
                                        <%
                                            String status = item.getStatus();
                                            String badgeClass;
                                            String badgeText;
                                            if ("OK".equals(status)) {
                                                badgeClass = "stock-ok";
                                                badgeText = "OK";
                                            } else if ("LOW".equals(status)) {
                                                badgeClass = "stock-low";
                                                badgeText = "Stock Bajo";
                                            } else if ("UNAVAILABLE".equals(status)) {
                                                badgeClass = "stock-none";
                                                badgeText = "Sin Stock";
                                            } else {
                                                badgeClass = "stock-ok";
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
                    Mostrando <%= items != null ? items.size() : 0 %> materiales
                </p>
            </div>
        </div>

    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>