<%--
    ════════════════════════════════════════════════════════════════════
     index.jsp — Landing pública con identidad Quinta Ola
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    Integer userId = (Integer) session.getAttribute("userId");
    boolean estaLogueado = (userId != null);
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Quinta Ola | Sistema Inteligente de Inventario</title>

    <link href="<%= ctx %>/css/style.css?v=22" rel="stylesheet" />

    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Estilos específicos del index ═════ */

        /* Reset del body para landing pública (sin sidebar) */
        body.landing-body {
            background: var(--white);
            display: block;
            min-height: 100vh;
            font-family: 'Montserrat', sans-serif;
        }

        /* Tarjetas 3D */
        .perspective-1000 { perspective: 1000px; }
        .transform-style-3d { transform-style: preserve-3d; }
        .backface-hidden { backface-visibility: hidden; -webkit-backface-visibility: hidden; }
        .rotate-y-180 { transform: rotateY(180deg); }

        /* ─── Navbar público ─── */
        .public-navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            padding: 0.75rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 50;
        }
        .public-navbar-logo {
            height: 56px;
            width: auto;
            object-fit: contain;
        }
        .public-navbar-actions {
            display: flex;
            gap: 1.5rem;
            align-items: center;
            font-size: 0.875rem;
        }
        .public-nav-link {
            color: var(--purple);
            font-weight: 700;
            font-size: 0.9rem;
            text-decoration: none;
            transition: color var(--transition);
        }
        .public-nav-link:hover {
            color: var(--pink);
        }
        .public-nav-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: var(--pink);
            color: var(--white);
            padding: 0.625rem 1.25rem;
            border-radius: var(--radius-full);
            font-weight: 700;
            transition: all var(--transition);
            box-shadow: 0 2px 8px rgba(233, 30, 140, 0.25);
        }
        .public-nav-btn:hover {
            background: var(--purple);
            transform: translateY(-1px);
        }
        .public-nav-btn i { width: 16px; height: 16px; }

        /* ─── HERO ─── */
        .hero-section {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            min-height: 80vh;
            padding: 1.5rem;
            margin-top: 80px;
            overflow: hidden;
        }
        .hero-bg-image {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .hero-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(91, 31, 168, 0.85) 0%, rgba(74, 22, 144, 0.92) 100%);
        }
        .hero-content {
            position: relative;
            z-index: 10;
            max-width: 56rem;
            width: 100%;
            margin-top: 2.5rem;
        }
        .hero-title {
            font-size: 2.25rem;
            font-weight: 900;
            line-height: 1.1;
            color: var(--white);
            margin-bottom: 1.5rem;
            letter-spacing: -0.5px;
        }
        .hero-title-accent {
            color: var(--pink-light);
        }
        .hero-subtitle {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--yellow);
            display: block;
            margin-top: 0.75rem;
        }
        .hero-description {
            font-size: 1rem;
            color: rgba(255,255,255,0.92);
            max-width: 42rem;
            margin: 0 auto 2rem;
            line-height: 1.6;
        }
        .hero-cta-group {
            display: flex;
            flex-direction: column;
            gap: 1rem;
            justify-content: center;
            max-width: 42rem;
            margin: 1.5rem auto 0;
        }
        .hero-btn-primary,
        .hero-btn-secondary {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.875rem 2rem;
            border-radius: var(--radius-full);
            font-weight: 700;
            font-size: 0.95rem;
            transition: all var(--transition);
            text-align: center;
        }
        .hero-btn-primary {
            background: var(--yellow);
            color: var(--purple);
            box-shadow: 0 4px 16px rgba(255, 193, 7, 0.4);
        }
        .hero-btn-primary:hover {
            background: var(--yellow-light);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 193, 7, 0.5);
        }
        .hero-btn-secondary {
            background: var(--pink);
            color: var(--white);
            box-shadow: 0 4px 16px rgba(233, 30, 140, 0.3);
        }
        .hero-btn-secondary:hover {
            background: #C2185B;
            transform: translateY(-2px);
        }

        @media (min-width: 768px) {
            .hero-title { font-size: 3.5rem; }
            .hero-subtitle { font-size: 1.5rem; }
            .hero-description { font-size: 1.125rem; }
            .hero-cta-group { flex-direction: row; }
        }

        /* ─── SECCIÓN FEATURES ─── */
        .features-section {
            padding: 5rem 1.5rem;
            background: var(--gray-50);
            border-top: 1px solid var(--gray-200);
        }
        .features-inner {
            max-width: 72rem;
            margin: 0 auto;
            text-align: center;
        }
        .features-tag {
            display: inline-block;
            font-size: 0.75rem;
            font-weight: 800;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: var(--pink);
            background: var(--pink-bg);
            padding: 0.4rem 1rem;
            border-radius: var(--radius-full);
            margin-bottom: 1.5rem;
        }
        .features-title {
            font-size: 2rem;
            font-weight: 800;
            color: var(--purple);
            margin-bottom: 1rem;
            line-height: 1.2;
        }
        .features-subtitle {
            font-size: 1rem;
            color: var(--gray-600);
            max-width: 42rem;
            margin: 0 auto 4rem;
            line-height: 1.6;
        }
        @media (min-width: 768px) {
            .features-title { font-size: 2.5rem; }
        }
        .features-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 2rem;
            text-align: left;
        }
        @media (min-width: 768px) {
            .features-grid { grid-template-columns: repeat(3, 1fr); }
        }

        /* Tarjetas 3D feature */
        .feature-card-wrap {
            height: 460px;
            perspective: 1000px;
        }
        .feature-card {
            position: relative;
            width: 100%;
            height: 100%;
            transition: transform 0.7s;
            transform-style: preserve-3d;
        }
        .feature-card-face {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            backface-visibility: hidden;
            -webkit-backface-visibility: hidden;
            border-radius: var(--radius-lg);
            overflow: hidden;
        }
        .feature-card-front {
            background: var(--white);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            display: flex;
            flex-direction: column;
        }
        .feature-card-img {
            position: relative;
            height: 12rem;
            overflow: hidden;
        }
        .feature-card-img img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .feature-card-img-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(to top, rgba(91, 31, 168, 0.85), rgba(91, 31, 168, 0.2), transparent);
        }
        .feature-card-icon-corner {
            position: absolute;
            bottom: 1rem;
            left: 1rem;
            color: var(--white);
        }
        .feature-card-icon-corner i { width: 28px; height: 28px; }
        .feature-card-body {
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }
        .feature-card-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--purple);
            margin-bottom: 0.5rem;
        }
        .feature-card-desc {
            color: var(--gray-600);
            font-size: 0.875rem;
            line-height: 1.6;
            flex-grow: 1;
            margin-bottom: 1.5rem;
        }
        .feature-card-link {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            color: var(--pink);
            font-weight: 700;
            font-size: 0.875rem;
            background: none;
            border: none;
            cursor: pointer;
            transition: opacity var(--transition);
            width: max-content;
            padding: 0;
        }
        .feature-card-link:hover { opacity: 0.7; }
        .feature-card-link i { width: 16px; height: 16px; }

        .feature-card-back {
            background: linear-gradient(135deg, var(--purple) 0%, var(--pink) 100%);
            color: var(--white);
            padding: 2rem;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            transform: rotateY(180deg);
            box-shadow: var(--shadow-lg);
        }
        .feature-card-back i.main-icon { width: 48px; height: 48px; margin-bottom: 1rem; opacity: 0.85; }
        .feature-card-back h3 {
            font-size: 1.25rem;
            font-weight: 700;
            margin-bottom: 0.75rem;
        }
        .feature-card-back p {
            font-size: 0.875rem;
            margin-bottom: 1.5rem;
            color: rgba(255,255,255,0.92);
            line-height: 1.6;
        }
        .feature-card-back button {
            background: var(--yellow);
            color: var(--purple);
            padding: 0.6rem 1.5rem;
            border-radius: var(--radius-full);
            font-weight: 700;
            font-size: 0.875rem;
            border: none;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
            transition: all var(--transition);
        }
        .feature-card-back button:hover {
            background: var(--yellow-light);
            transform: translateY(-1px);
        }

        /* ─── CTA section ─── */
        .cta-section {
            position: relative;
            padding: 5rem 1.5rem;
            background: linear-gradient(135deg, var(--purple) 0%, var(--purple-dark) 100%);
            overflow: hidden;
        }
        .cta-bg-glow {
            position: absolute;
            inset: 0;
            opacity: 0.4;
            pointer-events: none;
        }
        .cta-bg-glow-1 {
            position: absolute;
            top: -6rem;
            left: -6rem;
            width: 24rem;
            height: 24rem;
            border-radius: 50%;
            background: var(--pink);
            filter: blur(100px);
        }
        .cta-bg-glow-2 {
            position: absolute;
            bottom: 0;
            right: 0;
            width: 16rem;
            height: 16rem;
            border-radius: 50%;
            background: var(--yellow);
            filter: blur(100px);
            opacity: 0.6;
        }
        .cta-inner {
            position: relative;
            z-index: 10;
            max-width: 56rem;
            margin: 0 auto;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 1.5rem;
        }
        .cta-title {
            font-size: 2rem;
            font-weight: 800;
            color: var(--white);
            line-height: 1.2;
        }
        @media (min-width: 768px) {
            .cta-title { font-size: 3rem; }
        }
        .cta-desc {
            font-size: 1rem;
            color: rgba(255,255,255,0.9);
            max-width: 42rem;
            line-height: 1.6;
        }
        @media (min-width: 768px) {
            .cta-desc { font-size: 1.125rem; }
        }
        .cta-buttons {
            display: flex;
            flex-direction: column;
            gap: 1rem;
            width: 100%;
            margin-top: 1.5rem;
        }
        @media (min-width: 640px) {
            .cta-buttons { flex-direction: row; width: auto; }
        }
        .cta-btn-main {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            background: var(--yellow);
            color: var(--purple);
            padding: 0.875rem 2rem;
            border-radius: var(--radius-full);
            font-weight: 700;
            transition: all var(--transition);
            box-shadow: 0 4px 16px rgba(255, 193, 7, 0.3);
        }
        .cta-btn-main:hover {
            background: var(--white);
            transform: translateY(-2px);
        }
        .cta-btn-main:hover i { transform: translateX(3px); }
        .cta-btn-main i { width: 20px; height: 20px; transition: transform var(--transition); }

        .cta-btn-outline {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: rgba(255,255,255,0.1);
            color: var(--white);
            padding: 0.875rem 2rem;
            border-radius: var(--radius-full);
            font-weight: 600;
            border: 1px solid rgba(255,255,255,0.25);
            transition: all var(--transition);
        }
        .cta-btn-outline:hover {
            background: rgba(255,255,255,0.2);
        }

        /* ─── FOOTER ─── */
        .public-footer {
            background: var(--gray-900);
            color: var(--gray-400);
            border-top: 1px solid var(--gray-800);
            padding: 4rem 1.5rem 2rem;
        }
        .public-footer-inner {
            max-width: 72rem;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr;
            gap: 2.5rem;
            margin-bottom: 3rem;
            font-size: 0.875rem;
        }
        @media (min-width: 768px) {
            .public-footer-inner { grid-template-columns: 2fr 1fr 1fr; }
        }
        .public-footer-brand img {
            height: 56px;
            width: auto;
            filter: brightness(0) invert(1);
            margin-bottom: 1.25rem;
        }
        .public-footer-brand p {
            max-width: 24rem;
            line-height: 1.7;
            color: var(--gray-400);
            margin-bottom: 1.25rem;
        }
        .public-footer-social {
            display: flex;
            gap: 0.75rem;
        }
        .public-footer-social a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: var(--gray-800);
            color: var(--gray-400);
            transition: all var(--transition);
        }
        .public-footer-social a:hover {
            background: var(--pink);
            color: var(--white);
            transform: translateY(-2px);
        }
        .public-footer-social i { width: 16px; height: 16px; }

        .public-footer-col h4 {
            color: var(--white);
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            margin-bottom: 1rem;
        }
        .public-footer-col ul { list-style: none; padding: 0; }
        .public-footer-col li { margin-bottom: 0.75rem; }
        .public-footer-col a {
            color: var(--gray-400);
            transition: color var(--transition);
        }
        .public-footer-col a:hover { color: var(--pink-light); }

        .public-footer-bottom {
            max-width: 72rem;
            margin: 0 auto;
            padding-top: 2rem;
            border-top: 1px solid var(--gray-800);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            font-size: 0.75rem;
            color: var(--gray-500);
        }
        @media (min-width: 768px) {
            .public-footer-bottom { flex-direction: row; }
        }
        .public-footer-bottom i {
            width: 12px;
            height: 12px;
            display: inline;
            color: var(--pink);
            fill: var(--pink);
        }
    </style>
