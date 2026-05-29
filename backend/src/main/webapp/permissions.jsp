<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <title>Permisos | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main">
        <div>
            <h1 class="page-title">Gestión de Permisos (SuperAdmin)</h1>
            <p class="page-subtitle">Control de privilegios del sistema</p>
        </div>

        <div class="panel-form text-center py-12">
            <h2 class="text-xl font-bold text-purple-700">🛡️ Vista SuperAdmin</h2>
            <p class="text-gray-500 mt-2">Vista pendiente de migrar.</p>
        </div>
    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>