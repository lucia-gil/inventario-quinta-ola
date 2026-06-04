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
    <title>Auditoría | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=3" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
</head>

<body class="page-body">

<%-- 🛡️ ENVOLTURA PARA EVITAR EL SOLAPAMIENTO DEL SIDEBAR --%>
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <div class="flex items-center gap-4 mb-8">
                <div class="page-icon-title">
                    <i data-lucide="shield-check" class="w-7 h-7 text-accent"></i>
                </div>
                <div>
                    <h1 class="page-title">Bitácora de Auditoría</h1>
                    <p class="page-subtitle">Registro de trazabilidad y seguridad del sistema.</p>
                </div>
            </div>

            <div class="table-panel">
                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th-center">Fecha y Hora</th>
                            <th class="th-center">Usuario</th>
                            <th class="th-center">Cargo</th>
                            <th class="th">Acción Realizada</th>
                        </tr>
                        </thead>
                        <tbody class="table-body">

                        <tr class="table-row">
                            <td class="td-center text-gray-500 font-mono text-xs">2026-05-07 16:40</td>
                            <td class="td-center font-semibold text-gray-800">Gianina Marquez</td>
                            <td class="td-center">
                                <span class="role-admin" style="background:#f3e8ff;color:#7c3aed;border-color:#e9d5ff">SuperAdmin</span>
                            </td>
                            <td class="td">
                                Cambió el rol de <span class="font-bold text-gray-800">Juan Pérez</span> a <span class="role-admin ml-1">Admin</span>.
                            </td>
                        </tr>

                        <tr class="table-row">
                            <td class="td-center text-gray-500 font-mono text-xs">2026-05-07 15:12</td>
                            <td class="td-center font-semibold text-gray-800">Juan Pérez</td>
                            <td class="td-center">
                                <span class="role-admin">Admin</span>
                            </td>
                            <td class="td">
                                Aprobó la transacción <span class="status-approved ml-1">TXN-0002</span>
                            </td>
                        </tr>

                        </tbody>
                    </table>
                </div>

                <div class="panel-footer">
                    <p class="panel-count-text">
                        Mostrando <span id="pagi-inicio" class="font-bold text-gray-700">1</span> a <span id="pagi-fin" class="font-bold text-gray-700">10</span> de <span id="total-items" class="font-bold text-gray-700">2</span> registros
                    </p>

                    <div id="contenedor-paginacion" class="flex gap-2"></div>
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