</head>

<body class="landing-body">

<%-- ═════ NAVBAR PÚBLICO ═════ --%>
<nav class="public-navbar">
    <div>
        <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Quinta Ola" class="public-navbar-logo"/>
    </div>
    <div class="public-navbar-actions">
        <a href="<%= ctx %>/CatalogServlet" class="public-nav-link">Nuestros productos</a>

        <% if (estaLogueado) { %>
        <a href="<%= ctx %>/HomeServlet" class="public-nav-btn">
            <i data-lucide="layout-dashboard"></i> Ir al Panel
        </a>
        <% } else { %>
        <a href="<%= ctx %>/AuthServlet?action=formLogin" class="public-nav-btn">
            <i data-lucide="log-in"></i> Iniciar sesión
        </a>
        <% } %>
    </div>
</nav>

<%-- ═════ HERO ═════ --%>
<section id="top" class="hero-section">
    <img id="heroImage"
         src="https://img.freepik.com/foto-gratis/grupo-personas-arrojando-dinero-oficina_1303-15891.jpg"
         class="hero-bg-image"
         alt="Hero Background"/>
    <div class="hero-overlay"></div>

    <div class="hero-content">
        <h1 class="hero-title">
            Bienvenido a <span class="hero-title-accent">Quinta Ola</span>
            <span class="hero-subtitle">Sistema inteligente de inventario</span>
        </h1>

        <p class="hero-description">
            Gestiona materiales, visualiza productos y optimiza procesos
            con una plataforma moderna, rápida y eficiente.
        </p>

        <div class="hero-cta-group">
            <a href="<%= ctx %>/CatalogServlet" class="hero-btn-primary">
                <i data-lucide="package"></i> Ver Catálogo
            </a>

            <% if (estaLogueado) { %>
            <a href="<%= ctx %>/HomeServlet" class="hero-btn-secondary">
                <i data-lucide="layout-dashboard"></i> Ir al Panel
            </a>
            <% } else { %>
            <a href="<%= ctx %>/AuthServlet?action=formLogin" class="hero-btn-secondary">
                <i data-lucide="log-in"></i> Acceder al sistema
            </a>
            <% } %>
        </div>
    </div>
