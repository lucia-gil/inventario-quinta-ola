<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();

    // 1. SEGURIDAD: Validar que la sesión esté activa
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect(ctx + "/AuthServlet?action=formLogin");
        return;
    }

    // 2. CONTROL DE ACCESO: Solo Manager (3) y Admin (4).
    //    SuperAdmin (5) NO entra: audita, no consume analíticas operativas.
    //    Member (2) y Viewer (1) tampoco.
    Integer roleId = (Integer) userSession.getAttribute("roleId");
    if (roleId == null || (roleId != 3 && roleId != 4)) {
        response.sendRedirect(ctx + "/HomeServlet");
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

            <%-- ═══════════════════════════════════════════════════════════ --%>
            <%-- SECCIÓN DE REPORTES Y EXPORTACIONES                          --%>
            <%-- ═══════════════════════════════════════════════════════════ --%>
            <div class="panel md:col-span-3 flex flex-col p-4">

                <div class="flex items-center justify-between mb-6">
                    <div>
                        <h2 class="text-lg font-bold text-gray-800 flex items-center gap-2">
                            <i data-lucide="file-text" class="w-5 h-5" style="color: var(--purple);"></i>
                            Reportes y Exportaciones
                        </h2>
                        <p class="text-sm text-gray-500 mt-1">
                            Descarga reportes detallados en formato CSV o Excel (.xlsx)
                        </p>
                    </div>
                </div>

                <%-- Filtro de fechas compartido --%>
                <div style="background: var(--gray-50); border: 1px solid var(--gray-100); border-radius: 12px; padding: 1rem 1.25rem; margin-bottom: 1.25rem;">
                    <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                        <div style="display: flex; align-items: center; gap: 0.5rem;">
                            <i data-lucide="calendar-range" style="width: 18px; height: 18px; color: var(--purple);"></i>
                            <span style="font-size: 0.78rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px; color: var(--gray-600);">
                            Rango de fechas
                        </span>
                        </div>

                        <div style="display: flex; align-items: center; gap: 0.5rem;">
                            <label style="font-size: 0.8rem; color: var(--gray-600); font-weight: 600;">Desde:</label>
                            <input type="date" id="report-from"
                                   style="border: 1.5px solid var(--gray-200); border-radius: 6px; padding: 0.4rem 0.6rem; font-size: 0.85rem; font-family: inherit;"/>
                        </div>

                        <div style="display: flex; align-items: center; gap: 0.5rem;">
                            <label style="font-size: 0.8rem; color: var(--gray-600); font-weight: 600;">Hasta:</label>
                            <input type="date" id="report-to"
                                   style="border: 1.5px solid var(--gray-200); border-radius: 6px; padding: 0.4rem 0.6rem; font-size: 0.85rem; font-family: inherit;"/>
                        </div>

                        <span style="font-size: 0.72rem; color: var(--gray-500); margin-left: auto;">
                        Por defecto: mes en curso
                    </span>
                    </div>
                </div>

                <%-- Cards de reportes --%>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1rem;">

                    <%-- Reporte 1: Salidas del período --%>
                    <div style="border: 1.5px solid var(--gray-100); border-radius: 12px; padding: 1.25rem; transition: all 0.2s;"
                         onmouseover="this.style.borderColor='var(--purple)'; this.style.boxShadow='0 4px 16px rgba(91,31,168,0.10)'"
                         onmouseout="this.style.borderColor='var(--gray-100)'; this.style.boxShadow='none'">

                        <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.5rem;">
                            <div style="width: 36px; height: 36px; border-radius: 8px; background: var(--purple-bg); display: flex; align-items: center; justify-content: center;">
                                <i data-lucide="package-2" style="width: 18px; height: 18px; color: var(--purple);"></i>
                            </div>
                            <h3 style="font-size: 0.95rem; font-weight: 700; color: var(--gray-800); margin: 0;">
                                Salidas del Período
                            </h3>
                        </div>

                        <p style="font-size: 0.8rem; color: var(--gray-500); line-height: 1.5; margin-bottom: 1rem; min-height: 38px;">
                            Listado completo de materiales entregados en el rango seleccionado. Reemplaza el Excel mensual manual.
                        </p>

                        <div style="display: flex; gap: 0.5rem;">
                            <button onclick="descargarReporte('salidas', 'csv')"
                                    style="flex: 1; background: var(--white); border: 1.5px solid var(--purple); color: var(--purple); padding: 0.5rem 0.8rem; border-radius: 6px; font-size: 0.78rem; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 0.3rem;">
                                <i data-lucide="file-text" style="width: 13px; height: 13px;"></i>
                                CSV
                            </button>
                            <button onclick="descargarReporte('salidas', 'xlsx')"
                                    style="flex: 1; background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%); border: none; color: var(--white); padding: 0.5rem 0.8rem; border-radius: 6px; font-size: 0.78rem; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 0.3rem;">
                                <i data-lucide="file-spreadsheet" style="width: 13px; height: 13px;"></i>
                                Excel
                            </button>
                        </div>
                    </div>

                    <%-- Reporte 2: Consumo por material --%>
                    <div style="border: 1.5px solid var(--gray-100); border-radius: 12px; padding: 1.25rem; transition: all 0.2s;"
                         onmouseover="this.style.borderColor='var(--purple)'; this.style.boxShadow='0 4px 16px rgba(91,31,168,0.10)'"
                         onmouseout="this.style.borderColor='var(--gray-100)'; this.style.boxShadow='none'">

                        <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.5rem;">
                            <div style="width: 36px; height: 36px; border-radius: 8px; background: var(--pink-bg); display: flex; align-items: center; justify-content: center;">
                                <i data-lucide="bar-chart-3" style="width: 18px; height: 18px; color: var(--pink);"></i>
                            </div>
                            <h3 style="font-size: 0.95rem; font-weight: 700; color: var(--gray-800); margin: 0;">
                                Consumo por Material
                            </h3>
                        </div>

                        <p style="font-size: 0.8rem; color: var(--gray-500); line-height: 1.5; margin-bottom: 1rem; min-height: 38px;">
                            Total consumido por cada material en el período, con stock actual y stock mínimo.
                        </p>

                        <div style="display: flex; gap: 0.5rem;">
                            <button onclick="descargarReporte('consumo', 'csv')"
                                    style="flex: 1; background: var(--white); border: 1.5px solid var(--purple); color: var(--purple); padding: 0.5rem 0.8rem; border-radius: 6px; font-size: 0.78rem; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 0.3rem;">
                                <i data-lucide="file-text" style="width: 13px; height: 13px;"></i>
                                CSV
                            </button>
                            <button onclick="descargarReporte('consumo', 'xlsx')"
                                    style="flex: 1; background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%); border: none; color: var(--white); padding: 0.5rem 0.8rem; border-radius: 6px; font-size: 0.78rem; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 0.3rem;">
                                <i data-lucide="file-spreadsheet" style="width: 13px; height: 13px;"></i>
                                Excel
                            </button>
                        </div>
                    </div>

                    <%-- Reporte 3: Inventario actual --%>
                    <div style="border: 1.5px solid var(--gray-100); border-radius: 12px; padding: 1.25rem; transition: all 0.2s;"
                         onmouseover="this.style.borderColor='var(--purple)'; this.style.boxShadow='0 4px 16px rgba(91,31,168,0.10)'"
                         onmouseout="this.style.borderColor='var(--gray-100)'; this.style.boxShadow='none'">

                        <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 0.5rem;">
                            <div style="width: 36px; height: 36px; border-radius: 8px; background: #FEF3C7; display: flex; align-items: center; justify-content: center;">
                                <i data-lucide="warehouse" style="width: 18px; height: 18px; color: #F59E0B;"></i>
                            </div>
                            <h3 style="font-size: 0.95rem; font-weight: 700; color: var(--gray-800); margin: 0;">
                                Inventario Actual
                            </h3>
                        </div>

                        <p style="font-size: 0.8rem; color: var(--gray-500); line-height: 1.5; margin-bottom: 1rem; min-height: 38px;">
                            Foto actual del inventario: stock disponible, mínimos y estado. No depende de fechas.
                        </p>

                        <div style="display: flex; gap: 0.5rem;">
                            <button onclick="descargarReporte('inventario', 'csv')"
                                    style="flex: 1; background: var(--white); border: 1.5px solid var(--purple); color: var(--purple); padding: 0.5rem 0.8rem; border-radius: 6px; font-size: 0.78rem; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 0.3rem;">
                                <i data-lucide="file-text" style="width: 13px; height: 13px;"></i>
                                CSV
                            </button>
                            <button onclick="descargarReporte('inventario', 'xlsx')"
                                    style="flex: 1; background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%); border: none; color: var(--white); padding: 0.5rem 0.8rem; border-radius: 6px; font-size: 0.78rem; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; justify-content: center; gap: 0.3rem;">
                                <i data-lucide="file-spreadsheet" style="width: 13px; height: 13px;"></i>
                                Excel
                            </button>
                        </div>
                    </div>

                </div>

            </div>

        </div>
    </main>
    <jsp:include page="includes/footer.jsp"/>
</div>

<script>
    lucide.createIcons();
</script>

<%-- Script de descarga de reportes --%>
<script>
    function descargarReporte(action, format) {
        const from = document.getElementById('report-from').value;
        const to   = document.getElementById('report-to').value;

        let url = '<%= ctx %>/ReportServlet?action=' + action + '&format=' + format;
        if (from) url += '&from=' + from;
        if (to)   url += '&to=' + to;

        // Disparar descarga
        window.location.href = url;
    }

    // Pre-llenar fechas con el primer día del mes actual hasta hoy
    document.addEventListener('DOMContentLoaded', function() {
        const today = new Date();
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);

        const fmt = (d) => {
            const y = d.getFullYear();
            const m = String(d.getMonth() + 1).padStart(2, '0');
            const da = String(d.getDate()).padStart(2, '0');
            return y + '-' + m + '-' + da;
        };

        const fromInput = document.getElementById('report-from');
        const toInput = document.getElementById('report-to');
        if (fromInput) fromInput.value = fmt(firstDay);
        if (toInput)   toInput.value   = fmt(today);
    });
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