<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userName = (String) session.getAttribute("userName");
    String roleName = (String) session.getAttribute("roleName");
    String activeMenu = (String) request.getAttribute("activeMenu");

    if (userName == null) userName = "Usuario";
    if (roleName == null) roleName = "";
    if (activeMenu == null) activeMenu = "";

    String ctx = request.getContextPath();
%>

<nav class="sidebar">
    <div class="sidebar-header">
        <a href="<%= ctx %>/<%= "SuperAdmin".equals(roleName) ? "RoleServlet" : "HomeServlet" %>">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Quinta Ola" class="sidebar-logo"/>
        </a>
    </div>

    <div class="sidebar-menu">

        <%-- ── Links para todos EXCEPTO SuperAdmin ── --%>
        <% if (!"SuperAdmin".equals(roleName)) { %>

        <!-- CATEGORÍA: PRINCIPAL -->
        <div class="sidebar-category-title">Principal</div>

        <a href="<%= ctx %>/HomeServlet"
           class="<%= activeMenu.equals("home") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="home" class="sidebar-icon"></i>
            <span>Inicio</span>
        </a>

        <a href="<%= ctx %>/DashboardServlet"
           class="<%= activeMenu.equals("dashboard") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="layout-dashboard" class="sidebar-icon"></i>
            <span>Dashboard</span>
        </a>

        <!-- CATEGORÍA: APROBACIÓN / SEGUIMIENTO -->
        <div class="sidebar-category-title">Aprobación</div>

        <a href="<%= ctx %>/TransactionServlet"
           class="<%= activeMenu.equals("transactions") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="repeat" class="sidebar-icon"></i>
            <span>Transacciones</span>
        </a>

        <a href="<%= ctx %>/HistoryServlet"
           class="<%= activeMenu.equals("history") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="file-text" class="sidebar-icon"></i>
            <span>Historial</span>
        </a>

        <!-- CATEGORÍA: INVENTARIO -->
        <div class="sidebar-category-title">Inventario</div>

        <a href="<%= ctx %>/InventoryServlet"
           class="<%= activeMenu.equals("inventory") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="package" class="sidebar-icon"></i>
            <span>Inventario</span>
        </a>

        <%-- GESTIÓN DE MIEMBROS (Solo Administrador) --%>
        <% if ("Administrador".equals(roleName)) { %>
        <div class="sidebar-category-title">Gestión</div>
        <a href="<%= ctx %>/UserServlet"
           class="<%= activeMenu.equals("members") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="users" class="sidebar-icon"></i>
            <span>Miembros</span>
        </a>
        <% } %>

        <% } %>

        <%-- ── Links SuperAdmin ── --%>
        <% if ("SuperAdmin".equals(roleName)) { %>

        <div class="sidebar-category-title">Control (SA)</div>

        <a href="<%= ctx %>/RoleServlet"
           class="<%= activeMenu.equals("roles") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="key-round" class="sidebar-icon"></i>
            <span>Roles (SA)</span>
        </a>

        <a href="<%= ctx %>/PermissionServlet"
           class="<%= activeMenu.equals("permissions") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="shield" class="sidebar-icon"></i>
            <span>Permisos (SA)</span>
        </a>

        <a href="<%= ctx %>/AuditServlet"
           class="<%= activeMenu.equals("audit") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="search" class="sidebar-icon"></i>
            <span>Auditoría (SA)</span>
        </a>

        <% } %>

    </div>

    <!-- PIE DEL SIDEBAR: ACCIONES DE CUENTA -->
    <div class="sidebar-footer">
        <div class="sidebar-actions">
            <a href="<%= ctx %>/ProfileServlet" class="sidebar-profile">Mi Perfil</a>
            <a href="<%= ctx %>/AuthServlet?action=logout" class="sidebar-logout">Salir</a>
        </div>
    </div>
</nav>