</section>

<%-- ═════ FEATURES ═════ --%>
<section class="features-section">
    <div class="features-inner">

        <span class="features-tag">Funcionalidades principales</span>
        <h2 class="features-title">Todo lo que necesitas en una sola plataforma</h2>
        <p class="features-subtitle">
            Optimiza los procesos de tu organización con herramientas diseñadas para escalar,
            mantener el orden y mejorar la toma de decisiones.
        </p>

        <div class="features-grid">

            <%-- Tarjeta 1 --%>
            <div class="feature-card-wrap">
                <div id="card-1" class="feature-card">
                    <div class="feature-card-face feature-card-front">
                        <div class="feature-card-img">
                            <img src="https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d" alt="Gestión de Inventario"/>
                            <div class="feature-card-img-overlay"></div>
                            <div class="feature-card-icon-corner">
                                <i data-lucide="package"></i>
                            </div>
                        </div>
                        <div class="feature-card-body">
                            <h3 class="feature-card-title">Gestión de inventario</h3>
                            <p class="feature-card-desc">
                                Supervisa y controla tu stock en tiempo real. Configura alertas de
                                escasez y mantén siempre disponible lo que tu equipo necesita.
                            </p>
                            <button onclick="document.getElementById('card-1').classList.toggle('rotate-y-180')"
                                    class="feature-card-link">
                                Conocer más <i data-lucide="arrow-right"></i>
                            </button>
                        </div>
                    </div>

                    <div class="feature-card-face feature-card-back">
                        <i data-lucide="info" class="main-icon"></i>
                        <h3>Detalle Técnico</h3>
                        <p>
                            El sistema actualiza automáticamente el stock cada vez que se aprueba
                            una solicitud, manteniendo la trazabilidad completa de cada movimiento.
                        </p>
                        <button onclick="document.getElementById('card-1').classList.toggle('rotate-y-180')">
                            Volver
                        </button>
                    </div>
                </div>
            </div>

            <%-- Tarjeta 2 --%>
            <div class="feature-card-wrap">
                <div id="card-2" class="feature-card">
                    <div class="feature-card-face feature-card-front">
                        <div class="feature-card-img">
                            <img src="https://images.unsplash.com/photo-1551288049-bebda4e38f71" alt="Análisis de Datos"/>
                            <div class="feature-card-img-overlay"></div>
                            <div class="feature-card-icon-corner">
                                <i data-lucide="bar-chart-3"></i>
                            </div>
                        </div>
                        <div class="feature-card-body">
                            <h3 class="feature-card-title">Análisis y Reportes</h3>
                            <p class="feature-card-desc">
                                Convierte datos complejos en paneles visuales intuitivos.
                                Analiza tendencias y toma decisiones basadas en información precisa.
                            </p>
                            <button onclick="document.getElementById('card-2').classList.toggle('rotate-y-180')"
                                    class="feature-card-link">
                                Conocer más <i data-lucide="arrow-right"></i>
                            </button>
                        </div>
                    </div>

                    <div class="feature-card-face feature-card-back">
                        <i data-lucide="file-spreadsheet" class="main-icon"></i>
                        <h3>Exportación Rápida</h3>
                        <p>
                            Reportes mensuales que reemplazan el uso manual de Excel.
                            Exporta toda la data en formato CSV con un solo clic.
                        </p>
                        <button onclick="document.getElementById('card-2').classList.toggle('rotate-y-180')">
                            Volver
                        </button>
                    </div>
                </div>
            </div>

            <%-- Tarjeta 3 --%>
            <div class="feature-card-wrap">
                <div id="card-3" class="feature-card">
                    <div class="feature-card-face feature-card-front">
                        <div class="feature-card-img">
                            <img src="https://images.unsplash.com/photo-1556740749-887f6717d7e4" alt="Solicitudes Internas"/>
                            <div class="feature-card-img-overlay"></div>
                            <div class="feature-card-icon-corner">
                                <i data-lucide="zap"></i>
                            </div>
                        </div>
                        <div class="feature-card-body">
                            <h3 class="feature-card-title">Solicitudes rápidas</h3>
                            <p class="feature-card-desc">
                                Agiliza los pedidos internos con flujos de aprobación automáticos.
                                Reduce el papeleo y mejora la comunicación entre áreas.
                            </p>
                            <button onclick="document.getElementById('card-3').classList.toggle('rotate-y-180')"
                                    class="feature-card-link">
                                Conocer más <i data-lucide="arrow-right"></i>
                            </button>
                        </div>
                    </div>

                    <div class="feature-card-face feature-card-back">
                        <i data-lucide="check-circle" class="main-icon"></i>
                        <h3>Flujo de Aprobación</h3>
                        <p>
                            Las solicitudes pasan por estados de Pendiente, Aprobada, Rechazada
                            y Entregada, con notificaciones automáticas en cada cambio.
                        </p>
                        <button onclick="document.getElementById('card-3').classList.toggle('rotate-y-180')">
                            Volver
                        </button>
                    </div>
                </div>
            </div>

        </div>
    </div>
