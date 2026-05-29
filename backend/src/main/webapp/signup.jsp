<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <title>Crear cuenta | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="min-h-screen flex items-center justify-center bg-gray-50 p-4">

    <div class="bg-white shadow-2xl rounded-2xl p-10 max-w-md w-full">
        <div class="text-center mb-8">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png"
                 class="h-16 mx-auto mb-4"/>
            <h1 class="text-2xl font-bold text-gray-900">Crear cuenta</h1>
            <p class="text-gray-500 text-sm mt-1">Regístrate en el sistema</p>
        </div>

        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 mb-4 text-sm">
                <%= error %>
            </div>
        <% } %>

        <form action="<%= ctx %>/AuthServlet" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="signup"/>

            <div>
                <label class="form-label">Nombre completo</label>
                <input type="text" name="name" required class="input-page"/>
            </div>

            <div>
                <label class="form-label">DNI</label>
                <input type="text" name="dni" required maxlength="8" pattern="[0-9]{8}"
                       class="input-page" placeholder="8 dígitos"/>
            </div>

            <div>
                <label class="form-label">Correo</label>
                <input type="email" name="email" required class="input-page"/>
            </div>

            <div>
                <label class="form-label">Contraseña</label>
                <input type="password" name="password" required minlength="8"
                       class="input-page" placeholder="Mínimo 8 caracteres"/>
            </div>

            <button type="submit" class="btn-submit">Crear cuenta</button>
        </form>

        <div class="mt-6 text-center text-sm text-gray-600">
            ¿Ya tienes cuenta?
            <a href="<%= ctx %>/AuthServlet?action=formLogin"
               class="text-pink-600 font-semibold">Inicia sesión</a>
        </div>
    </div>

</body>
</html>