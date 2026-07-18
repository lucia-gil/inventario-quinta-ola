<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();

    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect(ctx + "/AuthServlet?action=formLogin");
        return;
    }

    Integer roleId = (Integer) userSession.getAttribute("roleId");
    if (roleId == null || (roleId != 3 && roleId != 4)) {
        response.sendRedirect(ctx + "/HomeServlet");
        return;
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Análisis de Inventario | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=13" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        /* ── Responsive: grids que en el original eran fijos a 3 columnas ── */
        .analytics-main-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1.5rem;
        }
        @media (min-width: 1100px) {
            .analytics-main-grid { grid-template-columns: repeat(3, 1fr); }
        }

        .analytics-report-cards {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1rem;
        }
        @media (min-width: 640px) {
            .analytics-report-cards { grid-template-columns: repeat(2, 1fr); }
        }
        @media (min-width: 900px) {
            .analytics-report-cards { grid-template-columns: repeat(3, 1fr); }
        }
    </style>
</head>

<body class="page-body">
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- ── Encabezado ─────────────────────────────────────────────── --%>
            <div style="display:flex; justify-content:space-between; align-items:center; gap:1rem; margin-bottom:2rem; flex-wrap:wrap;">
                <div style="display:flex; align-items:center; gap:1rem;">
                    <div class="page-icon-title">
                        <i data-lucide="bar-chart-2" style="width:28px; height:28px; color:var(--purple);"></i>
                    </div>
                    <div>
                        <h1 class="page-title">Análisis de Inventario</h1>
                        <p class="page-subtitle">Métricas, rendimiento y visualización de datos del sistema.</p>
                    </div>
                </div>
                <a href="<%= ctx %>/HistoryServlet" class="btn-ghost">
                    <i data-lucide="arrow-left" style="width:16px; height:16px;"></i>
                    Volver
                </a>
            </div>

            <%-- ── Grid principal: 3 columnas ─────────────────────────────── --%>
            <div class="analytics-main-grid">

                <%-- Gráfica 1: Distribución (1 columna) --%>
                <div class="panel" style="grid-column:span 1; display:flex; flex-direction:column; padding:1.25rem;">
                    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:1.5rem;">
                        <h2 style="font-size:1rem; font-weight:700; color:var(--gray-800); margin:0;">Distribución</h2>
                        <i data-lucide="pie-chart" style="width:20px; height:20px; color:var(--pink);"></i>
                    </div>
                    <div style="position:relative; width:100%; flex:1; display:flex; align-items:center; justify-content:center; min-height:250px;">
                        <canvas id="myChart00"></canvas>
                    </div>
                </div>

                <%-- Gráfica 2: Entradas y Salidas (2 columnas) --%>
                <div class="panel" style="grid-column:span 2; display:flex; flex-direction:column; padding:1.25rem;">
                    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:1.5rem;">
                        <h2 style="font-size:1rem; font-weight:700; color:var(--gray-800); margin:0;">
                            Entradas y Salidas
                            <span style="font-size:0.8rem; font-weight:400; color:var(--gray-400); margin-left:0.4rem;">(Última Semana)</span>
                        </h2>
                        <i data-lucide="trending-up" style="width:20px; height:20px; color:#2563eb;"></i>
                    </div>
                    <div style="position:relative; width:100%; flex:1; display:flex; align-items:center; justify-content:center; min-height:250px;">
                        <canvas id="myChart01"></canvas>
                    </div>
                </div>

                <%-- Gráfica 3: Trámites por Estado (3 columnas) --%>
                <div class="panel" style="grid-column:span 3; display:flex; flex-direction:column; padding:1.25rem;">
                    <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:1.5rem;">
                        <h2 style="font-size:1rem; font-weight:700; color:var(--gray-800); margin:0;">
                            Trámites por Estado
                            <span style="font-size:0.8rem; font-weight:400; color:var(--gray-400); margin-left:0.4rem;">(Última Semana)</span>
                        </h2>
                        <i data-lucide="activity" style="width:20px; height:20px; color:#059669;"></i>
                    </div>
                    <div style="position:relative; width:100%; min-height:250px;">
                        <canvas id="myChart02"></canvas>
                    </div>
                </div>

                <%-- ── Reportes y Exportaciones (3 columnas) ───────────────── --%>
                <div class="panel" style="grid-column:span 3; display:flex; flex-direction:column; padding:1.25rem;">

                    <div style="margin-bottom:1.5rem;">
                        <h2 style="font-size:1rem; font-weight:700; color:var(--gray-800); margin:0 0 0.25rem; display:flex; align-items:center; gap:0.5rem;">
                            <i data-lucide="file-text" style="width:20px; height:20px; color:var(--purple);"></i>
                            Reportes y Exportaciones
                        </h2>
                        <p style="font-size:0.82rem; color:var(--gray-500); margin:0;">
                            Descarga reportes detallados en formato CSV o Excel (.xlsx)
                        </p>
                    </div>

                    <%-- Filtro de fechas --%>
                    <div style="background:var(--gray-50); border:1px solid var(--gray-100); border-radius:12px; padding:1rem 1.25rem; margin-bottom:1.25rem;">
                        <div style="display:flex; align-items:center; gap:1rem; flex-wrap:wrap;">
                            <div style="display:flex; align-items:center; gap:0.5rem;">
                                <i data-lucide="calendar-range" style="width:18px; height:18px; color:var(--purple);"></i>
                                <span style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.8px; color:var(--gray-600);">
                                    Rango de fechas
                                </span>
                            </div>
                            <div style="display:flex; align-items:center; gap:0.5rem;">
                                <label style="font-size:0.8rem; color:var(--gray-600); font-weight:600;">Desde:</label>
                                <input type="date" id="report-from"
                                       style="border:1.5px solid var(--gray-200); border-radius:6px; padding:0.4rem 0.6rem; font-size:0.85rem; font-family:inherit;"/>
                            </div>
                            <div style="display:flex; align-items:center; gap:0.5rem;">
                                <label style="font-size:0.8rem; color:var(--gray-600); font-weight:600;">Hasta:</label>
                                <input type="date" id="report-to"
                                       style="border:1.5px solid var(--gray-200); border-radius:6px; padding:0.4rem 0.6rem; font-size:0.85rem; font-family:inherit;"/>
                            </div>
                            <span style="font-size:0.72rem; color:var(--gray-500); margin-left:auto;">
                                Por defecto: mes en curso
                            </span>
                        </div>
                    </div>

                    <%-- Cards de reportes: siempre 3 columnas --%>
                    <div class="analytics-report-cards">

                        <%-- Reporte 1: Salidas del período --%>
                        <div style="border:1.5px solid var(--gray-100); border-radius:12px; padding:1.25rem; transition:all 0.2s;"
                             onmouseover="this.style.borderColor='var(--purple)';this.style.boxShadow='0 4px 16px rgba(91,31,168,0.10)'"
                             onmouseout="this.style.borderColor='var(--gray-100)';this.style.boxShadow='none'">
                            <div style="display:flex; align-items:center; gap:0.6rem; margin-bottom:0.75rem;">
                                <div style="width:36px; height:36px; border-radius:8px; background:var(--purple-bg); display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                    <i data-lucide="package-2" style="width:18px; height:18px; color:var(--purple);"></i>
                                </div>
                                <h3 style="font-size:0.9rem; font-weight:700; color:var(--gray-800); margin:0;">
                                    Salidas del Período
                                </h3>
                            </div>
                            <p style="font-size:0.8rem; color:var(--gray-500); line-height:1.5; margin-bottom:1rem; min-height:42px;">
                                Listado completo de materiales entregados en el rango seleccionado. Reemplaza el Excel mensual manual.
                            </p>
                            <div style="display:flex; gap:0.5rem;">
                                <button onclick="descargarReporte('salidas','csv')"
                                        style="flex:1; background:var(--white); border:1.5px solid var(--purple); color:var(--purple); padding:0.5rem 0.6rem; border-radius:6px; font-size:0.76rem; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; gap:0.3rem;">
                                    <i data-lucide="file-text" style="width:13px; height:13px;"></i> CSV
                                </button>
                                <button onclick="descargarReporte('salidas','xlsx')"
                                        style="flex:1; background:linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%); border:none; color:var(--white); padding:0.5rem 0.6rem; border-radius:6px; font-size:0.76rem; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; gap:0.3rem;">
                                    <i data-lucide="file-spreadsheet" style="width:13px; height:13px;"></i> Excel
                                </button>
                            </div>
                        </div>

                        <%-- Reporte 2: Consumo por material --%>
                        <div style="border:1.5px solid var(--gray-100); border-radius:12px; padding:1.25rem; transition:all 0.2s;"
                             onmouseover="this.style.borderColor='var(--purple)';this.style.boxShadow='0 4px 16px rgba(91,31,168,0.10)'"
                             onmouseout="this.style.borderColor='var(--gray-100)';this.style.boxShadow='none'">
                            <div style="display:flex; align-items:center; gap:0.6rem; margin-bottom:0.75rem;">
                                <div style="width:36px; height:36px; border-radius:8px; background:var(--pink-bg); display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                    <i data-lucide="bar-chart-3" style="width:18px; height:18px; color:var(--pink);"></i>
                                </div>
                                <h3 style="font-size:0.9rem; font-weight:700; color:var(--gray-800); margin:0;">
                                    Consumo por Material
                                </h3>
                            </div>
                            <p style="font-size:0.8rem; color:var(--gray-500); line-height:1.5; margin-bottom:1rem; min-height:42px;">
                                Total consumido por cada material en el período, con stock actual y stock mínimo.
                            </p>
                            <div style="display:flex; gap:0.5rem;">
                                <button onclick="descargarReporte('consumo','csv')"
                                        style="flex:1; background:var(--white); border:1.5px solid var(--purple); color:var(--purple); padding:0.5rem 0.6rem; border-radius:6px; font-size:0.76rem; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; gap:0.3rem;">
                                    <i data-lucide="file-text" style="width:13px; height:13px;"></i> CSV
                                </button>
                                <button onclick="descargarReporte('consumo','xlsx')"
                                        style="flex:1; background:linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%); border:none; color:var(--white); padding:0.5rem 0.6rem; border-radius:6px; font-size:0.76rem; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; gap:0.3rem;">
                                    <i data-lucide="file-spreadsheet" style="width:13px; height:13px;"></i> Excel
                                </button>
                            </div>
                        </div>

                        <%-- Reporte 3: Inventario actual --%>
                        <div style="border:1.5px solid var(--gray-100); border-radius:12px; padding:1.25rem; transition:all 0.2s;"
                             onmouseover="this.style.borderColor='var(--purple)';this.style.boxShadow='0 4px 16px rgba(91,31,168,0.10)'"
                             onmouseout="this.style.borderColor='var(--gray-100)';this.style.boxShadow='none'">
                            <div style="display:flex; align-items:center; gap:0.6rem; margin-bottom:0.75rem;">
                                <div style="width:36px; height:36px; border-radius:8px; background:#FEF3C7; display:flex; align-items:center; justify-content:center; flex-shrink:0;">
                                    <i data-lucide="warehouse" style="width:18px; height:18px; color:#F59E0B;"></i>
                                </div>
                                <h3 style="font-size:0.9rem; font-weight:700; color:var(--gray-800); margin:0;">
                                    Inventario Actual
                                </h3>
                            </div>
                            <p style="font-size:0.8rem; color:var(--gray-500); line-height:1.5; margin-bottom:1rem; min-height:42px;">
                                Foto actual del inventario: stock disponible, mínimos y estado. No depende de fechas.
                            </p>
                            <div style="display:flex; gap:0.5rem;">
                                <button onclick="descargarReporte('inventario','csv')"
                                        style="flex:1; background:var(--white); border:1.5px solid var(--purple); color:var(--purple); padding:0.5rem 0.6rem; border-radius:6px; font-size:0.76rem; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; gap:0.3rem;">
                                    <i data-lucide="file-text" style="width:13px; height:13px;"></i> CSV
                                </button>
                                <button onclick="descargarReporte('inventario','xlsx')"
                                        style="flex:1; background:linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%); border:none; color:var(--white); padding:0.5rem 0.6rem; border-radius:6px; font-size:0.76rem; font-weight:700; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; gap:0.3rem;">
                                    <i data-lucide="file-spreadsheet" style="width:13px; height:13px;"></i> Excel
                                </button>
                            </div>
                        </div>

                    </div><%-- /cards --%>
                </div><%-- /reportes panel --%>

            </div><%-- /grid principal --%>

        </main>

        <jsp:include page="includes/footer.jsp"/>
    </div>