</section>

<%-- ═════ CTA ═════ --%>
<section class="cta-section">
    <div class="cta-bg-glow">
        <div class="cta-bg-glow-1"></div>
        <div class="cta-bg-glow-2"></div>
    </div>

    <div class="cta-inner">
        <h2 class="cta-title">¿Lista para tomar el control de tu inventario?</h2>
        <p class="cta-desc">
            Únete al equipo de Quinta Ola y optimiza la gestión de recursos.
            Toma decisiones inteligentes basadas en datos reales.
        </p>

        <div class="cta-buttons">
            <% if (estaLogueado) { %>
            <a href="<%= ctx %>/HomeServlet" class="cta-btn-main">
                Ir al Panel <i data-lucide="arrow-right"></i>
            </a>
            <% } else { %>
            <a href="<%= ctx %>/AuthServlet?action=formLogin" class="cta-btn-main">
                Acceder al sistema <i data-lucide="arrow-right"></i>
            </a>
            <% } %>
            <a href="#top" class="cta-btn-outline">Explorar funcionalidades</a>
        </div>
    </div>
</section>

<%-- ═════ FOOTER ═════ --%>
<footer class="public-footer">
    <div class="public-footer-inner">

        <div class="public-footer-brand">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Quinta Ola Logo"/>
            <p>
                Innovando la gestión de inventarios con soluciones modernas, intuitivas
                y escalables para organizaciones que miran hacia el futuro.
            </p>
            <div class="public-footer-social">
                <!-- Instagram -->
                <a href="https://www.instagram.com/quintaolaperu/" target="_blank" rel="noopener noreferrer" title="Instagram">
                    <i data-lucide="instagram"></i>
                </a>

                <!-- Correo Electrónico -->
                <a href="mailto:comunicaciones@quintaola.org" title="Enviar correo">
                    <i data-lucide="mail"></i>
                </a>

                <!-- Facebook -->
                <a href="https://www.facebook.com/QuintaOlaPeru" target="_blank" rel="noopener noreferrer" title="Facebook">
                    <i data-lucide="facebook"></i>
                </a>

                <!-- LinkedIn -->
                <a href="https://www.linkedin.com/company/quintaola/" target="_blank" rel="noopener noreferrer" title="LinkedIn">
                    <i data-lucide="linkedin"></i>
                </a>
            </div>
        </div>

        <div class="public-footer-col">
            <h4>Plataforma</h4>
            <ul>
                <li><a href="#top">Inicio</a></li>
                <li><a href="<%= ctx %>/CatalogServlet">Nuestros productos</a></li>
                <li><a href="<%= ctx %>/AuthServlet?action=formLogin">Iniciar sesión</a></li>
            </ul>
        </div>

        <div class="public-footer-col">
            <h4>Soporte</h4>
            <ul>
                <li><a href="#">Centro de ayuda</a></li>
                <li><a href="#">Términos de servicio</a></li>
                <li><a href="#">Política de privacidad</a></li>
            </ul>
        </div>

    </div>

    <div class="public-footer-bottom">
        <p>© 2026 Quinta Ola. Todos los derechos reservados.</p>
        <p>Hecho con <i data-lucide="heart"></i> para la gestión de inventarios</p>
    </div>
</footer>

<script src="https://unpkg.com/lucide@0.400.0/dist/umd/lucide.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });
</script>

</body>
</html>