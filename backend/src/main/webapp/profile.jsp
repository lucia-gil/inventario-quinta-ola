<%--
    ════════════════════════════════════════════════════════════════════
     profile.jsp — Vista del perfil del usuario
    ════════════════════════════════════════════════════════════════════

     PROPÓSITO:
     Mostrar la información personal del usuario logueado:
     avatar con iniciales, nombre, email, DNI, rol e ID.

     ¿DE DÓNDE SACAMOS LOS DATOS?
     - "usuario" → lo inyectó ProfileServlet con setAttribute (ver clase 7.2 slide 49)
     - "error"   → mensaje opcional si algo falló al cargar
     - session   → datos generales del usuario logueado

     CONVERTIDO DESDE:
     profile.html (versión original con fetch + JS). Se eliminó toda la lógica
     de JavaScript porque el JP pidió que la lógica viva en el servidor uwu

     PATRÓN DEL CURSO:
     - Scriptlets <% %> para código Java (ver en la clasecita 7.2 slide 32)
     - Expresiones <%= %> para imprimir valores
     - jsp:include para fragmentos reutilizables (ver la clasesita 7.2 slide 62)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.User" %>
<%
    /* ════════════════════════════════════════════════════════════════
     *  BLOQUE DE PREPARACIÓN DE DATOS
     *  Se ejecuta ANTES de pintar el HTML.
     *  ════════════════════════════════════════════════════════════════ */

    // contextPath = el "/inventario" del proyecto
    // Lo guardo en una variable para no repetirlo en cada URL
    String ctx = request.getContextPath();

    // Castear el atributo "usuario" a User
    // El servlet lo metió ahí con setAttribute (Clase 7.2 slide 53)
    User usuario = (User) request.getAttribute("usuario");

    // Mensajes de feedback (pueden ser null)
    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");

    // Calcular iniciales del nombre para el avatar
    // Ejemplito: "Pedro Administrador" → "PA"
    String iniciales = "U";
    if (usuario != null && usuario.getName() != null) {
        String[] partes = usuario.getName().split(" ");
        if (partes.length >= 2) {
            iniciales = (partes[0].charAt(0) + "" + partes[1].charAt(0)).toUpperCase();
        } else if (partes.length == 1 && partes[0].length() >= 2) {
            iniciales = partes[0].substring(0, 2).toUpperCase();
        }
    }

    // Calcular color de avatar según primera letra del nombre
    // Replica la lógica de avatarColor() del JS original
    String avatarColor = "bg-blue-50 text-blue-600 border-blue-100";
    if (usuario != null && usuario.getName() != null) {
        int idx = usuario.getName().charAt(0) % 4;
        switch (idx) {
            case 0: avatarColor = "bg-blue-50 text-blue-600 border-blue-100";       break;
            case 1: avatarColor = "bg-pink-50 text-pink-600 border-pink-100";       break;
            case 2: avatarColor = "bg-emerald-50 text-emerald-600 border-emerald-100"; break;
            case 3: avatarColor = "bg-yellow-50 text-yellow-600 border-yellow-100"; break;
        }
    }

    // Calcular badge del rol
    // Replica QO.roleBadge() del JS original
    String roleName = usuario != null ? usuario.getRoleName() : "";
    String roleBadgeClass;
    if ("SuperAdmin".equals(roleName)) {
        roleBadgeClass = "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-purple-50 text-purple-600 border border-purple-100";
    } else if ("Administrador".equals(roleName)) {
        roleBadgeClass = "role-admin";
    } else if ("Manager".equals(roleName)) {
        roleBadgeClass = "role-manager";
    } else if ("Member".equals(roleName)) {
        roleBadgeClass = "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-600 border border-emerald-100";
    } else {
        roleBadgeClass = "role-viewer";
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Mi Perfil | Quinta Ola</title>
    <%-- contextPath para que el CSS cargue bien desde Tomcat --%>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>

<body class="page-body">

    <%-- ─── NAVBAR REUTILIZABLE ─── --%>
    <%-- Incluye el navbar (Clase 7.2 slide 62) --%>
    <%-- La lógica de qué menú mostrar según rol vive en navbar.jsp --%>
    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main-narrow">

        <%-- ─── CABECERA ─── --%>
        <div class="page-header">
            <div>
                <h1 class="page-title">Mi Perfil</h1>
                <p class="page-subtitle">
                    Información personal y configuración de tu cuenta
                </p>
            </div>
        </div>

        <%-- ─── MENSAJES DE FEEDBACK (opcionales) ─── --%>
        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 mb-4">
                ❌ <%= error %>
            </div>
        <% } %>
        <% if (success != null) { %>
            <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3 mb-4">
                ✅ <%= success %>
            </div>
        <% } %>

        <%-- ─── Si no hay usuario, no renderizar más ─── --%>
        <% if (usuario == null) { %>
            <div class="panel-form text-center py-12">
                <p class="text-gray-500">No se pudo cargar tu perfil.</p>
            </div>
        <% } else { %>

        <%-- ──────────────────────────────────────────────────────────
              CARD PRINCIPAL DEL PERFIL (Avatar + Nombre + Rol)
             ────────────────────────────────────────────────────────── --%>
        <div class="panel p-8 text-center relative overflow-hidden shadow-sm border border-gray-100 rounded-2xl bg-white">

            <%-- Línea de color decorativa arriba --%>
            <div class="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-accent to-pink-500"></div>

            <%-- Avatar circular con iniciales (color dinámico calculado en el bloque Java de arriba) --%>
            <div class="relative w-28 h-28 mx-auto mb-4">
                <div class="w-full h-full rounded-full flex items-center justify-center text-3xl font-bold shadow-inner border-2 border-white ring-4 ring-gray-50 overflow-hidden transition-all duration-300 <%= avatarColor %>">
                    <%-- <%= %> imprime el valor de la variable Java --%>
                    <span><%= iniciales %></span>
                </div>
            </div>

            <%-- Nombre del usuario --%>
            <h2 class="text-2xl font-bold text-gray-800 tracking-tight">
                <%= usuario.getName() %>
            </h2>

            <%-- Email del usuario --%>
            <p class="text-sm text-gray-500 font-medium mt-0.5">
                <%= usuario.getEmail() %>
            </p>

            <%-- Badge del rol (clase CSS calculada en el bloque Java de arriba) --%>
            <div class="mt-3 inline-block">
                <span class="<%= roleBadgeClass %>"><%= roleName %></span>
            </div>
        </div>

        <%-- ──────────────────────────────────────────────────────────
              PANEL: INFORMACIÓN PERSONAL
             ────────────────────────────────────────────────────────── --%>
        <div class="panel mt-6 rounded-2xl shadow-sm border border-gray-100 bg-white">

            <div class="border-b border-gray-50 p-5">
                <h3 class="font-bold text-gray-800 flex items-center gap-2 text-base">
                    🪪 Información Personal
                </h3>
            </div>

            <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6">

                <div>
                    <p class="form-label-tiny text-gray-400 font-semibold tracking-wider uppercase text-[11px]">
                        Nombre Completo
                    </p>
                    <p class="text-sm font-semibold text-gray-700 mt-1">
                        <%= usuario.getName() %>
                    </p>
                </div>

                <div>
                    <p class="form-label-tiny text-gray-400 font-semibold tracking-wider uppercase text-[11px]">
                        DNI
                    </p>
                    <p class="text-sm font-semibold text-gray-700 font-mono mt-1">
                        <%-- Operador ternario: si DNI es null, mostrar guión --%>
                        <%= usuario.getDni() != null ? usuario.getDni() : "—" %>
                    </p>
                </div>

                <div>
                    <p class="form-label-tiny text-gray-400 font-semibold tracking-wider uppercase text-[11px]">
                        Correo electrónico
                    </p>
                    <p class="text-sm font-semibold text-gray-700 mt-1">
                        <%= usuario.getEmail() %>
                    </p>
                </div>

                <div>
                    <p class="form-label-tiny text-gray-400 font-semibold tracking-wider uppercase text-[11px]">
                        Rol en el sistema
                    </p>
                    <p class="text-sm font-semibold text-gray-700 mt-1">
                        <%= roleName %>
                    </p>
                </div>

                <div>
                    <p class="form-label-tiny text-gray-400 font-semibold tracking-wider uppercase text-[11px]">
                        ID de Usuario
                    </p>
                    <p class="text-xs font-mono text-gray-400 mt-1">
                        #<%= usuario.getId() %>
                    </p>
                </div>

                <div>
                    <p class="form-label-tiny text-gray-400 font-semibold tracking-wider uppercase text-[11px]">
                        Estado de cuenta
                    </p>
                    <p class="text-sm font-semibold text-emerald-600 flex items-center gap-1.5 mt-1">
                        ✅ Activo
                    </p>
                </div>

            </div>
        </div>

        <%-- ──────────────────────────────────────────────────────────
              PANEL: SEGURIDAD (Cambio de Contraseña)
             ────────────────────────────────────────────────────────── --%>
        <div class="panel mt-6 rounded-2xl shadow-sm border border-gray-100 bg-white">

            <div class="border-b border-gray-50 p-5">
                <h3 class="font-bold text-gray-800 flex items-center gap-2 text-base">
                    🔒 Seguridad de la Cuenta
                </h3>
            </div>

            <div class="p-6">

                <%-- Formulario que envía POST al mismo ProfileServlet --%>
                <%-- En el doPost del servlet se procesa con action=cambiarPassword --%>
                <form action="<%= ctx %>/ProfileServlet" method="POST" class="space-y-4 max-w-md">

                    <%-- Campo oculto que indica al servlet qué acción ejecutar --%>
                    <input type="hidden" name="action" value="cambiarPassword"/>

                    <div>
                        <label class="block text-xs font-semibold text-gray-500 mb-1">
                            Contraseña actual
                        </label>
                        <input type="password" name="currentPassword" required
                               class="input-page w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:border-accent focus:ring-1 focus:ring-accent outline-none"/>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-gray-500 mb-1">
                            Nueva contraseña
                        </label>
                        <input type="password" name="newPassword" minlength="6" required
                               class="input-page w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:border-accent focus:ring-1 focus:ring-accent outline-none"/>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-gray-500 mb-1">
                            Confirmar nueva contraseña
                        </label>
                        <input type="password" name="confirmPassword" minlength="6" required
                               class="input-page w-full border border-gray-200 rounded-xl px-3 py-2 text-sm focus:border-accent focus:ring-1 focus:ring-accent outline-none"/>
                    </div>

                    <div class="flex gap-3 pt-2">
                        <button type="submit"
                                class="btn-page-primary bg-accent hover:bg-accent-dark text-white px-4 py-2 rounded-xl text-sm font-medium shadow-sm">
                            Guardar Cambios
                        </button>
                    </div>
                </form>

            </div>
        </div>

        <% } %>

    </main>

    <%-- ─── FOOTER REUTILIZABLE QUE YA Cree uwu─── --%>
    <jsp:include page="includes/footer.jsp"/>

</body>
</html>