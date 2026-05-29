<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <title>Entregas | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main">
        <div>
            <h1 class="page-title">Entregas Pendientes</h1>
            <p class="page-subtitle">Vista del Encargado de Depósito</p>
        </div>

        <div class="panel-form text-center py-12">
            <h2 class="text-xl font-bold text-blue-700">📦 Vista Depósito</h2>
            <p class="text-gray-500 mt-2">Vista pendiente de migrar (Sprint 3).</p>
        </div>
    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>