<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();

    // Validar por seguridad que solo el SuperAdmin (5) pueda renderizar esta vista
    Integer roleId = (Integer) session.getAttribute("roleId");
    if (roleId == null || roleId != 5) {
        response.sendRedirect(ctx + "/HomeServlet");
        return;
    }
%>
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Permisos | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=12" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
</head>

<body class="page-body">

<%-- 🛡️ ENVOLTURA PARA EVITAR EL SOLAPAMIENTO DEL SIDEBAR --%>
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <div class="page-header">
                <div>
                    <h1 class="page-title">Control de Privilegios Críticos</h1>
                    <p class="page-subtitle">Asigna o revoca permisos específicos a nivel de sistema para usuarios administrativos.</p>
                </div>
                <div class="flex gap-3">
                    <button class="btn-ghost" onclick="window.history.back()">
                        <i data-lucide="arrow-left" class="w-4 h-4 mr-1"></i> Volver
                    </button>
                </div>
            </div>

            <div class="table-panel">
                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th">Miembro</th>
                            <th class="th">Privilegios Específicos</th>
                            <th class="th-center">Acciones de Control</th>
                        </tr>
                        </thead>

                        <tbody id="permissions-tbody" class="table-body">
                        <tr class="table-row">
                            <td class="td">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-accent/10 text-accent flex items-center justify-center text-xs font-bold border border-accent/20">
                                        PA
                                    </div>
                                    <div>
                                        <span class="font-semibold text-gray-800 block">Pedro Administrador</span>
                                        <span class="text-[10px] text-gray-400 uppercase font-medium tracking-wider">Administrador</span>
                                    </div>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex flex-wrap gap-2">
                              <span class="px-2.5 py-1 text-[10px] font-bold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                                <i data-lucide="check" class="w-3 h-3"></i> inventory.edit
                              </span>
                                    <span class="px-2.5 py-1 text-[10px] font-bold rounded-full bg-blue-50 text-blue-600 border border-blue-100 flex items-center gap-1">
                                <i data-lucide="shield" class="w-3 h-3"></i> user.manage
                              </span>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex items-center justify-center gap-3">
                                    <button class="text-emerald-500 hover:text-emerald-700 bg-emerald-50 hover:bg-emerald-100 p-2 rounded-xl transition-all shadow-sm" title="Otorgar nuevo permiso">
                                        <i data-lucide="plus-circle" class="w-5 h-5"></i>
                                    </button>
                                    <button class="text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 p-2 rounded-xl transition-all shadow-sm" title="Revocar permiso">
                                        <i data-lucide="minus-circle" class="w-5 h-5"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr class="table-row">
                            <td class="td">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-purple-100 text-purple-600 flex items-center justify-center text-xs font-bold border border-purple-200">
                                        AS
                                    </div>
                                    <div>
                                        <span class="font-semibold text-gray-800 block">Ana SuperAdmin</span>
                                        <span class="role-admin inline-block mt-0.5" style="background:#f3e8ff; color:#7c3aed; border: 1px solid #e9d5ff; padding: 1px 6px; font-size: 10px; font-weight: 500; border-radius: 4px;">SuperAdmin</span>
                                    </div>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex flex-wrap gap-2">
                              <span class="px-2.5 py-1 text-[10px] font-bold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                                <i data-lucide="check" class="w-3 h-3"></i> system.all
                              </span>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex items-center justify-center gap-3">
                                    <button class="text-emerald-500 hover:text-emerald-700 bg-emerald-50 hover:bg-emerald-100 p-2 rounded-xl transition-all" title="Otorgar">
                                        <i data-lucide="plus-circle" class="w-5 h-5"></i>
                                    </button>
                                    <button class="text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 p-2 rounded-xl transition-all" title="Revocar">
                                        <i data-lucide="minus-circle" class="w-5 h-5"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr class="table-row">
                            <td class="td">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-teal-50 text-teal-600 flex items-center justify-center text-xs font-bold border border-teal-100">
                                        MA
                                    </div>
                                    <div>
                                        <span class="font-semibold text-gray-800 block">María Aprobadora</span>
                                        <span class="text-[10px] text-gray-400 uppercase font-medium tracking-wider">Aprobador</span>
                                    </div>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex flex-wrap gap-2">
                              <span class="px-2.5 py-1 text-[10px] font-bold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                                <i data-lucide="check" class="w-3 h-3"></i> request.approve
                              </span>
                                    <span class="px-2.5 py-1 text-[10px] font-bold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                                <i data-lucide="check" class="w-3 h-3"></i> request.reject
                              </span>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex items-center justify-center gap-3">
                                    <button class="text-emerald-500 hover:text-emerald-700 bg-emerald-50 hover:bg-emerald-100 p-2 rounded-xl transition-all" title="Otorgar">
                                        <i data-lucide="plus-circle" class="w-5 h-5"></i>
                                    </button>
                                    <button class="text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 p-2 rounded-xl transition-all" title="Revocar">
                                        <i data-lucide="minus-circle" class="w-5 h-5"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr class="table-row">
                            <td class="td">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center text-xs font-bold border border-amber-100">
                                        CD
                                    </div>
                                    <div>
                                        <span class="font-semibold text-gray-800 block">Carmen del Depósito</span>
                                        <span class="text-[10px] text-gray-400 uppercase font-medium tracking-wider">Encargado de Depósito</span>
                                    </div>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex flex-wrap gap-2">
                              <span class="px-2.5 py-1 text-[10px] font-bold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                                <i data-lucide="check" class="w-3 h-3"></i> stock.view
                              </span>
                                    <span class="px-2.5 py-1 text-[10px] font-bold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center gap-1">
                                <i data-lucide="check" class="w-3 h-3"></i> stock.update
                              </span>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex items-center justify-center gap-3">
                                    <button class="text-emerald-500 hover:text-emerald-700 bg-emerald-50 hover:bg-emerald-100 p-2 rounded-xl transition-all" title="Otorgar">
                                        <i data-lucide="plus-circle" class="w-5 h-5"></i>
                                    </button>
                                    <button class="text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 p-2 rounded-xl transition-all" title="Revocar">
                                        <i data-lucide="minus-circle" class="w-5 h-5"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>

                        <tr class="table-row">
                            <td class="td">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center text-xs font-bold border border-blue-100">
                                        LS
                                    </div>
                                    <div>
                                        <span class="font-semibold text-gray-800 block">Lucía Solicitante</span>
                                        <span class="text-[10px] text-gray-400 uppercase font-medium tracking-wider">Solicitante</span>
                                    </div>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex flex-wrap gap-2">
                              <span class="px-2.5 py-1 text-[10px] font-bold rounded-full bg-red-50 text-red-600 border border-red-100 flex items-center gap-1">
                                <i data-lucide="minus" class="w-3 h-3"></i> sin.privilegios
                              </span>
                                </div>
                            </td>
                            <td class="td">
                                <div class="flex items-center justify-center gap-3">
                                    <button class="text-emerald-500 hover:text-emerald-700 bg-emerald-50 hover:bg-emerald-100 p-2 rounded-xl transition-all" title="Otorgar">
                                        <i data-lucide="plus-circle" class="w-5 h-5"></i>
                                    </button>
                                    <button class="text-red-500 hover:text-red-700 bg-red-50 hover:bg-red-100 p-2 rounded-xl transition-all" title="Revocar" disabled style="opacity: 0.4; cursor: not-allowed;">
                                        <i data-lucide="minus-circle" class="w-5 h-5"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        </tbody>

                    </table>
                </div>

                <div class="panel-footer">
                    <p class="panel-count-text">Mostrando 2 usuarios con permisos especiales</p>
                </div>
            </div>
        </main>

        <script>
            lucide.createIcons();
        </script>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

</body>
</html>