</div><%-- /layout-wrapper --%>

<script>lucide.createIcons();</script>

<script>
    function descargarReporte(action, format) {
        const from = document.getElementById('report-from').value;
        const to   = document.getElementById('report-to').value;
        let url = '<%= ctx %>/ReportServlet?action=' + action + '&format=' + format;
        if (from) url += '&from=' + from;
        if (to)   url += '&to='   + to;
        window.location.href = url;
    }

    document.addEventListener('DOMContentLoaded', function () {
        const today    = new Date();
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        const fmt = (d) => {
            const y  = d.getFullYear();
            const m  = String(d.getMonth() + 1).padStart(2, '0');
            const da = String(d.getDate()).padStart(2, '0');
            return y + '-' + m + '-' + da;
        };
        const fromInput = document.getElementById('report-from');
        const toInput   = document.getElementById('report-to');
        if (fromInput) fromInput.value = fmt(firstDay);
        if (toInput)   toInput.value   = fmt(today);
    });
</script>

<script>
    document.addEventListener('DOMContentLoaded', () => {

        Chart.defaults.font.family = "'Inter', sans-serif";
        Chart.defaults.color = '#6b7280';

        // GRÁFICA 00: Distribución (Doughnut)
        const ctx00 = document.getElementById('myChart00');
        if (ctx00) {
            new Chart(ctx00, {
                type: 'doughnut',
                data: {
                    labels: ${item_name},
                    datasets: [{
                        data: ${cantidad},
                        backgroundColor: ['#db2777','#3b82f6','#10b981','#8310b9','#f59e0b','#ef4444','#6366f1'],
                        borderWidth: 0,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom', labels: { padding: 20, usePointStyle: true } }
                    },
                    cutout: '70%'
                }
            });
        }

        // GRÁFICA 01: Entradas y Salidas (Barras)
        const ctx01 = document.getElementById('myChart01');
        if (ctx01) {
            new Chart(ctx01, {
                type: 'bar',
                data: {
                    labels: ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'],
                    datasets: [
                        { label: 'Entradas (IN)',  data: ${in},  backgroundColor: '#10b981', borderRadius: 4 },
                        { label: 'Salidas (OUT)',  data: ${out}, backgroundColor: '#db2777', borderRadius: 4 }
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
                        legend: { position: 'top', align: 'end', labels: { usePointStyle: true, boxWidth: 8 } }
                    }
                }
            });
        }

        // GRÁFICA 02: Trámites por Estado (Línea)
        const ctx02 = document.getElementById('myChart02');
        if (ctx02) {
            new Chart(ctx02, {
                type: 'line',
                data: {
                    labels: ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'],
                    datasets: [
                        { label: 'Aprobados',  data: ${completed}, borderColor: '#10b981', backgroundColor: 'rgba(16,185,129,0.1)', tension: 0.4, fill: true },
                        { label: 'Rechazados', data: ${rejected},  borderColor: '#ef4444', backgroundColor: 'transparent', tension: 0.4 },
                        { label: 'Pendientes', data: ${pending},   borderColor: '#f59e0b', backgroundColor: 'transparent', tension: 0.4 }
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
