<%--
    ════════════════════════════════════════════════════════════════════
     request-form.jsp — Formulario para crear una nueva solicitud
    ════════════════════════════════════════════════════════════════════

     PROPÓSITO:
     Mostrar un formulario donde el usuario elige un material y la
     cantidad que necesita. Al enviarlo, se hace POST al TransactionServlet
     con action=crear, que crea la solicitud en la BD.

     ¿DE DÓNDE SACAN LOS DATOS?
     - "items" → lista de materiales que envió TransactionServlet (formCrear)
     - "itemPreseleccionado" (opcional) → ID del item a pre-seleccionar
       (cuando vienen desde el catálogo con ?itemId=X)
     - session → nombre del usuario logueado

     CONVERTIDO DESDE:
     request-form.html original (con fetch + JS). La validación de auth
     ahora la hace SessionFilter. La carga de materiales y el envío del
     formulario van por TransactionServlet, no por /api/.
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();

    // Lista de materiales que mandó el servlet
    List<Item> items = (List<Item>) request.getAttribute("items");

    // ID preseleccionado (si vino desde el catálogo)
    Integer itemPreseleccionado = (Integer) request.getAttribute("itemPreseleccionado");

    // Datos del usuario logueado (desde la sesión)
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");
    if (userName == null) userName = "Usuario";
    if (userEmail == null) userEmail = "";

    // Mensajes de feedback (por query string después de un POST fallido)
    String error = request.getParameter("error");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Nueva Solicitud | Quinta Ola</title>
    <%-- Ruta CORRECTA del CSS (era /src/style.css, ahora /css/style.css) --%>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>

<body class="page-body">

    <%-- Navbar reutilizable (sustituye al QO.navbar() del JS viejo) --%>
    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main-narrow">

        <%-- ─── CABECERA ─── --%>
        <div class="page-header">
            <div>
                <h1 class="page-title">Nueva Solicitud</h1>
                <p class="page-subtitle">Pide los materiales que necesitas para tu proyecto.</p>
            </div>
            <%-- Botón Volver: link directo en vez de JS history.back() --%>
            <a href="<%= ctx %>/HomeServlet" class="btn-ghost">
                ← Volver
            </a>
        </div>

        <%-- ─── MENSAJE DE ERROR (si lo hay) ─── --%>
        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 mb-4">
                ❌ <%= error %>
            </div>
        <% } %>

        <%-- ─── FORMULARIO ─── --%>
        <%-- form action= apunta al TransactionServlet con action=crear --%>
        <%-- method=POST porque crea recursos en la BD --%>
        <div class="panel-form">
            <form action="<%= ctx %>/TransactionServlet" method="POST" class="space-y-6">

                <%-- Hidden con la acción que ejecutará el switch del servlet --%>
                <input type="hidden" name="action" value="crear"/>

                <%-- ─── Info del solicitante (informativo, viene de la sesión) ─── --%>
                <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 flex items-center gap-3">
                    <span class="text-2xl">👤</span>
                    <div>
                        <p class="text-xs text-blue-600 font-bold uppercase tracking-wider text-left">
                            Solicitante
                        </p>
                        <p class="text-sm font-semibold text-blue-800 text-left">
                            <%= userName %>
                            <% if (!userEmail.isEmpty()) { %>
                                (<%= userEmail %>)
                            <% } %>
                        </p>
                    </div>
                </div>

                <%-- ─── Material (select con todos los items de la BD) ─── --%>
                <div>
                    <label for="itemId" class="form-label text-left block">Material *</label>
                    <select id="itemId" name="itemId" class="select-page" required>
                        <option value="" disabled <%= itemPreseleccionado == null ? "selected" : "" %>>
                            Selecciona un material...
                        </option>
                        <%-- Iterar lista de items (Clase 7.2 slide 54) --%>
                        <% if (items != null) { %>
                            <% for (Item it : items) { %>
                                <%-- Solo mostrar items que NO estén UNAVAILABLE --%>
                                <% if (!"UNAVAILABLE".equals(it.getStatus())) { %>
                                    <option value="<%= it.getId() %>"
                                            <%= (itemPreseleccionado != null && itemPreseleccionado == it.getId()) ? "selected" : "" %>>
                                        <%= it.getName() %>
                                        — Disponible: <%= it.getCachedQuantity() %>
                                        <%= it.getUnit() != null ? it.getUnit() : "" %>
                                    </option>
                                <% } %>
                            <% } %>
                        <% } %>
                    </select>
                </div>

                <%-- ─── Cantidad y Fecha ─── --%>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label for="cantidad" class="form-label text-left block">Cantidad *</label>
                        <input type="number" id="cantidad" name="cantidad"
                               min="1" value="1" class="input-page" required/>
                    </div>
                    <div>
                        <label for="needed-by" class="form-label text-left block">
                            ¿Para cuándo lo necesitas?
                        </label>
                        <input type="date" id="needed-by" name="neededBy"
                               class="input-page"/>
                        <p class="text-[11px] text-gray-400 mt-1 text-left">
                            Opcional. Esta fecha ayuda a priorizar.
                        </p>
                    </div>
                </div>

                <%-- ─── Propósito (notas) ─── --%>
                <div>
                    <label for="notas" class="form-label text-left block">
                        Propósito / Uso del material *
                    </label>
                    <textarea id="notas" name="notas" rows="4" class="textarea-page"
                              placeholder="Describe para qué necesitas este material..."
                              required></textarea>
                </div>

                <hr class="border-gray-100"/>

                <%-- ─── Botones ─── --%>
                <div class="flex justify-end gap-3 pt-2">
                    <a href="<%= ctx %>/HomeServlet" class="btn-ghost">
                        Cancelar
                    </a>
                    <button type="submit" class="btn-page-primary">
                        📤 Enviar Solicitud
                    </button>
                </div>

            </form>
        </div>
    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>