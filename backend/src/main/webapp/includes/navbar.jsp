<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.dao.NotificationDAO" %>
<%
    String userName = (String) session.getAttribute("userName");
    String roleName = (String) session.getAttribute("roleName");
    String activeMenu = (String) request.getAttribute("activeMenu");
    Integer navUserId = (Integer) session.getAttribute("userId");

    if (userName == null) userName = "Usuario";
    if (roleName == null) roleName = "";
    if (activeMenu == null) activeMenu = "";

    String ctx = request.getContextPath();

    // ─── Notificaciones no leídas ───
    int unreadNotifs = 0;
    if (navUserId != null && !"SuperAdmin".equals(roleName)) {
        try {
            NotificationDAO navNotifDao = new NotificationDAO();
            unreadNotifs = navNotifDao.getUnreadCount(navUserId);
        } catch (Exception ignored) {}
    }
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

        <a href="<%= ctx %>/TransactionServlet"
           class="<%= activeMenu.equals("transactions") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="repeat" class="sidebar-icon"></i>
            <span>Transacciones</span>
        </a>

        <a href="<%= ctx %>/InventoryServlet"
           class="<%= activeMenu.equals("inventory") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="package" class="sidebar-icon"></i>
            <span>Inventario</span>
        </a>

        <a href="<%= ctx %>/HistoryServlet"
           class="<%= activeMenu.equals("history") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="file-text" class="sidebar-icon"></i>
            <span>Historial</span>
        </a>

        <% if ("Administrador".equals(roleName)) { %>
        <a href="<%= ctx %>/UserServlet"
           class="<%= activeMenu.equals("members") ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="users" class="sidebar-icon"></i>
            <span>Miembros</span>
        </a>
        <% } %>

        <% } %>

        <%-- ── Links SuperAdmin ── --%>
        <% if ("SuperAdmin".equals(roleName)) { %>

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

    <div class="sidebar-footer">

        <%-- Solo la campana de notificaciones (centrada) --%>
        <% if (!"SuperAdmin".equals(roleName)) { %>
        <a href="<%= ctx %>/NotificationServlet"
           class="sidebar-bell"
           title="Notificaciones"
           style="position: relative; display: flex; align-items: center; justify-content: center; margin-bottom: 1rem;">
            <i data-lucide="bell" style="width: 22px; height: 22px; color: #db2777;"></i>
            <% if (unreadNotifs > 0) { %>
            <span style="
                    position: absolute;
                    top: -5px;
                    right: 50%;
                    margin-right: -18px;
                    background-color: #db2777;
                    color: white;
                    font-size: 10px;
                    font-weight: bold;
                    border-radius: 9999px;
                    min-width: 16px;
                    height: 16px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 0 3px;
                    border: 2px solid white;
                    box-shadow: 0 1px 2px rgba(0,0,0,0.2);
                ">
                    <%= unreadNotifs %>
                </span>
            <% } %>
        </a>
        <% } %>

        <div class="sidebar-actions">
            <a href="<%= ctx %>/ProfileServlet" class="sidebar-profile">Mi Perfil</a>
            <a href="<%= ctx %>/AuthServlet?action=logout" class="sidebar-logout">Salir</a>
        </div>

    </div>
</nav>