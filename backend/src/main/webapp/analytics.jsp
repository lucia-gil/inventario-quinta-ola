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
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>

<body class="page-body">

<jsp:include page="includes/navbar.jsp"/>

<div class="main-content">
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

        <div class="panel md:col-span-1 flex flex-col h-full p-4">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-lg font-bold text-gray-800">Distribución</h2>
                <div class="text-accent">
                    <i data-lucide="pie-chart" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="relative w-full flex-grow flex items-center justify-center min-h-[250px]">
                <canvas id="myChart00"></canvas>
            </div>
        </div>

        <div class="panel md:col-span-2 flex flex-col h-full p-4">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-lg font-bold text-gray-800">Entradas y Salidas <span class="text-sm font-normal text-gray-400 ml-2">(Última Semana)</span></h2>
                <div class="text-blue-600">
                    <i data-lucide="trending-up" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="relative w-full flex-grow flex items-center justify-center min-h-[250px]">
                <canvas id="myChart01"></canvas>
            </div>
        </div>

        <div class="panel md:col-span-3 flex flex-col p-4">
            <div class="flex items-center justify-between mb-6">
                <h2 class="text-lg font-bold text-gray-800">Trámites por Estado <span class="text-sm font-normal text-gray-400 ml-2">(Última Semana)</span></h2>
                <div class="text-emerald-600">
                    <i data-lucide="activity" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="relative w-full flex items-center justify-center">
                <canvas id="myChart02" height="300"></canvas>
            </div>
        </div>

    </div>
</main>
<jsp:include page="includes/footer.jsp"/>
</div>

<script>
    lucide.createIcons();
</script>


<%-- IMPORTANTE: Mantenemos tu script de gráficas.
     Si lo estás compilando a JS en tu proyecto, asegúrate de cambiar la extensión a .js --%>
<%-- <script type="module" src="<%= ctx %>/src/analytics.ts"></script> --%>
<script>
// Esperamos a que el DOM cargue completamente
document.addEventListener('DOMContentLoaded', () => {
    
    // Configuración general para mantener los estilos limpios
    Chart.defaults.font.family = "'Inter', 'sans-serif'";
    Chart.defaults.color = '#6b7280'; // text-gray-500

    // ----------------------------------------------------------------------
    // GRÁFICA 00: Distribución del inventario (Doughnut / Anillo)
    // ----------------------------------------------------------------------
    const ctx00 = document.getElementById('myChart00');
    if (ctx00) {
        new Chart(ctx00, {
            type: 'doughnut',
            data: {
                labels: ${item_name},
                datasets: [{
                    data: ${cantidad},
                    backgroundColor: [
                        '#db2777', 
                        '#3b82f6', 
                        '#10b981', 
                        '#8310b9', 
                        '#f59e0b'  
                    ],
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { padding: 20, usePointStyle: true }
                    }
                },
                cutout: '70%'
            }
        });
    }

    // ----------------------------------------------------------------------
    // GRÁFICA 01: Entradas y Salidas en la última semana (Líneas / Barras)
    // ----------------------------------------------------------------------
    const ctx01 = document.getElementById('myChart01');
    if (ctx01) {
        new Chart(ctx01, {
            type: 'bar',
            data: {
                labels: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
                datasets: [
                    {
                        label: 'Entradas (IN)',
                        data: ${in},
                        backgroundColor: '#10b981', // emerald
                        borderRadius: 4
                    },
                    {
                        label: 'Salidas (OUT)',
                        data: ${out},
                        backgroundColor: '#db2777', // pink/accent
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: { beginAtZero: true, grid: { color: '#f3f4f6' } },
                    x: { grid: { display: false } }
                },
                plugins: {
                    legend: {
                        position: 'top',
                        align: 'end',
                        labels: { usePointStyle: true, boxWidth: 8 }
                    }
                }
            }
        });
    }

    // ----------------------------------------------------------------------
    // GRÁFICA 02: Trámites en la última semana por Estado (Línea)
    // ----------------------------------------------------------------------
    const ctx02 = document.getElementById('myChart02');
    if (ctx02) {
        new Chart(ctx02, {
            type: 'line',
            data: {
                labels: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
                datasets: [
                    {
                        label: 'Aprobados',
                        data: ${completed},
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        tension: 0.4, // Curvas suaves
                        fill: true
                    },
                    {
                        label: 'Rechazados',
                        data: ${rejected},
                        borderColor: '#ef4444',
                        backgroundColor: 'transparent',
                        tension: 0.4
                    },
                    {
                        label: 'Pendientes',
                        data: ${pending},
                        borderColor: '#f59e0b',
                        backgroundColor: 'transparent',
                        tension: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                scales: {
                    y: { beginAtZero: true, grid: { color: '#f3f4f6' } },
                    x: { grid: { display: false } }
                },
                plugins: {
                    legend: { position: 'top', labels: { usePointStyle: true } }
                }
            }
        });
    }
});
</script>
</body>

</html>