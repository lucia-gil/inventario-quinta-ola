<%--
    ════════════════════════════════════════════════════════════════════
     topbar.jsp — Barra superior con información del usuario
    ════════════════════════════════════════════════════════════════════

     PROPÓSITO:
     Mostrar arriba en cada vista interna:
       - Nombre del usuario logueado
       - Su rol
       - Su avatar (foto o iniciales como fallback)

     ¿DE DÓNDE SACAMOS LOS DATOS?
     - userName, roleName, avatarUrl → session

     UBICACIÓN EN EL LAYOUT:
     Va dentro de .main-content, antes del <main>.
     Se ve a la derecha por defecto, con flex justify-content: flex-end.
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctxTop  = request.getContextPath();
    String userNameTop = (String) session.getAttribute("userName");
    String roleNameTop = (String) session.getAttribute("roleName");
    String avatarUrl   = (String) session.getAttribute("avatarUrl");

    if (userNameTop == null) userNameTop = "Usuario";
    if (roleNameTop == null) roleNameTop = "";

    // ─── Iniciales del usuario para el avatar fallback ───
    // Ej: "Pedro Administrador" -> "PA"
    //     "Carmen del Depósito" -> "CD"
    //     "Ana" -> "AN"
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

    // ─── Traducir rol técnico al español del cliente ───
    // Internamente usamos Viewer/Member/Manager pero al usuario
    // le mostramos el nombre del cliente real.
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

    <%-- Espacio vacio a la izquierda (para que el contenido del usuario quede a la derecha) --%>
    <div class="topbar-spacer"></div>

    <%-- Info del usuario alineada a la derecha --%>
    <div class="topbar-user">

        <div class="topbar-user-text">
            <p class="topbar-user-name"><%= userNameTop %></p>
            <p class="topbar-user-role"><%= roleDisplay %></p>
        </div>

        <%-- Avatar: si hay foto la usa, si no muestra iniciales con gradiente --%>
        <a href="<%= ctxTop %>/ProfileServlet" class="topbar-avatar-link" title="Ir a Mi Perfil">
            <% if (avatarUrl != null && !avatarUrl.trim().isEmpty()) { %>
            <%-- Si el usuario subió foto, la mostramos --%>
            <img src="<%= avatarUrl %>"
                 alt="<%= userNameTop %>"
                 class="topbar-avatar-img"
                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"/>
            <div class="topbar-avatar-fallback" style="display: none;">
                <%= iniciales %>
            </div>
            <% } else { %>
            <%-- Si no hay foto, mostramos las iniciales con gradiente --%>
            <div class="topbar-avatar-fallback">
                <%= iniciales %>
            </div>
            <% } %>
        </a>

    </div>

</header>