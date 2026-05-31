<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String userName = (String) session.getAttribute("userName");
    String roleName = (String) session.getAttribute("roleName");
    if (userName == null) userName = "Usuario";
    if (roleName == null) roleName = "";
    request.setAttribute("activeMenu", "home");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Inicio | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=2" rel="stylesheet"/>
</head>
<body class="page-body">

    <div class="layout-wrapper">

        <jsp:include page="includes/navbar.jsp"/>

        <div class="main-content">

            <main class="page-main">

                <%-- ─── BANNER DE BIENVENIDA ─── --%>
                <div class="panel-form flex flex-col md:flex-row md:items-center md:justify-between gap-6">
                    <div>
                        <h2 class="page-title mb-2">Hola, <%= userName %> 👋</h2>
                        <p class="text-gray-500 text-base max-w-2xl">
                            Bienvenida al sistema de inventario de Quinta Ola.
                            Controla, gestiona y optimiza el flujo de materiales desde un solo lugar.
                        </p>
                    </div>
                    <div class="flex flex-col sm:flex-row gap-3">
                        <a href="<%= ctx %>/HistoryServlet" class="btn-ghost">
                            📋 Ver Historial
                        </a>
                        <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="btn-page-primary">
                            ➕ Nueva Solicitud
                        </a>
                    </div>
                </div>

                <%-- ─── STAT CARDS ─── --%>
                <%-- Por ahora valores simulados. En el Sprint 2 conectamos a DAOs. --%>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div class="stat-card">
                        <div>
                            <p class="stat-card-label">Transacciones del mes</p>
                            <p class="stat-card-value">0</p>
                        </div>
                        <div class="stat-card-icon stat-icon-blue">📊</div>
                    </div>

                    <div class="stat-card">
                        <div>
                            <p class="stat-card-label">Items en inventario</p>
                            <p class="stat-card-value">0</p>
                        </div>
                        <div class="stat-card-icon stat-icon-pink">📦</div>
                    </div>

                    <div class="stat-card">
                        <div>
                            <p class="stat-card-label">Solicitudes aprobadas</p>
                            <p class="stat-card-value">0</p>
                        </div>
                        <div class="stat-card-icon stat-icon-green">✅</div>
                    </div>
                </div>

                <%-- ─── ACCESOS RÁPIDOS ─── --%>
                <div>
                    <h3 class="text-lg font-bold text-secondary mb-4">Accesos rápidos</h3>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">

                        <a href="<%= ctx %>/HistoryServlet" class="quick-card">
                            <div class="quick-card-icon">📋</div>
                            <h3 class="quick-card-title">Mi Historial</h3>
                            <p class="quick-card-desc">Visualiza tus movimientos</p>
                        </a>

                        <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="quick-card">
                            <div class="quick-card-icon">🛒</div>
                            <h3 class="quick-card-title">Solicitar Material</h3>
                            <p class="quick-card-desc">Registra un nuevo pedido</p>
                        </a>

                        <a href="<%= ctx %>/ProfileServlet" class="quick-card">
                            <div class="quick-card-icon">👤</div>
                            <h3 class="quick-card-title">Mi Perfil</h3>
                            <p class="quick-card-desc">Gestiona tus datos</p>
                        </a>

                        <%-- ─── Card EXCLUSIVA para SuperAdmin ─── --%>
                        <% if ("SuperAdmin".equals(roleName)) { %>
                            <a href="<%= ctx %>/PermissionServlet" class="quick-card">
                                <div class="quick-card-icon">🛡️</div>
                                <h3 class="quick-card-title">Permisos</h3>
                                <p class="quick-card-desc">Control de accesos (Admin)</p>
                            </a>
                        <% } %>

                    </div>
                </div>

            </main>

            <jsp:include page="includes/footer.jsp"/>

        </div> </div> </body>
</html>