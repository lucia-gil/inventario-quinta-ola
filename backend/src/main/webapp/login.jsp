<%--
    ════════════════════════════════════════════════════════════════════
     login.jsp — Vista de Inicio de Sesión Oficial (Quinta Ola)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Iniciar Sesión | Quinta Ola</title>

    <!-- Tu Sistema de Diseño Oficial -->
    <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet" />

    <!-- Iconos vectoriales Lucide -->
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* Contenedor adaptado al reset de tu body */
        .login-screen-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background-color: var(--gray-50);
            padding: 1rem;
            box-sizing: border-box;
        }

        /* Estructura de tarjeta usando tus bordes, radios y sombras */
        .login-card {
            display: flex;
            width: 100%;
            max-width: 960px;
            min-height: 580px;
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--gray-100);
            overflow: hidden;
        }

        /* PANEL IZQUIERDO: Corrección de contraste y mezcla de imagen */
        .login-branding {
            flex: 1;
            position: relative;
            background: linear-gradient(180deg, var(--purple) 0%, var(--purple-dark) 100%) !important;
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            padding: 3rem;
            box-sizing: border-box;
        }

        /* Fusión de la imagen para eliminar su fondo blanco nativo */
        .login-branding .bg-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.18;
            mix-blend-mode: multiply;
            pointer-events: none;
            z-index: 1;
        }

        .login-branding-text {
            position: relative;
            z-index: 2;
        }

        /* ENCAPSULAMIENTO DE ICONOS: Solución definitiva para Lucide SVG */
        .input-icon-wrapper {
            position: relative;
            display: block;
            width: 100%;
        }

        /* Selector dual para soportar el cambio dinámico de i a svg */
        .input-icon-wrapper i,
        .input-icon-wrapper svg {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
            width: 18px;
            height: 18px;
            pointer-events: none;
            transition: color var(--transition);
            z-index: 10;
        }

        /* Forzamos la sangría en tu .input-page nativo para que el texto no pise el icono */
        .input-icon-wrapper .input-page {
            padding-left: 2.75rem !important;
            display: block;
            width: 100%;
            box-sizing: border-box;
        }

        /* Iluminación del icono utilizando tu variable de marca focus */
        .input-icon-wrapper:focus-within i,
        .input-icon-wrapper:focus-within svg {
            color: var(--purple);
        }

        /* Botón de acción usando tu paleta rosa oficial */
        .btn-pink-submit {
            width: 100%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            background: var(--pink);
            color: var(--white);
            padding: 0.65rem 1.4rem;
            border-radius: var(--radius-full);
            font-size: 0.875rem;
            font-weight: 700;
            transition: all var(--transition);
            border: none;
            box-shadow: 0 4px 12px rgba(233, 30, 140, 0.2);
        }

        .btn-pink-submit:hover {
            background: var(--pink-dark);
            box-shadow: 0 4px 14px rgba(233, 30, 140, 0.4);
            transform: translateY(-1px);
        }
    </style>
</head>

<body class="page-body">

