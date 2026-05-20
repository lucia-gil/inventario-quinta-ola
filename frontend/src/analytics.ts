import { Chart } from 'chart.js/auto';

document.addEventListener('DOMContentLoaded', async () => {
    
    // Configuración estética general de las gráficas
    Chart.defaults.font.family = "'Inter', 'sans-serif'";
    Chart.defaults.color = '#6b7280'; // text-gray-500

    try {
        // FETCH SIMULTÁNEO A TUS DOS ENDPOINTS REALES
        const [resItems, resHistory] = await Promise.all([
            fetch('/api/items', { credentials: 'include' }),
            fetch('/api/transactions', { credentials: 'include' })
        ]);

        if (!resItems.ok || !resHistory.ok) {
            throw new Error("No se pudo conectar con los Servlets del servidor.");
        }

        // Parseamos los JSON reales de tu base de datos
        const listadoMateriales = await resItems.json();
        const historialSolicitudes = await resHistory.json();

        // ======================================================================
        // GRÁFICA 00: Distribución de Stock por Categoría Real (Doughnut)
        // ======================================================================
        const conteoEtiquetas: Record<string, number> = {};

        listadoMateriales.forEach((item: any) => {
            // Capturamos el stock físico real (usando el alias exacto de tu DAO: cachedQuantity)
            const stockActual = item.cachedQuantity || 0;

            // 🌟 EVALUACIÓN REAL DE TU PROPIEDAD 'tags' (que es un Array de Strings)
            if (item.tags && Array.isArray(item.tags) && item.tags.length > 0) {
                
                // Si un ítem tiene múltiples tags, le sumamos el stock a cada una de sus categorías
                item.tags.forEach((tag: string) => {
                    const nombreTag = tag.toUpperCase().trim();
                    if (conteoEtiquetas[nombreTag] !== undefined) {
                        conteoEtiquetas[nombreTag] += stockActual;
                    } else {
                        conteoEtiquetas[nombreTag] = stockActual;
                    }
                });

            } else {
                // Si por alguna razón el ítem no tiene ninguna etiqueta asignada en item_tags
                if (conteoEtiquetas['SIN ETIQUETA'] !== undefined) {
                    conteoEtiquetas['SIN ETIQUETA'] += stockActual;
                } else {
                    conteoEtiquetas['SIN ETIQUETA'] = stockActual;
                }
            }
        });

        const ctx00 = document.getElementById('myChart00') as HTMLCanvasElement;
        if (ctx00) {
            new Chart(ctx00, {
                type: 'doughnut',
                data: {
                    labels: Object.keys(conteoEtiquetas),
                    datasets: [{
                        data: Object.values(conteoEtiquetas),
                        backgroundColor: ['#3b82f6', '#10b981', '#f59e0b', '#db2777', '#9ca3af'],
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

        // ======================================================================
        // GRÁFICAS 01 Y 02: Procesamiento Semanal Basado en tus Solicitudes
        // ======================================================================
        // Inicializamos contadores para los 7 días de la semana según Javascript (0=Dom, 1=Lun...)
        const entradasPorDia = [0, 0, 0, 0, 0, 0, 0];
        const salidasPorDia = [0, 0, 0, 0, 0, 0, 0];
        
        const aprobadasPorDia = [0, 0, 0, 0, 0, 0, 0];
        const rechazadasPorDia = [0, 0, 0, 0, 0, 0, 0];
        const pendientesPorDia = [0, 0, 0, 0, 0, 0, 0];

        historialSolicitudes.forEach((t: any) => {
            // En tu servlet el campo de fecha es 'createdAt'
            if (!t.createdAt) return;
            
            const fechaObj = new Date(t.createdAt);
            const numeroDia = fechaObj.getDay(); // 0 = Domingo, 1 = Lunes, etc.

            // 1. Gráfica de Barras: Filtramos por tipo (t.type es "IN" o "OUT")
            const tipo = t.type ? t.type.toUpperCase() : 'OUT';
            const cantidad = t.quantity || 0;
            if (tipo === 'IN')  entradasPorDia[numeroDia] += cantidad;
            if (tipo === 'OUT') salidasPorDia[numeroDia] += cantidad;

            // 2. Gráfica de Líneas: Estados procesados con tu método t.getStatusFrontend()
            // Como tu servlet ejecuta t.setStatus(t.getStatusFrontend()), los estados llegan normalizados
            const estado = t.status ? t.status.toLowerCase() : '';
            
            if (estado === 'aprobada' || estado === 'entregada' || estado === 'approved' || estado === 'completed') {
                aprobadasPorDia[numeroDia]++;
            } else if (estado === 'rechazada' || estado === 'rejected') {
                rechazadasPorDia[numeroDia]++;
            } else {
                // 'pendiente' o 'pending'
                pendientesPorDia[numeroDia]++;
            }
        });

        // Rotamos el arreglo para que visualmente empiece en Lunes y termine en Domingo
        const ordenarSemana = (arr: number[]) => [...arr.slice(1), arr[0]];
        const labelsSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

        // GRÁFICA 01: Entradas y Salidas Semanales (Barras)
        const ctx01 = document.getElementById('myChart01') as HTMLCanvasElement;
        if (ctx01) {
            new Chart(ctx01, {
                type: 'bar',
                data: {
                    labels: labelsSemana,
                    datasets: [
                        {
                            label: 'Entradas (IN)',
                            data: ordenarSemana(entradasPorDia),
                            backgroundColor: '#10b981', // emerald-500
                            borderRadius: 4
                        },
                        {
                            label: 'Salidas (OUT)',
                            data: ordenarSemana(salidasPorDia),
                            backgroundColor: '#db2777', // pink-600
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

        // GRÁFICA 02: Solicitudes por Estado por Día (Líneas)
        const ctx02 = document.getElementById('myChart02') as HTMLCanvasElement;
        if (ctx02) {
            new Chart(ctx02, {
                type: 'line',
                data: {
                    labels: labelsSemana,
                    datasets: [
                        {
                            label: 'Aprobados',
                            data: ordenarSemana(aprobadasPorDia),
                            borderColor: '#10b981',
                            backgroundColor: 'rgba(16, 185, 129, 0.1)',
                            tension: 0.4,
                            fill: true
                        },
                        {
                            label: 'Rechazados',
                            data: ordenarSemana(rechazadasPorDia),
                            borderColor: '#ef4444',
                            backgroundColor: 'transparent',
                            tension: 0.4
                        },
                        {
                            label: 'Pendientes',
                            data: ordenarSemana(pendientesPorDia),
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

    } catch (error) {
        console.error("Error al renderizar analíticas con la data de la BD:", error);
    }
});