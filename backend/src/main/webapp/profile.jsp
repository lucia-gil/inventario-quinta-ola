<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.User" %>
<%
    String ctx = request.getContextPath();
    User usuario = (User) request.getAttribute("usuario");
    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");

    // Calcular iniciales (las primeras 2 letras del nombre)
    String iniciales = "U";
    if (usuario != null && usuario.getName() != null) {
        String[] partes = usuario.getName().split(" ");
        if (partes.length >= 2) {
            iniciales = (partes[0].charAt(0) + "" + partes[1].charAt(0)).toUpperCase();
        } else if (partes.length == 1 && partes[0].length() >= 2) {
            iniciales = partes[0].substring(0, 2).toUpperCase();
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Mi Perfil | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main-narrow">

        <%-- Mensajes de feedback --%>
        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3">
                ❌ <%= error %>
            </div>
        <% } %>
        <% if (success != null) { %>
            <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3">
                ✅ <%= success %>
            </div>
        <% } %>

        <% if (usuario == null) { %>
            <div class="panel-form text-center py-12">
                <p class="text-gray-500">No se pudo cargar tu perfil.</p>
            </div>
        <% } else { %>

        <div class="flex flex-col md:flex-row gap-8">

            <%-- ─── COLUMNA IZQUIERDA: AVATAR + ESTADO ─── --%>
            <div class="md:w-1/3 space-y-6">

                <div class="panel-form text-center">
                    <div class="profile-avatar mb-4">
                        <span><%= iniciales %></span>
                    </div>

                    <h2 class="profile-name"><%= usuario.getName() %></h2>
                    <p class="text-gray-500 text-sm mb-6"><%= usuario.getEmail() %></p>

                    <div class="pt-6 border-t border-gray-100">
                        <a href="<%= ctx %>/AuthServlet?action=logout" class="btn-logout">
                            🚪 Cerrar Sesión
                        </a>
                    </div>
                </div>

                <div class="panel-form">
                    <h3 class="form-label-tiny mb-4">Estado del Perfil</h3>
                    <div class="flex items-center gap-3">
                        <div class="h-2.5 w-2.5 rounded-full bg-green-500"></div>
                        <span class="text-sm font-medium text-gray-700">Cuenta Activa</span>
                    </div>
                </div>

            </div>

            <%-- ─── COLUMNA DERECHA: INFO + SEGURIDAD ─── --%>
            <div class="md:w-2/3 space-y-6">

                <%-- Información personal --%>
                <div class="panel">
                    <div class="panel-header">
                        <h3 class="font-bold text-gray-900">
                            🔧 Información Personal
                        </h3>
                        <span class="role-manager"><%= usuario.getRoleName() %></span>
                    </div>
                    <div class="p-8">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">
                            <div class="space-y-1">
                                <label class="form-label-tiny">Nombre Completo</label>
                                <p class="text-sm font-semibold text-gray-800 border-b border-gray-50 pb-2">
                                    <%= usuario.getName() %>
                                </p>
                            </div>
                            <div class="space-y-1">
                                <label class="form-label-tiny">DNI / Identificación</label>
                                <p class="text-sm font-semibold text-gray-800 border-b border-gray-50 pb-2 font-mono">
                                    <%= usuario.getDni() != null ? usuario.getDni() : "—" %>
                                </p>
                            </div>
                            <div class="md:col-span-2 space-y-1">
                                <label class="form-label-tiny">Correo Electrónico</label>
                                <p class="text-sm font-semibold text-gray-800 border-b border-gray-50 pb-2">
                                    <%= usuario.getEmail() %>
                                </p>
                            </div>
                            <div class="space-y-1">
                                <label class="form-label-tiny">Rol del Sistema</label>
                                <p class="text-sm font-semibold text-gray-800 border-b border-gray-50 pb-2">
                                    <%= usuario.getRoleName() %>
                                </p>
                            </div>
                            <div class="space-y-1">
                                <label class="form-label-tiny">Fecha de Registro</label>
                                <p class="text-sm font-semibold text-gray-800 border-b border-gray-50 pb-2">
                                    <%= usuario.getCreatedAt() != null ? usuario.getCreatedAt() : "—" %>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Cambio de contraseña --%>
                <div class="panel">
                    <div class="panel-header">
                        <h3 class="font-bold text-gray-900">
                            🔒 Seguridad
                        </h3>
                    </div>
                    <form action="<%= ctx %>/ProfileServlet" method="POST" class="p-8 space-y-5">
                        <input type="hidden" name="action" value="cambiarPassword"/>

                        <div>
                            <label class="form-label-tiny">Contraseña actual</label>
                            <input type="password" name="currentPassword"
                                   placeholder="••••••••" class="input-page mt-1"/>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="form-label-tiny">Nueva contraseña</label>
                                <input type="password" name="newPassword" minlength="8"
                                       placeholder="Mín. 8 caracteres" class="input-page mt-1"/>
                            </div>
                            <div>
                                <label class="form-label-tiny">Confirmar nueva contraseña</label>
                                <input type="password" name="confirmPassword" minlength="8"
                                       placeholder="Repite la contraseña" class="input-page mt-1"/>
                            </div>
                        </div>
                        <button type="submit" class="btn-submit mt-2">
                            Actualizar Contraseña
                        </button>
                    </form>
                </div>

            </div>
        </div>

        <% } %>

    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>