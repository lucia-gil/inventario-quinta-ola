<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.dao.NotificationDAO" %>
<%
    String ctxTop  = request.getContextPath();
    String userNameTop = (String) session.getAttribute("userName");
    String roleNameTop = (String) session.getAttribute("roleName");
    String avatarUrl   = (String) session.getAttribute("avatarUrl");
    Integer topbarUserId = (Integer) session.getAttribute("userId");

    if (userNameTop == null) userNameTop = "Usuario";
    if (roleNameTop == null) roleNameTop = "";

    // ─── Notificaciones en tiempo real trasladadas al topbar ───
    int unreadNotifsTop = 0;
    if (topbarUserId != null && !"SuperAdmin".equals(roleNameTop)) {
        try {
            NotificationDAO topNotifDao = new NotificationDAO();
            unreadNotifsTop = topNotifDao.getUnreadCount(topbarUserId);
        } catch (Exception ignored) {}
    }

    // ─── Iniciales del usuario para el avatar fallback ───
    String iniciales = "U";
    if (userNameTop != null && !userNameTop.trim().isEmpty()) {
        String[] partes = userNameTop.trim().split("\\s+");
        if (partes.length >= 2) {
            iniciales = (partes[0].charAt(0) + "" + partes[1].charAt(0)).toUpperCase();
        } else if (partes[0].length() >= 2) {
            iniciales = partes[0].substring(0, 2).toUpperCase();
        } else {
            iniciales = partes[0].substring(0, 1).toUpperCase();
        }
    }

    // ─── Traducir rol técnico al español ───
    String roleDisplay = roleNameTop;
    switch (roleNameTop) {
        case "Viewer":        roleDisplay = "Solicitante"; break;
        case "Member":        roleDisplay = "Encargado de Depósito"; break;
        case "Manager":       roleDisplay = "Aprobador"; break;
        case "Administrador": roleDisplay = "Administrador"; break;
        case "SuperAdmin":    roleDisplay = "Super Admin"; break;
    }
%>

<header class="topbar">

    <!-- Buscador Integrado a la izquierda -->
    <div class="topbar-search-container">
        <i data-lucide="search"></i>
        <input type="text" placeholder="Buscar en el panel de inventarios...">
    </div>

    <!-- Info del usuario alineada a la derecha -->
    <div class="topbar-user">

        <%-- Campana de Notificaciones Profesional --%>
        <% if (!"SuperAdmin".equals(roleNameTop)) { %>
        <a href="<%= ctxTop %>/NotificationServlet" class="topbar-bell-btn" title="Ver Notificaciones">
            <i data-lucide="bell" style="width: 20px; height: 20px;"></i>
            <% if (unreadNotifsTop > 0) { %>
            <span class="topbar-bell-badge"><%= unreadNotifsTop %></span>
            <% } %>
        </a>
        <% } %>

        <!-- Datos textuales -->
        <div class="topbar-user-text">
            <p class="topbar-user-name"><%= userNameTop %></p>
            <p class="topbar-user-role"><%= roleDisplay %></p>
        </div>

        <%-- Avatar redondo con fallback dinámico --%>
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

</header>