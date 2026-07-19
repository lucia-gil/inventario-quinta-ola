<%--
    ════════════════════════════════════════════════════════════════════
     profile.jsp — Vista del perfil del usuario (rediseño Quinta Ola)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();
    User usuario = (User) request.getAttribute("usuario");
    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");

    // Iniciales para fallback del avatar
    String iniciales = "U";
    if (usuario != null && usuario.getName() != null) {
        String[] partes = usuario.getName().trim().split("\\s+");
        if (partes.length >= 2) {
            iniciales = (partes[0].charAt(0) + "" + partes[1].charAt(0)).toUpperCase();
        } else if (partes.length == 1 && partes[0].length() >= 2) {
            iniciales = partes[0].substring(0, 2).toUpperCase();
        }
    }

    // Rol amigable + clase de badge según rol
    String roleName = usuario != null ? usuario.getRoleName() : "";
    String roleDisplay = roleName;
    String roleBadgeClass = "role-badge-default";
    switch (roleName) {
        case "Viewer":
            roleDisplay = "Solicitante";
            roleBadgeClass = "role-badge-pink";
            break;
        case "Member":
            roleDisplay = "Encargado de Depósito";
            roleBadgeClass = "role-badge-green";
            break;
        case "Manager":
            roleDisplay = "Aprobador(a)";
            roleBadgeClass = "role-badge-yellow";
            break;
        case "Administrador":
            roleDisplay = "Administrador";
            roleBadgeClass = "role-badge-purple";
            break;
        case "SuperAdmin":
            roleDisplay = "Super Admin";
            roleBadgeClass = "role-badge-blue";
            break;
    }

    String avatarUrl = usuario != null ? usuario.getAvatarUrl() : null;

    // Fecha de creación formateada
    String fechaCreacion = "Reciente";
    if (usuario != null && usuario.getCreatedAt() != null) {
        try {
            String dbDate = usuario.getCreatedAt();
            if (dbDate.contains(".")) dbDate = dbDate.substring(0, dbDate.indexOf("."));
            java.text.SimpleDateFormat formatoBD = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            java.util.Date fechaParseada = formatoBD.parse(dbDate);
            java.text.SimpleDateFormat formatoBonito = new java.text.SimpleDateFormat("dd 'de' MMMM, yyyy", new java.util.Locale("es", "ES"));
            fechaCreacion = formatoBonito.format(fechaParseada);
        } catch (Exception e) {
            fechaCreacion = usuario.getCreatedAt().split(" ")[0];
        }
    }

    request.setAttribute("activeMenu", "profile");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Mi Perfil | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=22" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Estilos específicos del perfil ═════ */

        .profile-grid {
            display: grid;
            grid-template-columns: 360px 1fr;
            gap: 1.5rem;
            align-items: start;
        }

        @media (max-width: 1024px) {
            .profile-grid {
                grid-template-columns: 1fr;
            }
        }

        /* ── Card avatar grande ── */
        .profile-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            position: relative;
        }

        .profile-card-banner {
            height: 100px;
            background: linear-gradient(135deg, var(--purple) 0%, var(--pink) 100%);
            position: relative;
        }

        .profile-card-banner::after {
            content: '';
            position: absolute;
            top: 10px;
            right: 10px;
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: var(--yellow);
            opacity: 0.25;
        }

        .profile-card-body {
            padding: 0 1.75rem 1.75rem;
            text-align: center;
            margin-top: -65px;
            position: relative;
        }

        /* ── Avatar circular con cámara ── */
        .profile-avatar-wrap {
            position: relative;
            width: 130px;
            height: 130px;
            margin: 0 auto 1rem;
            cursor: pointer;
        }

        .profile-avatar {
            width: 130px;
            height: 130px;
            border-radius: 50%;
            overflow: hidden;
            border: 5px solid var(--white);
            box-shadow: 0 6px 20px rgba(91, 31, 168, 0.15);
            background: var(--gray-100);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform var(--transition);
        }

        .profile-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .profile-avatar-initials {
            font-size: 2.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%);
            color: var(--white);
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            letter-spacing: 1px;
        }

        /* Botón cámara siempre visible */
        .profile-avatar-camera {
            position: absolute;
            bottom: 5px;
            right: 5px;
            width: 38px;
            height: 38px;
            background: var(--pink);
            color: var(--white);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 3px solid var(--white);
            box-shadow: 0 4px 10px rgba(233, 30, 140, 0.35);
            transition: all var(--transition);
            z-index: 2;
        }

        .profile-avatar-camera i {
            width: 16px;
            height: 16px;
        }

        .profile-avatar-wrap:hover .profile-avatar-camera {
            background: var(--purple);
            transform: scale(1.1);
        }

        .profile-avatar-wrap:hover .profile-avatar {
            transform: scale(1.02);
        }

        .profile-name {
            font-size: 1.35rem;
            font-weight: 800;
            color: var(--gray-800);
            margin-bottom: 0.25rem;
        }

        .profile-email {
            font-size: 0.85rem;
            color: var(--gray-500);
            margin-bottom: 1rem;
            word-break: break-word;
        }

        /* ── Badges de rol ── */
        .role-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.4rem 1rem;
            border-radius: var(--radius-full);
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.3px;
        }
        .role-badge i { width: 14px; height: 14px; }

        .role-badge-pink    { background: var(--pink-bg);   color: var(--pink); }
        .role-badge-green   { background: var(--green-bg);  color: var(--green-dark); }
        .role-badge-yellow  { background: var(--yellow-bg); color: var(--orange-dark); }
        .role-badge-purple  { background: var(--purple-bg); color: var(--purple); }
        .role-badge-blue    { background: var(--blue-bg);   color: var(--blue-dark); }
        .role-badge-default { background: var(--gray-100);  color: var(--gray-600); }

        /* ── Card seguridad ── */
        .security-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            margin-top: 1.5rem;
        }

        .card-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
            background: var(--gray-50);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
        }

        .card-header-title {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--purple);
        }

        .card-header-title i {
            width: 18px;
            height: 18px;
            color: var(--pink);
        }

        .card-body {
            padding: 1.5rem;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.25rem;
        }

        @media (max-width: 640px) {
            .form-row { grid-template-columns: 1fr; }
        }

        .field-group {
            margin-bottom: 1.1rem;
        }

        .field-label {
            display: block;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: var(--gray-500);
            margin-bottom: 0.4rem;
        }

        .field-value {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--gray-800);
            word-break: break-word;
        }

        .field-value.mono {
            font-family: 'Courier New', monospace;
            color: var(--purple);
        }

        .field-input {
            width: 100%;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.65rem 0.85rem;
            font-size: 0.88rem;
            color: var(--gray-800);
            background: var(--gray-50);
            transition: all var(--transition);
            outline: none;
            font-family: inherit;
        }

        .field-input:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }

        /* ── Info personal — grid 2 cols ── */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem 2rem;
        }

        @media (max-width: 640px) {
            .info-grid { grid-template-columns: 1fr; }
        }

        /* ── Card cuenta activa ── */
        .verified-card {
            grid-column: 1 / -1;
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            padding: 1.1rem 1.25rem;
            background: linear-gradient(135deg, var(--green-bg) 0%, var(--blue-bg) 100%);
            border: 1px solid #BBF7D0;
            border-radius: var(--radius-md);
            margin-top: 0.5rem;
        }

        .verified-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 40px;
            border-radius: var(--radius-sm);
            background: var(--green);
            color: var(--white);
            flex-shrink: 0;
        }

        .verified-icon i { width: 20px; height: 20px; }

        .verified-text-title {
            font-size: 0.9rem;
            font-weight: 700;
            color: var(--green-dark);
            margin-bottom: 0.2rem;
        }

        .verified-text-sub {
            font-size: 0.82rem;
            color: var(--gray-600);
            line-height: 1.5;
        }

        .verified-text-sub strong { color: var(--gray-800); }

        /* ── ID badge en header ── */
        .id-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            font-size: 0.7rem;
            font-weight: 700;
            color: var(--pink);
            background: var(--pink-bg);
            padding: 0.3rem 0.7rem;
            border-radius: var(--radius-sm);
            letter-spacing: 0.5px;
        }

        /* ── Privilegios ── */
        .privilege-intro {
            font-size: 0.9rem;
            color: var(--gray-600);
            margin-bottom: 1rem;
            line-height: 1.6;
        }

        .privilege-intro strong {
            background: var(--purple-bg);
            color: var(--purple);
            padding: 0.15rem 0.55rem;
            border-radius: var(--radius-sm);
            font-weight: 700;
        }

        .privilege-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 0.7rem;
        }

        .privilege-item {
            display: flex;
            align-items: flex-start;
            gap: 0.75rem;
            font-size: 0.88rem;
            color: var(--gray-700);
            line-height: 1.5;
        }

        .privilege-check {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 22px;
            height: 22px;
            border-radius: 50%;
            background: var(--pink-bg);
            color: var(--pink);
            flex-shrink: 0;
            margin-top: 1px;
        }

        .privilege-check i { width: 13px; height: 13px; }

        /* ── Botón guardar ── */
        .btn-save {
            width: 100%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white);
            padding: 0.75rem 1.5rem;
            border-radius: var(--radius-full);
            font-size: 0.88rem;
            font-weight: 700;
            border: none;
            cursor: pointer;
            transition: all var(--transition);
            box-shadow: 0 4px 12px rgba(233, 30, 140, 0.2);
            margin-top: 0.5rem;
        }

        .btn-save:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(233, 30, 140, 0.35);
        }

        .btn-save i { width: 16px; height: 16px; }

        /* ── Mensajes de alerta ── */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            padding: 0.9rem 1.1rem;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 600;
            margin-bottom: 1.25rem;
            border: 1px solid;
        }
        .alert-error {
            background: var(--red-bg);
            color: var(--red-dark);
            border-color: #FECACA;
        }
        .alert-success {
            background: var(--green-bg);
            color: var(--green-dark);
            border-color: #BBF7D0;
        }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }
    </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- Header --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">Mi Perfil</h1>
                    <p class="page-subtitle">Información personal y configuración de tu cuenta</p>
                </div>
            </div>

            <%-- Alertas --%>
            <% if (error != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>
            <% if (success != null) { %>
            <div class="alert alert-success">
                <i data-lucide="check-circle"></i>
                <span><%= success %></span>
            </div>
            <% } %>

            <% if (usuario == null) { %>
            <div class="profile-card" style="padding: 4rem; text-align: center;">
                <i data-lucide="user-x" style="width: 56px; height: 56px; color: var(--gray-300); margin: 0 auto 1rem;"></i>
                <p style="color: var(--gray-500); font-weight: 600;">No se pudo cargar tu perfil.</p>
            </div>
            <% } else { %>

            <div class="profile-grid">

                <%-- ═══════ COLUMNA IZQUIERDA ═══════ --%>
                <div>

                    <%-- Card avatar --%>
                    <div class="profile-card">
                        <div class="profile-card-banner"></div>

                        <div class="profile-card-body">

                            <div class="profile-avatar-wrap" onclick="document.getElementById('avatar-upload').click();" title="Cambiar foto de perfil">
                                <div class="profile-avatar">
                                    <% if (avatarUrl != null && !avatarUrl.trim().isEmpty()) { %>
                                    <img src="<%= ctx %><%= avatarUrl %>" alt="Avatar de <%= usuario.getName() %>"/>
                                    <% } else { %>
                                    <div class="profile-avatar-initials"><%= iniciales %></div>
                                    <% } %>
                                </div>
                                <div class="profile-avatar-camera">
                                    <i data-lucide="camera"></i>
                                </div>
                            </div>

                            <form id="avatar-form" action="<%= ctx %>/ProfileServlet" method="POST" enctype="multipart/form-data" style="display: none;">
                                <input type="hidden" name="action" value="uploadAvatar"/>
                                <input type="file" id="avatar-upload" name="avatarFile"
                                       accept="image/png, image/jpeg, image/webp"
                                       onchange="validarYSubirAvatar(this);"/>
                            </form>

                            <%-- Texto pequeño con el límite, debajo del avatar --%>
                            <p style="font-size: 0.7rem; color: var(--gray-500); margin-top: 0.4rem; line-height: 1.4;">
                                <i data-lucide="info" style="width: 11px; height: 11px; display: inline-block; vertical-align: middle;"></i>
                                JPG, PNG o WEBP &middot; Máximo 5 MB
                            </p>

                            <h2 class="profile-name"><%= usuario.getName() %></h2>
                            <p class="profile-email"><%= usuario.getEmail() %></p>

                            <span class="role-badge <%= roleBadgeClass %>">
                                <i data-lucide="shield-check"></i>
                                <%= roleDisplay %>
                            </span>

                        </div>
                    </div>

                    <%-- Card seguridad --%>
                    <div class="security-card">
                        <div class="card-header">
                            <div class="card-header-title">
                                <i data-lucide="shield"></i>
                                <span>Seguridad</span>
                            </div>
                        </div>
                        <div class="card-body">
                            <form action="<%= ctx %>/ProfileServlet" method="POST">
                                <input type="hidden" name="action" value="cambiarPassword"/>

                                <div class="field-group">
                                    <label class="field-label">Clave actual</label>
                                    <input type="password" name="currentPassword" required class="field-input"/>
                                </div>

                                <div class="field-group">
                                    <label class="field-label">Nueva clave</label>
                                    <input type="password" name="newPassword" minlength="8" required class="field-input"/>
                                    <p style="font-size: 0.72rem; color: var(--gray-500); margin-top: 0.4rem; line-height: 1.4;">
                                        Mínimo 8 caracteres, con al menos 1 mayúscula, 1 minúscula, 1 número y 1 símbolo.
                                    </p>
                                </div>

                                <div class="field-group">
                                    <label class="field-label">Confirmar clave</label>
                                    <input type="password" name="confirmPassword" minlength="8" required class="field-input"/>
                                </div>

                                <button type="submit" class="btn-save">
                                    <i data-lucide="key"></i>
                                    Guardar Cambios
                                </button>
                            </form>
                        </div>
                    </div>

                </div>

                <%-- ═══════ COLUMNA DERECHA ═══════ --%>
                <div>

                    <%-- Información personal --%>
                    <div class="profile-card">
                        <div class="card-header">
                            <div class="card-header-title">
                                <i data-lucide="user"></i>
                                <span>Información Personal</span>
                            </div>
                            <span class="id-badge">
                                <i data-lucide="hash" style="width: 12px; height: 12px;"></i>
                                ID <%= usuario.getId() %>
                            </span>
                        </div>

                        <div class="card-body">
                            <div class="info-grid">

                                <div>
                                    <p class="field-label">Nombre Completo</p>
                                    <p class="field-value"><%= usuario.getName() %></p>
                                </div>

                                <div>
                                    <p class="field-label">Documento (DNI)</p>
                                    <p class="field-value mono"><%= usuario.getDni() %></p>
                                </div>

                                <div>
                                    <p class="field-label">Correo Electrónico</p>
                                    <p class="field-value"><%= usuario.getEmail() %></p>
                                </div>

                                <div>
                                    <p class="field-label">Rol Principal</p>
                                    <p class="field-value"><%= roleDisplay %></p>
                                </div>

                                <div class="verified-card">
                                    <div class="verified-icon">
                                        <i data-lucide="check"></i>
                                    </div>
                                    <div>
                                        <p class="verified-text-title">Cuenta Activa y Verificada</p>
                                        <p class="verified-text-sub">
                                            Miembro en el sistema desde el
                                            <strong><%= fechaCreacion %></strong>.
                                        </p>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>

                    <%-- Privilegios --%>
                    <div class="profile-card" style="margin-top: 1.5rem;">
                        <div class="card-header">
                            <div class="card-header-title">
                                <i data-lucide="zap" style="color: var(--orange-dark);"></i>
                                <span style="color: var(--gray-800);">Privilegios de tu Rol</span>
                            </div>
                        </div>

                        <div class="card-body">
                            <p class="privilege-intro">
                                Como <strong><%= roleDisplay %></strong>, tienes los siguientes accesos habilitados:
                            </p>

                            <ul class="privilege-list">
                                <% if ("SuperAdmin".equals(roleName)) { %>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Control total y auditoría del sistema (bitácora completa)
                                </li>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Gestión de permisos y roles del sistema
                                </li>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Administración avanzada de usuarios
                                </li>
                                <% } else if ("Administrador".equals(roleName)) { %>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Gestión completa de usuarios y materiales
                                </li>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Exportar reportes del inventario
                                </li>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Modificación y eliminación de items
                                </li>
                                <% } else if ("Manager".equals(roleName)) { %>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Aprobación o rechazo de solicitudes (transacciones)
                                </li>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Revisión de pedidos en espera
                                </li>
                                <% } else if ("Member".equals(roleName)) { %>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Entregar materiales (despacho de inventario)
                                </li>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Actualización de stock tras las entregas
                                </li>
                                <% } else { %>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Visualizar el catálogo de productos
                                </li>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Crear nuevos pedidos de materiales
                                </li>
                                <li class="privilege-item">
                                    <span class="privilege-check"><i data-lucide="check"></i></span>
                                    Revisar historial de pedidos propios
                                </li>
                                <% } %>
                            </ul>
                        </div>
                    </div>

                </div>

            </div>

            <% } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>

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
     *
     * Usa createElement (no innerHTML/template literals) para evitar
     * conflicto con la sintaxis EL de JSP
     */
    function mostrarAlertaAvatar(titulo, mensaje, tipo) {
        // Eliminar alerta previa si existe
        const previa = document.getElementById('avatar-alert-dynamic');
        if (previa) previa.remove();

        const esError = (tipo === 'error');

        // Wrapper
        const wrapper = document.createElement('div');
        wrapper.id = 'avatar-alert-dynamic';
        wrapper.style.display       = 'flex';
        wrapper.style.alignItems    = 'flex-start';
        wrapper.style.gap           = '0.7rem';
        wrapper.style.padding       = '1rem 1.2rem';
        wrapper.style.marginBottom  = '1.25rem';
        wrapper.style.borderRadius  = '8px';
        wrapper.style.fontSize      = '0.92rem';
        wrapper.style.fontWeight    = '600';
        wrapper.style.fontFamily    = "'Montserrat', sans-serif";
        wrapper.style.animation     = 'slideDown 0.3s ease';
        wrapper.style.boxShadow     = '0 4px 12px rgba(0,0,0,0.05)';

        if (esError) {
            wrapper.style.background = '#FEE2E2';
            wrapper.style.color      = '#B91C1C';
            wrapper.style.border     = '1px solid #FECACA';
        } else {
            wrapper.style.background = '#DCFCE7';
            wrapper.style.color      = '#15803D';
            wrapper.style.border     = '1px solid #BBF7D0';
        }

        // Ícono Lucide (usamos document.createElement para crear el <i>)
        const iconWrap = document.createElement('div');
        iconWrap.style.flexShrink = '0';
        iconWrap.style.marginTop  = '2px';

        const iconI = document.createElement('i');
        iconI.setAttribute('data-lucide', esError ? 'alert-triangle' : 'check-circle');
        iconI.style.width  = '22px';
        iconI.style.height = '22px';
        iconWrap.appendChild(iconI);

        // Contenido del texto
        const contentDiv = document.createElement('div');
        contentDiv.style.flex = '1';

        const titleDiv = document.createElement('div');
        titleDiv.style.fontWeight    = '800';
        titleDiv.style.marginBottom  = '0.25rem';
        titleDiv.style.fontSize      = '0.95rem';
        titleDiv.textContent         = titulo;

        const msgDiv = document.createElement('div');
        msgDiv.style.fontWeight  = '500';
        msgDiv.style.lineHeight  = '1.55';
        msgDiv.textContent       = mensaje;

        contentDiv.appendChild(titleDiv);
        contentDiv.appendChild(msgDiv);

        // Botón cerrar (con ícono Lucide x)
        const closeBtn = document.createElement('button');
        closeBtn.type            = 'button';
        closeBtn.style.background = 'none';
        closeBtn.style.border    = 'none';
        closeBtn.style.cursor    = 'pointer';
        closeBtn.style.color     = wrapper.style.color;
        closeBtn.style.padding   = '0';
        closeBtn.style.opacity   = '0.6';
        closeBtn.style.display   = 'flex';
        closeBtn.style.alignItems= 'center';

        const closeI = document.createElement('i');
        closeI.setAttribute('data-lucide', 'x');
        closeI.style.width  = '18px';
        closeI.style.height = '18px';
        closeBtn.appendChild(closeI);

        closeBtn.onclick = function () { wrapper.remove(); };

        wrapper.appendChild(iconWrap);
        wrapper.appendChild(contentDiv);
        wrapper.appendChild(closeBtn);

        // Insertar arriba del page-header
        const pageHeader = document.querySelector('.page-header');
        if (pageHeader && pageHeader.parentNode) {
            pageHeader.parentNode.insertBefore(wrapper, pageHeader.nextSibling);

            // Re-renderizar íconos Lucide (importante: después de insertar)
            if (typeof lucide !== 'undefined') lucide.createIcons();

            // Scroll arriba para que se vea
            window.scrollTo({ top: 0, behavior: 'smooth' });

            // Auto-ocultar después de 6 segundos
            setTimeout(function () {
                const el = document.getElementById('avatar-alert-dynamic');
                if (el) {
                    el.style.transition = 'opacity 0.4s, transform 0.4s';
                    el.style.opacity    = '0';
                    el.style.transform  = 'translateY(-10px)';
                    setTimeout(function () { el.remove(); }, 400);
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