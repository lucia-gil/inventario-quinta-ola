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

    // ─── CONSULTAR NOTIFICACIONES NO LEÍDAS ───
    int unreadNotifs = 0;
    if (navUserId != null && !"SuperAdmin".equals(roleName)) {
        try {
            NotificationDAO navNotifDao = new NotificationDAO();
            unreadNotifs = navNotifDao.getUnreadCount(navUserId);
        } catch (Exception ignored) {
            // Failsafe para evitar que se rompa el renderizado si la BD falla
        }
    }
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
            <%-- Modificado sutilmente con position inline-relative para albergar el contador flotante --%>
            <a href="<%= ctx %>/NotificationServlet" class="sidebar-bell" title="Notificaciones" style="position: relative; display: inline-flex; align-items: center; justify-content: center;">
                🔔
                <% if (unreadNotifs > 0) { %>
                <span style="
                    position: absolute;
                    top: -5px;
                    right: -5px;
                    background-color: #db2777; /* Rosa fuerte corporativo */
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
        </div>
        <div class="sidebar-actions">
            <a href="<%= ctx %>/ProfileServlet" class="sidebar-profile">Mi Perfil</a>
            <a href="<%= ctx %>/AuthServlet?action=logout" class="sidebar-logout">Salir</a>
        </div>
    </div>
</nav>