<div class="login-screen-wrapper">
    <div class="login-card">

        <!-- PANEL IZQUIERDO: Identidad Visual Corp (Muestra el fondo morado oficial) -->
        <div class="login-branding md:flex hidden">
            <img src="${pageContext.request.contextPath}/img/chicas.png" alt="Diseño Quinta Ola" class="bg-image" />

            <div class="login-branding-text">
                <h2 style="font-size: 2rem; font-weight: 800; color: var(--white); margin-bottom: 0.75rem; letter-spacing: -0.5px;">
                    Bienvenido de nuevo
                </h2>
                <p style="font-size: 0.95rem; color: var(--purple-bg); font-weight: 500; line-height: 1.6;">
                    Tecnología con propósito. Gestiona recursos, conecta personas y genera un impacto real en tu organización.
                </p>
            </div>
        </div>

        <!-- PANEL DERECHO: Formulario utilizando tus utilidades nativas -->
        <div class="flex flex-col p-8 md:p-8 justify-center bg-white" class="flex-grow" style="flex: 1;">
            <div class="w-full" style="max-width: 360px; margin: 0 auto;">

                <!-- Botón Volver usando tus clases utilitarias de texto -->
                <div class="mb-6">
                    <a href="${pageContext.request.contextPath}/index.jsp" class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-gray-400 hover:text-purple-600 transition-all">
                        <i data-lucide="arrow-left" style="width: 14px; height: 14px;"></i> Volver al inicio
                    </a>
                </div>

                <!-- Bloque de Identidad Central -->
                <div class="text-center mb-6">
                    <img src="${pageContext.request.contextPath}/img/QuintaOlaLogo.png" alt="Logo" style="height: 48px; width: auto; margin: 0 auto 1rem;">
                    <h1 class="text-xl font-bold text-gray-800">Iniciar Sesión</h1>
                    <p class="text-gray-400 text-sm mt-1">Accede a tu cuenta para gestionar el inventario</p>
                </div>

                <!-- Formulario estructurado con tus utilidades de espacio -->
                <form action="${pageContext.request.contextPath}/AuthServlet" method="POST" class="space-y-4">
                    <input type="hidden" name="action" value="login" />

                    <!-- Entrada: Email -->
                    <div>
                        <label class="form-label uppercase tracking-wider text-xs font-bold mb-1 block text-gray-600">
                            Correo electrónico
                        </label>
                        <div class="input-icon-wrapper">
                            <i data-lucide="mail"></i>
                            <input type="email" name="email" required class="input-page"
                                   placeholder="admin.demo@quintaola.com" value="admin.demo@quintaola.com">
                        </div>
                    </div>

                    <!-- Entrada: Password -->
                    <div>
                        <label class="form-label uppercase tracking-wider text-xs font-bold mb-1 block text-gray-600">
                            Contraseña
                        </label>
                        <div class="input-icon-wrapper">
                            <i data-lucide="lock"></i>
                            <input type="password" name="password" required class="input-page"
                                   placeholder="••••••••">
                        </div>
                    </div>

                    <!-- Fila de opciones: Recordar / Olvido -->
                    <div class="flex items-center justify-between pt-2">
                        <label class="inline-flex items-center gap-2" style="cursor: pointer;">
                            <input type="checkbox" name="remember-me" class="rounded-lg" style="accent-color: var(--pink); width: 16px; height: 16px;">
                            <span class="text-xs font-semibold text-gray-500">Recordarme</span>
                        </label>
                        <a href="#" class="text-xs font-bold text-purple-600 hover:text-pink-600 transition-all">
                            ¿Olvidaste tu contraseña?
                        </a>
                    </div>

                    <!-- Botón de Envío Ejecutable -->
                    <div class="pt-2">
                        <button type="submit" class="btn-pink-submit">
                            Ingresar al sistema <i data-lucide="arrow-right" style="width: 16px; height: 16px;"></i>
                        </button>
                    </div>
                </form>

                <%-- Despliegue de errores usando tus clases de badges nativas --%>
                <% if (request.getAttribute("error") != null) { %>
                <div class="bg-red-50 border-red-200 text-red-700 text-xs rounded-lg p-3 mt-4 flex items-center gap-2 border">
                    <i data-lucide="alert-circle" style="width: 16px; height: 16px; flex-shrink: 0;"></i>
                    <span class="font-semibold"><%= request.getAttribute("error") %></span>
                </div>
                <% } %>

                <!-- Footer del Formulario -->
                <div class="mt-6 text-center border-gray-100 pt-4" style="border-top: 1px solid var(--gray-100);">
                    <p class="text-xs text-gray-500 font-medium">
                        ¿No tienes una cuenta activa?
                        <a href="${pageContext.request.contextPath}/AuthServlet?action=formSignup" class="font-bold text-pink-600 hover:text-purple-600 transition-all">
                            Regístrate aquí
                        </a>
                    </p>
                </div>

            </div>
        </div>

    </div>
</div>

<script>
    // Inicialización limpia de Lucide Icons
    lucide.createIcons();
</script>
</body>
</html>