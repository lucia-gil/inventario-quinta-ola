<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();

    // 1. Seguridad: Solo Administrador (4) y SuperAdmin (5) pueden gestionar el catálogo
    Integer roleId = (Integer) session.getAttribute("roleId");
    if (roleId == null || (roleId != 4 && roleId != 5)) {
        response.sendRedirect(ctx + "/DashboardServlet");
        return;
    }

    // 2. Detectar si es Creación o Edición
    // El AdminItemServlet enviará un objeto "item" si estamos editando
    Item item = (Item) request.getAttribute("item");
    boolean isEditMode = (item != null);

    // 3. Textos dinámicos de la interfaz
    String pageTitle    = isEditMode ? "Editar Material Existente" : "Añadir Nuevo Material";
    String pageSubtitle = isEditMode
            ? "Modifica los parámetros del material en la base de datos."
            : "Registra un nuevo material en el sistema de inventario.";
    String btnText      = isEditMode ? "Actualizar Cambios" : "Guardar Material";
    String actionType   = isEditMode ? "actualizar" : "crear";
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= pageTitle %> | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
</head>

<body class="page-body">

<jsp:include page="includes/navbar.jsp"/>

<main class="page-main-narrow">

    <div class="page-header">
        <div>
            <h1 class="page-title"><%= pageTitle %></h1>
            <p class="page-subtitle"><%= pageSubtitle %></p>
        </div>
        <a href="<%= ctx %>/InventoryServlet" class="btn-ghost">
            <i data-lucide="arrow-left" class="w-4 h-4"></i> Volver
        </a>
    </div>

    <div class="panel-form">
        <%-- El formulario ahora apunta a tu Servlet mediante POST --%>
        <form action="<%= ctx %>/AdminItemServlet" method="POST" class="space-y-6">

            <input type="hidden" name="action" value="<%= actionType %>" />
            <% if (isEditMode) { %>
            <input type="hidden" name="id" value="<%= item.getId() %>" />
            <% } %>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label for="nombre" class="form-label">Nombre del Material</label>
                    <input type="text" id="nombre" name="nombre" class="input-page"
                           placeholder="Ej. Kit de Ayuda Humanitaria" required
                           value="<%= isEditMode && item.getName() != null ? item.getName() : "" %>">
                </div>
                <div>
                    <label for="tags" class="form-label">Etiqueta (Categoría)</label>
                    <select id="tags" name="tags" class="select-page" required>
                        <option value="" <%= !isEditMode ? "selected" : "" %> disabled>Seleccionar etiqueta...</option>
                        <option value="Construcción" <%= isEditMode && "Construcción".equals(item.getCategory()) ? "selected" : "" %>>Construcción</option>
                        <option value="Acabados" <%= isEditMode && "Acabados".equals(item.getCategory()) ? "selected" : "" %>>Acabados</option>
                        <option value="Líquidos" <%= isEditMode && "Líquidos".equals(item.getCategory()) ? "selected" : "" %>>Líquidos</option>
                        <option value="Plomería" <%= isEditMode && "Plomería".equals(item.getCategory()) ? "selected" : "" %>>Plomería</option>
                    </select>
                </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                    <label for="stock" class="form-label">Stock Inicial</label>
                    <input type="number" id="stock" name="stock" min="0"
                           class="input-page" placeholder="0"
                           value="<%= isEditMode ? item.getCachedQuantity() : "" %>"
                        <%= isEditMode ? "readonly title=\"El stock físico se altera mediante transacciones formalizadas.\"" : "required" %>>
                </div>
                <div>
                    <label for="unidad" class="form-label">Unidad</label>
                    <select id="unidad" name="unidad" class="select-page" required>
                        <option value="" <%= !isEditMode ? "selected" : "" %> disabled>Seleccionar...</option>
                        <option value="unidades" <%= isEditMode && "unidades".equals(item.getUnit()) ? "selected" : "" %>>Unidades</option>
                        <option value="cajas" <%= isEditMode && "cajas".equals(item.getUnit()) ? "selected" : "" %>>Cajas</option>
                        <option value="bolsas" <%= isEditMode && "bolsas".equals(item.getUnit()) ? "selected" : "" %>>Bolsas</option>
                        <option value="kits" <%= isEditMode && "kits".equals(item.getUnit()) ? "selected" : "" %>>Kits</option>
                        <option value="galones" <%= isEditMode && "galones".equals(item.getUnit()) ? "selected" : "" %>>Galones</option>
                        <option value="metros" <%= isEditMode && "metros".equals(item.getUnit()) ? "selected" : "" %>>Metros</option>
                    </select>
                </div>
                <div>
                    <label for="minimo" class="form-label">Stock Mínimo</label>
                    <input type="number" id="minimo" name="minimo" min="0"
                           class="input-page" placeholder="0" required
                           value="<%= isEditMode ? item.getMinQuantity() : "" %>">
                </div>
            </div>

            <div>
                <label for="imagen" class="form-label">URL de la Imagen</label>
                <div class="relative">
                    <i data-lucide="image" class="input-icon-left"></i>
                    <input type="url" id="imagen" name="imagen" class="input-icon"
                           placeholder="https://ejemplo.com/imagen.jpg"
                           value="<%= isEditMode && item.getImageUrl() != null ? item.getImageUrl() : "" %>">
                </div>
            </div>

            <div>
                <label for="descripcion" class="form-label">Descripción (Opcional)</label>
                <textarea id="descripcion" name="descripcion" rows="3"
                          class="textarea-page"
                          placeholder="Detalles adicionales sobre el material..."><%= isEditMode && item.getDescription() != null ? item.getDescription() : "" %></textarea>
            </div>

            <hr class="border-gray-100">

            <div class="flex justify-end gap-3 pt-2">
                <a href="<%= ctx %>/InventoryServlet" class="btn-ghost">Cancelar</a>
                <button type="submit" class="btn-page-primary">
                    <i data-lucide="save" class="w-4 h-4"></i> <%= btnText %>
                </button>
            </div>

        </form>
    </div>
</main>

<script>
    lucide.createIcons();
</script>

<jsp:include page="includes/footer.jsp"/>

</body>
</html>
