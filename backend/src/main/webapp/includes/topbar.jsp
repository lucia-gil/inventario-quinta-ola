<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.dao.NotificationDAO" %>
<%@ page import="com.quintaola.model.Notification" %>
<%@ page import="java.util.List" %>
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

    // Notificaciones no leídas + últimas notificaciones para el dropdown
    int topUnread = 0;
    List<Notification> topRecent = null;
    if (topUserId != null && !"SuperAdmin".equals(roleNameTop)) {
        try {
            NotificationDAO topNotifDao = new NotificationDAO();
            topUnread = topNotifDao.getUnreadCount(topUserId);
            topRecent = topNotifDao.getRecent(topUserId, 5);
        } catch (Exception ignored) {}
    }
%>

<header class="topbar">

    <%-- Espacio vacío a la izquierda --%>
    <div class="topbar-spacer"></div>

    <%-- Usuario a la derecha --%>
    <div class="topbar-user">

        <% if (!"SuperAdmin".equals(roleNameTop)) { %>
        <div class="notif-drop-wrap">
            <input type="checkbox" id="notifDropToggle" class="notif-drop-check" />

            <label for="notifDropToggle" class="topbar-bell" title="Notificaciones">
                <i data-lucide="bell"></i>
                <% if (topUnread > 0) { %>
                <span class="topbar-bell-badge"><%= topUnread %></span>
                <% } %>
            </label>

            <label for="notifDropToggle" class="notif-drop-backdrop"></label>

            <div class="notif-dropdown">
                <div class="notif-dropdown-header">
                    <span>Notificaciones</span>
                    <% if (topUnread > 0) { %>
                    <span class="notif-dropdown-count"><%= topUnread %> nueva<%= topUnread == 1 ? "" : "s" %></span>
                    <% } %>
                </div>

                <div class="notif-dropdown-list">
                    <% if (topRecent == null || topRecent.isEmpty()) { %>
                    <div class="notif-dropdown-empty">
                        <i data-lucide="inbox"></i>
                        <p>No tienes notificaciones</p>
                    </div>
                    <% } else { %>
                    <% for (Notification rn : topRecent) {
                        boolean rLeida = (rn.getIsRead() == 1);
                        String rTipo = rn.getType();
                        String rIconName = "bell";
                        String rIconClass = "notif-drop-icon notif-icon--default";

                        if ("request_approved".equals(rTipo)) {
                            rIconName = "check-circle";
                            rIconClass = "notif-drop-icon notif-icon--approved";
                        } else if ("request_rejected".equals(rTipo)) {
                            rIconName = "x-circle";
                            rIconClass = "notif-drop-icon notif-icon--rejected";
                        } else if ("new_request".equals(rTipo)) {
                            rIconName = "mail";
                            rIconClass = "notif-drop-icon notif-icon--request";
                        }
                    %>
                    <a href="<%= ctxTop %>/NotificationServlet" class="notif-drop-item <%= rLeida ? "" : "notif-drop-item--unread" %>">
                        <div class="<%= rIconClass %>">
                            <i data-lucide="<%= rIconName %>"></i>
                        </div>
                        <div class="notif-drop-item-body">
                            <p class="notif-drop-item-title"><%= rn.getTitle() %></p>
                            <p class="notif-drop-item-msg"><%= rn.getMessage() %></p>
                            <p class="notif-drop-item-date"><%= rn.getCreatedAt() != null ? rn.getCreatedAt() : "" %></p>
                        </div>
                        <% if (!rLeida) { %><span class="notif-drop-dot"></span><% } %>
                    </a>
                    <% } %>
                    <% } %>
                </div>

                <a href="<%= ctxTop %>/NotificationServlet" class="notif-dropdown-footer">
                    Ver todas las notificaciones <i data-lucide="arrow-right"></i>
                </a>
            </div>
        </div>
        <% } %>

        <div class="topbar-user-info">

            <div class="topbar-user-text">
                <p class="topbar-user-name"><%= userNameTop %></p>
                <p class="topbar-user-role"><%= roleDisplay %></p>
            </div>

            <a href="<%= ctxTop %>/ProfileServlet" class="topbar-avatar-link" title="Ir a Mi Perfil" style="text-decoration: none; display: inline-block;">
                <% if (avatarUrl != null && !avatarUrl.trim().isEmpty()) { %>
                <img src="<%= ctxTop %><%= avatarUrl %>"
                     alt="<%= userNameTop %>"
                     class="topbar-avatar-img"
                     style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover; border: 2px solid var(--purple-light); display: block;"
                     onerror="this.style.display='none'; document.getElementById('topbar-fallback-safe').style.display='flex';"/>

                <div id="topbar-fallback-safe" class="topbar-avatar-fallback" style="display: none; width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%); color: white; align-items: center; justify-content: center; font-weight: bold; font-size: 0.9rem;">
                    <%= iniciales %>
                </div>
                <% } else { %>
                <div class="topbar-avatar-fallback" style="width: 40px; height: 40px; border-radius: 50%; background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%); color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 0.9rem;">
                    <%= iniciales %>
                </div>
                <% } %>
            </a>

        </div>

    </div>

</header>

<%-- ── ESTILOS RESPONSIVOS PARA EL DROPDOWN EN CELULARES ── --%>
<style>
    @media (max-width: 576px) {
        /* 1. Forzamos al contenedor principal a mantener su lugar */
        .notif-drop-wrap {
            position: relative !important;
        }

        /* 2. El truco maestro: Volvemos el dropdown fijo a la pantalla */
        .notif-dropdown {
            position: fixed !important;
            top: 65px !important;       /* Ajusta este valor si queda muy arriba o muy abajo de tu topbar */
            right: 16px !important;     /* Margen limpio a la derecha de la pantalla */
            left: 16px !important;      /* Margen limpio a la izquierda de la pantalla */
            width: auto !important;     /* Olvídate de los anchos fijos, ahora es fluido */
            max-width: none !important; /* Rompe cualquier limitación previa */
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.2) !important;
            border-radius: 12px !important;
            z-index: 99999 !important;  /* Lo posiciona por encima de todo */
        }

        /* 3. Aseguramos que el fondo invisible ocupe toda la pantalla para poder cerrar el menú */
        .notif-drop-backdrop {
            position: fixed !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            background: transparent !important;
            z-index: 99998 !important;
        }
    }
</style>