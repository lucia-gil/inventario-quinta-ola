<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();

    // Seguridad: Solo Admin (4) y SuperAdmin (5)
    Integer roleIdSession = (Integer) session.getAttribute("roleId");
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

    // Método auxiliar para dibujar el badge del rol (adaptado de tu ui.js)
    private String renderRoleBadge(int roleId, String roleName) {
        if (roleName == null) roleName = "Desconocido";
        String label = roleName;
        String extraClass = "";

        switch (roleId) {
            case 5: // SuperAdmin
                return "<span class=\"role-admin\" style=\"background:#f3e8ff; color:#7c3aed; border: 1px solid #e9d5ff; padding: 2px 8px; border-radius: 9999px; font-size: 0.75rem; font-weight: 600;\">" + label + "</span>";
            case 4: // Administrador
                return "<span class=\"role-admin\">" + label + "</span>";
            case 3: // Manager (Aprobador)
                return "<span class=\"role-manager\">Aprobador</span>";
            case 2: // Member (Depósito)
                return "<span class=\"role-manager\" style=\"background-color:#fffbeb; color:#d97706; border-color:#fef3c7;\">Encargado</span>";
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

<jsp:include page="includes/navbar.jsp"/>

<main class="page-main">

    <div class="page-header">
        <div>
            <h1 class="page-title">Administrar Miembros</h1>
            <p class="page-subtitle">Control de acceso y gestión de usuarios del sistema.</p>
        </div>
        <%-- El botón de registro te envía al AuthServlet (si lo tienes configurado, o dejalo pendiente si no) --%>
        <a href="<%= ctx %>/AuthServlet?action=formSignup" class="btn-page-primary">
            <i data-lucide="user-plus" class="w-4 h-4"></i> Agregar Miembro
        </a>
    </div>

    <div class="table-panel">
        <div class="table-wrapper">
            <table class="table">
                <thead class="table-head">
                <tr>
                    <th class="th">Miembro</th>
                    <th class="th">Correo Electrónico</th>
                    <th class="th">Fecha de Creación</th>
                    <th class="th">Nivel Actual</th>
                    <th class="th">Cambiar Nivel</th>
                </tr>
                </thead>
                <tbody id="users-tbody" class="table-body">
                <% if (usuarios == null || usuarios.isEmpty()) { %>
                <tr>
                    <td colspan="5" class="py-10 text-center text-gray-400">
                        No hay usuarios registrados.
                    </td>
                </tr>
                <% } else { %>
                <% for (User u : usuarios) { %>
                <tr class="table-row">
                    <td class="td">
                        <div class="flex items-center gap-3">
                            <%-- Avatar (Si no tiene, genera las iniciales con fondo gris) --%>
                            <div class="w-9 h-9 rounded-full bg-gray-100 text-gray-600 flex items-center justify-center text-xs font-bold border border-gray-200">
                                <%= getInitials(u.getName()) %>
                            </div>

                            <%-- Como todavía no tenemos ProfileServlet por ID, quitamos el link temporalmente --%>
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
                    <td class="td">
                        <%= renderRoleBadge(u.getRoleId(), "Rol " + u.getRoleId()) %>
                    </td>
                    <td class="td">
                        <%-- Deshabilitar el select si es el propio usuario o si es SuperAdmin --%>
                        <select class="select-table"
                                <%= (u.getRoleId() == 5 || u.getId() == (Integer)session.getAttribute("userId")) ? "disabled style=\"opacity:0.5;\"" : "" %>>

                            <option value="4" <%= u.getRoleId() == 4 ? "selected" : "" %>>Administrador</option>
                            <option value="3" <%= u.getRoleId() == 3 ? "selected" : "" %>>Aprobador</option>
                            <option value="2" <%= u.getRoleId() == 2 ? "selected" : "" %>>Depósito</option>
                            <option value="1" <%= u.getRoleId() == 1 ? "selected" : "" %>>Solicitante</option>
                        </select>
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

</body>
</html>