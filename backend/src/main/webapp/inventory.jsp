<%--
    ════════════════════════════════════════════════════════════════════
     inventory.jsp — Vista del inventario de materiales
    ════════════════════════════════════════════════════════════════════

     PROPÓSITO:
     Listar materiales con filtros (búsqueda, tag, estado).
     Muestra 2 vistas distintas según el rol:
       - Viewer/Member: tarjetas tipo catálogo (solo lectura)
       - Manager/Admin/SuperAdmin: tabla administrativa con acciones

     ¿DE DÓNDE SACAMOS LOS DATOS?
     - "items"       → lista filtrada que envió InventoryServlet
     - "totalItems"  → cantidad total (antes de filtrar)
     - "filtroTexto" → para preservar el texto de búsqueda
     - "filtroTag"   → para preservar el filtro de tag
     - "filtroStock" → para preservar el filtro de stock

     CONVERTIDO DESDE:
     inventory.html (versión con fetch + JS). Toda la lógica de filtrado
     pasó al servidor (Clase 7.2 slide 13 - patrón MVC).
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    /* ════════════════════════════════════════════════════════════════
     * BLOQUE DE PREPARACIÓN DE DATOS
     * ════════════════════════════════════════════════════════════════ */

    String ctx = request.getContextPath();

    // Castear la lista de items que mandó el servlet (Clase 7.2 slide 53)
    List<Item> items = (List<Item>) request.getAttribute("items");
    Integer totalItems = (Integer) request.getAttribute("totalItems");
    if (totalItems == null) totalItems = 0;

    // Recuperar los filtros aplicados (para conservarlos en los inputs)
    String filtroTexto = (String) request.getAttribute("filtroTexto");
    String filtroTag   = (String) request.getAttribute("filtroTag");
    String filtroStock = (String) request.getAttribute("filtroStock");
    if (filtroTexto == null) filtroTexto = "";
    if (filtroTag == null) filtroTag = "";
    if (filtroStock == null) filtroStock = "";

    // Mensaje de error si lo hay
    String error = (String) request.getAttribute("error");

    // ─── DETERMINAR QUÉ VISTA MOSTRAR SEGÚN ROL ───
    // Antes esto lo decidía JavaScript; ahora lo hago en JSP
    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    int roleId = roleIdSession != null ? roleIdSession : 0;
    String roleName = (String) session.getAttribute("roleName");

    // Roles 1 (Viewer) y 2 (Member) → vista catálogo (tarjetas)
    boolean esCatalogo = (roleId == 1 || roleId == 2);

    // Roles 3,4,5 → vista tabla con CRUD
    boolean esAdmin = (roleId == 4 || roleId == 5);
    //Solo administrador y Gestor (roles 2 y 4) pueden agregar material
    boolean puedeAgregarMaterial = (roleId == 2 || roleId == 4);

    // Título y subtítulo según rol
    String pageTitle    = esCatalogo ? "Catálogo de Materiales" : "Lista de Materiales";
    String pageSubtitle = esCatalogo
            ? "Selecciona materiales y agrégalos a tu solicitud."
            : "Listado de materiales y stock actual en tiempo real.";
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Inventario | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>

<body class="page-body">

