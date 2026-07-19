<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Recuperar Contraseña | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=22" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="page-body" style="display:flex; align-items:center; justify-content:center; min-height:100vh; background: linear-gradient(135deg, #5B1FA8 0%, #4A1690 55%, #E91E8C 130%);">

<div class="panel-form" style="max-width: 420px; width: 100%; margin: 1.5rem;">

    <div style="text-align:center; margin-bottom: 1.5rem;">
        <div style="width:64px; height:64px; border-radius:50%; background: var(--purple-bg); display:flex; align-items:center; justify-content:center; margin: 0 auto 1rem;">
            <i data-lucide="mail-question" style="width:28px; height:28px; color: var(--purple);"></i>
        </div>
        <h1 class="page-title" style="font-size: 1.4rem;">¿Olvidaste tu contraseña?</h1>
        <p class="page-subtitle">Ingresa tu correo y te enviaremos un enlace para restablecerla.</p>
    </div>

    <% if (error != null) { %>
    <div class="notif-alert-error" style="margin-bottom: 1.25rem;">
        <i data-lucide="alert-triangle"></i>
        <span><%= error %></span>
    </div>
    <% } %>

    <% if (success != null) { %>
    <div style="background-color: var(--green-bg); border-left: 4px solid var(--green); color: var(--green-dark); border-radius: 0 12px 12px 0; padding: 1rem; display: flex; align-items: center; gap: 12px; margin-bottom: 1.25rem; font-weight: 600; font-size: 0.875rem;">
        <i data-lucide="check-circle" style="width:20px; height:20px; flex-shrink:0;"></i>
        <span><%= success %></span>
    </div>
    <% } else { %>
    <form action="<%= ctx %>/AuthServlet" method="POST">
        <input type="hidden" name="action" value="forgotPassword"/>

        <div style="margin-bottom: 1.5rem;">
            <label class="form-label">Correo electrónico</label>
            <input type="email"
                   name="email"
                   class="input-page"
                   required
                   placeholder="tucorreo@quintaola.com"
                   maxlength="100"
                   pattern="[^\s@]+@[^\s@]+\.[^\s@]+"
                   autocomplete="email"/>
        </div>

        <button type="submit" class="btn-page-primary btn-icon" style="width:100%; justify-content:center; padding: 0.75rem;">
            <i data-lucide="send"></i> Enviar enlace de recuperación
        </button>
    </form>
    <% } %>

    <div style="text-align:center; margin-top: 1.5rem; padding-top: 1rem; border-top: 1px solid var(--gray-100);">
        <a href="<%= ctx %>/AuthServlet?action=formLogin" style="font-size: 0.85rem; font-weight: 700; color: var(--purple); display:inline-flex; align-items:center; gap:6px;">
            <i data-lucide="arrow-left" style="width:14px; height:14px;"></i> Volver a Iniciar Sesión
        </a>
    </div>

</div>

<script>lucide.createIcons();</script>
</body>
</html>