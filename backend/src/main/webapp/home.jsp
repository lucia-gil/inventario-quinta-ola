<%--
    ════════════════════════════════════════════════════════════════════
     home.jsp — Vista PERSONAL del usuario
    ════════════════════════════════════════════════════════════════════
     Datos personalizados que recibe del HomeServlet:
     - stat1/stat2/stat3: números calculados desde BD según rol
     - label1/label2/label3: etiquetas adaptadas al rol
     Iconos: Lucide (cargado globalmente desde footer.jsp)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String userName = (String) session.getAttribute("userName");
    String roleName = (String) session.getAttribute("roleName");
    Integer roleId  = (Integer) session.getAttribute("roleId");
    if (userName == null) userName = "Usuario";
    if (roleName == null) roleName = "";
    if (roleId == null) roleId = 0;

    Integer stat1 = (Integer) request.getAttribute("stat1");
    Integer stat2 = (Integer) request.getAttribute("stat2");
    Integer stat3 = (Integer) request.getAttribute("stat3");
    String label1 = (String) request.getAttribute("label1");
    String label2 = (String) request.getAttribute("label2");
    String label3 = (String) request.getAttribute("label3");
    if (stat1 == null) stat1 = 0;
    if (stat2 == null) stat2 = 0;
    if (stat3 == null) stat3 = 0;
    if (label1 == null) label1 = "—";
    if (label2 == null) label2 = "—";
    if (label3 == null) label3 = "—";

    request.setAttribute("activeMenu", "home");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Inicio | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=3" rel="stylesheet"/>
</head>
<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <main class="page-main">

            <%-- ─── BANNER DE BIENVENIDA ─── --%>
            <div class="panel-form flex flex-col md:flex-row md:items-center md:justify-between gap-6">
                <div>
                    <h2 class="page-title mb-2" style="display: flex; align-items: center; gap: 0.5rem;">
                        Hola, <%= userName %>
                        <i data-lucide="hand" style="width: 26px; height: 26px; color: #db2777;"></i>
                    </h2>
                    <p class="text-gray-500 text-base max-w-2xl">
                        <% if (roleId == 1) { %>
                        Bienvenida a tu espacio personal. Aquí ves un resumen de tus solicitudes y puedes pedir nuevos materiales.
                        <% } else if (roleId == 2) { %>
                        Bienvenida al panel de depósito. Aquí ves los pedidos esperando entrega y el estado del stock.
                        <% } else if (roleId == 3) { %>
                        Bienvenida al panel de aprobaciones. Aquí ves las solicitudes que necesitan tu revisión.
                        <% } else if (roleId == 4) { %>
                        Bienvenida al panel de administración. Resumen ejecutivo del sistema.
                        <% } else { %>
                        Bienvenida al sistema de inventario de Quinta Ola.
                        <% } %>
                    </p>
                </div>
                <div class="flex flex-col sm:flex-row gap-3">
                    <a href="<%= ctx %>/HistoryServlet" class="btn-ghost btn-icon">
                        <i data-lucide="file-text"></i>
                        <span>Ver Historial</span>
                    </a>
                    <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="btn-page-primary btn-icon">
                        <i data-lucide="plus"></i>
                        <span>Nueva Solicitud</span>
                    </a>
                </div>
            </div>

            <%-- ─── STAT CARDS CON DATOS REALES ─── --%>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label"><%= label1 %></p>
                        <p class="stat-card-value"><%= stat1 %></p>
                    </div>
                    <div class="stat-card-icon stat-icon-blue">
                        <i data-lucide="package"></i>
                    </div>
                </div>

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label"><%= label2 %></p>
                        <p class="stat-card-value"><%= stat2 %></p>
                    </div>
                    <div class="stat-card-icon stat-icon-green">
                        <i data-lucide="check-circle"></i>
                    </div>
                </div>

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label"><%= label3 %></p>
                        <p class="stat-card-value"><%= stat3 %></p>
                    </div>
                    <div class="stat-card-icon stat-icon-pink">
                        <i data-lucide="clock"></i>
                    </div>
                </div>

            </div>

            <%-- ─── ACCESOS RÁPIDOS ─── --%>
            <div>
                <h3 class="text-lg font-bold text-secondary mb-4">Accesos rápidos</h3>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">

                    <a href="<%= ctx %>/HistoryServlet" class="quick-card">
                        <div class="quick-card-icon">
                            <i data-lucide="file-text"></i>
                        </div>
                        <h3 class="quick-card-title">Mi Historial</h3>
                        <p class="quick-card-desc">Visualiza tus movimientos</p>
                    </a>

                    <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="quick-card">
                        <div class="quick-card-icon">
                            <i data-lucide="shopping-cart"></i>
                        </div>
                        <h3 class="quick-card-title">Solicitar Material</h3>
                        <p class="quick-card-desc">Registra un nuevo pedido</p>
                    </a>

                    <a href="<%= ctx %>/ProfileServlet" class="quick-card">
                        <div class="quick-card-icon">
                            <i data-lucide="user"></i>
                        </div>
                        <h3 class="quick-card-title">Mi Perfil</h3>
                        <p class="quick-card-desc">Gestiona tus datos</p>
                    </a>

                    <%-- Atajo CONTEXTUAL según rol --%>
                    <% if (roleId == 2) { %>
                    <a href="<%= ctx %>/DepositServlet" class="quick-card">
                        <div class="quick-card-icon">
                            <i data-lucide="truck"></i>
                        </div>
                        <h3 class="quick-card-title">Entregar Pedidos</h3>
                        <p class="quick-card-desc">Marca solicitudes aprobadas</p>
                    </a>
                    <% } else if (roleId == 3) { %>
                    <a href="<%= ctx %>/TransactionServlet" class="quick-card">
                        <div class="quick-card-icon">
                            <i data-lucide="check-circle"></i>
                        </div>
                        <h3 class="quick-card-title">Aprobar Solicitudes</h3>
                        <p class="quick-card-desc">Revisa pendientes</p>
                    </a>
                    <% } else if (roleId == 4) { %>
                    <a href="<%= ctx %>/UserServlet" class="quick-card">
                        <div class="quick-card-icon">
                            <i data-lucide="users"></i>
                        </div>
                        <h3 class="quick-card-title">Miembros</h3>
                        <p class="quick-card-desc">Gestiona usuarios</p>
                    </a>
                    <% } else { %>
                    <a href="<%= ctx %>/InventoryServlet" class="quick-card">
                        <div class="quick-card-icon">
                            <i data-lucide="package"></i>
                        </div>
                        <h3 class="quick-card-title">Inventario</h3>
                        <p class="quick-card-desc">Ver catálogo</p>
                    </a>
                    <% } %>

                </div>
            </div>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

</body>
</html>