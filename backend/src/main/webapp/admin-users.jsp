<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();

    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    Integer userIdSession = (Integer) session.getAttribute("userId");

    if (roleIdSession == null || roleIdSession < 4) {
        response.sendRedirect(ctx + "/HomeServlet");
        return;
    }

    boolean esSuperAdmin = (roleIdSession == 5);

    List<User> usuarios      = (List<User>) request.getAttribute("usuarios");
    Map<Integer, String> inactiveStatus = (Map<Integer, String>) request.getAttribute("inactiveStatus");

    String successParam = request.getParameter("success");
    String errorParam   = request.getParameter("error");
    String mensajeExito = (String) request.getAttribute("mensajeExito");
    String errorAttr    = (String) request.getAttribute("error");

    String _search    = request.getAttribute("searchQ")  != null ? (String)  request.getAttribute("searchQ")  : "";
    int    _rolFilter = request.getAttribute("rolFilter") != null ? (Integer) request.getAttribute("rolFilter") : 0;

    Integer _cp    = (Integer) request.getAttribute("currentPage");
    Integer _tp    = (Integer) request.getAttribute("totalPages");
    Integer _tc    = (Integer) request.getAttribute("totalCount");
    int _page  = (_cp != null) ? _cp : 1;
    int _total = (_tp != null) ? _tp : 1;
    int _count = (_tc != null) ? _tc : (usuarios != null ? usuarios.size() : 0);
    int _size  = 15;
    int _from  = (_count == 0) ? 0 : (_page - 1) * _size + 1;
    int _to    = Math.min(_page * _size, _count);
    int _winS  = Math.max(1, _page - 2);
    int _winE  = Math.min(_total, _page + 2);

    String _qEncoded = "";
    try {
        if (!_search.isEmpty())
            _qEncoded = "&q=" + java.net.URLEncoder.encode(_search, "UTF-8");
    } catch (Exception ignored) {}
    String _pUrl = ctx + "/UserServlet?action=lista"
            + _qEncoded
            + (_rolFilter > 0 ? "&rol=" + _rolFilter : "");

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
            case 5: return "<span class=\"role-pill role-pill-blue\">Superadministrador(a)</span>";
            case 4: return "<span class=\"role-pill role-pill-purple\">Administrador(a)</span>";
            case 3: return "<span class=\"role-pill role-pill-yellow\">Aprobador(a)</span>";
            case 2: return "<span class=\"role-pill role-pill-green\">Encargado(a) Depósito</span>";
            default: return "<span class=\"role-pill role-pill-pink\">Solicitante</span>";
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Administrar Miembros | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=25" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ── Alertas ──────────────────────────────────────────────────────── */
        .alert {
            display: flex; align-items: center; gap: 0.6rem;
            padding: 0.9rem 1.1rem;
            border-radius: var(--radius-sm);
            font-size: 0.88rem; font-weight: 600;
            margin-bottom: 1rem; border: 1px solid;
        }
        .alert-success { background: var(--green-bg); color: var(--green-dark); border-color: #BBF7D0; }
        .alert-error   { background: var(--red-bg);   color: var(--red-dark);   border-color: #FECACA; }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }

        .filter-active-chip {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.22rem 0.65rem; background: var(--purple-bg); color: var(--purple);
            border-radius: var(--radius-full); font-size: 0.73rem; font-weight: 700;
        }
        .filter-active-chip i { width: 11px; height: 11px; }

        /* ── Celda de usuario ─────────────────────────────────────────────── */
        .user-cell { display: flex; align-items: center; gap: 0.7rem; }
        .user-cell-avatar-wrap { width: 36px; height: 36px; flex-shrink: 0; }
        .user-cell-avatar-photo {
            width: 36px; height: 36px; border-radius: 50%;
            object-fit: cover; border: 2px solid var(--purple-light); display: block;
        }
        .user-cell-avatar {
            width: 36px; height: 36px; border-radius: 50%;
            background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%);
            color: var(--white); display: flex; align-items: center; justify-content: center;
            font-size: 0.78rem; font-weight: 700;
        }
        .user-cell-name { font-weight: 700; color: var(--gray-800); font-size: 0.88rem; }

        /* ── Fila desactivada ─────────────────────────────────────────────── */
        .row-deactivated { opacity: 0.55; background: var(--gray-50); }
        .row-deactivated .user-cell-name { text-decoration: line-through; }

        /* ── Role pills ───────────────────────────────────────────────────── */
        .role-pill {
            display: inline-block; padding: 0.28rem 0.65rem;
            border-radius: var(--radius-full);
            font-size: 0.7rem; font-weight: 700; letter-spacing: 0.2px; white-space: nowrap;
        }
        .role-pill-pink   { background: var(--pink-bg);   color: var(--pink); }
        .role-pill-green  { background: var(--green-bg);  color: var(--green-dark); }
        .role-pill-yellow { background: var(--yellow-bg); color: var(--orange-dark); }
        .role-pill-purple { background: var(--purple-bg); color: var(--purple); }
        .role-pill-blue   { background: var(--blue-bg);   color: var(--blue-dark); }

        /* ── Status pills ─────────────────────────────────────────────────── */
        .status-pill {
            display: inline-flex; align-items: center; gap: 0.28rem;
            padding: 0.28rem 0.65rem; border-radius: var(--radius-full);
            font-size: 0.7rem; font-weight: 700; white-space: nowrap;
        }
        .status-pill i { width: 11px; height: 11px; }
        .status-pill-active      { background: var(--green-bg);  color: var(--green-dark); }
        .status-pill-pending     { background: var(--yellow-bg); color: var(--orange-dark); }
        .status-pill-deactivated { background: var(--gray-200);  color: var(--gray-700); }

        /* ── Celda DNI ────────────────────────────────────────────────────── */
        .dni-cell { font-size: 0.82rem; color: var(--gray-600); }

        /* ── Acciones ─────────────────────────────────────────────────────── */
        .change-role-form   { display: inline-flex; gap: 0.3rem; align-items: center; }
        .change-role-select {
            padding: 0.35rem 0.45rem; border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm); font-size: 0.74rem; color: var(--gray-700);
            background: var(--gray-50); font-family: inherit; cursor: pointer; outline: none;
            transition: all var(--transition); min-width: 95px; max-width: 120px;
        }
        .change-role-select:focus { border-color: var(--purple); background: var(--white); box-shadow: 0 0 0 3px rgba(91,31,168,0.1); }
        .actions-stack { display: flex; gap: 0.3rem; align-items: center; }
        .btn-action {
            display: inline-flex; align-items: center; justify-content: center;
            gap: 0.22rem; padding: 0.36rem 0.6rem;
            border-radius: var(--radius-sm); border: 1px solid transparent;
            font-size: 0.71rem; font-weight: 700;
            cursor: pointer; transition: all var(--transition); font-family: inherit;
            text-decoration: none;
        }
        .btn-change-role { background: var(--pink); color: var(--white); }
        .btn-change-role:hover { background: var(--purple); transform: translateY(-1px); }
        .btn-change-role i { width: 11px; height: 11px; }
        .btn-deactivate {
            background: var(--white); color: var(--red-dark);
            border-color: #FECACA; padding: 0.36rem 0.48rem;
        }
        .btn-deactivate:hover { background: var(--red); color: var(--white); border-color: var(--red); }
        .btn-deactivate i { width: 13px; height: 13px; }
        .btn-reactivate {
            background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%);
            color: var(--white);
        }
        .btn-reactivate:hover { transform: translateY(-1px); box-shadow: 0 3px 10px rgba(34,197,94,0.3); }
        .btn-reactivate i { width: 11px; height: 11px; }
        .pending-actions { display: flex; gap: 0.3rem; align-items: center; justify-content: center; }
        .btn-approve, .btn-reject {
            display: inline-flex; align-items: center; gap: 0.22rem;
            padding: 0.36rem 0.6rem; border-radius: var(--radius-sm); border: none;
            font-size: 0.71rem; font-weight: 700;
            cursor: pointer; transition: all var(--transition); font-family: inherit;
            text-decoration: none;
        }
        .btn-approve { background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%); color: var(--white); }
        .btn-approve:hover { transform: translateY(-1px); box-shadow: 0 3px 10px rgba(34,197,94,0.3); }
        .btn-reject { background: var(--white); color: var(--red-dark); border: 1.5px solid #FECACA; }
        .btn-reject:hover { background: var(--red); color: var(--white); border-color: var(--red); }
        .btn-approve i, .btn-reject i { width: 11px; height: 11px; }
        .self-tag {
            display: inline-flex; align-items: center; gap: 0.28rem;
            padding: 0.34rem 0.75rem; background: var(--purple-bg); color: var(--purple);
            border-radius: var(--radius-full); font-size: 0.7rem; font-weight: 700;
        }
        .self-tag i { width: 11px; height: 11px; }
        .blocked-tag { color: var(--gray-400); font-size: 0.75rem; font-style: italic; }

        /* ── Estado vacío ─────────────────────────────────────────────────── */
        .empty-search {
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            padding: 2.5rem 1rem; gap: 0.6rem; color: var(--gray-400);
        }
        .empty-search i { width: 36px; height: 36px; opacity: 0.4; }
        .empty-search p { font-size: 0.88rem; margin: 0; }
        .empty-search strong { color: var(--gray-600); }

        /* Paginación: ver componente global ".pager" en style.css */

        /* ── Modales CSS-only ─────────────────────────────────────────────── */
        .modal-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(17, 5, 35, 0.58);
            backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px);
            z-index: 9000;
            align-items: center; justify-content: center;
            padding: 1rem;
        }
        .modal-overlay:target { display: flex; }
        .modal-box {
            background: var(--white); border-radius: 18px;
            box-shadow: 0 24px 64px rgba(0,0,0,0.22), 0 4px 16px rgba(109,40,217,0.10);
            padding: 2rem 1.75rem 1.6rem;
            max-width: 400px; width: 100%; text-align: center;
            animation: modal-pop 0.2s cubic-bezier(.34,1.56,.64,1) both;
        }
        @keyframes modal-pop {
            from { opacity: 0; transform: scale(0.92) translateY(12px); }
            to   { opacity: 1; transform: scale(1) translateY(0); }
        }
        .modal-icon {
            width: 58px; height: 58px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 1.1rem;
        }
        .modal-icon i { width: 26px; height: 26px; }
        .modal-icon--green  { background: var(--green-bg); }
        .modal-icon--green i { color: var(--green-dark); }
        .modal-icon--red    { background: var(--red-bg); }
        .modal-icon--red i  { color: var(--red-dark); }
        .modal-icon--purple { background: var(--purple-bg); }
        .modal-icon--purple i { color: var(--purple); }
        .modal-title { font-size: 1.08rem; font-weight: 800; color: var(--gray-800); margin: 0 0 0.45rem; }
        .modal-name { color: var(--purple); }
        .modal-desc { font-size: 0.83rem; color: var(--gray-500); line-height: 1.65; margin: 0 0 1.5rem; }
        .modal-btns { display: flex; gap: 0.65rem; }
        .btn-modal-cancel {
            flex: 1;
            display: inline-flex; align-items: center; justify-content: center;
            padding: 0.62rem 0.75rem;
            background: var(--white); color: var(--gray-600);
            border: 1.5px solid var(--gray-200); border-radius: var(--radius-sm);
            font-size: 0.84rem; font-weight: 600; text-decoration: none;
            transition: all var(--transition);
        }
        .btn-modal-cancel:hover { border-color: var(--gray-400); color: var(--gray-800); }
        .modal-form { flex: 1; display: flex; }
        .btn-modal-ok {
            flex: 1; width: 100%;
            display: inline-flex; align-items: center; justify-content: center; gap: 0.3rem;
            padding: 0.62rem 0.75rem; border: none; border-radius: var(--radius-sm);
            font-size: 0.84rem; font-weight: 700; cursor: pointer; font-family: inherit;
            transition: all var(--transition);
        }
        .btn-modal-ok i { width: 13px; height: 13px; }
        .btn-modal-ok--green  { background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%); color: var(--white); }
        .btn-modal-ok--green:hover  { box-shadow: 0 4px 14px rgba(34,197,94,0.4); transform: translateY(-1px); }
        .btn-modal-ok--red    { background: linear-gradient(135deg, #f87171 0%, #dc2626 100%); color: var(--white); }
        .btn-modal-ok--red:hover    { box-shadow: 0 4px 14px rgba(220,38,38,0.4); transform: translateY(-1px); }
        .btn-modal-ok--purple { background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%); color: var(--white); }
        .btn-modal-ok--purple:hover { box-shadow: 0 4px 14px rgba(91,31,168,0.4); transform: translateY(-1px); }
    </style>
</head>

<body class="page-body">
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <a id="modal-cerrar" style="display:block;height:0;overflow:hidden;"></a>

            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="users" style="display:inline-block;width:24px;height:24px;vertical-align:middle;margin-right:8px;color:var(--purple);"></i>
                        Administrar Miembros
                    </h1>
                    <p class="page-subtitle">Control de acceso y gestión de usuarios del sistema.</p>
                </div>
                <a href="<%= ctx %>/UserServlet?action=formCrear" class="btn-page-primary btn-icon">
                    <i data-lucide="user-plus"></i>
                    Agregar Miembro
                </a>
            </div>

            <% if (mensajeExito != null) { %><div class="alert alert-success"><i data-lucide="check-circle"></i><span><%= mensajeExito %></span></div><% } %>
            <% if (successParam != null) { %><div class="alert alert-success"><i data-lucide="check-circle"></i><span><%= successParam %></span></div><% } %>
            <% if (errorAttr   != null) { %><div class="alert alert-error"  ><i data-lucide="alert-circle"></i><span><%= errorAttr %></span></div><% } %>
            <% if (errorParam  != null) { %><div class="alert alert-error"  ><i data-lucide="alert-circle"></i><span><%= errorParam %></span></div><% } %>

            <%-- FILTROS --%>
            <form method="GET" action="<%= ctx %>/UserServlet" class="filter-bar">
                <input type="hidden" name="action" value="lista"/>
                <input type="hidden" name="page"   value="1"/>

                <div class="filter-search">
                    <i data-lucide="search"></i>
                    <input type="text" name="q" value="<%= _search %>"
                           placeholder="Buscar por nombre o apellido..." autocomplete="off"/>
                </div>

                <div class="filter-actions">
                    <select name="rol" class="filter-select">
                        <option value="0" <%= _rolFilter==0?"selected":"" %>>Todos los roles</option>
                        <option value="1" <%= _rolFilter==1?"selected":"" %>>Solicitante</option>
                        <option value="2" <%= _rolFilter==2?"selected":"" %>>Enc. Depósito</option>
                        <option value="3" <%= _rolFilter==3?"selected":"" %>>Aprobador(a)</option>
                        <option value="4" <%= _rolFilter==4?"selected":"" %>>Administrador(a)</option>
                        <option value="5" <%= _rolFilter==5?"selected":"" %>>Superadministrador(a)</option>
                    </select>

                    <button type="submit" class="btn-page-primary btn-icon">
                        <i data-lucide="filter"></i>
                        Filtrar
                    </button>

                    <% if (!_search.isEmpty() || _rolFilter > 0) { %>
                    <a href="<%= ctx %>/UserServlet?action=lista" class="btn-clear-filter">
                        <i data-lucide="x"></i>Limpiar
                    </a>
                    <% if (!_search.isEmpty()) { %>
                    <span class="filter-active-chip"><i data-lucide="text-cursor-input"></i>"<%= _search %>"</span>
                    <% } %>
                    <% } %>
                </div>
            </form>

            <div class="table-panel">

                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th">Miembro</th>
                            <th class="th" style="max-width:160px;">Correo Electrónico</th>
                            <th class="th">DNI</th>
                            <th class="th-center">Estado</th>
                            <th class="th-center">Nivel Actual</th>
                            <th class="th-center" style="width:220px;">Acciones</th>
                        </tr>
                        </thead>
                        <tbody class="table-body">

                        <% if (usuarios == null || usuarios.isEmpty()) { %>
                        <tr><td colspan="6">
                            <div class="empty-search">
                                <i data-lucide="search-x"></i>
                                <% if (!_search.isEmpty() || _rolFilter > 0) { %>
                                <p>Sin resultados para <% if (!_search.isEmpty()) { %><strong>"<%= _search %>"</strong><% } %><% if (_rolFilter > 0) { %> con el rol seleccionado<% } %></p>
                                <% } else { %>
                                <p>No hay usuarios registrados.</p>
                                <% } %>
                            </div>
                        </td></tr>

                        <% } else {
                            for (User u : usuarios) {
                                boolean isSelf          = (userIdSession != null && userIdSession == u.getId());
                                boolean isSuperAdminRow = (u.getRoleId() == 5);
                                boolean isAdminRow      = (u.getRoleId() == 4);
                                boolean isInactive      = (u.getActivo() == 0);
                                String inactiveType = null;
                                if (isInactive && inactiveStatus != null) inactiveType = inactiveStatus.get(u.getId());
                                boolean isDeactivated = "DEACTIVATED".equals(inactiveType);
                                boolean isPending     = isInactive && !isDeactivated;
                                boolean adminBloqueado = (roleIdSession == 4 && (isAdminRow || isSuperAdminRow));
                                boolean cannotEdit     = isSelf || isSuperAdminRow || adminBloqueado;
                                String memberAvatar = u.getAvatarUrl();
                        %>
                        <tr class="table-row <%= isDeactivated ? "row-deactivated" : "" %>">

                            <td class="td">
                                <div class="user-cell">
                                    <div class="user-cell-avatar-wrap">
                                        <% if (memberAvatar != null && !memberAvatar.trim().isEmpty()) { %>
                                        <img src="<%= ctx + memberAvatar %>" alt="<%= u.getName() %>"
                                             class="user-cell-avatar-photo"
                                             onerror="this.style.display='none';this.nextElementSibling.style.display='flex';"/>
                                        <div class="user-cell-avatar" style="display:none;"><%= getInitials(u.getName()) %></div>
                                        <% } else { %>
                                        <div class="user-cell-avatar"><%= getInitials(u.getName()) %></div>
                                        <% } %>
                                    </div>
                                    <span class="user-cell-name"><%= u.getName() != null ? u.getName() : "Sin Nombre" %></span>
                                </div>
                            </td>

                            <td class="td-light" style="max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:0.8rem;">
                                <%= u.getEmail() != null ? u.getEmail() : "—" %>
                            </td>

                            <td class="td"><span class="dni-cell"><%= u.getDni() != null ? u.getDni() : "—" %></span></td>

                            <td class="td-center">
                                <% if (u.getActivo() == 1) { %>
                                <span class="status-pill status-pill-active"><i data-lucide="check"></i>Activo</span>
                                <% } else if (isDeactivated) { %>
                                <span class="status-pill status-pill-deactivated"><i data-lucide="ban"></i>Desactivado</span>
                                <% } else { %>
                                <span class="status-pill status-pill-pending"><i data-lucide="clock"></i>Pendiente</span>
                                <% } %>
                            </td>

                            <td class="td-center"><%= renderRoleBadge(u.getRoleId()) %></td>

                            <td class="td-center">
                                <% if (isSelf) { %>
                                <span class="self-tag"><i data-lucide="user"></i>Tú</span>

                                <% } else if (isPending) { %>
                                <div class="pending-actions">
                                    <a href="#modal-aprobar-<%= u.getId() %>" class="btn-approve">
                                        <i data-lucide="check"></i>Aprobar
                                    </a>
                                    <a href="#modal-rechazar-<%= u.getId() %>" class="btn-reject">
                                        <i data-lucide="x"></i>Rechazar
                                    </a>
                                </div>

                                <% } else if (isDeactivated) { %>
                                <% if (esSuperAdmin && !isSuperAdminRow) { %>
                                <a href="#modal-reactivar-<%= u.getId() %>" class="btn-action btn-reactivate">
                                    <i data-lucide="rotate-ccw"></i>Reactivar
                                </a>
                                <% } else { %>
                                <span class="blocked-tag">— Desactivado —</span>
                                <% } %>

                                <% } else if (cannotEdit) { %>
                                <span class="blocked-tag">— Sin permisos —</span>

                                <% } else { %>
                                <div class="actions-stack">
                                    <form action="<%= ctx %>/UserServlet" method="POST" class="change-role-form">
                                        <input type="hidden" name="action" value="cambiarRol"/>
                                        <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                                        <select name="nuevoRolId" class="change-role-select">
                                            <option value="1" <%= u.getRoleId()==1?"selected":"" %>>Solicitante</option>
                                            <option value="2" <%= u.getRoleId()==2?"selected":"" %>>Enc. Depósito</option>
                                            <option value="3" <%= u.getRoleId()==3?"selected":"" %>>Aprobador(a)</option>
                                            <% if (esSuperAdmin) { %>
                                            <option value="4" <%= u.getRoleId()==4?"selected":"" %>>Administrador(a)</option>
                                            <% } %>
                                        </select>
                                        <button type="submit" class="btn-action btn-change-role">
                                            <i data-lucide="refresh-cw"></i>Cambiar
                                        </button>
                                    </form>
                                    <% if (esSuperAdmin && !isSuperAdminRow) { %>
                                    <a href="#modal-desactivar-<%= u.getId() %>"
                                       class="btn-action btn-deactivate"
                                       title="Desactivar cuenta de <%= u.getName() %>">
                                        <i data-lucide="ban"></i>
                                    </a>
                                    <% } %>
                                </div>
                                <% } %>
                            </td>
                        </tr>
                        <% } } %>
                        </tbody>
                    </table>
                </div>

                <div class="pager">
                    <div class="pager-info">
                        <span>Mostrando <strong><%= _from %>–<%= _to %></strong> de <strong><%= _count %></strong> miembros</span>
                        <span class="pager-info-badge"><i data-lucide="waves"></i> ≈ 15 por ola</span>
                    </div>
                    <% if (_total > 1) { %>
                    <div class="pager-nav">
                        <% if (_page > 1) { %><a href="<%= _pUrl %>&page=<%= _page-1 %>" class="pager-btn"><i data-lucide="chevron-left"></i></a>
                        <% } else { %><span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-left"></i></span><% } %>
                        <% if (_winS > 1) { %><a href="<%= _pUrl %>&page=1" class="pager-btn">1</a><% if (_winS > 2) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %><% } %>
                        <% for (int _p = _winS; _p <= _winE; _p++) { %>
                        <% if (_p == _page) { %><span class="pager-btn pager-btn--active"><%= _p %></span>
                        <% } else { %><a href="<%= _pUrl %>&page=<%= _p %>" class="pager-btn"><%= _p %></a><% } %>
                        <% } %>
                        <% if (_winE < _total) { %><% if (_winE < _total-1) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %><a href="<%= _pUrl %>&page=<%= _total %>" class="pager-btn"><%= _total %></a><% } %>
                        <% if (_page < _total) { %><a href="<%= _pUrl %>&page=<%= _page+1 %>" class="pager-btn"><i data-lucide="chevron-right"></i></a>
                        <% } else { %><span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-right"></i></span><% } %>
                    </div>
                    <% } %>
                </div>

            </div><%-- /table-panel --%>

            <%-- MODALES --%>
            <% if (usuarios != null) {
                for (User u : usuarios) {
                    boolean isSuperAdminRow2 = (u.getRoleId() == 5);
                    boolean isInactive2      = (u.getActivo() == 0);
                    String  inactiveType2    = null;
                    if (isInactive2 && inactiveStatus != null) inactiveType2 = inactiveStatus.get(u.getId());
                    boolean isDeactivated2   = "DEACTIVATED".equals(inactiveType2);
                    boolean isPending2       = isInactive2 && !isDeactivated2;
                    boolean isSelf2          = (userIdSession != null && userIdSession == u.getId());
            %>
            <% if (isPending2) { %>
            <div id="modal-aprobar-<%= u.getId() %>" class="modal-overlay">
                <div class="modal-box">
                    <div class="modal-icon modal-icon--green"><i data-lucide="user-check"></i></div>
                    <h3 class="modal-title">¿Aprobar acceso?</h3>
                    <p class="modal-desc"><strong class="modal-name"><%= u.getName() %></strong> podrá iniciar sesión en el sistema.</p>
                    <div class="modal-btns">
                        <a href="#modal-cerrar" class="btn-modal-cancel">Cancelar</a>
                        <form action="<%= ctx %>/UserServlet" method="POST" class="modal-form">
                            <input type="hidden" name="action" value="approveUser"/>
                            <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                            <button type="submit" class="btn-modal-ok btn-modal-ok--green"><i data-lucide="check"></i>Sí, aprobar</button>
                        </form>
                    </div>
                </div>
            </div>
            <div id="modal-rechazar-<%= u.getId() %>" class="modal-overlay">
                <div class="modal-box">
                    <div class="modal-icon modal-icon--red"><i data-lucide="user-x"></i></div>
                    <h3 class="modal-title">¿Rechazar solicitud?</h3>
                    <p class="modal-desc">Se rechazará el registro de <strong class="modal-name"><%= u.getName() %></strong>. Esta acción quedará registrada.</p>
                    <div class="modal-btns">
                        <a href="#modal-cerrar" class="btn-modal-cancel">Cancelar</a>
                        <form action="<%= ctx %>/UserServlet" method="POST" class="modal-form">
                            <input type="hidden" name="action" value="rejectUser"/>
                            <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                            <button type="submit" class="btn-modal-ok btn-modal-ok--red"><i data-lucide="x"></i>Sí, rechazar</button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
            <% if (isDeactivated2 && esSuperAdmin && !isSuperAdminRow2) { %>
            <div id="modal-reactivar-<%= u.getId() %>" class="modal-overlay">
                <div class="modal-box">
                    <div class="modal-icon modal-icon--purple"><i data-lucide="rotate-ccw"></i></div>
                    <h3 class="modal-title">¿Reactivar cuenta?</h3>
                    <p class="modal-desc"><strong class="modal-name"><%= u.getName() %></strong> podrá iniciar sesión nuevamente.</p>
                    <div class="modal-btns">
                        <a href="#modal-cerrar" class="btn-modal-cancel">Cancelar</a>
                        <form action="<%= ctx %>/UserServlet" method="POST" class="modal-form">
                            <input type="hidden" name="action" value="reactivarUsuario"/>
                            <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                            <button type="submit" class="btn-modal-ok btn-modal-ok--purple"><i data-lucide="rotate-ccw"></i>Sí, reactivar</button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
            <% if (!isDeactivated2 && !isSuperAdminRow2 && !isSelf2 && esSuperAdmin) { %>
            <div id="modal-desactivar-<%= u.getId() %>" class="modal-overlay">
                <div class="modal-box">
                    <div class="modal-icon modal-icon--red"><i data-lucide="ban"></i></div>
                    <h3 class="modal-title">¿Desactivar cuenta?</h3>
                    <p class="modal-desc"><strong class="modal-name"><%= u.getName() %></strong> no podrá iniciar sesión. Su historial y aprobaciones se conservarán. Esta acción quedará en la bitácora.</p>
                    <div class="modal-btns">
                        <a href="#modal-cerrar" class="btn-modal-cancel">Cancelar</a>
                        <form action="<%= ctx %>/UserServlet" method="POST" class="modal-form">
                            <input type="hidden" name="action" value="desactivarUsuario"/>
                            <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                            <button type="submit" class="btn-modal-ok btn-modal-ok--red"><i data-lucide="ban"></i>Sí, desactivar</button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
            <% } } %>

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