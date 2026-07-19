<%--
    ════════════════════════════════════════════════════════════════════
     login.jsp — Vista de Inicio de Sesión (estilo Quinta Ola oficial)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Iniciar Sesión | Quinta Ola</title>

    <link href="<%= ctx %>/css/style.css?v=22" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Estilos específicos del login ═════ */

        body.login-body {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;              /* ← altura fija, no min-height */
            overflow: hidden;           /* ← sin scroll global */
            background: linear-gradient(135deg, #FCE7F3 0%, #EDE9FE 50%, #FFF8E1 100%);
            padding: 1.5rem 1rem;
        }

        .login-card {
            display: flex;
            width: 100%;
            max-width: 1000px;
            height: 92vh;               /* ← altura controlada, no min-height */
            max-height: 700px;          /* ← tope superior */
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--gray-100);
            overflow: hidden;
        }

        /* ── Panel izquierdo: branding ── */
        .login-branding {
            flex: 1;
            position: relative;
            background: linear-gradient(180deg, var(--purple) 0%, var(--purple-dark) 100%);
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            padding: 2.5rem;
            overflow: hidden;
        }

        .login-branding-bg {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.35;
            mix-blend-mode: luminosity;
            pointer-events: none;
        }

        .login-branding::before {
            content: '';
            position: absolute;
            top: -50px;
            right: -50px;
            width: 180px;
            height: 180px;
            border-radius: 50%;
            background: var(--yellow);
            opacity: 0.15;
            z-index: 1;
        }

        .login-branding::after {
            content: '';
            position: absolute;
            bottom: 150px;
            left: -80px;
            width: 220px;
            height: 220px;
            border-radius: 50%;
            background: var(--pink);
            opacity: 0.15;
            z-index: 1;
        }

        .login-branding-content {
            position: relative;
            z-index: 2;
        }

        .login-branding-content h2 {
            font-size: 1.85rem;
            font-weight: 800;
            color: var(--white);
            margin-bottom: 0.85rem;
            letter-spacing: -0.5px;
            line-height: 1.15;
        }

        .login-branding-content h2 .accent {
            color: var(--yellow);
        }

        .login-branding-content p {
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.92);
            font-weight: 500;
            line-height: 1.6;
            max-width: 340px;
        }

        .login-branding-tagline {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: rgba(255, 193, 7, 0.18);
            color: var(--yellow);
            padding: 0.35rem 0.85rem;
            border-radius: var(--radius-full);
            font-size: 0.65rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.4px;
            margin-bottom: 1.25rem;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }

        .login-branding-tagline i {
            width: 12px;
            height: 12px;
        }

        /* ── Panel derecho: formulario ── */
        .login-form-panel {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 2rem 2.5rem;
            background: var(--white);
            overflow-y: auto;           /* ← scroll interno SOLO si fuera necesario */
        }

        .login-form-inner {
            width: 100%;
            max-width: 380px;
            margin: 0 auto;
        }

        .login-back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: var(--gray-400);
            transition: color var(--transition);
            margin-bottom: 1rem;
        }

        .login-back-link:hover {
            color: var(--purple);
        }

        .login-back-link i {
            width: 14px;
            height: 14px;
        }

        .login-form-header {
            text-align: center;
            margin-bottom: 1.5rem;
        }

        .login-form-header img {
            height: 48px;
            width: auto;
            margin: 0 auto 0.85rem;
        }

        .login-form-header h1 {
            font-size: 1.35rem;
            font-weight: 800;
            color: var(--purple);
            margin-bottom: 0.3rem;
        }

        .login-form-header p {
            font-size: 0.82rem;
            color: var(--gray-500);
            font-weight: 500;
        }

        .login-form-group {
            margin-bottom: 0.95rem;
        }

        .login-form-group label {
            display: block;
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: var(--gray-600);
            margin-bottom: 0.45rem;
        }

        /* ═══════ ICONO DENTRO DEL INPUT (corregido) ═══════ */
        .login-input-wrap {
            position: relative;
            display: block;
        }

        .login-input-wrap > i,
        .login-input-wrap > svg {
            position: absolute !important;
            left: 0.95rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
            width: 18px !important;
            height: 18px !important;
            pointer-events: none;
            transition: color var(--transition);
            z-index: 5;
        }

        .login-input-wrap .login-input {
            display: block;
            width: 100%;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.7rem 1rem 0.7rem 2.85rem !important;
            font-size: 0.88rem;
            color: var(--gray-800);
            background: var(--gray-50);
            transition: all var(--transition);
            outline: none;
            font-family: inherit;
            box-sizing: border-box;
        }

        .login-input-wrap .login-input:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }

        .login-input-wrap:focus-within > i,
        .login-input-wrap:focus-within > svg {
            color: var(--purple);
        }

        .login-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.25rem;
            margin-top: 0.85rem;
        }

        .login-remember {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
        }

        .login-remember input[type="checkbox"] {
            width: 15px;
            height: 15px;
            accent-color: var(--pink);
            cursor: pointer;
        }

        .login-remember span {
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--gray-600);
        }

        .login-forgot {
            font-size: 0.78rem;
            font-weight: 700;
            color: var(--purple);
            transition: color var(--transition);
        }

        .login-forgot:hover {
            color: var(--pink);
        }

        .login-submit-btn {
            width: 100%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white);
            padding: 0.78rem 1.5rem;
            border-radius: var(--radius-full);
            font-size: 0.88rem;
            font-weight: 700;
            border: none;
            cursor: pointer;
            transition: all var(--transition);
            box-shadow: 0 4px 16px rgba(233, 30, 140, 0.25);
        }

        .login-submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(233, 30, 140, 0.4);
        }

        .login-submit-btn i {
            width: 16px;
            height: 16px;
            transition: transform var(--transition);
        }

        .login-submit-btn:hover i {
            transform: translateX(3px);
        }

        .login-error {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            background: var(--red-bg);
            border: 1px solid #FECACA;
            color: var(--red-dark);
            font-size: 0.78rem;
            font-weight: 600;
            border-radius: var(--radius-sm);
            padding: 0.65rem 0.9rem;
            margin-top: 0.85rem;
        }

        .login-error i {
            width: 16px;
            height: 16px;
            flex-shrink: 0;
        }

        .login-footer {
            margin-top: 1rem;
            padding-top: 0.95rem;
            border-top: 1px solid var(--gray-100);
            text-align: center;
        }

        .login-footer p {
            font-size: 0.8rem;
            color: var(--gray-500);
            font-weight: 500;
        }

        .login-footer a {
            font-weight: 700;
            color: var(--pink);
            transition: color var(--transition);
        }

        .login-footer a:hover {
            color: var(--purple);
        }

        /* ── Responsive ── */
        @media (max-width: 900px) {
            body.login-body {
                overflow: auto;
                height: auto;
                min-height: 100vh;
            }
            .login-branding {
                display: none;
            }
            .login-card {
                height: auto;
                max-height: none;
                max-width: 480px;
            }
            .login-form-panel {
                padding: 2rem;
            }
        }

        @media (max-width: 480px) {
            body.login-body {
                padding: 0;
            }
            .login-card {
                border-radius: 0;
                min-height: 100vh;
                box-shadow: none;
            }
            .login-form-panel {
                padding: 1.75rem 1.5rem;
            }
        }
    </style>
