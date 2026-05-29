<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>Title</title>
  </head>
  <body>
  
  </body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
    Navbar reutilizable.
    Se incluye con: <jsp:include page="includes/navbar.jsp"/>
    Usa scriptlets puros (estilo Clase 7.2 del cursito de iweb).
    La lógica de qué links mostrar según rol vive aquí en Java.
--%>
<%
    String userName = (String) session.getAttribute("userName");
    String roleName = (String) session.getAttribute("roleName");
    String activeMenu = (String) request.getAttribute("activeMenu");
    if (userName == null) userName = "Usuario";
    if (roleName == null) roleName = "";
    if (activeMenu == null) activeMenu = "";
    String ctx = request.getContextPath();
%>
<nav class="navbar">
    <div class="flex items-center">
        <a href="<%= ctx %>/DashboardServlet">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png"
                 alt="Quinta Ola" class="navbar-logo"/>
        </a>
    </div>
    <div class="navbar-menu">

        <%-- ── Links comunes a todos los usuarios autenticados ── --%>
        <a href="<%= ctx %>/HomeServlet"
           class="<%= activeMenu.equals("home") ? "nav-link-active" : "nav-link" %>">
           Inicio
        </a>

        <a href="<%= ctx %>/DashboardServlet"
           class="<%= activeMenu.equals("dashboard") ? "nav-link-active" : "nav-link" %>">
           Dashboard
        </a>

        <a href="<%= ctx %>/TransactionServlet"
           class="<%= activeMenu.equals("transactions") ? "nav-link-active" : "nav-link" %>">
           Transacciones
        </a>

        <a href="<%= ctx %>/InventoryServlet"
           class="<%= activeMenu.equals("inventory") ? "nav-link-active" : "nav-link" %>">
           Inventario
        </a>

        <a href="<%= ctx %>/HistoryServlet"
           class="<%= activeMenu.equals("history") ? "nav-link-active" : "nav-link" %>">
           Historial
        </a>

        <%-- ── Links solo para Administrador y SuperAdmin ── --%>
        <% if ("Administrador".equals(roleName) || "SuperAdmin".equals(roleName)) { %>
            <a href="<%= ctx %>/UserServlet"
               class="<%= activeMenu.equals("members") ? "nav-link-active" : "nav-link" %>">
               Miembros
            </a>
        <% } %>

        <%-- ── Links solo para SuperAdmin ── --%>
        <% if ("SuperAdmin".equals(roleName)) { %>
            <a href="<%= ctx %>/RoleServlet"
               class="<%= activeMenu.equals("roles") ? "nav-link-active" : "nav-link" %>">
               Roles (SA)
            </a>

            <a href="<%= ctx %>/PermissionServlet"
               class="<%= activeMenu.equals("permissions") ? "nav-link-active" : "nav-link" %>">
               Permisos (SA)
            </a>

            <a href="<%= ctx %>/AuditServlet"
               class="<%= activeMenu.equals("audit") ? "nav-link-active" : "nav-link" %>">
               Auditoría (SA)
            </a>
        <% } %>

        <%-- ── Info usuario + logout ── --%>
        <div class="nav-divider">
            <div class="nav-user-info">
                <p class="nav-user-name"><%= userName %></p>
                <p class="nav-user-role"><%= roleName %></p>
            </div>
            <a href="<%= ctx %>/ProfileServlet" class="nav-avatar">👤</a>
            <a href="<%= ctx %>/AuthServlet?action=logout"
               class="ml-2 text-xs text-gray-500 hover:text-red-500">Salir</a>
        </div>
    </div>
</nav>