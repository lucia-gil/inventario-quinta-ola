<%--
    ============================================================
     roles-list.jsp
    ============================================================
     Vista de Gestion de Roles para SuperAdmin.
     Muestra los 5 roles del sistema y debajo de cada uno
     despliega los usuarios que pertenecen a ese rol con
     un select para poder cambiarles el rol al vuelo.

     Recibe del RoleServlet:
     - "roles" (List<Role>): los 5 roles del sistema
     - "usuariosPorRol" (Map<Integer, List<User>>): mapa donde
       la clave es el roleId y el valor es la lista de usuarios
       de ese rol.
    ============================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.quintaola.model.Role" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    Map<Integer, List<User>> usuariosPorRol = (Map<Integer, List<User>>) request.getAttribute("usuariosPorRol");

    String success = request.getParameter("success");
    String errParam = request.getParameter("error");
    String error = (String) request.getAttribute("error");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>Gestión de Roles | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>
<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <main class="page-main">

            <%-- Cabecera --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">🛡️ Gestión de Roles</h1>
                    <p class="page-subtitle">
                        Los 5 roles del sistema y los usuarios asignados a cada uno
                    </p>
                </div>
                <a href="<%= ctx %>/UserServlet?action=formCrear" class="btn-page-primary">
                    ➕ Crear Usuario
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

            <%-- Info --%>
            <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 flex items-start gap-3">
                <span class="text-2xl">ℹ️</span>
                <div>
                    <p class="text-sm font-semibold text-blue-800">Cómo funciona</p>
                    <p class="text-sm text-blue-700 mt-1">
                        Los 5 roles son fijos del sistema. Para cambiar el rol de un usuario,
                        usa el desplegable junto a su nombre. Para registrar un usuario nuevo,
                        click en <strong>"Crear Usuario"</strong>.
                    </p>
                </div>
            </div>

            <%-- Cards de cada rol con sus usuarios desplegados --%>
            <% if (roles != null) {
                for (Role rol : roles) {
                    List<User> usuariosDelRol = usuariosPorRol.get(rol.getId());
            %>

            <div class="panel">

                <%-- Header del rol --%>
                <div class="panel-header" style="background: linear-gradient(to right, #fdf2f8, #ffffff);">
                    <div>
                        <h2 class="panel-header-title">
                            Rol #<%= rol.getId() %>: <%= rol.getName() %>
                        </h2>
                        <p class="panel-header-sub">
                            <%= rol.getDescription() != null ? rol.getDescription() : "" %>
                        </p>
                    </div>
                    <div style="background: #ec4899; color: white; padding: 4px 12px; border-radius: 12px; font-size: 0.85rem; font-weight: 700;">
                        <%= rol.getUserCount() %> usuario<%= rol.getUserCount() != 1 ? "s" : "" %>
                    </div>
                </div>

                <%-- Tabla de usuarios de este rol --%>
                <% if (usuariosDelRol == null || usuariosDelRol.isEmpty()) { %>
                <div class="p-6 text-center text-gray-400 text-sm">
                    Aún no hay usuarios con este rol.
                </div>
                <% } else { %>
                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th">Nombre</th>
                            <th class="th">Email</th>
                            <th class="th">DNI</th>
                            <th class="th">Cambiar Rol</th>
                        </tr>
                        </thead>
                        <tbody class="table-body">
                        <% for (User u : usuariosDelRol) { %>
                        <tr class="table-row">
                            <td class="td font-semibold text-gray-800">
                                <%= u.getName() %>
                            </td>
                            <td class="td text-gray-600 text-sm">
                                <%= u.getEmail() %>
                            </td>
                            <td class="td-light font-mono">
                                <%= u.getDni() != null ? u.getDni() : "—" %>
                            </td>
                            <td class="td">
                                <%-- Form inline para cambiar rol --%>
                                <%-- El select tiene onchange que envia el form al vuelo --%>
                                <form action="<%= ctx %>/UserServlet" method="POST"
                                      onsubmit="return confirm('¿Cambiar el rol de <%= u.getName() %>?');"
                                      style="display: inline-flex; gap: 0.5rem; align-items: center;">
                                    <input type="hidden" name="action" value="cambiarRol"/>
                                    <input type="hidden" name="userId" value="<%= u.getId() %>"/>

                                    <select name="nuevoRolId"
                                            style="padding: 0.4rem 0.6rem; border: 1px solid #e5e7eb; border-radius: 6px; font-size: 0.85rem;">
                                        <% for (Role r : roles) { %>
                                        <option value="<%= r.getId() %>"
                                                <%= r.getId() == u.getRoleId() ? "selected" : "" %>>
                                            <%= r.getName() %>
                                        </option>
                                        <% } %>
                                    </select>

                                    <button type="submit"
                                            style="background: #ec4899; color: white; padding: 0.4rem 0.8rem; border-radius: 6px; border: none; font-size: 0.8rem; font-weight: 600; cursor: pointer;">
                                        Cambiar
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>

            </div>

            <% }
            } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

</body>
</html>