</head>

<body class="login-body">

<div class="login-card">

    <%-- ═══════ PANEL IZQUIERDO: Branding ═══════ --%>
    <div class="login-branding">

        <img src="<%= ctx %>/img/chicas.png"
             alt="Equipo Quinta Ola"
             class="login-branding-bg"
             onerror="this.style.display='none'"/>

        <div class="login-branding-content">

            <span class="login-branding-tagline">
                <i data-lucide="sparkles"></i>
                Quinta Ola — Sistema de Inventario
            </span>

            <h2>
                Bienvenida de <span class="accent">vuelta</span>
            </h2>

            <p>
                Tecnología con propósito. Gestiona recursos, conecta personas
                y genera un impacto real en tu organización.
            </p>

        </div>

    </div>

    <%-- ═══════ PANEL DERECHO: Formulario ═══════ --%>
    <div class="login-form-panel">

        <div class="login-form-inner">

            <a href="<%= ctx %>/index.jsp" class="login-back-link">
                <i data-lucide="arrow-left"></i>
                Volver al inicio
            </a>

            <div class="login-form-header">
                <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Logo Quinta Ola"/>
                <h1>Iniciar Sesión</h1>
                <p>Accede a tu cuenta para gestionar el inventario</p>
            </div>

            <form action="<%= ctx %>/AuthServlet" method="POST">

                <input type="hidden" name="action" value="login"/>

                <%-- Email --%>
                <div class="login-form-group">
                    <label>Correo electrónico</label>
                    <div class="login-input-wrap">
                        <i data-lucide="mail"></i>
                        <input type="email"
                               name="email"
                               class="login-input"
                               placeholder="ejemplo@quintaola.com"
                               value="admin.demo@quintaola.com"
                               required/>
                    </div>
                </div>

                <%-- Contraseña --%>
                <div class="login-form-group">
                    <label>Contraseña</label>
                    <div class="login-input-wrap">
                        <i data-lucide="lock"></i>
                        <input type="password"
                               name="password"
                               class="login-input"
                               placeholder="••••••••"
                               required/>
                    </div>
                </div>

                <%-- Opciones --%>
                <div class="login-options">
                    <label class="login-remember">
                        <input type="checkbox" name="remember"/>
                        <span>Recordarme</span>
                    </label>
                    <a href="#" class="login-forgot">¿Olvidaste tu contraseña?</a>
                </div>

                <%-- Botón submit --%>
                <button type="submit" class="login-submit-btn">
                    Ingresar al sistema
                    <i data-lucide="arrow-right"></i>
                </button>

            </form>

            <%-- Error --%>
            <% if (request.getAttribute("error") != null) { %>
            <div class="login-error">
                <i data-lucide="alert-circle"></i>
                <span><%= request.getAttribute("error") %></span>
            </div>
            <% } %>

            <%-- Footer --%>
            <div class="login-footer">
                <p>
                    ¿No tienes una cuenta activa?
                    <a href="<%= ctx %>/AuthServlet?action=formSignup">Regístrate aquí</a>
                </p>
            </div>

        </div>

    </div>

</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });
</script>

</body>
</html>