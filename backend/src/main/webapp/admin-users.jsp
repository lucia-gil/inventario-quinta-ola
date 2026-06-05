<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();

    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    Integer userIdSession = (Integer) session.getAttribute("userId");

    if (roleIdSession == null || roleIdSession < 4) {
        response.sendRedirect(ctx + "/HomeServlet");
        return;
    }

    List<User> usuarios = (List<User>) request.getAttribute("usuarios");

    // Mensajes (atributos forward + params)
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    String mensajeExito = (String) request.getAttribute("mensajeExito");
    String errorAttr = (String) request.getAttribute("error");

    request.setAttribute("activeMenu", "members");
%>
<%!
    private String getInitials(String name) {
        if (name == null || name.trim().isEmpty()) return "U";
        String[] words = name.trim().split("\\s+");
        if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
        return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
    }

    private String renderRoleBadge(int roleId) {
        switch (roleId) {
            case 5:
                return "<span class=\"role-pill role-pill-blue\">Superadministrador(a)</span>";
            case 4:
                return "<span class=\"role-pill role-pill-purple\">Administrador(a)</span>";
            case 3:
                return "<span class=\"role-pill role-pill-yellow\">Aprobador(a)</span>";
            case 2:
                return "<span class=\"role-pill role-pill-green\">Encargado(a) Depósito</span>";
            case 1:
            default:
                return "<span class=\"role-pill role-pill-pink\">Solicitante</span>";
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Administrar Miembros | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=10" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        .alert {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            padding: 0.9rem 1.1rem;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 600;
            margin-bottom: 1rem;
            border: 1px solid;
        }
        .alert-success { background: var(--green-bg); color: var(--green-dark); border-color: #BBF7D0; }
        .alert-error   { background: var(--red-bg);   color: var(--red-dark);   border-color: #FECACA; }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }

        .user-cell { display: flex; align-items: center; gap: 0.75rem; }
        .user-cell-avatar {
            width: 36px; height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%);
            color: var(--white);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.78rem; font-weight: 700;
            flex-shrink: 0;
        }
        .user-cell-name {
            font-weight: 700; color: var(--gray-800); font-size: 0.9rem;
        }

        .role-pill {
            display: inline-block;
            padding: 0.3rem 0.75rem;
            border-radius: var(--radius-full);
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.2px;
        }
        .role-pill-pink   { background: var(--pink-bg);   color: var(--pink); }
        .role-pill-green  { background: var(--green-bg);  color: var(--green-dark); }
        .role-pill-yellow { background: var(--yellow-bg); color: var(--orange-dark); }
        .role-pill-purple { background: var(--purple-bg); color: var(--purple); }
        .role-pill-blue   { background: var(--blue-bg);   color: var(--blue-dark); }

        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.3rem 0.75rem;
            border-radius: var(--radius-full);
            font-size: 0.72rem;
            font-weight: 700;
        }
        .status-pill i { width: 12px; height: 12px; }
        .status-pill-active  { background: var(--green-bg); color: var(--green-dark); }
        .status-pill-pending { background: var(--red-bg);   color: var(--red-dark); }

        .change-role-form {
            display: inline-flex;
            gap: 0.4rem;
            align-items: center;
        }

        .change-role-select {
            padding: 0.4rem 0.7rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            font-size: 0.8rem;
            color: var(--gray-700);
            background: var(--gray-50);
            font-family: inherit;
            cursor: pointer;
            outline: none;
            transition: all var(--transition);
            min-width: 130px;
        }
        .change-role-select:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }
        .change-role-select:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .btn-change-role {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            background: var(--pink);
            color: var(--white);
            padding: 0.45rem 0.8rem;
            border-radius: var(--radius-sm);
            border: none;
            font-size: 0.75rem;
            font-weight: 700;
            cursor: pointer;
            transition: all var(--transition);
        }
        .btn-change-role:hover {
            background: var(--purple);
            transform: translateY(-1px);
        }
        .btn-change-role:disabled {
            background: var(--gray-300);
            cursor: not-allowed;
            transform: none;
        }
        .btn-change-role i { width: 12px; height: 12px; }

        .pending-actions {
            display: flex;
            gap: 0.4rem;
            align-items: center;
        }

        .btn-approve, .btn-reject {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.45rem 0.8rem;
            border-radius: var(--radius-sm);
            border: none;
            font-size: 0.75rem;
            font-weight: 700;
            cursor: pointer;
            transition: all var(--transition);
        }
        .btn-approve {
            background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%);
            color: var(--white);
        }
        .btn-approve:hover { transform: translateY(-1px); box-shadow: 0 3px 10px rgba(34, 197, 94, 0.3); }
        .btn-reject {
            background: var(--white);
            color: var(--red-dark);
            border: 1.5px solid #FECACA;
        }
        .btn-reject:hover { background: var(--red); color: var(--white); border-color: var(--red); }
        .btn-approve i, .btn-reject i { width: 12px; height: 12px; }

        .self-tag {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.4rem 0.85rem;
            background: var(--purple-bg);
            color: var(--purple);
            border-radius: var(--radius-full);
            font-size: 0.72rem;
            font-weight: 700;
        }
        .self-tag i { width: 12px; height: 12px; }

        .blocked-tag {
            color: var(--gray-400);
            font-size: 0.78rem;
            font-style: italic;
        }

        .date-cell {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            font-family: 'Courier New', monospace;
            font-size: 0.78rem;
            color: var(--gray-600);
        }
        .date-cell i { width: 13px; height: 13px; color: var(--gray-400); }
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
                        <i data-lucide="users" style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        Administrar Miembros
                    </h1>
                    <p class="page-subtitle">Control de acceso y gestión de usuarios del sistema.</p>
                </div>
                <a href="<%= ctx %>/UserServlet?action=formCrear" class="btn-page-primary btn-icon">
                    <i data-lucide="user-plus"></i>
                    Agregar Miembro
                </a>
            </div>

            <%-- Alertas --%>
            <% if (mensajeExito != null) { %>
            <div class="alert alert-success">
                <i data-lucide="check-circle"></i>
                <span><%= mensajeExito %></span>
            </div>
            <% } %>
            <% if (successParam != null) { %>
            <div class="alert alert-success">
                <i data-lucide="check-circle"></i>
                <span><%= successParam %></span>
            </div>
            <% } %>
            <% if (errorAttr != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= errorAttr %></span>
            </div>
            <% } %>
            <% if (errorParam != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= errorParam %></span>
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
                            <th class="th-center">Estado</th>
                            <th class="th-center">Nivel Actual</th>
                            <th class="th-center" style="width: 280px;">Acciones</th>
                        </tr>
                        </thead>
                        <tbody class="table-body">
                        <% if (usuarios == null || usuarios.isEmpty()) { %>
                        <tr>
                            <td colspan="6" class="py-10 text-center text-gray-400">
                                No hay usuarios registrados.
                            </td>
                        </tr>
                        <% } else {
                            for (User u : usuarios) {
                                boolean isSelf       = (userIdSession != null && userIdSession == u.getId());
                                boolean isSuperAdmin = (u.getRoleId() == 5);
                                boolean isAdminRow   = (u.getRoleId() == 4);
                                boolean isPending    = (u.getActivo() == 0);

                                // Admin no puede tocar a otros Admin ni a SuperAdmin
                                boolean adminBloqueado = (roleIdSession == 4 && (isAdminRow || isSuperAdmin));
                                boolean cannotEdit     = isSelf || isSuperAdmin || adminBloqueado;
                        %>
                        <tr class="table-row">
                            <td class="td">
                                <div class="user-cell">
                                    <div class="user-cell-avatar"><%= getInitials(u.getName()) %></div>
                                    <span class="user-cell-name">
                                            <%= u.getName() != null ? u.getName() : "Sin Nombre" %>
                                        </span>
                                </div>
                            </td>

                            <td class="td-light"><%= u.getEmail() != null ? u.getEmail() : "—" %></td>

                            <td class="td">
                                    <span class="date-cell">
                                        <i data-lucide="clock"></i>
                                        <%= u.getCreatedAt() != null ? u.getCreatedAt() : "—" %>
                                    </span>
                            </td>

                            <td class="td-center">
                                <% if (u.getActivo() == 1) { %>
                                <span class="status-pill status-pill-active">
                                            <i data-lucide="check"></i>
                                            Activo
                                        </span>
                                <% } else { %>
                                <span class="status-pill status-pill-pending">
                                            <i data-lucide="clock"></i>
                                            Pendiente
                                        </span>
                                <% } %>
                            </td>

                            <td class="td-center">
                                <%= renderRoleBadge(u.getRoleId()) %>
                            </td>

                            <td class="td-center">

                                <% if (isSelf) { %>
                                <%-- No puedes editar tu propio rol --%>
                                <span class="self-tag">
                                            <i data-lucide="user"></i>
                                            Tú
                                        </span>

                                <% } else if (isPending) { %>
                                <%-- Usuario pendiente: aprobar o rechazar --%>
                                <div class="pending-actions">
                                    <form action="<%= ctx %>/UserServlet" method="POST"
                                          onsubmit="return confirm('¿Aprobar a <%= u.getName() %>? Podrá iniciar sesión.');"
                                          style="margin:0;">
                                        <input type="hidden" name="action" value="approveUser"/>
                                        <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                                        <button type="submit" class="btn-approve">
                                            <i data-lucide="check"></i>
                                            Aprobar
                                        </button>
                                    </form>
                                    <form action="<%= ctx %>/UserServlet" method="POST"
                                          onsubmit="return confirm('¿Rechazar a <%= u.getName() %>? Esta acción quedará registrada.');"
                                          style="margin:0;">
                                        <input type="hidden" name="action" value="rejectUser"/>
                                        <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                                        <button type="submit" class="btn-reject">
                                            <i data-lucide="x"></i>
                                            Rechazar
                                        </button>
                                    </form>
                                </div>

                                <% } else if (cannotEdit) { %>
                                <%-- Admin viendo a otro Admin o SA --%>
                                <span class="blocked-tag">— Sin permisos —</span>

                                <% } else { %>
                                <%--
                                    Form completo: select + botón submit.
                                    Las opciones que ve cada rol:
                                    - SuperAdmin: 1, 2, 3, 4
                                    - Admin: solo 1, 2, 3
                                --%>
                                <form action="<%= ctx %>/UserServlet" method="POST"
                                      onsubmit="return confirm('¿Cambiar el rol de <%= u.getName() %>? Este cambio quedará registrado en la bitácora.');"
                                      class="change-role-form">

                                    <input type="hidden" name="action" value="cambiarRol"/>
                                    <input type="hidden" name="userId" value="<%= u.getId() %>"/>

                                    <select name="nuevoRolId" class="change-role-select">
                                        <option value="1" <%= u.getRoleId() == 1 ? "selected" : "" %>>Solicitante</option>
                                        <option value="2" <%= u.getRoleId() == 2 ? "selected" : "" %>>Encargado(a) Depósito</option>
                                        <option value="3" <%= u.getRoleId() == 3 ? "selected" : "" %>>Aprobador(a)</option>

                                        <% if (roleIdSession == 5) { %>
                                        <option value="4" <%= u.getRoleId() == 4 ? "selected" : "" %>>Administrador(a)</option>
                                        <% } %>
                                    </select>

                                    <button type="submit" class="btn-change-role">
                                        <i data-lucide="refresh-cw"></i>
                                        Cambiar
                                    </button>
                                </form>
                                <% } %>

                            </td>
                        </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>
                <div class="panel-footer">
                    <p class="panel-count-text">
                        <strong style="color: var(--gray-800);">
                            <%= usuarios != null ? usuarios.size() : 0 %>
                        </strong>
                        miembros registrados
                    </p>
                </div>
            </div>

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