<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acceso Denegado | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=10" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            font-family: 'Montserrat', sans-serif;
            background: linear-gradient(135deg, #FEE2E2 0%, #FCE7F3 50%, #EDE9FE 100%);
            min-height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
        }

        .error-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            box-shadow: 0 20px 60px rgba(91, 31, 168, 0.15);
            padding: 3rem 2.5rem;
            max-width: 480px;
            width: 100%;
            text-align: center;
            border: 1px solid var(--gray-100);
        }

        .error-icon-wrap {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            background: linear-gradient(135deg, #FECACA 0%, var(--red-bg) 100%);
            margin: 0 auto 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 20px rgba(239, 68, 68, 0.2);
        }
        .error-icon-wrap i {
            width: 44px;
            height: 44px;
            color: var(--red-dark);
            stroke-width: 2;
        }

        .error-code {
            font-size: 5.5rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--red) 0%, var(--purple) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1;
            margin: 0;
            letter-spacing: -3px;
        }

        .error-title {
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--gray-800);
            margin: 0.75rem 0 0.5rem;
        }

        .error-message {
            font-size: 0.92rem;
            color: var(--gray-600);
            line-height: 1.6;
            margin-bottom: 2rem;
        }

        .error-actions {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
            justify-content: center;
        }

        .btn-primary, .btn-secondary {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            border-radius: var(--radius-full);
            font-size: 0.85rem;
            font-weight: 700;
            text-decoration: none;
            transition: all var(--transition);
            cursor: pointer;
            font-family: inherit;
            border: 2px solid transparent;
        }
        .btn-primary {
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white);
            box-shadow: 0 4px 14px rgba(233, 30, 140, 0.3);
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(233, 30, 140, 0.4);
        }
        .btn-secondary {
            background: var(--white);
            color: var(--purple);
            border-color: var(--purple-bg);
        }
        .btn-secondary:hover {
            background: var(--purple-bg);
            border-color: var(--purple);
        }
        .btn-primary i, .btn-secondary i { width: 16px; height: 16px; }

        .error-hint {
            margin-top: 2rem;
            padding-top: 1.5rem;
            border-top: 1px solid var(--gray-100);
            font-size: 0.78rem;
            color: var(--gray-500);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
        }
        .error-hint i { width: 14px; height: 14px; color: var(--purple); }
    </style>
</head>
<body>

<div class="error-card">

    <div class="error-icon-wrap">
        <i data-lucide="shield-off"></i>
    </div>

    <h1 class="error-code">403</h1>
    <h2 class="error-title">Acceso Denegado</h2>

    <p class="error-message">
        No tienes los permisos necesarios para acceder a esta sección del sistema.
        Si crees que esto es un error, contacta al Administrador.
    </p>

    <div class="error-actions">
        <a href="<%= ctx %>/HomeServlet" class="btn-primary">
            <i data-lucide="home"></i>
            Ir al inicio
        </a>
        <button onclick="window.history.back()" class="btn-secondary">
            <i data-lucide="arrow-left"></i>
            Volver atrás
        </button>
    </div>

    <div class="error-hint">
        <i data-lucide="info"></i>
        <span>Si necesitas estos permisos, solicítalos a tu coordinador.</span>
    </div>

</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });
</script>

</body>
</html>