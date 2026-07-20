<%--
    ════════════════════════════════════════════════════════════════════
     roles-list.jsp — Gestión de Roles (SuperAdmin)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.quintaola.model.Role" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<Role> roles = (List<Role>) request.getAttribute("roles");

    @SuppressWarnings("unchecked")
    Map<Integer, List<User>> pagedUsuariosPorRol =
            (Map<Integer, List<User>>) request.getAttribute("pagedUsuariosPorRol");

    @SuppressWarnings("unchecked")
    Map<Integer, String> inactiveStatus =
            (Map<Integer, String>) request.getAttribute("inactiveStatus");

    @SuppressWarnings("unchecked")
    Map<Integer, Integer> totalsByRole =
            (Map<Integer, Integer>) request.getAttribute("totalsByRole");

    @SuppressWarnings("unchecked")
    Map<Integer, Integer> totalPagesByRole =
            (Map<Integer, Integer>) request.getAttribute("totalPagesByRole");

    @SuppressWarnings("unchecked")
    Map<Integer, Integer> pagesByRole =
            (Map<Integer, Integer>) request.getAttribute("pagesByRole");

    String  _searchQ   = request.getAttribute("searchQ")   != null ? (String)  request.getAttribute("searchQ")   : "";
    int     _rolFilter = request.getAttribute("rolFilter")  != null ? (Integer) request.getAttribute("rolFilter") : 0;

    Integer userIdSession = (Integer) session.getAttribute("userId");

    String success  = request.getParameter("success");
    String errParam = request.getParameter("error");
    String error    = (String) request.getAttribute("error");

    // URL base para búsqueda y paginación (preserva filtros activos)
    String _qEncoded = "";
    try {
        if (!_searchQ.isEmpty())
            _qEncoded = "&q=" + java.net.URLEncoder.encode(_searchQ, "UTF-8");
    } catch (Exception ignored) {}
    String _baseUrl = ctx + "/RoleServlet?" + _qEncoded
            + (_rolFilter > 0 ? "&rol=" + _rolFilter : "");

    // Query string para las pestañas (preserva la búsqueda por texto)
    String _searchQS = "";
    try {
        if (!_searchQ.isEmpty())
            _searchQS = "q=" + java.net.URLEncoder.encode(_searchQ, "UTF-8") + "&";
    } catch (Exception ignored) {}

    request.setAttribute("activeMenu", "roles");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Gestión de Roles | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=25" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ── Info banner ──────────────────────────────────────────────── */
        .info-banner {
            display: flex; gap: 0.85rem; align-items: flex-start;
            background: linear-gradient(135deg, var(--blue-bg) 0%, var(--purple-bg) 100%);
            border: 1px solid #BAE6FD;
            border-radius: var(--radius-md);
            padding: 1rem 1.25rem;
            margin-bottom: 1.25rem;
        }
        .info-banner-icon {
            display: flex; align-items: center; justify-content: center;
            width: 36px; height: 36px;
            border-radius: var(--radius-sm);
            background: var(--blue); color: var(--white); flex-shrink: 0;
        }
        .info-banner-icon i { width: 18px; height: 18px; }
        .info-banner-title  { font-size: 0.88rem; font-weight: 700; color: var(--blue-dark); margin-bottom: 0.25rem; }
        .info-banner-text   { font-size: 0.82rem; color: var(--gray-700); line-height: 1.55; }
        .info-banner-text strong { color: var(--purple); }

        /* ── Pestañas de rol ──────────────────────────────────────────── */
        .role-tabs {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-bottom: 1.25rem;
        }
        .role-tab {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
            padding: 0.6rem 1.1rem;
            border-radius: var(--radius-full);
            font-size: 0.83rem;
            font-weight: 700;
            text-decoration: none;
            border: 1.5px solid var(--gray-200);
            background: var(--white);
            color: var(--gray-600);
            transition: all var(--transition);
            white-space: nowrap;
        }
        .role-tab i { width: 15px; height: 15px; }
        .role-tab:hover {
            border-color: var(--purple-light);
            color: var(--purple);
            background: var(--purple-bg);
            transform: translateY(-1px);
        }
        .role-tab--active {
            background: linear-gradient(135deg, var(--purple) 0%, var(--pink) 100%);
            color: var(--white);
            border-color: transparent;
            box-shadow: 0 4px 12px rgba(91,31,168,0.28);
        }
        .role-tab--active:hover {
            background: linear-gradient(135deg, var(--purple) 0%, var(--pink) 100%);
            color: var(--white);
            transform: translateY(-1px);
        }
        .role-tab-count {
            display: inline-flex; align-items: center; justify-content: center;
            min-width: 18px; height: 18px; padding: 0 5px;
            border-radius: var(--radius-full);
            font-size: 0.68rem; font-weight: 800;
            background: rgba(0,0,0,0.08);
        }
        .role-tab--active .role-tab-count { background: rgba(255,255,255,0.25); }

        /* ── Barra de búsqueda ────────────────────────────────────────── */
        .filter-active-chip {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.22rem 0.65rem; background: var(--purple-bg); color: var(--purple);
            border-radius: var(--radius-full); font-size: 0.73rem; font-weight: 700;
        }

        /* ── Role cards ───────────────────────────────────────────────── */
        .role-card {
            background: var(--white); border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100); box-shadow: var(--shadow-sm);
            overflow: hidden; margin-bottom: 1.5rem;
        }
        .role-card-header {
            display: flex; align-items: center; justify-content: space-between; gap: 1rem;
            padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--gray-100);
        }
        .role-card-header.role-1 { background: linear-gradient(to right, var(--pink-bg),   var(--white)); }
        .role-card-header.role-2 { background: linear-gradient(to right, var(--green-bg),  var(--white)); }
        .role-card-header.role-3 { background: linear-gradient(to right, var(--yellow-bg), var(--white)); }
        .role-card-header.role-4 { background: linear-gradient(to right, var(--purple-bg), var(--white)); }
        .role-card-header.role-5 { background: linear-gradient(to right, var(--blue-bg),   var(--white)); }

        .role-header-left  { display: flex; align-items: center; gap: 0.85rem; }
        .role-header-right { display: flex; align-items: center; gap: 0.65rem; }

        .role-header-icon {
            display: flex; align-items: center; justify-content: center;
            width: 42px; height: 42px; border-radius: var(--radius-sm);
            background: var(--white); box-shadow: var(--shadow-sm); flex-shrink: 0;
        }
        .role-header-icon i { width: 20px; height: 20px; }
        .role-header-icon.role-1 i { color: var(--pink); }
        .role-header-icon.role-2 i { color: var(--green-dark); }
        .role-header-icon.role-3 i { color: var(--orange-dark); }
        .role-header-icon.role-4 i { color: var(--purple); }
        .role-header-icon.role-5 i { color: var(--blue-dark); }

        .role-header-text h2 { font-size: 1rem; font-weight: 800; color: var(--gray-800); margin: 0; }
        .role-header-text p  { font-size: 0.78rem; color: var(--gray-500); margin: 0.15rem 0 0; font-weight: 500; }

        .role-count-badge {
            display: inline-flex; align-items: center; gap: 0.4rem;
            padding: 0.4rem 0.85rem; border-radius: var(--radius-full);
            background: var(--purple); color: var(--white);
            font-size: 0.78rem; font-weight: 700; white-space: nowrap;
        }
        .role-count-badge i { width: 14px; height: 14px; }

        /* Botón export por rol */
        .btn-export-rol {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.38rem 0.75rem;
            background: var(--white); color: var(--purple);
            border: 1.5px solid var(--purple-light);
            border-radius: var(--radius-sm);
            font-size: 0.75rem; font-weight: 700;
            text-decoration: none; white-space: nowrap;
            transition: all var(--transition);
        }
        .btn-export-rol:hover { background: var(--purple-bg); transform: translateY(-1px); }
        .btn-export-rol i { width: 13px; height: 13px; }

        /* Botón export general */
        .btn-export-all {
            display: inline-flex; align-items: center; gap: 0.35rem;
            padding: 0.5rem 0.9rem;
            background: var(--white); color: var(--green-dark);
            border: 1.5px solid var(--green-dark);
            border-radius: var(--radius-sm);
            font-size: 0.82rem; font-weight: 700;
            text-decoration: none; white-space: nowrap;
            transition: all var(--transition);
        }
        .btn-export-all:hover { background: var(--green-bg); transform: translateY(-1px); }
        .btn-export-all i { width: 14px; height: 14px; }

        /* ── Tabla ────────────────────────────────────────────────────── */
        .empty-row {
            padding: 2rem; text-align: center;
            color: var(--gray-400); font-size: 0.88rem; font-style: italic;
        }
        .row-deactivated { opacity: 0.55; background: var(--gray-50); }
        .row-deactivated .user-cell-name { text-decoration: line-through; }

        .status-pill {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.28rem 0.65rem; border-radius: var(--radius-full);
            font-size: 0.7rem; font-weight: 700; white-space: nowrap;
        }
        .status-pill i { width: 11px; height: 11px; }
        .status-pill-active      { background: var(--green-bg);  color: var(--green-dark); }
        .status-pill-pending     { background: var(--yellow-bg); color: var(--orange-dark); }
        .status-pill-deactivated { background: var(--gray-200);  color: var(--gray-700); }

        .actions-stack { display: flex; gap: 0.35rem; align-items: center; }
        .change-role-form { display: inline-flex; gap: 0.35rem; align-items: center; }
        .change-role-select {
            padding: 0.38rem 0.5rem;
            border: 1.5px solid var(--gray-200); border-radius: var(--radius-sm);
            font-size: 0.76rem; color: var(--gray-700);
            background: var(--gray-50); font-family: inherit;
            cursor: pointer; outline: none; transition: all var(--transition);
            min-width: 110px; max-width: 130px;
        }
        .change-role-select:focus { border-color: var(--purple); background: var(--white); }

        .btn-action {
            display: inline-flex; align-items: center; justify-content: center;
            gap: 0.22rem; padding: 0.36rem 0.65rem;
            border-radius: var(--radius-sm); border: 1px solid transparent;
            font-size: 0.71rem; font-weight: 700;
            cursor: pointer; transition: all var(--transition); font-family: inherit;
        }
        .btn-change-role { background: var(--pink); color: var(--white); border-color: var(--pink); }
        .btn-change-role:hover { background: var(--purple); border-color: var(--purple); transform: translateY(-1px); }
        .btn-change-role i { width: 11px; height: 11px; }
        .btn-deactivate { background: var(--white); color: var(--red-dark); border-color: #FECACA; padding: 0.36rem 0.48rem; }
        .btn-deactivate:hover { background: var(--red); color: var(--white); border-color: var(--red); }
        .btn-deactivate i { width: 12px; height: 12px; }
        .btn-reactivate { background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%); color: var(--white); }
        .btn-reactivate:hover { transform: translateY(-1px); box-shadow: 0 3px 10px rgba(34,197,94,0.3); }
        .btn-reactivate i { width: 11px; height: 11px; }

        .self-tag {
            display: inline-flex; align-items: center; gap: 0.28rem;
            padding: 0.34rem 0.75rem; background: var(--purple-bg); color: var(--purple);
            border-radius: var(--radius-full); font-size: 0.7rem; font-weight: 700;
        }
        .self-tag i { width: 11px; height: 11px; }

        .user-cell { display: flex; align-items: center; gap: 0.7rem; }
        .user-cell-avatar {
            width: 32px; height: 32px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%);
            color: var(--white); display: flex; align-items: center; justify-content: center;
            font-size: 0.72rem; font-weight: 700;
        }
        .user-cell-avatar-wrap { width: 32px; height: 32px; flex-shrink: 0; }
        .user-cell-avatar-photo {
            width: 32px; height: 32px; border-radius: 50%;
            object-fit: cover; border: 2px solid var(--purple-light); display: block;
        }

        .user-cell-name { font-weight: 700; color: var(--gray-800); font-size: 0.88rem; }

        .alert {
            display: flex; align-items: center; gap: 0.6rem;
            padding: 0.9rem 1.1rem; border-radius: var(--radius-sm);
            font-size: 0.88rem; font-weight: 600; margin-bottom: 1.25rem; border: 1px solid;
        }
        .alert-error   { background: var(--red-bg);   color: var(--red-dark);   border-color: #FECACA; }
        .alert-success { background: var(--green-bg); color: var(--green-dark); border-color: #BBF7D0; }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }

        /* Paginación: ver componente global ".pager" en style.css */

        /* Ocultar flechas nativas del details */
        .css-modal-wrapper summary {
            list-style: none;
            outline: none;
        }
        .css-modal-wrapper summary::-webkit-details-marker {
            display: none;
        }

        /* El disparador para el modal del Rol */
        .btn-change-role-trigger {
            display: inline-flex;
            align-items: center;
            background: var(--gray-100, #f3f4f6);
            color: var(--purple, #5b1fa8);
            padding: 0.5rem 0.8rem;
            font-size: 0.82rem;
            font-weight: 700;
            border-radius: var(--radius-sm, 4px);
            border: 1px solid var(--gray-200, #e5e7eb);
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-change-role-trigger:hover {
            background: var(--purple-bg);
        }

        /* El fondo oscuro pantalla completa */
        .css-modal-wrapper[open] .css-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 12, 23, 0.72);
            backdrop-filter: blur(4px);
            z-index: 99999;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: default;
            isolation: isolate;
            transform: translateZ(0);
            will-change: transform;
        }

        /* Tarjeta Blanca del Modal */
        .css-modal-card {
            background: #ffffff;
            padding: 2rem;
            border-radius: 16px;
            width: 92%;
            max-width: 400px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            text-align: center;
        }

        .css-modal-card h3 {
            margin: 0.75rem 0 0.5rem 0;
            font-size: 1.25rem;
            font-weight: 700;
            color: #1f2937;
        }

        .css-modal-card p {
            font-size: 0.88rem;
            color: #6b7280;
            line-height: 1.4;
            margin-bottom: 1rem;
        }

        /* Botones de acción del modal */
        .css-modal-actions {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 1.5rem;
        }

        .btn-cancel-modal {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.6rem 1.2rem;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 700;
            background: var(--gray-100, #f3f4f6);
            color: var(--gray-700, #4b5563);
            cursor: pointer;
            border: 1px solid var(--gray-200);
            font-family: inherit;
        }

        .btn-cancel-modal:hover {
            background: var(--gray-200, #e5e7eb);
        }

        /* Estilos de iconos circulares */
        .modal-icon-container {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto;
        }
        .modal-icon-container.text-purple { background: var(--purple-bg); color: var(--purple); }
        .modal-icon-container.text-pink { background: var(--pink-bg); color: var(--pink); }
    </style>
</head>

<body class="page-body">
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- ── Encabezado ───────────────────────────────────────────────── --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="key-round" style="display:inline-block;width:24px;height:24px;vertical-align:middle;margin-right:8px;color:var(--purple);"></i>
                        Gestión de Roles
                    </h1>
                    <p class="page-subtitle">Los 5 roles del sistema y los usuarios asignados a cada uno</p>
                </div>
                <div style="display:flex; align-items:center; gap:0.65rem; flex-wrap:wrap;">
                    <%-- Export general: descarga todos los usuarios en Excel --%>
                    <%-- ⚠️ Requiere implementar ReportServlet?action=todos_usuarios --%>
                    <a href="<%= ctx %>/ReportServlet?action=todos_usuarios&format=xlsx"
                       class="btn-export-all">
                        <i data-lucide="download"></i>
                        Exportar todo
                    </a>
                    <a href="<%= ctx %>/UserServlet?action=formCrear" class="btn-page-primary btn-icon">
                        <i data-lucide="user-plus"></i>
                        Crear Usuario
                    </a>
                </div>
            </div>

            <%-- Alertas --%>
            <% if (success != null) { %>
            <div class="alert alert-success"><i data-lucide="check-circle"></i><span><%= success %></span></div>
            <% } %>
            <% if (errParam != null) { %>
            <div class="alert alert-error"><i data-lucide="alert-circle"></i><span><%= errParam %></span></div>
            <% } %>
            <% if (error != null) { %>
            <div class="alert alert-error"><i data-lucide="alert-circle"></i><span><%= error %></span></div>
            <% } %>

            <%-- ── Info banner ───────────────────────────────────────────────── --%>
            <div class="info-banner">
                <div class="info-banner-icon"><i data-lucide="info"></i></div>
                <div>
                    <p class="info-banner-title">Cómo funciona</p>
                    <p class="info-banner-text">
                        Los <strong>5 roles del sistema</strong> son fijos según el modelo del cliente.
                        Desde aquí puedes cambiar el rol o desactivar/reactivar cuentas. Cada acción
                        queda en la <strong>bitácora de auditoría</strong>.
                    </p>
                </div>
            </div>

            <%-- ── Pestañas de rol ──────────────────────────────────────────── --%>
            <div class="role-tabs">
                <a href="<%= ctx %>/RoleServlet?<%= _searchQS %>"
                   class="role-tab <%= _rolFilter == 0 ? "role-tab--active" : "" %>">
                    <i data-lucide="layout-grid"></i>
                    Todos
                </a>
                <% if (roles != null) {
                    for (Role rolTab : roles) {
                        String tabIcon = "circle";
                        switch (rolTab.getId()) {
                            case 1: tabIcon = "user";         break;
                            case 2: tabIcon = "truck";        break;
                            case 3: tabIcon = "check-square"; break;
                            case 4: tabIcon = "shield";       break;
                            case 5: tabIcon = "shield-check"; break;
                        }
                %>
                <a href="<%= ctx %>/RoleServlet?<%= _searchQS %>rol=<%= rolTab.getId() %>"
                   class="role-tab <%= _rolFilter == rolTab.getId() ? "role-tab--active" : "" %>">
                    <i data-lucide="<%= tabIcon %>"></i>
                    <%= rolTab.getName() %>
                    <span class="role-tab-count"><%= rolTab.getUserCount() %></span>
                </a>
                <% } } %>
            </div>

            <%-- ── Barra de búsqueda ────────────────────────────────────────── --%>
            <form method="GET" action="<%= ctx %>/RoleServlet" class="filter-bar">
                <input type="hidden" name="page_1" value="1"/>
                <input type="hidden" name="page_2" value="1"/>
                <input type="hidden" name="page_3" value="1"/>
                <input type="hidden" name="page_4" value="1"/>
                <input type="hidden" name="page_5" value="1"/>
                <% if (_rolFilter > 0) { %>
                <input type="hidden" name="rol" value="<%= _rolFilter %>"/>
                <% } %>

                <div class="filter-search">
                    <i data-lucide="search"></i>
                    <input type="text" name="q" value="<%= _searchQ %>"
                           placeholder="Buscar por nombre, apellido o DNI..." autocomplete="off"/>
                </div>

                <div class="filter-actions">
                    <button type="submit" class="btn-page-primary btn-icon">
                        <i data-lucide="filter"></i>
                        Buscar
                    </button>

                    <% if (!_searchQ.isEmpty() || _rolFilter > 0) { %>
                    <a href="<%= ctx %>/RoleServlet" class="btn-clear-filter">
                        <i data-lucide="x"></i>Limpiar
                    </a>
                    <% if (!_searchQ.isEmpty()) { %>
                    <span class="filter-active-chip">"<%= _searchQ %>"</span>
                    <% } %>
                    <% } %>
                </div>
            </form>

            <%-- ── Cards de roles ─────────────────────────────────────────────── --%>
            <% if (roles != null) {
                for (Role rol : roles) {

                    // Si hay filtro de rol (por pestaña), saltamos los que no coinciden
                    if (_rolFilter > 0 && rol.getId() != _rolFilter) continue;

                    List<User> usuariosDelRol = pagedUsuariosPorRol != null
                            ? pagedUsuariosPorRol.get(rol.getId()) : null;

                    int _total      = totalsByRole      != null ? totalsByRole.getOrDefault(rol.getId(), 0)      : 0;
                    int _totalPages = totalPagesByRole  != null ? totalPagesByRole.getOrDefault(rol.getId(), 1)  : 1;
                    int _page       = pagesByRole       != null ? pagesByRole.getOrDefault(rol.getId(), 1)       : 1;
                    int _from       = (_total == 0) ? 0 : (_page - 1) * 5 + 1;
                    int _to         = Math.min(_page * 5, _total);
                    int _winS       = Math.max(1, _page - 2);
                    int _winE       = Math.min(_totalPages, _page + 2);

                    // URL de paginación para ESTE rol (preserva q, rol, y páginas de otros roles)
                    StringBuilder _pUrlSB = new StringBuilder(ctx + "/RoleServlet?");
                    if (!_searchQ.isEmpty()) {
                        _pUrlSB.append("q=").append(java.net.URLEncoder.encode(_searchQ, "UTF-8")).append("&");
                    }
                    if (_rolFilter > 0) _pUrlSB.append("rol=").append(_rolFilter).append("&");
                    String _pUrlBase = _pUrlSB.toString();
                    if (pagesByRole != null) {
                        for (Map.Entry<Integer, Integer> e : pagesByRole.entrySet()) {
                            if (e.getKey() != rol.getId()) {
                                _pUrlBase += "page_" + e.getKey() + "=" + e.getValue() + "&";
                            }
                        }
                    }

                    int colorId = rol.getId();
                    String iconName = "circle";
                    switch (rol.getId()) {
                        case 1: iconName = "user";         break;
                        case 2: iconName = "truck";        break;
                        case 3: iconName = "check-square"; break;
                        case 4: iconName = "shield";       break;
                        case 5: iconName = "shield-check"; break;
                    }
            %>

            <div class="role-card" id="role-card-<%= colorId %>">


                <%-- ── Encabezado del rol ─────────────────────────────────────── --%>
                <div class="role-card-header role-<%= colorId %>">
                    <div class="role-header-left">
                        <div class="role-header-icon role-<%= colorId %>">
                            <i data-lucide="<%= iconName %>"></i>
                        </div>
                        <div class="role-header-text">
                            <h2><%= rol.getName() %></h2>
                            <p><%= rol.getDescription() != null ? rol.getDescription() : "" %></p>
                        </div>
                    </div>
                    <div class="role-header-right">
                        <%-- Export por rol (⚠️ requiere ReportServlet?action=usuarios_por_rol&rol=X) --%>
                        <a href="<%= ctx %>/ReportServlet?action=usuarios_por_rol&rol=<%= rol.getId() %>&format=xlsx"
                           class="btn-export-rol" title="Exportar usuarios de este rol">
                            <i data-lucide="file-spreadsheet"></i>
                            Exportar
                        </a>
                        <div class="role-count-badge">
                            <i data-lucide="users"></i>
                            <%= rol.getUserCount() %> usuario<%= rol.getUserCount() != 1 ? "s" : "" %>
                        </div>
                    </div>
                </div>

                <%-- ── Tabla de usuarios ──────────────────────────────────────── --%>
                <div class="role-card-body">
                    <% if (usuariosDelRol == null || usuariosDelRol.isEmpty()) { %>
                    <div class="empty-row">
                        <% if (!_searchQ.isEmpty()) { %>
                        Sin resultados para "<%= _searchQ %>" en este rol.
                        <% } else { %>
                        Aún no hay usuarios con este rol.
                        <% } %>
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
                                <th class="th-center" style="width:210px;">Acciones</th>
                            </tr>
                            </thead>
                            <tbody class="table-body">
                            <% for (User u : usuariosDelRol) {
                                boolean isSelf          = (userIdSession != null && userIdSession == u.getId());
                                boolean isSuperAdminRow = (u.getRoleId() == 5);
                                boolean isInactive      = (u.getActivo() == 0);

                                String inactiveType = null;
                                if (isInactive && inactiveStatus != null) {
                                    inactiveType = inactiveStatus.get(u.getId());
                                }
                                boolean isDeactivated = "DEACTIVATED".equals(inactiveType);

                                // Iniciales del avatar
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
                                        <% String _av = u.getAvatarUrl(); %>
                                        <div class="user-cell-avatar-wrap">
                                            <% if (_av != null && !_av.trim().isEmpty()) { %>
                                            <img src="<%= ctx + _av %>"
                                                 alt="<%= u.getName() %>"
                                                 class="user-cell-avatar-photo"
                                                 onerror="this.style.display='none';this.nextElementSibling.style.display='flex';"/>
                                            <div class="user-cell-avatar" style="display:none;"><%= ini %></div>
                                            <% } else { %>
                                            <div class="user-cell-avatar"><%= ini %></div>
                                            <% } %>
                                        </div>
                                        <span class="user-cell-name"><%= u.getName() %></span>
                                    </div>
                                </td>

                                <td class="td-light" style="font-size:0.8rem; max-width:170px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                    <%= u.getEmail() %>
                                </td>

                                <td class="td-light" style="font-size:0.82rem; color:var(--gray-600);">
                                    <%= u.getDni() != null ? u.getDni() : "—" %>
                                </td>

                                <td class="td-center">
                                    <% if (u.getActivo() == 1) { %>
                                    <span class="status-pill status-pill-active"><i data-lucide="check"></i>Activo</span>
                                    <% } else if (isDeactivated) { %>
                                    <span class="status-pill status-pill-deactivated"><i data-lucide="ban"></i>Desactivado</span>
                                    <% } else { %>
                                    <span class="status-pill status-pill-pending"><i data-lucide="clock"></i>Pendiente</span>
                                    <% } %>
                                </td>

                                <td class="td-center">
                                    <% if (isSelf) { %>
                                    <span class="self-tag"><i data-lucide="user"></i>Tú</span>

                                    <% } else if (isDeactivated) { %>
                                    <% if (!isSuperAdminRow) { %>
                                    <%-- MODAL CSS: REACTIVAR USUARIO --%>
                                    <details class="css-modal-wrapper">
                                        <summary class="btn-action btn-reactivate">
                                            <i data-lucide="rotate-ccw"></i>Reactivar
                                        </summary>
                                        <div class="css-modal-overlay">
                                            <div class="css-modal-card">
                                                <div class="modal-icon-container text-purple">
                                                    <i data-lucide="alert-circle" style="width:32px; height:32px;"></i>
                                                </div>
                                                <h3>¿Reactivar Usuario?</h3>
                                                <p>¿Estás seguro de que deseas reactivar a <strong><%= u.getName() %></strong> en el sistema?</p>
                                                <div class="css-modal-actions">

                                                    <button
                                                            type="button"
                                                            class="btn-cancel-modal"
                                                            onclick="this.closest('details').removeAttribute('open')">
                                                        Cancelar
                                                    </button>

                                                    <form action="<%= ctx %>/UserServlet" method="POST" style="margin:0;">
                                                        <input type="hidden" name="action" value="reactivarUsuario"/>
                                                        <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                                                        <input type="hidden" name="redirectTo" value="roles"/>

                                                        <button type="submit"
                                                                class="btn-action btn-reactivate"
                                                                style="border:none;">
                                                            Sí, Reactivar
                                                        </button>
                                                    </form>

                                                </div>
                                            </div>
                                        </div>
                                    </details>
                                    <% } %>

                                    <% } else { %>
                                    <div class="actions-stack">
                                        <%-- MODAL CSS: CAMBIAR ROL --%>
                                        <details class="css-modal-wrapper change-role-form">
                                            <summary class="btn-action btn-change-role-trigger">
                                                <i data-lucide="refresh-cw" style="width:14px; height:14px; display:inline-block; vertical-align:middle; margin-right:4px;"></i> Cambiar Rol
                                            </summary>
                                            <div class="css-modal-overlay">
                                                <div class="css-modal-card" style="text-align: left;">
                                                    <div class="modal-icon-container text-purple" style="margin: 0 auto 1rem auto;">
                                                        <i data-lucide="shield" style="width:32px; height:32px;"></i>
                                                    </div>
                                                    <h3 style="text-align:center;">Modificar Rol de Usuario</h3>
                                                    <p style="text-align:center;">Esta acción modificará los accesos de <strong><%= u.getName() %></strong> y quedará en la bitácora.</p>

                                                    <form action="<%= ctx %>/UserServlet" method="POST" class="modal-form-body">
                                                        <input type="hidden" name="action"     value="cambiarRol"/>
                                                        <input type="hidden" name="userId"     value="<%= u.getId() %>"/>
                                                        <input type="hidden" name="redirectTo" value="roles"/>

                                                        <div class="form-group" style="margin: 1.25rem 0;">
                                                            <label class="form-label-custom" style="font-size:0.75rem; font-weight:700; color:var(--gray-600); text-transform:uppercase; display:block; margin-bottom:0.5rem;">
                                                                Seleccionar nuevo rol:
                                                            </label>
                                                            <select name="nuevoRolId" class="change-role-select" style="width:100%; max-width:100%; box-sizing:border-box; padding:0.5rem; font-size:0.85rem;">
                                                                <% if (roles != null) { for (Role r : roles) { %>
                                                                <option value="<%= r.getId() %>" <%= r.getId()==u.getRoleId()?"selected":"" %>>
                                                                    <%= r.getName() %>
                                                                </option>
                                                                <% } } %>
                                                            </select>
                                                        </div>

                                                        <div class="css-modal-actions" style="justify-content: flex-end;">
                                                            <button
                                                                    type="button"
                                                                    class="btn-cancel-modal"
                                                                    onclick="this.closest('details').removeAttribute('open')">
                                                                Cancelar
                                                            </button>

                                                            <button type="submit" class="btn-action btn-change-role" style="border:none;">
                                                                Confirmar Cambio
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </details>

                                        <% if (!isSuperAdminRow) { %>
                                        <%-- MODAL CSS: DESACTIVAR USUARIO --%>
                                        <details class="css-modal-wrapper">
                                            <summary class="btn-action btn-deactivate" title="Desactivar cuenta de <%= u.getName() %>">
                                                <i data-lucide="ban"></i>
                                            </summary>
                                            <div class="css-modal-overlay">
                                                <div class="css-modal-card">
                                                    <div class="modal-icon-container text-pink">
                                                        <i data-lucide="alert-triangle" style="width:32px; height:32px;"></i>
                                                    </div>
                                                    <h3>¿Desactivar Cuenta?</h3>
                                                    <p>¿Desactivar la cuenta de <strong><%= u.getName() %></strong>?<br><br>Su historial se conservará pero la acción se registrará en auditoría.</p>
                                                    <div class="css-modal-actions">

                                                        <button
                                                                type="button"
                                                                class="btn-cancel-modal"
                                                                onclick="this.closest('details').removeAttribute('open')">
                                                            Cancelar
                                                        </button>

                                                        <form action="<%= ctx %>/UserServlet" method="POST" style="margin:0;">
                                                            <input type="hidden" name="action" value="desactivarUsuario"/>
                                                            <input type="hidden" name="userId" value="<%= u.getId() %>"/>
                                                            <input type="hidden" name="redirectTo" value="roles"/>

                                                            <button type="submit"
                                                                    class="btn-action btn-deactivate"
                                                                    style="border:none;">
                                                                Sí, Desactivar
                                                            </button>
                                                        </form>

                                                    </div>
                                                </div>
                                            </div>
                                        </details>
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

                    <%-- ── Paginación "Ola" por rol ─────────────────────────────── --%>
                    <div class="pager">
                        <div class="pager-info">
                             <span>
                                Mostrando <strong><%= _from %>–<%= _to %></strong>
                                de <strong><%= _total %></strong>
                            </span>
                            <span class="pager-info-badge"><i data-lucide="waves"></i> ≈ 5 por ola</span>
                        </div>
                        <% if (_totalPages > 1) { %>
                        <div class="pager-nav">

                            <% if (_page > 1) { %>
                            <a href="<%= _pUrlBase %>page_<%= rol.getId() %>=<%= _page-1 %>#role-card-<%= rol.getId() %>"
                               class="pager-btn" title="Anterior">
                                <i data-lucide="chevron-left"></i>
                            </a>
                            <% } else { %>
                            <span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-left"></i></span>
                            <% } %>

                            <% if (_winS > 1) { %>
                            <a href="<%= _pUrlBase %>page_<%= rol.getId() %>=1#role-card-<%= rol.getId() %>"
                               class="pager-btn">1</a>
                            <% if (_winS > 2) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %>
                            <% } %>

                            <% for (int _p = _winS; _p <= _winE; _p++) { %>
                            <% if (_p == _page) { %>
                            <span class="pager-btn pager-btn--active"><%= _p %></span>
                            <% } else { %>
                            <a href="<%= _pUrlBase %>page_<%= rol.getId() %>=<%= _p %>#role-card-<%= rol.getId() %>"
                               class="pager-btn"><%= _p %></a>
                            <% } %>
                            <% } %>

                            <% if (_winE < _totalPages) { %>
                            <% if (_winE < _totalPages-1) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %>
                            <a href="<%= _pUrlBase %>page_<%= rol.getId() %>=<%= _totalPages %>#role-card-<%= rol.getId() %>"
                               class="pager-btn"><%= _totalPages %></a>
                            <% } %>

                            <% if (_page < _totalPages) { %>
                            <a href="<%= _pUrlBase %>page_<%= rol.getId() %>=<%= _page+1 %>#role-card-<%= rol.getId() %>"
                               class="pager-btn" title="Siguiente">
                                <i data-lucide="chevron-right"></i>
                            </a>
                            <% } else { %>
                            <span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-right"></i></span>
                            <% } %>

                        </div>
                        <% } %>
                    </div>

                </div><%-- /role-card-body --%>
            </div><%-- /role-card --%>

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