<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();
    List<Item> items = (List<Item>) request.getAttribute("items");
    String userName = (String) session.getAttribute("userName");
    String error = request.getParameter("error");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>Nueva Solicitud | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>
<body class="page-body bg-gray-50 text-gray-800 font-sans min-h-screen flex flex-col">

<jsp:include page="includes/navbar.jsp"/>

<main class="page-main-narrow container mx-auto px-4 py-8 max-w-3xl flex-grow">

    <div class="page-header mb-6 flex justify-between items-center">
        <div>
            <h1 class="text-3xl font-bold text-indigo-900">Nueva Solicitud</h1>
            <p class="text-gray-500">Pide los materiales que necesitas para tu proyecto.</p>
        </div>
        <a href="javascript:history.back()" class="text-indigo-600 hover:text-indigo-800 font-medium">
            ⬅ Volver
        </a>
    </div>

    <div class="bg-white p-8 rounded-xl shadow-md border border-gray-100">
        <% if (error != null) { %>
        <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-6">
            ❌ <%= error %>
        </div>
        <% } %>

        <%-- El action apunta al Servlet y enviará un POST --%>
        <form action="<%= ctx %>/TransactionServlet" method="POST" class="space-y-6">

            <%-- Campo oculto para que el Servlet sepa qué acción tomar --%>
            <input type="hidden" name="action" value="crear" />

            <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 flex items-center gap-3">
                <div>
                    <p class="text-xs text-blue-600 font-bold uppercase tracking-wider">Solicitante</p>
                    <p class="text-sm font-semibold text-blue-800">
                        <%= userName != null ? userName : "Usuario Actual" %>
                    </p>
                </div>
            </div>

            <div>
                <label for="material" class="block text-sm font-semibold text-gray-700 mb-1">Material *</label>
                <select id="material" name="itemId" class="w-full border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 p-2 border" required>
                    <option value="" disabled selected>Selecciona un material...</option>
                    <% if (items != null) {
                        for (Item it : items) {
                            // Solo mostrar si está disponible
                            if (!"UNAVAILABLE".equals(it.getStatus()) && it.getActivo() == 1) {
                    %>
                    <option value="<%= it.getId() %>">
                        <%= it.getName() %> — Disponible: <%= it.getCachedQuantity() %> <%= it.getUnit() != null ? it.getUnit() : "" %>
                    </option>
                    <%      }
                    }
                    } %>
                </select>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label for="cantidad" class="block text-sm font-semibold text-gray-700 mb-1">Cantidad *</label>
                    <input type="number" id="cantidad" name="cantidad" min="1" value="1" class="w-full border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 p-2 border" required>
                </div>
                <div>
                    <label for="needed-by" class="block text-sm font-semibold text-gray-700 mb-1">¿Para cuándo lo necesitas? *</label>
                    <input type="date" id="needed-by" name="needed-by" class="w-full border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 p-2 border" required>
                    <p class="text-[11px] text-gray-400 mt-1">Esta fecha ayuda a priorizar.</p>
                </div>
            </div>

            <div>
                <label for="proposito" class="block text-sm font-semibold text-gray-700 mb-1">Propósito / Uso del material *</label>
                <textarea id="proposito" name="proposito" rows="4" class="w-full border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 p-2 border" placeholder="Describe para qué necesitas este material..." required></textarea>
            </div>

            <hr class="border-gray-100">

            <div class="flex justify-end gap-3 pt-2">
                <a href="javascript:history.back()" class="px-4 py-2 text-gray-600 hover:text-gray-900 font-medium">
                    Cancelar
                </a>
                <button type="submit" class="bg-indigo-600 hover:bg-indigo-700 text-white font-bold py-2 px-6 rounded-lg shadow transition-colors">
                    Enviar Solicitud
                </button>
            </div>
        </form>
    </div>
</main>

<jsp:include page="includes/footer.jsp"/>

<%-- Js para no seleccionar fechas del pasado --%>
<script>
    document.getElementById('needed-by').setAttribute('min', new Date().toISOString().split('T')[0]);
</script>
</body>
</html>