// Esperamos a que el DOM cargue completamente
document.addEventListener('DOMContentLoaded', () => {
    
    // Configuración general para mantener los estilos limpios
    Chart.defaults.font.family = "'Inter', 'sans-serif'";
    Chart.defaults.color = '#6b7280'; // text-gray-500

    // ----------------------------------------------------------------------
    // GRÁFICA 00: Distribución del inventario (Doughnut / Anillo)
    // ----------------------------------------------------------------------
    const ctx00 = document.getElementById('myChart00') as HTMLCanvasElement;
    if (ctx00) {
        new Chart(ctx00, {
            type: 'doughnut',
            data: {
                labels: ['Materiales', 'Herramientas', 'Equipos', 'Otros'],
                datasets: [{
                    data: [45, 25, 20, 10],
                    backgroundColor: [
                        '#db2777', // bg-pink-600 (Accent)
                        '#3b82f6', // bg-blue-500
                        '#10b981', // bg-emerald-500
                        '#f59e0b'  // bg-amber-500
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
    const ctx01 = document.getElementById('myChart01') as HTMLCanvasElement;
    if (ctx01) {
        new Chart(ctx01, {
            type: 'bar',
            data: {
                labels: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
                datasets: [
                    {
                        label: 'Entradas (IN)',
                        data: [12, 19, 3, 5, 2, 3, 9],
                        backgroundColor: '#10b981', // emerald
                        borderRadius: 4
                    },
                    {
                        label: 'Salidas (OUT)',
                        data: [2, 3, 20, 5, 1, 4, 10],
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
    const ctx02 = document.getElementById('myChart02') as HTMLCanvasElement;
    if (ctx02) {
        new Chart(ctx02, {
            type: 'line',
            data: {
                labels: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
                datasets: [
                    {
                        label: 'Aprobados',
                        data: [15, 22, 10, 18, 25, 12, 14],
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        tension: 0.4, // Curvas suaves
                        fill: true
                    },
                    {
                        label: 'Rechazados',
                        data: [2, 1, 4, 1, 0, 2, 1],
                        borderColor: '#ef4444',
                        backgroundColor: 'transparent',
                        tension: 0.4
                    },
                    {
                        label: 'Pendientes',
                        data: [5, 8, 3, 6, 9, 4, 2],
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