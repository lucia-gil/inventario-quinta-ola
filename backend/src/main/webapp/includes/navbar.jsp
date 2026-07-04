<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userName   = (String) session.getAttribute("userName");
    String roleName   = (String) session.getAttribute("roleName");
    String activeMenu = (String) request.getAttribute("activeMenu");

    if (userName   == null) userName   = "Usuario";
    if (roleName   == null) roleName   = "";
    if (activeMenu == null) activeMenu = "";

    String ctx = request.getContextPath();

    boolean esSuperAdmin = "SuperAdmin".equals(roleName);
    boolean esAdmin      = "Administrador".equals(roleName);
    boolean esManager    = "Manager".equals(roleName);
    boolean esMember     = "Member".equals(roleName);
    boolean esViewer     = "Viewer".equals(roleName);

    boolean isActive_home         = "home".equals(activeMenu);
    boolean isActive_dashboard    = "dashboard".equals(activeMenu);
    boolean isActive_analytics    = "analytics".equals(activeMenu);   // ← NUEVO
    boolean isActive_transactions = "transactions".equals(activeMenu);
    boolean isActive_history      = "history".equals(activeMenu);
    boolean isActive_inventory    = "inventory".equals(activeMenu);
    boolean isActive_deposit      = "deposit".equals(activeMenu);
    boolean isActive_members      = "members".equals(activeMenu);
    boolean isActive_roles        = "roles".equals(activeMenu);
    boolean isActive_audit        = "audit".equals(activeMenu);
%>

<nav class="sidebar">

    <div class="sidebar-header">
        <a href="<%= ctx %>/<%= esSuperAdmin ? "RoleServlet" : "HomeServlet" %>">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Quinta Ola" class="sidebar-logo"/>
        </a>
    </div>

    <div class="sidebar-menu">

        <%-- ═══════ NO SUPERADMIN ═══════ --%>
        <% if (!esSuperAdmin) { %>

        <p class="sidebar-section-title">Principal</p>

        <a href="<%= ctx %>/HomeServlet"
           class="<%= isActive_home ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="home" class="sidebar-icon"></i>
            <span>Inicio</span>
        </a>

        <%-- Dashboard: activo SOLO cuando activeMenu="dashboard", no cuando es "analytics" --%>
        <a href="<%= ctx %>/DashboardServlet"
           class="<%= isActive_dashboard && !isActive_analytics ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="layout-dashboard" class="sidebar-icon"></i>
            <span>Dashboard</span>
        </a>

        <%-- APROBACIÓN (Manager, Admin) --%>
        <% if (esManager || esAdmin) { %>
        <p class="sidebar-section-title">Aprobación</p>

        <a href="<%= ctx %>/TransactionServlet"
           class="<%= isActive_transactions ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="check-square" class="sidebar-icon"></i>
            <span>Pendientes</span>
        </a>

        <%-- Mis Decisiones: activo también cuando se está en la vista de análisis --%>
        <a href="<%= ctx %>/HistoryServlet"
           class="<%= (isActive_history || isActive_analytics) ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="clipboard-list" class="sidebar-icon"></i>
            <span>Mis Decisiones</span>
        </a>
        <% } %>

        <%-- MIS PEDIDOS (Viewer) --%>
        <% if (esViewer) { %>
        <p class="sidebar-section-title">Mis Pedidos</p>

        <a href="<%= ctx %>/TransactionServlet"
           class="<%= isActive_transactions ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="repeat" class="sidebar-icon"></i>
            <span>Solicitudes</span>
        </a>

        <a href="<%= ctx %>/HistoryServlet"
           class="<%= (isActive_history || isActive_analytics) ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="file-text" class="sidebar-icon"></i>
            <span>Historial</span>
        </a>
        <% } %>

        <%-- INVENTARIO --%>
        <p class="sidebar-section-title">Inventario</p>

        <a href="<%= ctx %>/InventoryServlet"
           class="<%= isActive_inventory ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="package" class="sidebar-icon"></i>
            <span>Stock</span>
        </a>

        <% if (esMember) { %>
        <a href="<%= ctx %>/DepositServlet"
           class="<%= isActive_deposit ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="truck" class="sidebar-icon"></i>
            <span>Despacho</span>
        </a>
        <% } %>

        <% if (esAdmin) { %>
        <p class="sidebar-section-title">Gestión</p>

        <a href="<%= ctx %>/UserServlet"
           class="<%= isActive_members ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="users" class="sidebar-icon"></i>
            <span>Miembros</span>
        </a>
        <% } %>

        <% } %>

        <%-- ═══════ SUPERADMIN ═══════ --%>
        <% if (esSuperAdmin) { %>

        <p class="sidebar-section-title">Control SA</p>

        <a href="<%= ctx %>/RoleServlet"
           class="<%= isActive_roles ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="key-round" class="sidebar-icon"></i>
            <span>Roles</span>
        </a>

        <a href="<%= ctx %>/AuditServlet"
           class="<%= isActive_audit ? "sidebar-link-active" : "sidebar-link" %>">
            <i data-lucide="search" class="sidebar-icon"></i>
            <span>Auditoría</span>
        </a>

        <% } %>

    </div>

    <div class="sidebar-footer">
        <div class="sidebar-actions">
            <a href="<%= ctx %>/ProfileServlet" class="sidebar-profile">
                <i data-lucide="user" style="width:14px;height:14px;vertical-align:middle;margin-right:4px;"></i>
                Mi Perfil
            </a>
            <a href="<%= ctx %>/AuthServlet?action=logout" class="sidebar-logout">
                <i data-lucide="log-out" style="width:14px;height:14px;vertical-align:middle;margin-right:4px;"></i>
                Cerrar Sesión
            </a>
        </div>
    </div>
</nav>