<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <title>Dashboard | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main">
        <div>
            <h1 class="page-title">Dashboard</h1>
            <p class="page-subtitle">Resumen general del sistema</p>
        </div>

        <div class="panel-form text-center py-12">
            <h2 class="text-xl font-bold text-gray-700">📊 Dashboard</h2>
            <p class="text-gray-500 mt-2">Vista pendiente de migrar (Sprint 2).</p>
            <p class="text-sm text-gray-400 mt-4">Tu rol actual: <strong><%= session.getAttribute("roleName") %></strong></p>
        </div>
    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>