<%--
    ════════════════════════════════════════════════════════════════════
     signup.jsp — Registro de nuevos usuarios (estilo Quinta Ola oficial)
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
    <title>Crear Cuenta | Quinta Ola</title>

    <link href="<%= ctx %>/css/style.css?v=23" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Estilos específicos del signup ═════ */

        body.signup-body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #FCE7F3 0%, #EDE9FE 50%, #FFF8E1 100%);
            padding: 1.5rem 1rem;
        }

        .signup-card {
            display: flex;
            width: 100%;
            max-width: 1100px;
            min-height: 600px;
            max-height: 94vh;
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--gray-100);
            overflow: hidden;
        }

        /* ── Panel izquierdo: branding ── */
        .signup-branding {
            flex: 1;
            position: relative;
            background: linear-gradient(180deg, var(--purple) 0%, var(--purple-dark) 100%);
            display: flex;
            flex-direction: column;
            justify-content: flex-end;
            padding: 2.5rem;
            overflow: hidden;
        }

        .signup-branding-bg {
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

        .signup-branding::before {
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

        .signup-branding::after {
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

        .signup-branding-content {
            position: relative;
            z-index: 2;
        }

        .signup-branding-content h2 {
            font-size: 1.85rem;
            font-weight: 800;
            color: var(--white);
            margin-bottom: 0.85rem;
            letter-spacing: -0.5px;
            line-height: 1.15;
        }

        .signup-branding-content h2 .accent {
            color: var(--yellow);
        }

        .signup-branding-content p {
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.92);
            font-weight: 500;
            line-height: 1.6;
            max-width: 340px;
        }

        .signup-branding-tagline {
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

        .signup-branding-tagline i {
            width: 12px;
            height: 12px;
        }

        /* ── Panel derecho: formulario ── */
        .signup-form-panel {
            flex: 1.15;
            display: flex;
            flex-direction: column;
            padding: 0;
            background: var(--white);
            position: relative;
            overflow: hidden;
        }

        /* "Volver al inicio" FIJO arriba */
        .signup-back-bar {
            position: sticky;
            top: 0;
            background: var(--white);
            padding: 1rem 2.5rem 0.5rem;
            z-index: 10;
            border-bottom: 1px solid transparent;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .signup-back-bar.scrolled {
            border-bottom-color: var(--gray-100);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }

        .signup-back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: var(--gray-400);
            transition: color var(--transition);
        }

        .signup-back-link:hover {
            color: var(--purple);
        }

        .signup-back-link i {
            width: 14px;
            height: 14px;
        }

        .signup-form-scroll {
            flex: 1;
            overflow-y: auto;
            padding: 0.5rem 2.5rem 1.75rem;
        }

        .signup-form-inner {
            width: 100%;
            max-width: 460px;
            margin: 0 auto;
        }

        .signup-form-header {
            text-align: center;
            margin-bottom: 1.25rem;
        }

        .signup-form-header img {
            height: 44px;
            width: auto;
            margin: 0 auto 0.7rem;
        }

        .signup-form-header h1 {
            font-size: 1.35rem;
            font-weight: 800;
            color: var(--purple);
            margin-bottom: 0.3rem;
        }

        .signup-form-header p {
            font-size: 0.82rem;
            color: var(--gray-500);
            font-weight: 500;
        }

        .signup-form-group {
            margin-bottom: 0.75rem;
        }

        .signup-form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.85rem;
        }

        .signup-form-group label {
            display: block;
            font-size: 0.68rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: var(--gray-600);
            margin-bottom: 0.4rem;
        }

        /* ═══════ ICONO DENTRO DEL INPUT ═══════ */
        .signup-input-wrap {
            position: relative;
            display: block;
        }

        .signup-input-wrap > i,
        .signup-input-wrap > svg {
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

        .signup-input-wrap .signup-input {
            display: block;
            width: 100%;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.65rem 1rem 0.65rem 2.85rem !important;
            font-size: 0.85rem;
            color: var(--gray-800);
            background: var(--gray-50);
            transition: all var(--transition);
            outline: none;
            font-family: inherit;
            box-sizing: border-box;
        }

        .signup-input-wrap .signup-input:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }

        .signup-input-wrap:focus-within > i,
        .signup-input-wrap:focus-within > svg {
            color: var(--purple);
        }

        .signup-pass-error {
            display: none;
            align-items: center;
            gap: 0.45rem;
            background: var(--red-bg);
            border: 1px solid #FECACA;
            color: var(--red-dark);
            font-size: 0.75rem;
            font-weight: 600;
            border-radius: var(--radius-sm);
            padding: 0.55rem 0.85rem;
            margin-top: 0.6rem;
        }

        /* ═══════ Medidor de fortaleza COMPACTO ═══════ */
        .signup-pass-strength {
            margin-top: 0.6rem;
            margin-bottom: 0.5rem;
            padding: 0.65rem 0.8rem;
            background: var(--gray-50);
            border: 1px solid var(--gray-100);
            border-radius: var(--radius-sm);
        }

        .strength-top {
            display: flex;
            align-items: center;
            gap: 0.7rem;
            margin-bottom: 0.55rem;
        }
        .strength-top-text {
            text-transform: uppercase;
            letter-spacing: 0.6px;
            font-size: 0.6rem;
            font-weight: 700;
            color: var(--gray-500);
            flex-shrink: 0;
        }
        .strength-bar-track {
            flex: 1;
            height: 5px;
            background: var(--gray-200);
            border-radius: var(--radius-full);
            overflow: hidden;
        }
        .strength-bar-fill {
            height: 100%;
            width: 0%;
            background: var(--red);
            border-radius: var(--radius-full);
            transition: width 0.3s, background 0.3s;
        }
        .strength-bar-fill.level-1 { width: 25%;  background: var(--red); }
        .strength-bar-fill.level-2 { width: 50%;  background: var(--orange-dark); }
        .strength-bar-fill.level-3 { width: 75%;  background: var(--yellow); }
        .strength-bar-fill.level-4 { width: 100%; background: var(--green); }

        .strength-status {
            color: var(--red-dark);
            font-weight: 700;
            font-size: 0.65rem;
            flex-shrink: 0;
            min-width: 58px;
            text-align: right;
        }
        .strength-status.level-2 { color: var(--orange-dark); }
        .strength-status.level-3 { color: var(--orange-dark); }
        .strength-status.level-4 { color: var(--green-dark); }

        .strength-checklist {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.25rem 0.7rem;
        }

        .strength-check-item {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            font-size: 0.68rem;
            color: var(--gray-500);
            font-weight: 600;
            transition: color 0.2s;
        }
        .strength-check-item i {
            width: 13px;
            height: 13px;
            flex-shrink: 0;
        }
        .strength-check-item.met {
            color: var(--green-dark);
        }

        .signup-pass-error.visible {
            display: flex;
        }

        .signup-pass-error i {
            width: 14px;
            height: 14px;
            flex-shrink: 0;
        }

        .signup-submit-btn {
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
            margin-top: 0.7rem;
        }

        .signup-submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(233, 30, 140, 0.4);
        }

        .signup-submit-btn i {
            width: 16px;
            height: 16px;
            transition: transform var(--transition);
        }

        .signup-submit-btn:hover i.arrow {
            transform: translateX(3px);
        }

        .signup-error {
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

        .signup-error i {
            width: 16px;
            height: 16px;
            flex-shrink: 0;
        }

        .signup-success {
            background: var(--green-bg);
            border: 1.5px solid #BBF7D0;
            border-radius: var(--radius-md);
            padding: 1.25rem 1.1rem;
            margin-top: 0.5rem;
            text-align: center;
        }

        .signup-success-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 52px;
            height: 52px;
            border-radius: 50%;
            background: var(--green);
            color: var(--white);
            margin: 0 auto 0.75rem;
        }

        .signup-success-icon i {
            width: 26px;
            height: 26px;
        }

        .signup-success-title {
            font-size: 1rem;
            font-weight: 800;
            color: var(--green-dark);
            margin-bottom: 0.5rem;
        }

        .signup-success-desc {
            font-size: 0.82rem;
            color: var(--gray-700);
            line-height: 1.55;
            margin-bottom: 1rem;
        }

        .signup-success-desc strong {
            color: var(--green-dark);
        }

        .signup-success-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white);
            padding: 0.6rem 1.5rem;
            border-radius: var(--radius-full);
            font-size: 0.82rem;
            font-weight: 700;
            text-decoration: none;
            transition: all var(--transition);
            box-shadow: 0 4px 12px rgba(233, 30, 140, 0.25);
        }

        .signup-success-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(233, 30, 140, 0.4);
        }

        .signup-success-btn i {
            width: 14px;
            height: 14px;
        }
        .signup-footer {
            margin-top: 1rem;
            padding-top: 0.85rem;
            border-top: 1px solid var(--gray-100);
            text-align: center;
        }

        .signup-footer p {
            font-size: 0.8rem;
            color: var(--gray-500);
            font-weight: 500;
        }

        .signup-footer a {
            font-weight: 700;
            color: var(--pink);
            transition: color var(--transition);
        }

        .signup-footer a:hover {
            color: var(--purple);
        }

        /* ── Responsive ── */
        @media (max-width: 900px) {
            body.signup-body {
                overflow: auto;
                height: auto;
                min-height: 100vh;
            }
            .signup-branding {
                display: none;
            }
            .signup-card {
                height: auto;
                max-height: none;
                max-width: 520px;
            }
            .signup-back-bar { padding: 1rem 2rem 0.5rem; }
            .signup-form-scroll { padding: 0.5rem 2rem 1.75rem; }
        }

        @media (max-width: 600px) {
            .signup-form-row {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            body.signup-body {
                padding: 0;
            }
            .signup-card {
                border-radius: 0;
                min-height: 100vh;
                box-shadow: none;
            }
            .signup-back-bar { padding: 1rem 1.5rem 0.5rem; }
            .signup-form-scroll { padding: 0.5rem 1.5rem 1.75rem; }
        }
    </style>
</head>

<body class="signup-body">

<div class="signup-card">

    <%-- ═══════ PANEL IZQUIERDO: Branding ═══════ --%>
    <div class="signup-branding">

        <img src="<%= ctx %>/img/grupochicas.png"
             alt="Equipo Quinta Ola"
             class="signup-branding-bg"
             onerror="this.style.display='none'"/>

        <div class="signup-branding-content">

            <span class="signup-branding-tagline">
                <i data-lucide="sparkles"></i>
                Únete al equipo Quinta Ola
            </span>

            <h2>
                Sé parte del <span class="accent">cambio</span>
            </h2>

            <p>
                Regístrate para gestionar materiales, hacer seguimiento
                de pedidos y colaborar en cada proyecto del equipo.
            </p>

        </div>

    </div>

    <%-- ═══════ PANEL DERECHO: Formulario ═══════ --%>
    <div class="signup-form-panel">

        <%-- Barra superior FIJA con "Volver al inicio" --%>
        <div id="back-bar" class="signup-back-bar">
            <a href="<%= ctx %>/index.jsp" class="signup-back-link">
                <i data-lucide="arrow-left"></i>
                Volver al inicio
            </a>
        </div>

        <%-- Contenido scrollable --%>
        <div id="scroll-area" class="signup-form-scroll">

            <div class="signup-form-inner">

                <div class="signup-form-header">
                    <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Logo Quinta Ola"/>
                    <h1>Crea tu cuenta</h1>
                    <p>Ingresa tus datos para registrarte en el sistema</p>
                </div>

                <% if (request.getAttribute("success") != null) { %>

                <%-- ═══════ MENSAJE DE ÉXITO ═══════ --%>
                <div class="signup-success">
                    <div class="signup-success-icon">
                        <i data-lucide="check"></i>
                    </div>
                    <div class="signup-success-title">¡Cuenta creada con éxito!</div>
                    <div class="signup-success-desc">
                        <%= request.getAttribute("success") %>
                        <br/><br/>
                        Recibirás acceso al sistema una vez que <strong>un Administrador apruebe tu cuenta</strong>.
                    </div>
                    <a href="<%= ctx %>/index.jsp" class="signup-success-btn">
                        <i data-lucide="home"></i>
                        Volver al inicio
                    </a>
                </div>

                <% } else { %>

                <%-- ═══════ FORMULARIO DE REGISTRO ═══════ --%>
                <form action="<%= ctx %>/AuthServlet" method="POST" onsubmit="return validarPassword();">

                    <input type="hidden" name="action" value="register"/>

                    <%-- Nombres + Apellidos --%>
                    <div class="signup-form-row">
                        <div class="signup-form-group">
                            <label>Nombres</label>
                            <div class="signup-input-wrap">
                                <i data-lucide="user"></i>
                                <input type="text"
                                       name="nombres"
                                       id="reg-nombres"
                                       class="signup-input"
                                       placeholder="Tus nombres"
                                       required/>
                            </div>
                        </div>

                        <div class="signup-form-group">
                            <label>Apellidos</label>
                            <div class="signup-input-wrap">
                                <i data-lucide="users"></i>
                                <input type="text"
                                       name="apellidos"
                                       id="reg-apellidos"
                                       class="signup-input"
                                       placeholder="Tus apellidos"
                                       required/>
                            </div>
                        </div>
                    </div>

                    <%-- DNI --%>
                    <div class="signup-form-group">
                        <label>DNI</label>
                        <div class="signup-input-wrap">
                            <i data-lucide="id-card"></i>
                            <input type="text"
                                   name="dni"
                                   id="reg-dni"
                                   class="signup-input"
                                   placeholder="Documento de 8 dígitos"
                                   required
                                   maxlength="8"
                                   pattern="[0-9]{8}"/>
                        </div>
                    </div>

                    <%-- Correo --%>
                    <div class="signup-form-group">
                        <label>Correo electrónico</label>
                        <div class="signup-input-wrap">
                            <i data-lucide="mail"></i>
                            <input type="email"
                                   name="email"
                                   id="reg-email"
                                   class="signup-input"
                                   placeholder="ejemplo@quintaola.com"
                                   required/>
                        </div>
                    </div>

                    <%-- Password + Confirmar --%>
                    <div class="signup-form-row">
                        <div class="signup-form-group">
                            <label>Contraseña</label>
                            <div class="signup-input-wrap">
                                <i data-lucide="lock"></i>
                                <input type="password"
                                       name="password"
                                       id="reg-pass"
                                       class="signup-input"
                                       placeholder="••••••••"
                                       required
                                       minlength="8"
                                       oninput="actualizarFortaleza()"/>
                            </div>
                        </div>

                        <div class="signup-form-group">
                            <label>Confirmar</label>
                            <div class="signup-input-wrap">
                                <i data-lucide="check-circle"></i>
                                <input type="password"
                                       id="reg-confirm"
                                       class="signup-input"
                                       placeholder="••••••••"
                                       required
                                       minlength="8"/>
                            </div>
                        </div>
                    </div>

                    <%-- Medidor de fortaleza compacto --%>
                    <div class="signup-pass-strength">
                        <div class="strength-top">
                            <span class="strength-top-text">Seguridad</span>
                            <div class="strength-bar-track">
                                <div id="strength-bar" class="strength-bar-fill"></div>
                            </div>
                            <span id="strength-status" class="strength-status">Vacía</span>
                        </div>
                        <div class="strength-checklist">
                            <span class="strength-check-item" id="chk-length">
                                <i data-lucide="circle"></i> 8+ caracteres
                            </span>
                            <span class="strength-check-item" id="chk-upper">
                                <i data-lucide="circle"></i> 1 mayúscula
                            </span>
                            <span class="strength-check-item" id="chk-lower">
                                <i data-lucide="circle"></i> 1 minúscula
                            </span>
                            <span class="strength-check-item" id="chk-number">
                                <i data-lucide="circle"></i> 1 número
                            </span>
                            <span class="strength-check-item" id="chk-symbol" style="grid-column: span 2;">
                                <i data-lucide="circle"></i> 1 símbolo (!@#$%&*...)
                            </span>
                        </div>
                    </div>

                    <%-- Error contraseñas --%>
                    <div id="pass-error" class="signup-pass-error">
                        <i data-lucide="alert-circle"></i>
                        <span>Las contraseñas no coinciden</span>
                    </div>

                    <%-- Botón submit --%>
                    <button type="submit" class="signup-submit-btn">
                        Registrar mi cuenta
                        <i data-lucide="arrow-right" class="arrow"></i>
                    </button>

                </form>

                <%-- Error servidor --%>
                <% if (request.getAttribute("error") != null) { %>
                <div class="signup-error">
                    <i data-lucide="alert-circle"></i>
                    <span><%= request.getAttribute("error") %></span>
                </div>
                <% } %>

                <% } %>

                <%-- Footer --%>
                <div class="signup-footer">
                    <p>
                        ¿Ya tienes una cuenta?
                        <a href="<%= ctx %>/AuthServlet?action=formLogin">Inicia sesión aquí</a>
                    </p>
                </div>

            </div>

        </div>

    </div>

</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();

        // Sombra sutil en la barra de "Volver al inicio" cuando hay scroll
        const scrollArea = document.getElementById('scroll-area');
        const backBar    = document.getElementById('back-bar');
        if (scrollArea && backBar) {
            scrollArea.addEventListener('scroll', () => {
                if (scrollArea.scrollTop > 5) backBar.classList.add('scrolled');
                else                          backBar.classList.remove('scrolled');
            });
        }
    });

    function actualizarFortaleza() {
        const pass   = document.getElementById('reg-pass').value;
        const bar    = document.getElementById('strength-bar');
        const status = document.getElementById('strength-status');

        const checks = {
            'chk-length': pass.length >= 8,
            'chk-upper':  /[A-Z]/.test(pass),
            'chk-lower':  /[a-z]/.test(pass),
            'chk-number': /[0-9]/.test(pass),
            'chk-symbol': /[!@#$%^&*()_+\-=\[\]{};:'"<>,./?\\|`~]/.test(pass)
        };

        let cumplidos = 0;
        Object.keys(checks).forEach(id => {
            const el = document.getElementById(id);
            const iconEl = el.querySelector('svg, i');

            if (checks[id]) {
                el.classList.add('met');
                // Reemplazar el icono por un check fresco
                const newIcon = document.createElement('i');
                newIcon.setAttribute('data-lucide', 'check-circle');
                iconEl.replaceWith(newIcon);
                cumplidos++;
            } else {
                el.classList.remove('met');
                const newIcon = document.createElement('i');
                newIcon.setAttribute('data-lucide', 'circle');
                iconEl.replaceWith(newIcon);
            }
        });

        bar.className = 'strength-bar-fill';
        status.className = 'strength-status';

        if (cumplidos === 5) {
            bar.classList.add('level-4');
            status.classList.add('level-4');
            status.textContent = 'Excelente';
        } else if (cumplidos >= 4) {
            bar.classList.add('level-3');
            status.classList.add('level-3');
            status.textContent = 'Buena';
        } else if (cumplidos >= 2) {
            bar.classList.add('level-2');
            status.classList.add('level-2');
            status.textContent = 'Mejorable';
        } else if (cumplidos >= 1) {
            bar.classList.add('level-1');
            status.textContent = 'Débil';
        } else {
            status.textContent = 'Vacía';
        }

        if (typeof lucide !== 'undefined') lucide.createIcons();
    }

    function validarPassword() {
        const pass    = document.getElementById('reg-pass').value;
        const confirm = document.getElementById('reg-confirm').value;
        const errBox  = document.getElementById('pass-error');

        const cumple = pass.length >= 8
            && /[A-Z]/.test(pass)
            && /[a-z]/.test(pass)
            && /[0-9]/.test(pass)
            && /[!@#$%^&*()_+\-=\[\]{};:'"<>,./?\\|`~]/.test(pass);

        if (!cumple) {
            errBox.querySelector('span').textContent =
                'La contraseña no cumple los requisitos de seguridad.';
            errBox.classList.add('visible');
            return false;
        }

        if (pass !== confirm) {
            errBox.querySelector('span').textContent = 'Las contraseñas no coinciden';
            errBox.classList.add('visible');
            return false;
        }

        errBox.classList.remove('visible');
        return true;
    }
</script>

</body>
</html>