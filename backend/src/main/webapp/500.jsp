<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error del Servidor | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=25" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body {
            font-family: 'Montserrat', sans-serif;
            background: linear-gradient(135deg, #FFF8E1 0%, var(--pink-bg) 50%, var(--purple-bg) 100%);
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
            max-width: 500px;
            width: 100%;
            text-align: center;
            border: 1px solid var(--gray-100);
        }

        .error-icon-wrap {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--yellow-bg) 0%, #FED7AA 100%);
            margin: 0 auto 1.5rem;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 20px rgba(255, 193, 7, 0.25);
            animation: shake 2s ease-in-out infinite;
        }
        .error-icon-wrap i {
            width: 44px;
            height: 44px;
            color: var(--orange-dark);
            stroke-width: 2;
        }

        @keyframes shake {
            0%, 100% { transform: rotate(0); }
            25% { transform: rotate(-5deg); }
            75% { transform: rotate(5deg); }
        }

        .error-code {
            font-size: 5.5rem;
            font-weight: 900;
            background: linear-gradient(135deg, var(--orange-dark) 0%, var(--pink) 100%);
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
        .error-hint i { width: 14px; height: 14px; color: var(--orange-dark); }
    </style>
</head>
<body>

<div class="error-card">

    <div class="error-icon-wrap">
        <i data-lucide="alert-triangle"></i>
    </div>

    <h1 class="error-code">500</h1>
    <h2 class="error-title">¡Algo salió mal!</h2>

    <p class="error-message">
        Tuvimos un problema en el servidor mientras procesábamos tu solicitud.
        No te preocupes, nuestro equipo ya fue notificado y estamos trabajando en ello.
    </p>

    <div class="error-actions">
        <a href="<%= ctx %>/HomeServlet" class="btn-primary">
            <i data-lucide="home"></i>
            Ir al inicio
        </a>
        <button onclick="window.location.reload()" class="btn-secondary">
            <i data-lucide="refresh-cw"></i>
            Intentar de nuevo
        </button>
    </div>

    <div class="error-hint">
        <i data-lucide="info"></i>
        <span>Si el problema persiste, contacta al soporte técnico.</span>
    </div>

</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });

    /**
     * Valida la foto seleccionada ANTES de enviarla al servidor.
     * Si pasa las validaciones, dispara el submit del form oculto.
     */
    function validarYSubirAvatar(input) {
        const file = input.files[0];
        if (!file) return;

        const MAX_BYTES = 5 * 1024 * 1024; // 5 MB
        const TIPOS_PERMITIDOS = ['image/jpeg', 'image/png', 'image/webp'];

        // 1. Validar tipo (segunda barrera, además de "accept")
        if (TIPOS_PERMITIDOS.indexOf(file.type) === -1) {
            mostrarAlertaAvatar(
                'Formato no permitido',
                'Solo se aceptan imágenes en formato JPG, PNG o WEBP.',
                'error'
            );
            input.value = '';
            return;
        }

        // 2. Validar tamaño
        if (file.size > MAX_BYTES) {
            const sizeMb = (file.size / (1024 * 1024)).toFixed(1);
            mostrarAlertaAvatar(
                'Imagen demasiado grande',
                'Tu imagen pesa ' + sizeMb + ' MB. El máximo permitido es 5 MB. ' +
                'Por favor comprime la imagen o elige una más pequeña.',
                'error'
            );
            input.value = '';
            return;
        }

        // 3. Todo OK — enviar form
        document.getElementById('avatar-form').submit();
    }

    /**
     * Muestra una alerta visual bonita arriba del perfil.
     * Tipo: 'error' (rojo) o 'success' (verde).
     */
    function mostrarAlertaAvatar(titulo, mensaje, tipo) {
        // Eliminar alerta previa si existe
        const previa = document.getElementById('avatar-alert-dynamic');
        if (previa) previa.remove();

        const colorBg     = tipo === 'error' ? 'var(--red-bg)'     : 'var(--green-bg)';
        const colorTxt    = tipo === 'error' ? 'var(--red-dark)'   : 'var(--green-dark)';
        const colorBorder = tipo === 'error' ? '#FECACA'           : '#BBF7D0';
        const icono       = tipo === 'error' ? 'alert-triangle'    : 'check-circle';

        const html = `
            <div id="avatar-alert-dynamic"
                 style="display: flex; align-items: flex-start; gap: 0.7rem;
                        padding: 1rem 1.2rem; margin-bottom: 1.25rem;
                        background: ${colorBg}; color: ${colorTxt};
                        border: 1px solid ${colorBorder};
                        border-radius: var(--radius-sm); font-size: 0.88rem;
                        font-weight: 600; animation: slideDown 0.3s ease;">
                <i data-lucide="${icono}" style="width: 20px; height: 20px; flex-shrink: 0; margin-top: 2px;"></i>
                <div style="flex: 1;">
                    <div style="font-weight: 800; margin-bottom: 0.2rem; font-size: 0.92rem;">${titulo}</div>
                    <div style="font-weight: 500; line-height: 1.5;">${mensaje}</div>
                </div>
                <button onclick="this.parentElement.remove()"
                        style="background: none; border: none; cursor: pointer;
                               color: ${colorTxt}; padding: 0; opacity: 0.6;">
                    <i data-lucide="x" style="width: 16px; height: 16px;"></i>
                </button>
            </div>
        `;

        // Insertar arriba del page-header
        const pageHeader = document.querySelector('.page-header');
        if (pageHeader) {
            pageHeader.insertAdjacentHTML('afterend', html);
            // Re-renderizar íconos
            if (typeof lucide !== 'undefined') lucide.createIcons();
            // Hacer scroll arriba para que la vea
            window.scrollTo({ top: 0, behavior: 'smooth' });
            // Auto-ocultar después de 6 segundos
            setTimeout(() => {
                const el = document.getElementById('avatar-alert-dynamic');
                if (el) {
                    el.style.transition = 'opacity 0.4s';
                    el.style.opacity = '0';
                    setTimeout(() => el.remove(), 400);
                }
            }, 6000);
        }
    }
</script>

<style>
    @keyframes slideDown {
        from { opacity: 0; transform: translateY(-10px); }
        to   { opacity: 1; transform: translateY(0); }
    }
</style>

</body>
</html>