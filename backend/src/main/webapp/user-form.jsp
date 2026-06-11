<%--
    ============================================================
     user-form.jsp
    ============================================================
     Formulario dinámico:
     - SuperAdmin (5): Crea usuarios con cualquier rol.
     - Admin (4): Crea usuarios solo con roles 1, 2 y 3.
    ============================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Role" %>
<%
  String ctx = request.getContextPath();
  List<Role> roles = (List<Role>) request.getAttribute("roles");
  String errParam = request.getParameter("error");

  // 🛡️ REGLA DE NEGOCIO: Saber qué nivel tiene la persona creando la cuenta
  Integer currentRoleId = (Integer) session.getAttribute("roleId");
  if (currentRoleId == null) currentRoleId = 0;
%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Crear Usuario | Quinta Ola</title>
  <link href="<%= ctx %>/css/style.css?v=3" rel="stylesheet" />
</head>
<body class="page-body">

<div class="layout-wrapper">

  <jsp:include page="includes/navbar.jsp"/>

  <div class="main-content">
    <jsp:include page="includes/topbar.jsp"/>

    <main class="page-main-narrow" style="padding: 2rem;">

      <div class="page-header">
        <div>
          <h1 class="page-title">➕ Crear Usuario</h1>
          <p class="page-subtitle">
            Registra un nuevo usuario en el sistema y asígnale un rol.
          </p>
        </div>
        <%-- Cambiado para que vuelva a la lista de usuarios --%>
        <a href="<%= ctx %>/RoleServlet" class="btn-ghost">
          ← Volver
        </a>
      </div>

      <% if (errParam != null) { %>
      <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 mb-4">
        ❌ <%= errParam %>
      </div>
      <% } %>

      <div class="panel-form">
        <form action="<%= ctx %>/UserServlet" method="POST" class="space-y-5">

          <input type="hidden" name="action" value="crear"/>

          <%-- Nombre --%>
          <div>
            <label class="form-label text-left block">Nombre Completo *</label>
            <input type="text" name="name" class="input-page"
                   placeholder="Ej: Juan Pérez García"
                   maxlength="150" required/>
          </div>

          <%-- DNI y Email en fila --%>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
              <label class="form-label text-left block">DNI *</label>
              <input type="text" name="dni" class="input-page"
                     placeholder="8 dígitos"
                     pattern="[0-9]{8}" maxlength="8" required/>
              <p class="text-[11px] text-gray-400 mt-1 text-left">
                Exactamente 8 dígitos numéricos
              </p>
            </div>
            <div>
              <label class="form-label text-left block">Email *</label>
              <input type="email" name="email" class="input-page"
                     placeholder="usuario@quintaola.com" required/>
            </div>
          </div>

          <%-- Password --%>
          <div>
            <label class="form-label text-left block">Contraseña *</label>
            <input type="password" name="password" class="input-page"
                   placeholder="Mínimo 6 caracteres"
                   minlength="6" required/>
            <p class="text-[11px] text-gray-400 mt-1 text-left">
              El usuario podrá cambiarla después en su perfil
            </p>
          </div>

          <%-- ROL del usuario --%>
          <div>
            <label class="form-label text-left block">Asignar Rol *</label>
            <select name="roleId" class="select-page" required>
              <option value="" disabled selected>Selecciona un rol...</option>
              <% if (roles != null) {
                for (Role rol : roles) {
                  // MAGIA AQUÍ:
                  // Si es SuperAdmin (5), ve todos los roles.
                  // Si es Admin (4), solo ve los roles del 1 al 3.
                  if (currentRoleId == 5 || (currentRoleId == 4 && rol.getId() < 4)) {
              %>
              <option value="<%= rol.getId() %>">
                <%= rol.getName() %>
                <%= rol.getDescription() != null ? " — " + rol.getDescription() : "" %>
              </option>
              <%      } // fin del if validación
              } // fin del for
              } %>
            </select>
            <p class="text-[11px] text-gray-400 mt-1 text-left">
              Define qué puede hacer este usuario en el sistema
            </p>
          </div>

          <hr class="border-gray-100"/>

          <div class="flex justify-end gap-3 pt-2">
            <%-- Cambiado para que cancele a la lista de usuarios --%>
            <a href="<%= ctx %>/RoleServlet" class="btn-ghost">
              Cancelar
            </a>
            <button type="submit" class="btn-page-primary">
              ➕ Crear Usuario
            </button>
          </div>

        </form>
      </div>

    </main>

    <jsp:include page="includes/footer.jsp"/>

  </div>
</div>

</body>
</html>