<%-- 🛡️ ENVOLTURA PARA EVITAR EL SOLAPAMIENTO DEL SIDEBAR --%>
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <main class="page-main">

            <%-- ──────────────────────────────────────────────────────────
                  CABECERA (título + botón añadir)
                 ────────────────────────────────────────────────────────── --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title"><%= pageTitle %></h1>
                    <p class="page-subtitle"><%= pageSubtitle %></p>
                </div>

                <%-- Botón "Añadir Material" solo para Manager/Admin/SuperAdmin --%>
                <% if (puedeAgregarMaterial) { %>
                <a href="<%= ctx %>/AdminItemServlet?action=formCrear" class="btn-page-primary">
                    ➕ Añadir Material
                </a>
                <% } %>
            </div>

            <%-- ─── Mensaje de error si lo hay ─── --%>
            <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3">
                ❌ <%= error %>
            </div>
            <% } %>

            <%-- ──────────────────────────────────────────────────────────
                  BARRA DE BÚSQUEDA Y FILTROS
                 ────────────────────────────────────────────────────────── --%>
            <form action="<%= ctx %>/InventoryServlet" method="GET" class="search-bar">
                <input type="hidden" name="action" value="lista"/>

                <div class="search-input-wrap">
                    <span class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">🔍</span>
                    <input type="text" name="q"
                           value="<%= filtroTexto %>"
                           placeholder="Buscar materiales..."
                           class="input-icon"/>
                </div>

                <div class="flex gap-3">
                    <select name="tag" class="select-page w-auto">
                        <option value=""                              <%= filtroTag.isEmpty()              ? "selected" : "" %>>Todas las Etiquetas</option>
                        <option value="Construcción" <%= "Construcción".equals(filtroTag) ? "selected" : "" %>>Construcción</option>
                        <option value="Acabados"     <%= "Acabados".equals(filtroTag)     ? "selected" : "" %>>Acabados</option>
                        <option value="Líquidos"     <%= "Líquidos".equals(filtroTag)     ? "selected" : "" %>>Líquidos</option>
                        <option value="Plomería"     <%= "Plomería".equals(filtroTag)     ? "selected" : "" %>>Plomería</option>
                    </select>

                    <select name="stock" class="select-page w-auto">
                        <option value=""             <%= filtroStock.isEmpty()      ? "selected" : "" %>>Todos los Stocks</option>
                        <option value="OK"           <%= "OK".equals(filtroStock)   ? "selected" : "" %>>OK (En Stock)</option>
                        <option value="LOW"          <%= "LOW".equals(filtroStock)  ? "selected" : "" %>>Bajo Stock</option>
                        <option value="UNAVAILABLE"  <%= "UNAVAILABLE".equals(filtroStock) ? "selected" : "" %>>Sin Stock</option>
                    </select>

                    <button type="submit" class="btn-page-primary">Filtrar</button>
                </div>
            </form>

            <%-- ══════════════════════════════════════════════════════════
                  VISTA CATÁLOGO (para Viewer / Member)
                 ══════════════════════════════════════════════════════════ --%>
            <% if (esCatalogo) { %>

            <% if (items == null || items.isEmpty()) { %>
            <div class="panel-form text-center py-12">
                <p class="text-gray-500">No hay materiales que coincidan con tu búsqueda.</p>
            </div>
            <% } else { %>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                <% for (Item item : items) { %>
                <div class="catalog-card">
                    <div class="catalog-card-img">
                        <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) { %>
                        <img src="<%= item.getImageUrl() %>"
                             alt="<%= item.getName() %>"
                             onerror="this.src='<%= ctx %>/img/placeholder.png'"/>
                        <% } else { %>
                        <div class="w-full h-full bg-gray-100 flex items-center justify-center text-4xl">
                            📦
                        </div>
                        <% } %>
                    </div>
                    <div class="catalog-card-body">
                        <div class="flex justify-between items-start mb-2">
                            <h3 class="catalog-card-title"><%= item.getName() %></h3>

                            <%
                                String s = item.getStatus();
                                String stockClass, stockTxt;
                                if ("OK".equals(s))                  { stockClass = "stock-ok";   stockTxt = "OK"; }
                                else if ("LOW".equals(s))            { stockClass = "stock-low";  stockTxt = "Bajo"; }
                                else if ("UNAVAILABLE".equals(s))    { stockClass = "stock-none"; stockTxt = "Sin Stock"; }
                                else                                 { stockClass = "stock-ok";   stockTxt = s; }
                            %>
                            <span class="<%= stockClass %>"><%= stockTxt %></span>
                        </div>
                        <p class="catalog-card-sku">
                            Stock: <%= item.getCachedQuantity() %> <%= item.getUnit() %>
                        </p>
                        <a href="<%= ctx %>/TransactionServlet?action=formCrear&itemId=<%= item.getId() %>"
                           class="catalog-card-btn">
                            ➕ Solicitar
                        </a>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

            <% } else { %>

            <%-- ══════════════════════════════════════════════════════════
                  VISTA TABLA (para Manager / Admin / SuperAdmin)
                 ══════════════════════════════════════════════════════════ --%>
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
                            <% if (esAdmin) { %>
                            <th class="th-center" style="width: 200px;">Acciones</th>
                            <% } %>
                        </tr>
                        </thead>
                        <tbody class="table-body">

                        <% if (items == null || items.isEmpty()) { %>
                        <tr>
                            <td colspan="<%= esAdmin ? 6 : 5 %>" class="py-10 text-center text-gray-400">
                                No hay materiales que coincidan con tu búsqueda.
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
                                         class="w-10 h-10 rounded-lg object-cover border border-gray-100"
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
                                    String st = item.getStatus();
                                    String badgeClass, badgeText;
                                    if ("OK".equals(st)) {
                                        badgeClass = "stock-ok";
                                        badgeText = "OK";
                                    } else if ("LOW".equals(st)) {
                                        badgeClass = "stock-low";
                                        badgeText = "Stock Bajo";
                                    } else if ("UNAVAILABLE".equals(st)) {
                                        badgeClass = "stock-none";
                                        badgeText = "Sin Stock";
                                    } else {
                                        badgeClass = "stock-ok";
                                        badgeText = st;
                                    }
                                %>
                                <span class="<%= badgeClass %>"><%= badgeText %></span>
                            </td>

                            <% if (esAdmin) { %>
                            <td class="td-center">
                                <div class="flex justify-center gap-2">
                                    <a href="<%= ctx %>/AdminItemServlet?action=formEditar&id=<%= item.getId() %>"
                                       class="border border-gray-200 hover:border-purple-200 hover:bg-purple-50 text-gray-600 hover:text-purple-700 px-3 py-1.5 rounded-xl text-xs font-medium transition-all">
                                        ✏️ Editar
                                    </a>

                                    <form action="<%= ctx %>/AdminItemServlet" method="POST"
                                          onsubmit="return confirm('¿Confirmas desactivar este material?');"
                                          style="display:inline;">
                                        <input type="hidden" name="action" value="desactivar"/>
                                        <input type="hidden" name="id" value="<%= item.getId() %>"/>
                                        <button type="submit"
                                                class="border border-red-200 hover:bg-red-50 text-red-600 hover:text-red-700 px-3 py-1.5 rounded-xl text-xs font-medium transition-all">
                                            🗑️ Desactivar
                                        </button>
                                    </form>
                                </div>
                            </td>
                            <% } %>
                        </tr>
                        <% } %>
                        <% } %>

                        </tbody>
                    </table>
                </div>

                <div class="panel-footer">
                    <p class="panel-count-text">
                        Mostrando <%= items != null ? items.size() : 0 %>
                        de <%= totalItems %> items
                    </p>
                </div>
            </div>

            <% } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

</body>
</html>