<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Iniciar Sesión | Quinta Ola</title>
    <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
</head>

<body class="min-h-screen flex items-center justify-center bg-gray-50 font-sans p-4">

    <div class="flex flex-col md:flex-row w-full max-w-5xl bg-white shadow-2xl rounded-2xl overflow-hidden relative">

        <div class="hidden md:flex md:w-1/2 relative">
            <img
                src="${pageContext.request.contextPath}/img/chicas.png"
                alt="Equipo trabajando"
                class="absolute inset-0 w-full h-full object-cover"
            />
            <div class="absolute inset-0 bg-purple-900/80 mix-blend-multiply"></div>

            <div class="relative z-10 p-12 flex flex-col justify-center h-full w-full bg-gradient-to-t from-purple-900/90 to-transparent">
                <h2 class="text-4xl font-bold mb-4 tracking-tight text-white drop-shadow-md mt-auto">
                    Bienvenido de nuevo
                </h2>
                <p class="text-base text-purple-100 leading-relaxed max-w-sm drop-shadow">
                    Tecnología con propósito. Gestiona recursos, conecta personas y genera un impacto real en tu organización.
                </p>
            </div>
        </div>

        <div class="w-full md:w-1/2 p-8 md:p-14 flex flex-col justify-center relative">

            <a href="${pageContext.request.contextPath}/index.jsp" class="absolute top-6 right-6 text-sm text-gray-400 hover:text-purple-600 flex items-center gap-1 transition-colors">
                <i data-lucide="arrow-left" class="w-4 h-4"></i> Volver al inicio
            </a>

            <div class="max-w-md w-full mx-auto">

                <div class="text-center mb-10">
                    <img src="${pageContext.request.contextPath}/img/QuintaOlaLogo.png" alt="Logo Quinta Ola" class="h-16 w-auto mb-6 mx-auto object-contain block">

                    <h1 class="text-3xl font-bold text-gray-900 mb-2">Iniciar Sesión</h1>
                    <p class="text-gray-500 text-sm">
                        Accede a tu cuenta para gestionar el inventario
                    </p>
                </div>

                <form action="${pageContext.request.contextPath}/AuthServlet" method="POST" class="space-y-5">

                    <input type="hidden" name="action" value="login" />

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1 text-left">Correo electrónico</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i data-lucide="mail" class="h-5 w-5 text-gray-400"></i>
                            </div>
                            <input type="email" name="email" required id="email-input"
                                class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 transition-all sm:text-sm bg-gray-50 focus:bg-white"
                                placeholder="ejemplo@email.com">
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1 text-left">Contraseña</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i data-lucide="lock" class="h-5 w-5 text-gray-400"></i>
                            </div>
                            <input type="password" name="password" required id="password-input"
                                class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 transition-all sm:text-sm bg-gray-50 focus:bg-white"
                                placeholder="••••••••">
                        </div>
                    </div>

                    <div class="flex items-center justify-between mt-4">
                        <div class="flex items-center">
                            <input id="remember-me" name="remember-me" type="checkbox"
                                class="h-4 w-4 text-pink-500 focus:ring-pink-500 border-gray-300 rounded cursor-pointer">
                            <label for="remember-me" class="ml-2 block text-sm text-gray-600 cursor-pointer">
                                Recordarme
                            </label>
                        </div>

                        <div class="text-sm">
                            <a href="#" class="font-medium text-purple-600 hover:text-purple-500 transition-colors">
                                ¿Olvidaste tu contraseña?
                            </a>
                        </div>
                    </div>

                    <button type="submit"
                        class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-pink-500 hover:bg-pink-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-pink-500 transition-colors mt-6">
                        Ingresar al sistema
                    </button>

                </form>

                <%-- Error devuelto desde el Servlet si falla el login --%>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl px-4 py-3 mt-4 text-left">
                        <i data-lucide="alert-circle" class="w-4 h-4 inline-block mr-1"></i>
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                <%-- Mensaje de éxito si viene de registrarse --%>
                <% if (request.getAttribute("success") != null) { %>
                    <div class="bg-green-50 border border-green-200 text-green-700 text-sm rounded-xl px-4 py-3 mt-4 text-left">
                        <i data-lucide="check-circle" class="w-4 h-4 inline-block mr-1"></i>
                        <%= request.getAttribute("success") %>
                    </div>
                <% } %>

                <div class="mt-6 text-center">
                    <p class="text-sm text-gray-600">
                        ¿No tienes cuenta?
                        <a href="${pageContext.request.contextPath}/AuthServlet?action=formSignup" class="font-semibold text-pink-600 hover:text-pink-500 transition-colors">
                            Regístrate ahora
                        </a>
                    </p>
                </div>

            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>