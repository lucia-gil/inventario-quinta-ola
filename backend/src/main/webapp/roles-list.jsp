<%--
    ════════════════════════════════════════════════════════════════════
     roles-list.jsp — Gestión de Roles (SuperAdmin)
    ════════════════════════════════════════════════════════════════════
     Esta vista es el panel de control del SuperAdmin sobre los roles
     del sistema. Aquí NO hay aprobar/rechazar (eso vive en
     admin-users.jsp para el flujo de signup externo).

     Acciones por estado:
       Activo       → Cambiar rol + Desactivar cuenta
       Pendiente    → Cambiar rol + Desactivar cuenta
       Desactivado  → Reactivar
       Es él mismo  → Tag "Tú"
       Otro SA      → Solo Cambiar rol
    ════════════════════════════════════════════════════════════════════
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
    Map<Integer, String> inactiveStatus = (Map<Integer, String>) request.getAttribute("inactiveStatus");

    Integer userIdSession = (Integer) session.getAttribute("userId");

    String success = request.getParameter("success");
    String errParam = request.getParameter("error");
    String error = (String) request.getAttribute("error");

    request.setAttribute("activeMenu", "roles");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Gestión de Roles | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=10" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        .info-banner {
            display: flex;
            gap: 0.85rem;
            align-items: flex-start;
            background: linear-gradient(135deg, var(--blue-bg) 0%, var(--purple-bg) 100%);
            border: 1px solid #BAE6FD;
            border-radius: var(--radius-md);
            padding: 1rem 1.25rem;
        }
        .info-banner-icon {
            display: flex; align-items: center; justify-content: center;
            width: 36px; height: 36px;
            border-radius: var(--radius-sm);
            background: var(--blue); color: var(--white);
            flex-shrink: 0;
        }
        .info-banner-icon i { width: 18px; height: 18px; }
        .info-banner-title {
            font-size: 0.88rem; font-weight: 700;
            color: var(--blue-dark); margin-bottom: 0.25rem;
        }
        .info-banner-text {
            font-size: 0.82rem; color: var(--gray-700); line-height: 1.55;
        }
        .info-banner-text strong { color: var(--purple); }

        .role-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            margin-bottom: 1.5rem;
        }
        .role-card-header {
            display: flex; align-items: center; justify-content: space-between;
            gap: 1rem;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
        }
        .role-card-header.role-1 { background: linear-gradient(to right, var(--pink-bg), var(--white)); }
        .role-card-header.role-2 { background: linear-gradient(to right, var(--green-bg), var(--white)); }
        .role-card-header.role-3 { background: linear-gradient(to right, var(--yellow-bg), var(--white)); }
        .role-card-header.role-4 { background: linear-gradient(to right, var(--purple-bg), var(--white)); }
        .role-card-header.role-5 { background: linear-gradient(to right, var(--blue-bg),    var(--white)); }

        .role-header-info { display: flex; align-items: center; gap: 0.85rem; }
        .role-header-icon {
            display: flex; align-items: center; justify-content: center;
            width: 42px; height: 42px;
            border-radius: var(--radius-sm);
            background: var(--white); box-shadow: var(--shadow-sm);
            flex-shrink: 0;
        }
        .role-header-icon i { width: 20px; height: 20px; }
        .role-header-icon.role-1 i { color: var(--pink); }
        .role-header-icon.role-2 i { color: var(--green-dark); }
        .role-header-icon.role-3 i { color: var(--orange-dark); }
        .role-header-icon.role-4 i { color: var(--purple); }
        .role-header-icon.role-5 i { color: var(--blue-dark); }

        .role-header-text h2 {
            font-size: 1rem; font-weight: 800;
            color: var(--gray-800); margin: 0;
        }
        .role-header-text p {
            font-size: 0.78rem; color: var(--gray-500);
            margin: 0.15rem 0 0 0; font-weight: 500;
        }
        .role-count-badge {
            display: inline-flex; align-items: center; gap: 0.4rem;
            padding: 0.4rem 0.85rem;
            border-radius: var(--radius-full);
            background: var(--purple); color: var(--white);
            font-size: 0.78rem; font-weight: 700;
        }
        .role-count-badge i { width: 14px; height: 14px; }
        .role-card-body { padding: 0; }

        .empty-row {
            padding: 2rem; text-align: center;
            color: var(--gray-400); font-size: 0.88rem;
            font-style: italic;
        }

        .row-deactivated {
            opacity: 0.55;
            background: var(--gray-50);
        }
        .row-deactivated .user-cell-name { text-decoration: line-through; }

        .status-pill {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.3rem 0.75rem;
            border-radius: var(--radius-full);
            font-size: 0.72rem; font-weight: 700;
            white-space: nowrap;
        }
        .status-pill i { width: 12px; height: 12px; }
        .status-pill-active      { background: var(--green-bg);  color: var(--green-dark); }
        .status-pill-pending     { background: var(--yellow-bg); color: var(--orange-dark); }
        .status-pill-deactivated { background: var(--gray-200);  color: var(--gray-700); }

        .actions-stack {
            display: flex;
            gap: 0.4rem;
            min-width: 200px;
        }

        .change-role-form {
            display: inline-flex;
            gap: 0.4rem;
            align-items: center;
            justify-content: flex-start;
        }
        .change-role-select {
            padding: 0.4rem 0.7rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            color: var(--gray-700);
            background: var(--gray-50);
            font-family: inherit;
            cursor: pointer; outline: none;
            transition: all var(--transition);
            min-width: 130px;
        }
        .change-role-select:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }

        .btn-action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.35rem;
            padding: 0.45rem 0.85rem;
            border-radius: var(--radius-sm);
            border: 1px solid transparent;
            font-size: 0.75rem; font-weight: 700;
            cursor: pointer;
            transition: all var(--transition);
            font-family: inherit;
        }
        .btn-change-role {
            background: var(--pink);
            color: var(--white);
            border-color: var(--pink);
        }
        .btn-change-role:hover {
            background: var(--purple);
            border-color: var(--purple);
            transform: translateY(-1px);
        }
        .btn-change-role i { width: 13px; height: 13px; }

        .btn-deactivate {
            background: var(--white);
            color: var(--red-dark);
            border-color: #FECACA;
        }
        .btn-deactivate:hover {
            background: var(--red);
            color: var(--white);
            border-color: var(--red);
        }
        .btn-deactivate i { width: 13px; height: 13px; }

        .btn-reactivate {
            background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%);
            color: var(--white);
            border-color: transparent;
        }
        .btn-reactivate:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(34, 197, 94, 0.3);
        }
        .btn-reactivate i { width: 13px; height: 13px; }

        .self-tag {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.4rem 0.85rem;
            background: var(--purple-bg);
            color: var(--purple);
            border-radius: var(--radius-full);
            font-size: 0.72rem; font-weight: 700;
        }
        .self-tag i { width: 12px; height: 12px; }

        .user-cell {
            display: flex; align-items: center; gap: 0.7rem;
        }
        .user-cell-avatar {
            width: 32px; height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%);
            color: var(--white);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.75rem; font-weight: 700;
            flex-shrink: 0;
        }
        .user-cell-name {
            font-weight: 700; color: var(--gray-800);
            font-size: 0.88rem;
        }

        .alert {
            display: flex; align-items: center; gap: 0.6rem;
            padding: 0.9rem 1.1rem;
            border-radius: var(--radius-sm);
            font-size: 0.88rem; font-weight: 600;
            margin-bottom: 1.25rem;
            border: 1px solid;
        }
        .alert-error   { background: var(--red-bg);   color: var(--red-dark);   border-color: #FECACA; }
        .alert-success { background: var(--green-bg); color: var(--green-dark); border-color: #BBF7D0; }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }
    </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="key-round" style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        Gestión de Roles
                    </h1>
                    <p class="page-subtitle">
                        Los 5 roles del sistema y los usuarios asignados a cada uno
                    </p>
                </div>
                <a href="<%= ctx %>/UserServlet?action=formCrear" class="btn-page-primary btn-icon">
                    <i data-lucide="user-plus"></i>
                    Crear Usuario
                </a>
            </div>

            <%-- Alertas --%>
            <% if (success != null) { %>
            <div class="alert alert-success">
                <i data-lucide="check-circle"></i>
                <span><%= success %></span>
            </div>
            <% } %>
            <% if (errParam != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= errParam %></span>
            </div>
            <% } %>
            <% if (error != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <%-- Info banner --%>
            <div class="info-banner">
                <div class="info-banner-icon">
                    <i data-lucide="info"></i>
                </div>
                <div>
                    <p class="info-banner-title">Cómo funciona</p>
                    <p class="info-banner-text">
                        Los <strong>5 roles del sistema</strong> son fijos según el modelo del cliente.
                        Desde aquí puedes cambiar el rol o desactivar/reactivar cuentas. Cada acción
                        queda en la <strong>bitácora de auditoría</strong>.
                    </p>
                </div>
            </div>

            <%-- Cards de cada rol --%>
            <% if (roles != null) {
                for (Role rol : roles) {
                    List<User> usuariosDelRol = usuariosPorRol.get(rol.getId());
                    int roleColorId = rol.getId();

                    String iconName = "circle";
                    switch (rol.getId()) {
                        case 1: iconName = "user"; break;
                        case 2: iconName = "truck"; break;
                        case 3: iconName = "check-square"; break;
                        case 4: iconName = "shield"; break;
                        case 5: iconName = "shield-check"; break;
                    }
            %>

            <div class="role-card">

                <div class="role-card-header role-<%= roleColorId %>">
                    <div class="role-header-info">
                        <div class="role-header-icon role-<%= roleColorId %>">
                            <i data-lucide="<%= iconName %>"></i>
                        </div>
                        <div class="role-header-text">
                            <h2><%= rol.getName() %></h2>
                            <p><%= rol.getDescription() != null ? rol.getDescription() : "" %></p>
                        </div>
                    </div>

                    <div class="role-count-badge">
                        <i data-lucide="users"></i>
                        <%= rol.getUserCount() %> usuario<%= rol.getUserCount() != 1 ? "s" : "" %>
                    </div>
                </div>

                <div class="role-card-body">

                    <% if (usuariosDelRol == null || usuariosDelRol.isEmpty()) { %>
                    <div class="empty-row">
                        Aún no hay usuarios con este rol.
                    </div>
                    <% } else { %>
                    <div class="table-wrapper">
                        <table class="table">
                            <thead class="table-head">
                            <tr>
                                <th class="th">Usuario</th>
                                <th class="th">Email</th>
                                <th class="th">DNI</th>
                                <th class="th-center">Estado</th>
                                <th class="th-center" style="min-width: 240px;">Acciones</th>
                            </tr>
                            </thead>
                            <tbody class="table-body">

                            <% for (User u : usuariosDelRol) {
                                boolean isSelf       = (userIdSession != null && userIdSession == u.getId());
                                boolean isSuperAdminRow = (u.getRoleId() == 5);
                                boolean isInactive   = (u.getActivo() == 0);

                                String inactiveType = null;
                                if (isInactive && inactiveStatus != null) {
                                    inactiveType = inactiveStatus.get(u.getId());
                                }
                                boolean isDeactivated = "DEACTIVATED".equals(inactiveType);
                                boolean isPending = isInactive && !isDeactivated;

                                String ini = "U";
                                if (u.getName() != null && !u.getName().trim().isEmpty()) {
                                    String[] partes = u.getName().trim().split("\\s+");
                                    if (partes.length >= 2) {
                                        ini = (partes[0].charAt(0) + "" + partes[1].charAt(0)).toUpperCase();
                                    } else if (partes[0].length() >= 2) {
                                        ini = partes[0].substring(0, 2).toUpperCase();
                                    }
                                }
                            %>

                            <tr class="table-row <%= isDeactivated ? "row-deactivated" : "" %>">

                                <td class="td">
                                    <div class="user-cell">
                                        <div class="user-cell-avatar"><%= ini %></div>
                                        <span class="user-cell-name"><%= u.getName() %></span>
                                    </div>
                                </td>

                                <td class="td-light"><%= u.getEmail() %></td>

                                <td class="td-light" style="font-family: 'Courier New', monospace;">
                                    <%= u.getDni() != null ? u.getDni() : "—" %>
                                </td>

                                <td class="td-center">
                                    <% if (u.getActivo() == 1) { %>
                                    <span class="status-pill status-pill-active">
                                            <i data-lucide="check"></i>
                                            Activo
                                        </span>
                                    <% } else if (isDeactivated) { %>
                                    <span class="status-pill status-pill-deactivated">
                                            <i data-lucide="ban"></i>
                                            Desactivado
                                        </span>
                                    <% } else { %>
                                    <span class="status-pill status-pill-pending">
                                            <i data-lucide="clock"></i>
                                            Pendiente
                                        </span>
                                    <% } %>
                                </td>

                                <td class="td-center">

                                    <% if (isSelf) { %>

                                    <%-- Soy yo: no me puedo tocar --%>
                                    <span class="self-tag">
                                            <i data-lucide="user"></i>
                                            Tú
                                        </span>

                                    <% } else if (isDeactivated) { %>

                                    <%-- Usuario desactivado: solo reactivar --%>
                                    <% if (!isSuperAdminRow) { %>
                                    <form action="<%= ctx %>/UserServlet" method="POST"
                                          onsubmit="return confirm('¿Reactivar a <%= u.getName() %>? Podrá iniciar sesión nuevamente.');"
                                          style="margin:0;">
                                        <input type="hidden" name="action" value="reactivarUsuario"/>
                                        <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                                        <input type="hidden" name="redirectTo" value="roles"/>
                                        <button type="submit" class="btn-action btn-reactivate">
                                            <i data-lucide="rotate-ccw"></i>
                                            Reactivar
                                        </button>
                                    </form>
                                    <% } %>

                                    <% } else { %>

                                    <%--
                                        Estados Activo o Pendiente:
                                        siempre mostramos cambio de rol + desactivar
                                        (excepto desactivar a otro SuperAdmin)
                                    --%>
                                    <div class="actions-stack">

                                        <form action="<%= ctx %>/UserServlet"
                                              method="POST"
                                              onsubmit="return confirm('¿Cambiar el rol de <%= u.getName() %>? Quedará en la bitácora.');"
                                              class="change-role-form">

                                            <input type="hidden" name="action" value="cambiarRol"/>
                                            <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                                            <input type="hidden" name="redirectTo" value="roles"/>

                                            <select name="nuevoRolId" class="change-role-select">
                                                <% for (Role r : roles) { %>
                                                <option value="<%= r.getId() %>"
                                                        <%= r.getId() == u.getRoleId() ? "selected" : "" %>>
                                                    <%= r.getName() %>
                                                </option>
                                                <% } %>
                                            </select>

                                            <button type="submit" class="btn-action btn-change-role">
                                                <i data-lucide="refresh-cw"></i>
                                                Cambiar
                                            </button>
                                        </form>

                                        <% if (!isSuperAdminRow) { %>
                                        <form action="<%= ctx %>/UserServlet" method="POST"
                                              onsubmit="return confirm('¿Desactivar la cuenta de <%= u.getName() %>?\n\nEl usuario no podrá iniciar sesión. Su historial y aprobaciones se conservarán. Esta acción quedará en la bitácora.');"
                                              style="margin:0;">
                                            <input type="hidden" name="action" value="desactivarUsuario"/>
                                            <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                                            <input type="hidden" name="redirectTo" value="roles"/>
                                            <button type="submit" class="btn-action btn-deactivate">
                                                <i data-lucide="ban"></i>
                                                Desactivar cuenta
                                            </button>
                                        </form>
                                        <% } %>

                                    </div>
                                    <% } %>

                                </td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>

                </div>

            </div>

            <% }
            } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });
</script>
</body>
</html>