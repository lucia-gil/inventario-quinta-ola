<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Crear Cuenta | Quinta Ola</title>
    <link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
</head>

<body class="min-h-screen flex items-center justify-center bg-gray-50 font-sans p-4">

    <div class="flex flex-col md:flex-row w-full max-w-5xl bg-white shadow-2xl rounded-2xl overflow-hidden relative">

        <div class="hidden md:flex md:w-5/12 relative">
            <img
                src="${pageContext.request.contextPath}/img/grupochicas.png"
                alt="Equipo Quinta Ola"
                class="absolute inset-0 w-full h-full object-cover"
            />
            <div class="absolute inset-0 bg-purple-900/80 mix-blend-multiply"></div>

            <div class="relative z-10 p-12 flex flex-col justify-center h-full w-full bg-gradient-to-t from-purple-900/90 to-transparent">
                <h2 class="text-4xl font-bold mb-4 tracking-tight text-white drop-shadow-md mt-auto">
                    Únete al equipo
                </h2>
                <p class="text-base text-purple-100 leading-relaxed max-w-sm drop-shadow">
                    Regístrate para solicitar materiales y gestionar eficientemente los recursos de cada proyecto.
                </p>
            </div>
        </div>

        <div class="w-full md:w-7/12 p-8 md:p-12 flex flex-col justify-center relative">

            <a href="${pageContext.request.contextPath}/index.jsp" class="absolute top-6 right-6 text-sm text-gray-400 hover:text-purple-600 flex items-center gap-1 transition-colors">
                <i data-lucide="arrow-left" class="w-4 h-4"></i> Volver al inicio
            </a>

            <div class="max-w-lg w-full mx-auto">

                <div class="text-center mb-8">
                    <img src="${pageContext.request.contextPath}/img/QuintaOlaLogo.png" alt="Logo Quinta Ola" class="h-14 w-auto mb-4 mx-auto object-contain block">

                    <h1 class="text-2xl font-bold text-gray-900 mb-1">Crea tu cuenta</h1>
                    <p class="text-gray-500 text-sm">
                        Ingresa tus datos para registrarte en el sistema de inventario
                    </p>
                </div>

                <form action="${pageContext.request.contextPath}/AuthServlet" method="POST" class="space-y-4" onsubmit="return validarPassword()">

                    <input type="hidden" name="action" value="register" />

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1 text-left">Nombres</label>
                            <div class="relative">
                                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <i data-lucide="user" class="h-4 w-4 text-gray-400"></i>
                                </div>
                                <input type="text" name="nombres" required id="reg-nombres"
                                    class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 transition-all sm:text-sm bg-gray-50 focus:bg-white"
                                    placeholder="Tus nombres">
                            </div>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1 text-left">Apellidos</label>
                            <div class="relative">
                                <input type="text" name="apellidos" required id="reg-apellidos"
                                    class="block w-full px-3 py-2.5 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 transition-all sm:text-sm bg-gray-50 focus:bg-white"
                                    placeholder="Tus apellidos">
                            </div>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1 text-left">DNI</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i data-lucide="id-card" class="h-4 w-4 text-gray-400"></i>
                            </div>
                            <input type="text" name="dni" required maxlength="8" pattern="[0-9]{8}" id="reg-dni"
                                class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 transition-all sm:text-sm bg-gray-50 focus:bg-white"
                                placeholder="Ingresa tu documento de identidad">
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1 text-left">Correo electrónico</label>
                        <div class="relative">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i data-lucide="mail" class="h-4 w-4 text-gray-400"></i>
                            </div>
                            <input type="email" name="email" required id="reg-email"
                                class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 transition-all sm:text-sm bg-gray-50 focus:bg-white"
                                placeholder="ejemplo@email.com">
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1 text-left">Contraseña</label>
                            <div class="relative">
                                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <i data-lucide="lock" class="h-4 w-4 text-gray-400"></i>
                                </div>
                                <input type="password" name="password" required minlength="8" id="reg-pass"
                                    class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 transition-all sm:text-sm bg-gray-50 focus:bg-white"
                                    placeholder="••••••••">
                            </div>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1 text-left">Confirmar contraseña</label>
                            <div class="relative">
                                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <i data-lucide="check-circle" class="h-4 w-4 text-gray-400"></i>
                                </div>
                                <input type="password" required minlength="8" id="reg-confirm"
                                    class="block w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 transition-all sm:text-sm bg-gray-50 focus:bg-white"
                                    placeholder="••••••••">
                            </div>
                        </div>
                    </div>

                    <div id="password-error" class="hidden bg-red-50 text-red-600 text-sm p-3 rounded-lg text-left mt-2">
                        Las contraseñas no coinciden.
                    </div>

                    <button type="submit"
                        class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-medium text-white bg-pink-500 hover:bg-pink-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-pink-500 transition-colors mt-6">
                        Registrar mi cuenta
                    </button>

                </form>

                <%-- Error devuelto desde el Servlet si el correo o DNI ya existen --%>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl px-4 py-3 mt-4 text-left">
                        <i data-lucide="alert-circle" class="w-4 h-4 inline-block mr-1"></i>
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>

                <div class="mt-6 text-center">
                    <p class="text-sm text-gray-600">
                        ¿Ya tienes una cuenta?
                        <a href="${pageContext.request.contextPath}/AuthServlet?action=formLogin" class="font-semibold text-purple-600 hover:text-purple-500 transition-colors">
                            Inicia sesión aquí
                        </a>
                    </p>
                </div>

            </div>
        </div>
    </div>

    <script>
        lucide.createIcons();

        // Validamos en el navegador que las contraseñas coincidan antes de enviarlo al servidor
        function validarPassword() {
            const pass = document.getElementById('reg-pass').value;
            const confirm = document.getElementById('reg-confirm').value;
            const errorDiv = document.getElementById('password-error');

            if (pass !== confirm) {
                errorDiv.classList.remove('hidden');
                return false; // Evita que se envíe el formulario
            }
            errorDiv.classList.add('hidden');
            return true; // Envía los datos al Servlet
        }
    </script>
</body>
</html>