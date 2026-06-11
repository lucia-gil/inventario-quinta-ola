<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();

    // 1. SEGURIDAD: Validar que la sesión esté activa
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect(ctx + "/AuthServlet?action=formLogin");
        return;
    }

    // 2. CONTROL DE ACCESO: Solo Manager (3), Admin (4) y SuperAdmin (5)
    Integer roleId = (Integer) userSession.getAttribute("roleId");
    if (roleId == null || roleId < 3) {
        response.sendRedirect(ctx + "/DashboardServlet");
        return;
    }

    // Activa el indicador del menú superior si el navbar lo soporta
    request.setAttribute("activeMenu", "dashboard");
%>
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Análisis de Inventario | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=10" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body class="page-body">

<jsp:include page="includes/navbar.jsp"/>

<main class="page-main">

    <div>
        <div>
            <div class="page-icon-title">
                <i data-lucide="bar-chart-2" class="w-7 h-7 text-accent"></i>
            </div>
            <div>
                <h1 class="page-title">Análisis de Inventario</h1>
                <p class="page-subtitle">Métricas, rendimiento y visualización de datos del sistema.</p>
            </div>
        </div>

        <a href="<%= ctx %>/DashboardServlet" class="btn-ghost">
            <i data-lucide="arrow-left" class="w-4 h-4"></i> Volver al Panel Principal
        </a>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

        <div>
            <div>
                <h2>Distribución</h2>
                <div>
                    <i data-lucide="pie-chart"></i>
                </div>
            </div>
            <div>
                <canvas id="myChart00"></canvas>
            </div>
        </div>

        <div>
            <div>
                <h2>Entradas y Salidas <span >(Última Semana)</span></h2>
                <div>
                    <i data-lucide="trending-up"></i>
                </div>
            </div>
            <div>
                <canvas id="myChart01"></canvas>
            </div>
        </div>

        <div>
            <div>
                <h2>Trámites por Estado <span >(Última Semana)</span></h2>
                <div>
                    <i data-lucide="activity"></i>
                </div>
            </div>
            <div>
                <canvas id="myChart02" height="100"></canvas>
            </div>
        </div>

    </div>
</main>

<script>
    lucide.createIcons();
</script>

<jsp:include page="includes/footer.jsp"/>

<%-- IMPORTANTE: Mantenemos tu script de gráficas.
     Si lo estás compilando a JS en tu proyecto, asegúrate de cambiar la extensión a .js --%>
<script type="module" src="<%= ctx %>/src/analytics.js"></script>
</body>

</html>