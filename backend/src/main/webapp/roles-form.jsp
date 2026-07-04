<%--
    ============================================================
     roles-form.jsp — Formulario crear/editar rol
    ============================================================
     UN SOLO archivo sirve para los 2 casos:
     - modo = "crear"  -> form vacio
     - modo = "editar" -> form lleno con datos del rol
    ============================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.Role" %>
<%
    String ctx = request.getContextPath();
    String modo = (String) request.getAttribute("modo");
    Role rol = (Role) request.getAttribute("rol");

    String errParam = request.getParameter("error");

    boolean esEditar = "editar".equals(modo);
    String titulo = esEditar ? "Editar Rol" : "Crear Nuevo Rol";
    String actionSubmit = esEditar ? "editar" : "crear";

    // Valores precargados (en edicion) o vacios (en creacion)
    String nombreValor = rol != null ? rol.getName() : "";
    String descValor = rol != null && rol.getDescription() != null ? rol.getDescription() : "";
    int idValor = rol != null ? rol.getId() : 0;
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title><%= titulo %> | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>
<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <main class="page-main-narrow">

            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <%= esEditar ? "✏️" : "➕" %> <%= titulo %>
                    </h1>
                    <p class="page-subtitle">
                        <%= esEditar
                                ? "Modifica el nombre o descripción del rol"
                                : "Crea un nuevo rol personalizado para el sistema" %>
                    </p>
                </div>
                <a href="<%= ctx %>/RoleServlet" class="btn-ghost">
                    ← Volver
                </a>
            </div>

            <% if (errParam != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 mb-4">
                ❌ <%= errParam %>
            </div>
            <% } %>

            <%-- Formulario --%>
            <div class="panel-form">
                <form action="<%= ctx %>/RoleServlet" method="POST" class="space-y-6">

                    <input type="hidden" name="action" value="<%= actionSubmit %>"/>

                    <%-- Si es editar, mandar el id --%>
                    <% if (esEditar) { %>
                    <input type="hidden" name="id" value="<%= idValor %>"/>
                    <% } %>

                    <%-- Campo nombre --%>
                    <div>
                        <label class="form-label text-left block">
                            Nombre del Rol *
                        </label>
                        <input type="text" name="name"
                               value="<%= nombreValor %>"
                               class="input-page"
                               placeholder="Ej: Visitante, Auditor Externo, Practicante..."
                               required
                               maxlength="50"/>
                        <p class="text-[11px] text-gray-400 mt-1 text-left">
                            Nombre único que identifica el rol (máx. 50 caracteres)
                        </p>
                    </div>

                    <%-- Campo descripcion --%>
                    <div>
                        <label class="form-label text-left block">
                            Descripción
                        </label>
                        <textarea name="description"
                                  class="textarea-page"
                                  rows="3"
                                  placeholder="Describe brevemente las responsabilidades de este rol..."
                                  maxlength="255"><%= descValor %></textarea>
                        <p class="text-[11px] text-gray-400 mt-1 text-left">
                            Opcional. Aparecerá en el listado de roles.
                        </p>
                    </div>

                    <hr class="border-gray-100"/>

                    <%-- Botones --%>
                    <div class="flex justify-end gap-3 pt-2">
                        <a href="<%= ctx %>/RoleServlet" class="btn-ghost">
                            Cancelar
                        </a>
                        <button type="submit" class="btn-page-primary">
                            <%= esEditar ? "💾 Guardar Cambios" : "➕ Crear Rol" %>
                        </button>
                    </div>

                </form>
            </div>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

</body>
</html>
