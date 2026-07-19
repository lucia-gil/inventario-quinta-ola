<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
    String token = (String) request.getAttribute("token");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Restablecer Contraseña | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=22" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="page-body" style="display:flex; align-items:center; justify-content:center; min-height:100vh; background: linear-gradient(135deg, #5B1FA8 0%, #4A1690 55%, #E91E8C 130%);">

<div class="panel-form" style="max-width: 420px; width: 100%; margin: 1.5rem;">

    <div style="text-align:center; margin-bottom: 1.5rem;">
        <div style="width:64px; height:64px; border-radius:50%; background: var(--purple-bg); display:flex; align-items:center; justify-content:center; margin: 0 auto 1rem;">
            <i data-lucide="key-round" style="width:28px; height:28px; color: var(--purple);"></i>
        </div>
        <h1 class="page-title" style="font-size: 1.4rem;">Crea tu nueva contraseña</h1>
        <p class="page-subtitle">Elige una contraseña segura para tu cuenta.</p>
    </div>

    <% if (error != null) { %>
    <div class="notif-alert-error" style="margin-bottom: 1.25rem;">
        <i data-lucide="alert-triangle"></i>
        <span><%= error %></span>
    </div>
    <% } %>

    <form action="<%= ctx %>/AuthServlet" method="POST">
        <input type="hidden" name="action" value="resetPassword"/>
        <input type="hidden" name="token" value="<%= token %>"/>

        <div style="margin-bottom: 1.25rem;">
            <label class="form-label">Nueva contraseña</label>
            <input type="password" name="newPassword" class="input-page" required minlength="8"/>
        </div>

        <div style="margin-bottom: 1.5rem;">
            <label class="form-label">Confirmar contraseña</label>
            <input type="password" name="confirmPassword" class="input-page" required minlength="8"/>
        </div>

        <button type="submit" class="btn-page-primary btn-icon" style="width:100%; justify-content:center; padding: 0.75rem;">
            <i data-lucide="check"></i> Restablecer contraseña
        </button>
    </form>

</div>

<script>lucide.createIcons();</script>
</body>
</html>