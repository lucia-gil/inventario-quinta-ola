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

    <link href="<%= ctx %>/css/style.css?v=24" rel="stylesheet" />

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

        /* ═════ Animaciones de entrada (sin JS, sin scroll real) ═════ */
        @keyframes landingFadeInUp {
            from { opacity: 0; transform: translateY(22px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes landingFadeIn {
            from { opacity: 0; }
            to   { opacity: 1; }
        }

        .public-navbar {
            animation: landingFadeIn 0.5s ease both;
        }

        .hero-content > * {
            opacity: 0;
            animation: landingFadeInUp 0.7s cubic-bezier(.22,.9,.32,1) both;
        }
        .hero-content .hero-badge      { animation-delay: 0.05s; }
        .hero-content .hero-title      { animation-delay: 0.18s; }
        .hero-content .hero-description{ animation-delay: 0.34s; }
        .hero-content .hero-cta-group  { animation-delay: 0.5s; }

        .hero-photo-wrap {
            opacity: 0;
            animation: landingFadeInUp 0.8s cubic-bezier(.22,.9,.32,1) both;
            animation-delay: 0.4s;
        }

        .features-tag,
        .features-title,
        .features-subtitle {
            opacity: 0;
            animation: landingFadeInUp 0.65s cubic-bezier(.22,.9,.32,1) both;
        }
        .features-tag      { animation-delay: 0.05s; }
        .features-title    { animation-delay: 0.15s; }
        .features-subtitle { animation-delay: 0.25s; }

        .feature-card-wrap {
            opacity: 0;
            animation: landingFadeInUp 0.65s cubic-bezier(.22,.9,.32,1) both;
            height: 480px;
            perspective: 1000px;
        }
        .feature-card-wrap:nth-child(1) { animation-delay: 0.35s; }
        .feature-card-wrap:nth-child(2) { animation-delay: 0.48s; }
        .feature-card-wrap:nth-child(3) { animation-delay: 0.61s; }

        .cta-title,
        .cta-desc,
        .cta-buttons {
            opacity: 0;
            animation: landingFadeInUp 0.65s cubic-bezier(.22,.9,.32,1) both;
        }
        .cta-title   { animation-delay: 0.05s; }
        .cta-desc    { animation-delay: 0.18s; }
        .cta-buttons { animation-delay: 0.31s; }

        /* Respeta accesibilidad: sin movimiento si el usuario lo prefiere así */
        @media (prefers-reduced-motion: reduce) {
            .public-navbar,
            .hero-content > *,
            .hero-photo-wrap,
            .features-tag, .features-title, .features-subtitle,
            .feature-card-wrap,
            .cta-title, .cta-desc, .cta-buttons {
                animation: none;
                opacity: 1;
            }
        }

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
            align-items: center;
            min-height: 88vh;
            padding: 3.5rem 2rem;
            margin-top: 80px;
            background: linear-gradient(135deg, var(--purple) 0%, var(--purple-dark) 100%);
            overflow: hidden;
        }

        /* Círculo decorativo rosa, mismo recurso del sitio institucional */
        .hero-section::before {
            content: "";
            position: absolute;
            top: -80px;
            left: -80px;
            width: 220px;
            height: 220px;
            border-radius: 50%;
            background: var(--pink);
            opacity: 0.18;
            pointer-events: none;
            z-index: 1;
        }

        /* Burbuja decorativa extra, esquina opuesta */
        .hero-section::after {
            content: "";
            position: absolute;
            bottom: 40px;
            right: 6%;
            width: 130px;
            height: 130px;
            border-radius: 50%;
            background: var(--yellow);
            opacity: 0.14;
            pointer-events: none;
            z-index: 1;
        }

        /* Burbujas adicionales del hero — contenedor extra porque un
           elemento solo admite ::before y ::after (dos pseudo-elementos),
           así que las 3 restantes van sobre .hero-inner. */
        .hero-inner {
            position: relative;
        }
        .hero-inner::before {
            content: "";
            position: absolute;
            top: 8%;
            left: 42%;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            border: 2px solid rgba(255,255,255,0.25);
            pointer-events: none;
            z-index: 1;
        }
        .hero-inner::after {
            content: "";
            position: absolute;
            bottom: 12%;
            left: -2%;
            width: 90px;
            height: 90px;
            border-radius: 50%;
            background: var(--pink);
            opacity: 0.13;
            pointer-events: none;
            z-index: 1;
        }
        .hero-photo-frame::before {
            content: "";
            position: absolute;
            top: -35px;
            right: 15%;
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: var(--white);
            opacity: 0.18;
            pointer-events: none;
        }

        .hero-inner {
            position: relative;
            z-index: 2;
            max-width: 84rem;
            width: 100%;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr;
            gap: 3rem;
            align-items: center;
        }

        @media (min-width: 1024px) {
            .hero-inner {
                grid-template-columns: 1fr 1.15fr;
                gap: 4rem;
            }
        }

        .hero-content {
            position: relative;
            z-index: 2;
            text-align: center;
            max-width: 40rem;
            margin: 0 auto;
        }

        @media (min-width: 1024px) {
            .hero-content {
                text-align: left;
                margin: 0;
            }
        }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.75rem;
            font-weight: 800;
            letter-spacing: 1.8px;
            text-transform: uppercase;
            color: var(--white);
            background: rgba(255,255,255,0.14);
            border: 1px solid rgba(255,255,255,0.3);
            padding: 0.5rem 1.1rem;
            border-radius: var(--radius-full);
            margin-bottom: 1.5rem;
        }
        .hero-badge i { width: 14px; height: 14px; color: var(--yellow); }

        .hero-title {
            font-size: 2.5rem;
            font-weight: 900;
            line-height: 1.08;
            color: var(--white);
            margin-bottom: 1.5rem;
            letter-spacing: -0.8px;
        }
        .hero-title-accent {
            color: var(--pink-light);
        }
        .hero-subtitle {
            font-size: 1.35rem;
            font-weight: 700;
            color: var(--yellow);
            display: block;
            margin-top: 0.85rem;
        }
        .hero-description {
            font-size: 1.05rem;
            color: rgba(255,255,255,0.92);
            max-width: 42rem;
            margin: 0 auto 2.25rem;
            line-height: 1.7;
        }
        @media (min-width: 1024px) {
            .hero-description { margin: 0 0 2.25rem; }
        }

        .hero-cta-group {
            display: flex;
            flex-direction: column;
            gap: 1rem;
            justify-content: center;
            max-width: 30rem;
            margin: 0 auto;
        }
        @media (min-width: 1024px) {
            .hero-cta-group { justify-content: flex-start; margin: 0; }
        }

        .hero-btn-primary,
        .hero-btn-secondary {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 1rem 2.25rem;
            border-radius: var(--radius-full);
            font-weight: 700;
            font-size: 1rem;
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

        /* ─── Foto del equipo, estilo del sitio institucional: marco amarillo detrás ─── */
        .hero-photo-wrap {
            position: relative;
            z-index: 2;
            max-width: 46rem;
            width: 100%;
            margin: 0 auto;
        }
        .hero-photo-frame {
            position: absolute;
            top: 1.75rem;
            right: -1.75rem;
            bottom: -1.75rem;
            left: 1.75rem;
            background: var(--yellow);
            border-radius: var(--radius-lg);
            z-index: 1;
        }
        .hero-photo-wrap img {
            position: relative;
            z-index: 2;
            width: 100%;
            height: auto;
            display: block;
            border-radius: var(--radius-lg);
            box-shadow: 0 20px 48px rgba(0,0,0,0.35);
        }

        @media (max-width: 1023px) {
            .hero-photo-wrap { max-width: 30rem; }
            .hero-photo-frame { top: 1.1rem; right: -1.1rem; bottom: -1.1rem; left: 1.1rem; }
        }

        /* ─── SECCIÓN FEATURES ─── */
        .features-section {
            position: relative;
            padding: 5rem 1.5rem;
            background: var(--gray-50);
            border-top: 1px solid var(--gray-200);
        }

        /* Burbujas decorativas — colocadas DENTRO del área visible
           (sin offsets negativos) para que no queden recortadas por el
           overflow-x:clip global del body. */
        .features-section::before {
            content: "";
            position: absolute;
            top: 30px;
            right: 4%;
            width: 170px;
            height: 170px;
            border-radius: 50%;
            background: var(--pink);
            opacity: 0.16;
            pointer-events: none;
            z-index: 1;
        }
        .features-section::after {
            content: "";
            position: absolute;
            bottom: 50px;
            left: 3%;
            width: 130px;
            height: 130px;
            border-radius: 50%;
            background: var(--yellow);
            opacity: 0.20;
            pointer-events: none;
            z-index: 1;
        }

        .features-inner {
            position: relative;
            z-index: 2;
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
            height: 17rem;
            overflow: hidden;
            background: var(--gray-100);
        }
        .feature-card-img img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        /* Ajuste fino de encuadre por tarjeta — cada ilustración tiene su
           propia composición original, así que se calibra individualmente
           para que las 3 se vean con el mismo "peso" visual. */
        #card-1 .feature-card-img img { object-position: center 22%; }
        #card-2 .feature-card-img img { object-position: center 15%; }
        #card-3 .feature-card-img img { object-position: center 30%; }

        .feature-card-icon-corner {
            position: absolute;
            bottom: 0.85rem;
            left: 0.85rem;
            color: var(--purple);
            background: rgba(255,255,255,0.85);
            border-radius: 50%;
            width: 34px;
            height: 34px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: var(--shadow-sm);
        }
        .feature-card-icon-corner i { width: 18px; height: 18px; }
        .feature-card-body {
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            min-height: 0;
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

        /* Burbuja decorativa adicional, borde suave */
        .cta-section::after {
            content: "";
            position: absolute;
            top: 15%;
            left: 6%;
            width: 90px;
            height: 90px;
            border-radius: 50%;
            border: 2px solid rgba(255,255,255,0.25);
            pointer-events: none;
            z-index: 1;
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

    <div class="hero-inner">

        <div class="hero-content">
            <span class="hero-badge">
                <i data-lucide="sparkles"></i>
                Sistema de gestión de inventario
            </span>

            <h1 class="hero-title">
                Bienvenido a <span class="hero-title-accent">Quinta Ola</span>
                <span class="hero-subtitle">Sistema inteligente de inventario</span>
            </h1>

            <p class="hero-description">
                Gestiona materiales, visualiza productos y optimiza procesos
                con una plataforma moderna, rápida y eficiente.
            </p>

            <div class="hero-cta-group">
                <% if (estaLogueado) { %>
                <a href="<%= ctx %>/HomeServlet" class="hero-btn-primary">
                    <i data-lucide="layout-dashboard"></i> Ir al Panel
                </a>
                <% } else { %>
                <a href="<%= ctx %>/AuthServlet?action=formLogin" class="hero-btn-primary">
                    <i data-lucide="log-in"></i> Acceder al sistema
                </a>
                <% } %>
            </div>
        </div>

        <div class="hero-photo-wrap">
            <div class="hero-photo-frame"></div>
            <img src="<%= ctx %>/img/equipo-quintaola.png" alt="Equipo Quinta Ola"/>
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
                            <img src="<%= ctx %>/img/inventario.png" alt="Gestión de Inventario"/>
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
                            <img src="<%= ctx %>/img/analisis_y_resportes.png" alt="Análisis de Datos"/>
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
                            <img src="<%= ctx %>/img/solicitudes_rapidas.png" alt="Solicitudes Internas"/>
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