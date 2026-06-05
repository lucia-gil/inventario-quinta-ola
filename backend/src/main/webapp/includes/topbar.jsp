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

            <a href="<%= ctxTop %>/ProfileServlet" class="topbar-avatar-link" title="Ir a Mi Perfil" style="text-decoration: none; display: inline-block;">
                <% if (avatarUrl != null && !avatarUrl.trim().isEmpty()) { %>
                <%-- Caso A: El usuario SÍ tiene registrada una ruta de foto. Se dibuja SOLO la imagen --%>
                <img src="<%= ctxTop %><%= avatarUrl %>"
                     alt="<%= userNameTop %>"
                     class="topbar-avatar-img"
                     style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 2px solid var(--purple-light); display: block;"
                     onerror="this.style.display='none'; document.getElementById('topbar-fallback-safe').style.display='flex';"/>

                <%-- Este contenedor interno permanece completamente invisible y SOLO se activa por ID único mediante JS si el archivo físico se borra del servidor accidentalmente --%>
                <div id="topbar-fallback-safe" class="topbar-avatar-fallback" style="display: none; width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%); color: white; align-items: center; justify-content: center; font-weight: bold; font-size: 0.9rem;">
                    <%= iniciales %>
                </div>
                <% } else { %>
                <%-- Caso B: El usuario NO tiene foto de perfil. El servidor genera únicamente el círculo de iniciales --%>
                <div class="topbar-avatar-fallback" style="width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 0.9rem;">
                    <%= iniciales %>
                </div>
                <% } %>
            </a>

        </div>

    </div>

</header>