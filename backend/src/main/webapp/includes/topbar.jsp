<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.dao.NotificationDAO" %>
<%
    String ctxTop = request.getContextPath();
    String userNameTop = (String) session.getAttribute("userName");
    String roleNameTop = (String) session.getAttribute("roleName");
    String avatarUrl   = (String) session.getAttribute("avatarUrl");
    Integer topUserId  = (Integer) session.getAttribute("userId");

    if (userNameTop == null) userNameTop = "Usuario";
    if (roleNameTop == null) roleNameTop = "";

    // Iniciales para el avatar fallback
    String iniciales = "U";
    if (userNameTop != null && !userNameTop.trim().isEmpty()) {
        String[] partes = userNameTop.trim().split("\\s+");
        if (partes.length >= 2) {
            iniciales = (partes[0].charAt(0) + "" + partes[1].charAt(0)).toUpperCase();
        } else if (partes[0].length() >= 2) {
            iniciales = partes[0].substring(0, 2).toUpperCase();
        }
    }

    // Traducir rol técnico a español
    String roleDisplay = roleNameTop;
    switch (roleNameTop) {
        case "Viewer":        roleDisplay = "Solicitante"; break;
        case "Member":        roleDisplay = "Encargado de Depósito"; break;
        case "Manager":       roleDisplay = "Aprobador(a)"; break;
        case "Administrador": roleDisplay = "Administrador"; break;
        case "SuperAdmin":    roleDisplay = "Super Admin"; break;
    }

    // Notificaciones no leídas
    int topUnread = 0;
    if (topUserId != null && !"SuperAdmin".equals(roleNameTop)) {
        try {
            NotificationDAO topNotifDao = new NotificationDAO();
            topUnread = topNotifDao.getUnreadCount(topUserId);
        } catch (Exception ignored) {}
    }
%>

<header class="topbar">

    <%-- Espacio vacío a la izquierda --%>
    <div class="topbar-spacer"></div>

    <%-- Usuario a la derecha --%>
    <div class="topbar-user">

        <% if (!"SuperAdmin".equals(roleNameTop)) { %>
        <a href="<%= ctxTop %>/NotificationServlet" class="topbar-bell" title="Notificaciones">
            <i data-lucide="bell"></i>
            <% if (topUnread > 0) { %>
            <span class="topbar-bell-badge"><%= topUnread %></span>
            <% } %>
        </a>
        <% } %>

        <div class="topbar-user-info">

            <div class="topbar-user-text">
                <p class="topbar-user-name"><%= userNameTop %></p>
                <p class="topbar-user-role"><%= roleDisplay %></p>
            </div>

            <a href="<%= ctxTop %>/ProfileServlet" class="topbar-avatar-link" title="Ir a Mi Perfil">
                <% if (avatarUrl != null && !avatarUrl.trim().isEmpty()) { %>
                <img src="<%= avatarUrl %>"
                     alt="<%= userNameTop %>"
                     class="topbar-avatar-img"
                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"/>
                <div class="topbar-avatar-fallback" style="display: none;">
                    <%= iniciales %>
                </div>
                <% } else { %>
                <div class="topbar-avatar-fallback">
                    <%= iniciales %>
                </div>
                <% } %>
            </a>

        </div>

    </div>

</header>