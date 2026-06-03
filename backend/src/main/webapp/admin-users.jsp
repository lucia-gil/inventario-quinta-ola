<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();

    // Seguridad: Solo Admin (4) y SuperAdmin (5)
    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    Integer userIdSession = (Integer) session.getAttribute("userId"); // <-- Agregado para saber quién es el usuario actual

    if (roleIdSession == null || roleIdSession < 4) {
        response.sendRedirect(ctx + "/HomeServlet");
        return;
    }

    List<User> usuarios = (List<User>) request.getAttribute("usuarios");
%>
<%!
    // Método auxiliar para obtener iniciales para el avatar
    private String getInitials(String name) {
        if (name == null || name.trim().isEmpty()) return "U";
        String[] words = name.trim().split("\\s+");
        if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
        return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
    }

    // Metodo auxiliar para dibujar el badge del rol
    private String renderRoleBadge(int roleId, String roleName) {
        switch (roleId) {
            case 5: // SuperAdmin
                return "<span class=\"role-admin\" style=\"background:#f3e8ff; color:#7c3aed; border: 1px solid #e9d5ff; padding: 2px 8px; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;\">Superadministrador(a)</span>";
            case 4: // Administrador
                return "<span class=\"role-admin\">Administrador(a)</span>";
            case 3: // Manager (Aprobador)
                return "<span class=\"role-manager\">Aprobador(a)</span>";
            case 2: // Member (Depósito)
                return "<span class=\"role-manager\" style=\"background-color:#fffbeb; color:#d97706; border-color:#fef3c7;\">Encargado(a)</span>";
            case 1: // Viewer (Solicitante)
            default:
                return "<span class=\"role-viewer\">Solicitante</span>";
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Administrar Miembros | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <main class="page-main" style="padding: 2rem;">

            <div class="page-header">
                <div>
                    <h1 class="page-title">Administrar Miembros</h1>
                    <p class="page-subtitle">Control de acceso y gestión de usuarios del sistema.</p>
                </div>
                <a href="<%= ctx %>/UserServlet?action=formCrear" class="btn-page-primary">
                    <i data-lucide="user-plus" class="w-4 h-4"></i> Agregar Miembro
                </a>
            </div>

            <%-- Mensajes de éxito/error al aprobar --%>
            <% if (request.getAttribute("mensajeExito") != null) { %>
            <div class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded mb-4 text-sm">
                <%= request.getAttribute("mensajeExito") %>
            </div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-4 text-sm">
                <%= request.getAttribute("error") %>
            </div>
            <% } %>

            <div class="table-panel">
                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th">Miembro</th>
                            <th class="th">Correo Electrónico</th>
                            <th class="th">Fecha de Creación</th>
                            <th class="th">Estado</th> <%-- 🛡️ NUEVA COLUMNA ESTADO --%>
                            <th class="th">Nivel Actual</th>
                            <th class="th">Acciones</th> <%-- Cambiado de "Cambiar Nivel" a "Acciones" --%>
                        </tr>
                        </thead>
                        <tbody id="users-tbody" class="table-body">
                        <% if (usuarios == null || usuarios.isEmpty()) { %>
                        <tr>
                            <td colspan="6" class="py-10 text-center text-gray-400">
                                No hay usuarios registrados.
                            </td>
                        </tr>
                        <% } else { %>
                        <% for (User u : usuarios) {
                            boolean isSelf = (userIdSession != null && userIdSession == u.getId());
                            boolean isSuperAdmin = (u.getRoleId() == 5);
                            boolean isAdminEditingAdmin = (roleIdSession == 4 && u.getRoleId() >= 4);

                            boolean isDisabled = isSelf || isSuperAdmin || isAdminEditingAdmin;
                        %>
                        <tr class="table-row">
                            <td class="td">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-gray-100 text-gray-600 flex items-center justify-center text-xs font-bold border border-gray-200">
                                        <%= getInitials(u.getName()) %>
                                    </div>

                                    <span class="font-semibold text-gray-800">
                                        <%= u.getName() != null ? u.getName() : "Sin Nombre" %>
                                    </span>
                                </div>
                            </td>
                            <td class="td-muted">
                                <%= u.getEmail() != null ? u.getEmail() : "—" %>
                            </td>
                            <td class="td-light">
                                <div class="flex items-center gap-1.5">
                                    <i data-lucide="clock" class="w-3.5 h-3.5 text-gray-400"></i>
                                    <%= u.getCreatedAt() != null ? u.getCreatedAt() : "—" %>
                                </div>
                            </td>

                            <%-- 🛡️ NUEVA CELDA: ESTADO --%>
                            <td class="td">
                                <% if (u.getActivo() == 1) { %>
                                <span style="background-color:#dcfce7; color:#166534; padding: 2px 8px; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">Activo</span>
                                <% } else { %>
                                <span style="background-color:#fee2e2; color:#991b1b; padding: 2px 8px; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;">Pendiente</span>
                                <% } %>
                            </td>

                            <td class="td">
                                <%= renderRoleBadge(u.getRoleId(), "Rol " + u.getRoleId()) %>
                            </td>

                            <%-- 🛡️ CELDA ACCIONES: SELECT DE ROL O BOTÓN APROBAR --%>
                            <td class="td">
                                <% if (u.getActivo() == 0) { %>
                                <%-- Formulario para aprobar usuario --%>
                                <form action="<%= ctx %>/UserServlet" method="POST" style="margin: 0;">
                                    <input type="hidden" name="action" value="approveUser">
                                    <input type="hidden" name="userId" value="<%= u.getId() %>">
                                    <button type="submit" class="bg-pink-500 hover:bg-pink-600 text-white font-medium py-1 px-3 rounded-lg text-sm transition-colors flex items-center gap-1">
                                        <i data-lucide="check-circle" class="w-4 h-4"></i> Aprobar
                                    </button>
                                </form>
                                <% } else { %>
                                <%-- SELECT DINÁMICO (Si ya está activo) --%>
                                <select class="select-table"
                                        <%= isDisabled ? "disabled style=\"opacity:0.5;\"" : "" %>>

                                    <% if (roleIdSession == 5) { %>
                                    <option value="4" <%= u.getRoleId() == 4 ? "selected" : "" %>>Administrador</option>
                                    <% } %>

                                    <option value="3" <%= u.getRoleId() == 3 ? "selected" : "" %>>Aprobador</option>
                                    <option value="2" <%= u.getRoleId() == 2 ? "selected" : "" %>>Depósito</option>
                                    <option value="1" <%= u.getRoleId() == 1 ? "selected" : "" %>>Solicitante</option>
                                </select>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <div class="panel-footer">
                    <p class="panel-count-text" id="users-count">
                        Mostrando <%= usuarios != null ? usuarios.size() : 0 %> miembros registrados
                    </p>
                </div>
            </div>

        </main>

        <script>
            lucide.createIcons();
        </script>

        <jsp:include page="includes/footer.jsp"/>

    </div> <%-- Fin de main-content --%>
</div> <%-- Fin de layout-wrapper --%>

</body>
</html>