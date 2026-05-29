<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <title>Iniciar Sesión | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="min-h-screen flex items-center justify-center bg-gray-50 p-4">

    <div class="bg-white shadow-2xl rounded-2xl p-10 max-w-md w-full">

        <%-- Logo y título --%>
        <div class="text-center mb-8">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png"
                 alt="Logo Quinta Ola" class="h-16 mx-auto mb-4"/>
            <h1 class="text-2xl font-bold text-gray-900">Iniciar Sesión</h1>
            <p class="text-gray-500 text-sm mt-1">Accede al sistema de inventario</p>
        </div>

        <%-- Mensaje de éxito (ej. después de registrarse) --%>
        <% if (success != null) { %>
            <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3 mb-4 text-sm">
                ✅ <%= success %>
            </div>
        <% } %>

        <%-- Mensaje de error --%>
        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 mb-4 text-sm">
                <%= error %>
            </div>
        <% } %>

        <%-- Formulario: envía POST al AuthServlet con action=login --%>
        <form action="<%= ctx %>/AuthServlet" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="login"/>

            <div>
                <label class="form-label">Correo electrónico</label>
                <input type="email" name="email" required class="input-page"
                       placeholder="ejemplo@quintaola.com"/>
            </div>

            <div>
                <label class="form-label">Contraseña</label>
                <input type="password" name="password" required class="input-page"
                       placeholder="••••••••"/>
            </div>

            <button type="submit" class="btn-submit">
                Ingresar al sistema
            </button>
        </form>

        <div class="mt-6 text-center text-sm text-gray-600">
            ¿No tienes cuenta?
            <a href="<%= ctx %>/AuthServlet?action=formSignup"
               class="text-pink-600 font-semibold">Regístrate</a>
        </div>
    </div>

</body>
</html>
