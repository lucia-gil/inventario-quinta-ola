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
        <a href="<%= ctx %>/DashboardServlet">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Quinta Ola" class="sidebar-logo"/>
        </a>
    </div>

    <div class="sidebar-menu">
        <%-- ── Links para todos EXCEPTO SuperAdmin ── --%>
        <% if (!"SuperAdmin".equals(roleName)) { %>
        <a href="<%= ctx %>/HomeServlet" class="<%= activeMenu.equals("home") ? "sidebar-link-active" : "sidebar-link" %>">🏠 Inicio</a>
        <a href="<%= ctx %>/DashboardServlet" class="<%= activeMenu.equals("dashboard") ? "sidebar-link-active" : "sidebar-link" %>">📊 Dashboard</a>
        <a href="<%= ctx %>/TransactionServlet" class="<%= activeMenu.equals("transactions") ? "sidebar-link-active" : "sidebar-link" %>">🔄 Transacciones</a>
        <a href="<%= ctx %>/InventoryServlet" class="<%= activeMenu.equals("inventory") ? "sidebar-link-active" : "sidebar-link" %>">📦 Inventario</a>
        <a href="<%= ctx %>/HistoryServlet" class="<%= activeMenu.equals("history") ? "sidebar-link-active" : "sidebar-link" %>">📋 Historial</a>
        <% if ("Administrador".equals(roleName)) { %>
        <a href="<%= ctx %>/UserServlet" class="<%= activeMenu.equals("members") ? "sidebar-link-active" : "sidebar-link" %>">👥 Miembros</a>
        <% } %>
        <% } %>

        <%-- ── Links SuperAdmin ── --%>
        <% if ("SuperAdmin".equals(roleName)) { %>
        <a href="<%= ctx %>/RoleServlet" class="<%= activeMenu.equals("roles") ? "sidebar-link-active" : "sidebar-link" %>">🔑 Roles (SA)</a>
        <a href="<%= ctx %>/PermissionServlet" class="<%= activeMenu.equals("permissions") ? "sidebar-link-active" : "sidebar-link" %>">🛡️ Permisos (SA)</a>
        <a href="<%= ctx %>/AuditServlet" class="<%= activeMenu.equals("audit") ? "sidebar-link-active" : "sidebar-link" %>">🔍 Auditoría (SA)</a>
        <% } %>
    </div>

    <div class="sidebar-footer">
        <div class="sidebar-user-info">
            <div>
                <p class="sidebar-user-name"><%= userName %></p>
                <p class="sidebar-user-role"><%= roleName %></p>
            </div>
            <% if (!"SuperAdmin".equals(roleName)) { %>
            <a href="<%= ctx %>/NotificationServlet" class="sidebar-bell" title="Notificaciones">🔔</a>
            <% } %>
        </div>
        <div class="sidebar-actions">
            <a href="<%= ctx %>/ProfileServlet" class="sidebar-profile">Mi Perfil</a>
            <a href="<%= ctx %>/AuthServlet?action=logout" class="sidebar-logout">Salir</a>
        </div>
    </div>
</nav>