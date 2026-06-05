<%--
    ════════════════════════════════════════════════════════════════════
     profile.jsp — Vista del perfil del usuario
    ════════════════════════════════════════════════════════════════════
     PROPÓSITO: Mostrar información y permitir cambio de clave/avatar.
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();
    User usuario = (User) request.getAttribute("usuario");
    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");

    // Lógica para iniciales (Fallback si no hay avatar)
    String iniciales = "U";
    if (usuario != null && usuario.getName() != null) {
        String[] partes = usuario.getName().split(" ");
        if (partes.length >= 2) {
            iniciales = (partes[0].charAt(0) + "" + partes[1].charAt(0)).toUpperCase();
        } else if (partes.length == 1 && partes[0].length() >= 2) {
            iniciales = partes[0].substring(0, 2).toUpperCase();
        }
    }

    // Color de iniciales
    String avatarColor = "bg-purple-50 text-purple-700 border-purple-100";
    if (usuario != null && usuario.getName() != null) {
        int idx = usuario.getName().charAt(0) % 4;
        switch (idx) {
            case 0: avatarColor = "bg-blue-50 text-blue-700 border-blue-100";       break;
            case 1: avatarColor = "bg-pink-50 text-pink-600 border-pink-100";       break;
            case 2: avatarColor = "bg-green-50 text-green-700 border-green-100";    break;
            case 3: avatarColor = "bg-amber-50 text-amber-600 border-yellow-100";   break;
        }
    }

    // Lógica del Badge
    String roleName = usuario != null ? usuario.getRoleName() : "";
    String roleBadgeClass = "status-badge status-pending"; // Default
    if ("SuperAdmin".equals(roleName)) {
        roleBadgeClass = "status-badge status-delivered"; // Azul
    } else if ("Administrador".equals(roleName)) {
        roleBadgeClass = "status-badge bg-purple-50 text-purple-700"; // Morado
    } else if ("Manager".equals(roleName)) {
        roleBadgeClass = "status-badge status-pending"; // Naranja
    } else if ("Member".equals(roleName)) {
        roleBadgeClass = "status-badge status-approved"; // Verde
    } else {
        roleBadgeClass = "status-badge bg-gray-100 text-gray-600"; // Gris
    }

    // Obtener la URL del avatar
    String avatarUrl = usuario != null ? usuario.getAvatarUrl() : null;

    // Lógica para la fecha
    String fechaCreacion = "Reciente";
    if (usuario != null && usuario.getCreatedAt() != null) {
        try {
            String dbDate = usuario.getCreatedAt();
            if(dbDate.contains(".")) {
                dbDate = dbDate.substring(0, dbDate.indexOf("."));
            }
            java.text.SimpleDateFormat formatoBD = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            java.util.Date fechaParseada = formatoBD.parse(dbDate);

            java.text.SimpleDateFormat formatoBonito = new java.text.SimpleDateFormat("dd 'de' MMMM, yyyy");
            fechaCreacion = formatoBonito.format(fechaParseada);
        } catch (Exception e) {
            fechaCreacion = usuario.getCreatedAt().split(" ")[0];
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Mi Perfil | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=5" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        .avatar-box {
            width: 140px;
            height: 140px;
            min-width: 140px;
            min-height: 140px;
            border-radius: 50%;
            overflow: hidden;
            border: 4px solid white;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            position: relative;
            margin: 0 auto 1.25rem auto;
            flex-shrink: 0;
            background-color: #f9fafb;
        }
        .avatar-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            object-position: center;
        }
    </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <jsp:include page="includes/topbar.jsp"/>

        <%-- Aquí es donde ajustamos el ancho máximo (max-w-5xl) y forzamos el centrado (mx-auto) --%>
        <main class="w-full max-w-5xl mx-auto px-4 md:px-8 py-10">

            <div class="page-header mb-8">
                <div>
                    <h1 class="page-title">Mi Perfil</h1>
                    <p class="page-subtitle">Información personal y configuración de tu cuenta</p>
                </div>
            </div>

            <% if (error != null) { %>
            <div class="bg-red-50 border-red-200 text-red-700 text-sm rounded-lg p-4 mb-6 flex items-center gap-2 border">
                <i data-lucide="alert-circle" class="w-5 h-5 flex-shrink-0"></i>
                <%= error %>
            </div>
            <% } %>
            <% if (success != null) { %>
            <div class="bg-green-50 border-green-200 text-green-700 text-sm rounded-lg p-4 mb-6 flex items-center gap-2 border">
                <i data-lucide="check-circle" class="w-5 h-5 flex-shrink-0"></i>
                <%= success %>
            </div>
            <% } %>

            <% if (usuario == null) { %>
            <div class="panel py-16 text-center bg-white rounded-2xl shadow-sm border border-gray-100">
                <i data-lucide="user-x" class="w-16 h-16 mx-auto text-gray-300 mb-4"></i>
                <p class="text-gray-500 font-medium text-lg">No se pudo cargar tu perfil.</p>
            </div>
            <% } else { %>

            <%-- Ajustamos la cuadrícula a 3 columnas para que tenga mejores proporciones --%>
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

                <%-- ─── COLUMNA IZQUIERDA (Avatar y Seguridad - Ocupa 1/3) ─── --%>
                <div class="lg:col-span-1 space-y-8">

                    <%-- Avatar --%>
                    <div class="panel p-8 text-center relative overflow-hidden shadow-sm border border-gray-100 rounded-2xl bg-white">
                        <div class="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-purple-600 to-pink-500"></div>

                        <div class="avatar-box cursor-pointer group" title="Haz clic para cambiar tu foto" onclick="document.getElementById('avatar-upload').click();">
                            <% if (avatarUrl != null && !avatarUrl.trim().isEmpty()) { %>
                            <img src="<%= ctx %><%= avatarUrl %>" alt="Mi Avatar" />
                            <% } else { %>
                            <div class="w-full h-full flex items-center justify-center text-5xl font-bold <%= avatarColor %>">
                                <span><%= iniciales %></span>
                            </div>
                            <% } %>

                            <div class="absolute inset-0 bg-black bg-opacity-60 flex flex-col items-center justify-center opacity-0 group-hover:opacity-100 transition-all duration-300 backdrop-blur-sm">
                                <i data-lucide="camera" class="w-8 h-8 text-white mb-2"></i>
                                <span class="text-white text-xs font-semibold tracking-wider uppercase">Actualizar</span>
                            </div>
                        </div>

                        <form id="avatar-form" action="<%= ctx %>/ProfileServlet" method="POST" enctype="multipart/form-data" class="hidden">
                            <input type="hidden" name="action" value="uploadAvatar" />
                            <input type="file" id="avatar-upload" name="avatarFile" accept="image/png, image/jpeg, image/webp" onchange="document.getElementById('avatar-form').submit();" />
                        </form>

                        <h2 class="text-xl font-bold text-purple-700 tracking-tight leading-tight"><%= usuario.getName() %></h2>
                        <p class="text-sm text-gray-500 font-medium mt-1 mb-4 break-words"><%= usuario.getEmail() %></p>
                        <div class="inline-block mb-1">
                            <span class="<%= roleBadgeClass %> px-3 py-1 text-sm"><%= roleName %></span>
                        </div>
                    </div>

                    <%-- Seguridad --%>
                    <div class="panel rounded-2xl shadow-sm border border-gray-100 bg-white">
                        <div class="border-b border-gray-50 p-5">
                            <h3 class="font-bold text-pink-600 flex items-center gap-2 text-base">
                                <i data-lucide="shield-check" class="w-5 h-5 text-pink-500"></i> Seguridad
                            </h3>
                        </div>
                        <div class="p-5">
                            <form action="<%= ctx %>/ProfileServlet" method="POST" class="space-y-4">
                                <input type="hidden" name="action" value="cambiarPassword"/>
                                <div>
                                    <label class="form-label text-xs mb-1 block text-gray-600">Clave actual</label>
                                    <input type="password" name="currentPassword" required class="input-page text-sm py-2 w-full"/>
                                </div>
                                <div>
                                    <label class="form-label text-xs mb-1 block text-gray-600">Nueva clave</label>
                                    <input type="password" name="newPassword" minlength="6" required class="input-page text-sm py-2 w-full"/>
                                </div>
                                <div>
                                    <label class="form-label text-xs mb-1 block text-gray-600">Confirmar clave</label>
                                    <input type="password" name="confirmPassword" minlength="6" required class="input-page text-sm py-2 w-full"/>
                                </div>
                                <button type="submit" class="btn-page-primary w-full text-sm py-2 mt-2 transition-transform hover:scale-[1.02]">
                                    <i data-lucide="key" class="w-4 h-4"></i> Guardar Cambios
                                </button>
                            </form>
                        </div>
                    </div>

                </div>

                <%-- ─── COLUMNA DERECHA (Información - Ocupa 2/3) ─── --%>
                <div class="lg:col-span-2 space-y-8">

                    <%-- Información Personal --%>
                    <div class="panel rounded-2xl shadow-sm border border-gray-100 bg-white">
                        <div class="border-b border-gray-50 p-6 flex justify-between items-center">
                            <h3 class="font-bold text-purple-700 flex items-center gap-2 text-lg">
                                <i data-lucide="contact-2" class="w-5 h-5 text-purple-600"></i> Información Personal
                            </h3>
                            <span class="text-xs bg-pink-50 text-pink-600 border border-pink-100 px-3 py-1.5 rounded-md font-bold uppercase tracking-wider">ID #<%= usuario.getId() %></span>
                        </div>

                        <div class="p-6 md:p-8 grid grid-cols-1 sm:grid-cols-2 gap-x-8 gap-y-6">
                            <div>
                                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">Nombre Completo</p>
                                <p class="text-base font-medium text-gray-800"><%= usuario.getName() %></p>
                            </div>

                            <div>
                                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">Documento (DNI)</p>
                                <p class="text-base font-medium text-gray-800 font-mono"><%= usuario.getDni() %></p>
                            </div>

                            <div>
                                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">Correo Electrónico</p>
                                <p class="text-base font-medium text-gray-800"><%= usuario.getEmail() %></p>
                            </div>

                            <div>
                                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-1">Rol Principal</p>
                                <p class="text-base font-medium text-gray-800"><%= usuario.getRoleName() %></p>
                            </div>

                            <%-- Rectángulo Cuenta Activa --%>
                            <div class="sm:col-span-2 p-4 bg-gray-50 rounded-xl border border-gray-200 flex items-start gap-4 mt-2">
                                <div class="bg-emerald-100 p-2 rounded-lg text-emerald-600 shrink-0">
                                    <i data-lucide="check-circle-2" class="w-5 h-5"></i>
                                </div>
                                <div class="flex flex-col justify-center">
                                    <p class="text-sm font-bold text-purple-700 mb-0.5">Cuenta Activa y Verificada</p>
                                    <p class="text-sm text-gray-500">Miembro en el sistema desde el <span class="font-semibold text-gray-700"><%= fechaCreacion %></span>.</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Privilegios --%>
                    <div class="panel rounded-2xl shadow-sm border border-gray-100 bg-white">
                        <div class="border-b border-gray-50 p-6">
                            <h3 class="font-bold text-gray-800 flex items-center gap-2 text-lg">
                                <i data-lucide="zap" class="w-5 h-5 text-amber-600"></i> Privilegios de tu Rol
                            </h3>
                        </div>
                        <div class="p-6 md:p-8">
                            <p class="text-sm md:text-base text-gray-600 mb-5 leading-relaxed">Como <strong class="text-purple-700 bg-purple-50 px-2 py-0.5 rounded"><%= roleName %></strong>, tienes los siguientes accesos habilitados:</p>

                            <ul class="space-y-3">
                                <% if ("SuperAdmin".equals(roleName)) { %>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Control total y auditoría del sistema (Bitácora)</li>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Gestión de permisos y roles del sistema</li>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Administración avanzada de usuarios</li>
                                <% } else if ("Administrador".equals(roleName)) { %>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Gestión completa de usuarios y materiales</li>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Exportar reportes del inventario</li>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Modificación y eliminación de items</li>
                                <% } else if ("Manager".equals(roleName)) { %>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Aprobación o rechazo de solicitudes (Transacciones)</li>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Revisión de pedidos en espera</li>
                                <% } else if ("Member".equals(roleName)) { %>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Entregar materiales (Despacho de inventario)</li>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Actualización de stock tras las entregas</li>
                                <% } else { %>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Visualizar el catálogo de productos</li>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Crear nuevos pedidos de materiales</li>
                                <li class="flex items-start gap-3 text-sm md:text-base text-gray-700"><i data-lucide="check" class="w-5 h-5 text-pink-500 flex-shrink-0 mt-0.5"></i> Revisar historial de pedidos propios</li>
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
    lucide.createIcons();
</script>
</body>
</html>