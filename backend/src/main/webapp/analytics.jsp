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
    <link href="<%= ctx %>/css/style.css?v=3" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body class="page-body">

<jsp:include page="includes/navbar.jsp"/>

<main class="page-main">

    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-8">
        <div class="flex items-center gap-4">
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

        <div class="panel md:col-span-1 flex flex-col h-full">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-lg font-bold text-gray-800">Distribución</h2>
                <div class="p-2 bg-pink-50 text-accent rounded-lg">
                    <i data-lucide="pie-chart" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="relative w-full flex-grow flex items-center justify-center min-h-[250px]">
                <canvas id="myChart00"></canvas>
            </div>
        </div>

        <div class="panel md:col-span-2 flex flex-col h-full">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-lg font-bold text-gray-800">Entradas y Salidas <span class="text-sm font-normal text-gray-400 ml-2">(Última Semana)</span></h2>
                <div class="p-2 bg-blue-50 text-blue-600 rounded-lg">
                    <i data-lucide="trending-up" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="relative w-full flex-grow flex items-center justify-center min-h-[250px]">
                <canvas id="myChart01"></canvas>
            </div>
        </div>

        <div class="panel md:col-span-3 flex flex-col">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-lg font-bold text-gray-800">Trámites por Estado <span class="text-sm font-normal text-gray-400 ml-2">(Última Semana)</span></h2>
                <div class="p-2 bg-emerald-50 text-emerald-600 rounded-lg">
                    <i data-lucide="activity" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="relative w-full flex items-center justify-center">
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
<script type="module" src="<%= ctx %>/src/analytics.ts"></script>
</body>

</html>