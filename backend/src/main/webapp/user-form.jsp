<%--
    ════════════════════════════════════════════════════════════════════
     user-form.jsp — Crear Usuario (Admin y SuperAdmin)
    ════════════════════════════════════════════════════════════════════
     - SuperAdmin (5): puede asignar cualquier rol (1-4, no a otro SA).
     - Admin (4): solo puede asignar roles 1, 2 y 3.

     Validaciones:
     - Nombres y apellidos: solo letras, espacios, guiones y apóstrofes.
     - DNI: exactamente 8 dígitos.
     - Email: formato válido.
     - Contraseña: 8+ chars, mayúscula, minúscula, número, símbolo.
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Role" %>
<%
  String ctx = request.getContextPath();
  List<Role> roles = (List<Role>) request.getAttribute("roles");
  String errParam = request.getParameter("error");

  Integer currentRoleId = (Integer) session.getAttribute("roleId");
  if (currentRoleId == null) currentRoleId = 0;

  // El SuperAdmin no tiene "Miembros" en su sidebar, solo "Roles" —
  // por eso el menú activo debe coincidir con la sección desde la que
  // realmente se accede a este formulario.
  request.setAttribute("activeMenu", currentRoleId == 5 ? "roles" : "members");
%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Crear Usuario | Quinta Ola</title>
  <link href="<%= ctx %>/css/style.css?v=25" rel="stylesheet"/>
  <script src="https://unpkg.com/lucide@latest"></script>

  <style>
    .form-card {
      background: var(--white);
      border-radius: var(--radius-lg);
      border: 1px solid var(--gray-100);
      box-shadow: var(--shadow-md);
      max-width: 720px;
      margin: 0 auto;
      position: relative;
      overflow: hidden;
    }

    /* Franja de marca en el borde superior de la tarjeta — misma
       cresta que se usa en modales y el paginador. */
    .form-card::before {
      content: "";
      position: absolute;
      top: 0; left: 0; right: 0;
      height: 4px;
      background: linear-gradient(90deg, var(--purple) 0%, var(--pink) 50%, var(--yellow) 100%);
      z-index: 2;
    }

    .form-card-header {
      position: relative;
      padding: 1.5rem 1.75rem;
      background: linear-gradient(135deg, var(--purple) 0%, var(--pink) 100%);
      overflow: hidden;
    }

    /* Ondas decorativas sutiles en el header, igual que el hero de Inicio */
    .form-card-header::after {
      content: "";
      position: absolute;
      top: -60%; right: -8%;
      width: 220px; height: 220px;
      background: radial-gradient(circle, rgba(255,255,255,0.14) 0%, transparent 70%);
      border-radius: 50%;
      pointer-events: none;
    }

    .form-card-header h2 {
      position: relative;
      z-index: 1;
      display: flex;
      align-items: center;
      gap: 0.6rem;
      font-size: 1.1rem;
      font-weight: 800;
      color: var(--white);
      margin: 0;
    }
    .form-card-header h2 i {
      width: 20px; height: 20px; color: var(--white);
      background: rgba(255,255,255,0.18);
      padding: 6px; border-radius: 50%;
      box-sizing: content-box;
    }

    .form-card-header p {
      position: relative;
      z-index: 1;
      font-size: 0.82rem;
      color: rgba(255,255,255,0.92);
      margin: 0.45rem 0 0 2.35rem;
      font-weight: 500;
    }

    .form-card-body { padding: 1.75rem; }

    .form-grid-2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1rem;
    }
    @media (max-width: 640px) {
      .form-grid-2 { grid-template-columns: 1fr; }
    }

    .form-group {
      margin-bottom: 1.1rem;
    }

    .form-group label {
      display: block;
      font-size: 0.7rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 1.2px;
      color: var(--gray-600);
      margin-bottom: 0.4rem;
    }
    .form-group label .req { color: var(--pink); margin-left: 2px; }

    .input-wrap {
      position: relative;
      display: block;
    }
    .input-wrap > i,
    .input-wrap > svg {
      position: absolute !important;
      left: 0.9rem;
      top: 50%;
      transform: translateY(-50%);
      color: var(--purple-light);
      width: 18px !important;
      height: 18px !important;
      pointer-events: none;
      z-index: 5;
      transition: color 0.2s;
    }
    .input-wrap:focus-within > i,
    .input-wrap:focus-within > svg {
      color: var(--pink);
    }

    .form-input, .form-select {
      width: 100%;
      border: 1.5px solid var(--gray-200);
      border-radius: var(--radius-sm);
      padding: 0.65rem 1rem 0.65rem 2.6rem;
      font-size: 0.88rem;
      color: var(--gray-800);
      background: var(--gray-50);
      font-family: inherit;
      outline: none;
      transition: all var(--transition);
      box-sizing: border-box;
    }
    .form-select { padding-left: 1rem; cursor: pointer; }

    .form-input:focus, .form-select:focus {
      border-color: var(--purple);
      background: var(--white);
      box-shadow: 0 0 0 3px rgba(233, 30, 140, 0.12);
    }

    .form-input:invalid:not(:placeholder-shown) {
      border-color: var(--red);
      background: var(--red-bg);
    }

    .form-hint {
      font-size: 0.72rem;
      color: var(--gray-500);
      margin-top: 0.35rem;
      line-height: 1.45;
    }
    .form-hint strong { color: var(--purple); font-weight: 700; }

    .pass-policy {
      background: linear-gradient(135deg, var(--purple-bg) 0%, var(--pink-bg) 100%);
      border: 1px solid var(--purple-bg);
      border-radius: var(--radius-sm);
      padding: 0.75rem 0.95rem;
      margin-top: 0.5rem;
      font-size: 0.74rem;
      color: var(--gray-700);
      line-height: 1.55;
    }
    .pass-policy strong { color: var(--purple); font-weight: 700; }

    .alert {
      display: flex;
      align-items: center;
      gap: 0.6rem;
      padding: 0.85rem 1.05rem;
      border-radius: var(--radius-sm);
      font-size: 0.85rem;
      font-weight: 600;
      margin-bottom: 1.25rem;
      border: 1px solid;
    }
    .alert-error {
      background: var(--red-bg);
      color: var(--red-dark);
      border-color: #FECACA;
    }
    .alert i { width: 18px; height: 18px; flex-shrink: 0; }

    .form-actions {
      display: flex;
      justify-content: flex-end;
      gap: 0.65rem;
      padding-top: 1.25rem;
      border-top: 1px solid var(--gray-100);
      margin-top: 1.5rem;
    }

    .btn-cancel, .btn-create {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 0.4rem;
      padding: 0.65rem 1.4rem;
      border-radius: var(--radius-full);
      font-size: 0.85rem;
      font-weight: 700;
      text-decoration: none;
      transition: all var(--transition);
      cursor: pointer;
      border: 2px solid transparent;
      font-family: inherit;
    }
    .btn-cancel {
      background: var(--white);
      color: var(--gray-600);
      border-color: var(--gray-200);
    }
    .btn-cancel:hover { background: var(--gray-50); color: var(--gray-800); border-color: var(--gray-300); }

    .btn-create {
      background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
      color: var(--white);
      box-shadow: 0 4px 12px rgba(233, 30, 140, 0.25);
    }
    .btn-create:hover {
      transform: translateY(-1px);
      box-shadow: 0 6px 18px rgba(233, 30, 140, 0.4);
    }
    .btn-cancel i, .btn-create i { width: 14px; height: 14px; }

    /* Validación en vivo */
    .field-error {
      display: none;
      align-items: center;
      gap: 0.35rem;
      color: var(--red-dark);
      font-size: 0.72rem;
      font-weight: 600;
      margin-top: 0.35rem;
    }
    .field-error.visible { display: flex; }
    .field-error i { width: 13px; height: 13px; }
  </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

  <jsp:include page="includes/navbar.jsp"/>

  <div class="main-content">
    <jsp:include page="includes/topbar.jsp"/>

    <main class="page-main">

      <div class="page-header">
        <div>
          <h1 class="page-title">
            <i data-lucide="user-plus" style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
            Crear Usuario
          </h1>
          <p class="page-subtitle">Registra un nuevo usuario en el sistema y asígnale un rol.</p>
        </div>
        <a href="<%= ctx %>/<%= currentRoleId == 5 ? "RoleServlet" : "UserServlet" %>"
           class="btn-cancel">
          <i data-lucide="arrow-left"></i>
          Volver
        </a>
      </div>

      <% if (errParam != null) { %>
      <div class="alert alert-error">
        <i data-lucide="alert-circle"></i>
        <span><%= errParam %></span>
      </div>
      <% } %>

      <div class="form-card">

        <div class="form-card-header">
          <h2>
            <i data-lucide="user-plus"></i>
            Datos del nuevo usuario
          </h2>
          <p>Completa todos los campos. La cuenta quedará activa inmediatamente.</p>
        </div>

        <div class="form-card-body">

          <form action="<%= ctx %>/UserServlet" method="POST" onsubmit="return validarForm();" novalidate>

            <input type="hidden" name="action" value="crear"/>

            <%-- Nombre completo --%>
            <div class="form-group">
              <label>Nombre Completo <span class="req">*</span></label>
              <div class="input-wrap">
                <i data-lucide="user"></i>
                <input type="text" name="name" id="f-name" class="form-input"
                       placeholder="Ej: Juan Pérez García"
                       required
                       minlength="2"
                       maxlength="100"
                       pattern="(?=.*[A-Za-zÁÉÍÓÚáéíóúÑñÜü])[A-Za-zÁÉÍÓÚáéíóúÑñÜü\s'\-]{2,100}"
                       title="Debe contener al menos una letra. Solo letras, espacios, guiones y apóstrofes."
                       oninput="validarNombre()"/>
              </div>
              <div id="err-name" class="field-error">
                <i data-lucide="alert-circle"></i>
                <span>Solo se permiten letras, espacios, guiones y apóstrofes.</span>
              </div>
              <p class="form-hint">
                Solo <strong>letras</strong>, espacios, guiones y apóstrofes. No números ni símbolos.
              </p>
            </div>

            <%-- DNI y Email --%>
            <div class="form-grid-2">

              <div class="form-group">
                <label>DNI <span class="req">*</span></label>
                <div class="input-wrap">
                  <i data-lucide="id-card"></i>
                  <input type="text" name="dni" id="f-dni" class="form-input"
                         placeholder="8 dígitos"
                         required
                         pattern="[0-9]{8}"
                         maxlength="8"
                         title="Exactamente 8 dígitos numéricos"/>
                </div>
                <p class="form-hint">Exactamente 8 dígitos numéricos.</p>
              </div>

              <div class="form-group">
                <label>Correo Electrónico <span class="req">*</span></label>
                <div class="input-wrap">
                  <i data-lucide="mail"></i>
                  <input type="email" name="email" id="f-email" class="form-input"
                         placeholder="usuario@quintaola.com"
                         required
                         maxlength="150"/>
                </div>
              </div>

            </div>

            <%-- Contraseña --%>
            <div class="form-group">
              <label>Contraseña Inicial <span class="req">*</span></label>
              <div class="input-wrap">
                <i data-lucide="lock"></i>
                <input type="password" name="password" id="f-pass" class="form-input"
                       placeholder="••••••••"
                       required
                       minlength="8"/>
              </div>
              <div class="pass-policy">
                <i data-lucide="shield" style="display:inline-block; width:13px; height:13px; vertical-align:middle; color:var(--purple);"></i>
                <strong>Política de seguridad:</strong> mínimo 8 caracteres, con al menos
                <strong>1 mayúscula</strong>, <strong>1 minúscula</strong>,
                <strong>1 número</strong> y <strong>1 símbolo</strong> (!@#$%&*).
                <br/>
                El usuario podrá cambiarla después desde su perfil.
              </div>
            </div>

            <%-- Rol --%>
            <div class="form-group">
              <label>Asignar Rol <span class="req">*</span></label>
              <div class="input-wrap" style="padding-left: 0;">
                <select name="roleId" id="f-role" class="form-select" required>
                  <option value="" disabled selected>Selecciona un rol...</option>
                  <% if (roles != null) {
                    for (Role rol : roles) {
                      // SuperAdmin (5) ve todos los roles del 1 al 4.
                      // Admin (4) solo ve los roles del 1 al 3.
                      // En ambos casos NO se permite crear otro SuperAdmin.
                      boolean mostrar = false;
                      if (currentRoleId == 5 && rol.getId() < 5) mostrar = true;
                      if (currentRoleId == 4 && rol.getId() < 4) mostrar = true;
                      if (mostrar) {
                  %>
                  <option value="<%= rol.getId() %>">
                    <%= rol.getName() %><%= rol.getDescription() != null ? " — " + rol.getDescription() : "" %>
                  </option>
                  <%      }
                  }
                  } %>
                </select>
              </div>
              <p class="form-hint">Define qué puede hacer este usuario en el sistema.</p>
            </div>

            <%-- Acciones --%>
            <div class="form-actions">
              <a href="<%= ctx %>/<%= currentRoleId == 5 ? "RoleServlet" : "UserServlet" %>"
                 class="btn-cancel">
                <i data-lucide="x"></i>
                Cancelar
              </a>
              <button type="submit" class="btn-create">
                <i data-lucide="user-plus"></i>
                Crear Usuario
              </button>
            </div>

          </form>

        </div>

      </div>

    </main>

    <jsp:include page="includes/footer.jsp"/>

  </div>
</div>

<script>
  document.addEventListener('DOMContentLoaded', function () {
    if (typeof lucide !== 'undefined') lucide.createIcons();
  });

  function validarNombre() {
    const name = document.getElementById('f-name').value;
    const err  = document.getElementById('err-name');
    const reCaracteres = /^[A-Za-zÁÉÍÓÚáéíóúÑñÜü\s'\-]*$/;
    const reTieneLetra = /[A-Za-zÁÉÍÓÚáéíóúÑñÜü]/;

    if (name.length > 0) {
      if (!reCaracteres.test(name)) {
        err.querySelector('span').textContent =
                'Solo se permiten letras, espacios, guiones y apóstrofes.';
        err.classList.add('visible');
        return false;
      }
      if (!reTieneLetra.test(name)) {
        err.querySelector('span').textContent =
                'El nombre debe contener al menos una letra.';
        err.classList.add('visible');
        return false;
      }
    }
    err.classList.remove('visible');
    return true;
  }

  function validarForm() {
    const name = document.getElementById('f-name').value.trim();
    const dni  = document.getElementById('f-dni').value.trim();
    const pass = document.getElementById('f-pass').value;
    const role = document.getElementById('f-role').value;

    const reNombre = /^[A-Za-zÁÉÍÓÚáéíóúÑñÜü\s'\-]{2,100}$/;
    const reTieneLetra = /[A-Za-zÁÉÍÓÚáéíóúÑñÜü]/;
    if (!reNombre.test(name) || !reTieneLetra.test(name)) {
      alert('El nombre solo puede contener letras (al menos una), espacios, guiones y apóstrofes (2-100 caracteres).');
      document.getElementById('f-name').focus();
      return false;
    }

    if (!/^[0-9]{8}$/.test(dni)) {
      alert('El DNI debe tener exactamente 8 dígitos numéricos.');
      document.getElementById('f-dni').focus();
      return false;
    }

    const cumplePass = pass.length >= 8
            && /[A-Z]/.test(pass)
            && /[a-z]/.test(pass)
            && /[0-9]/.test(pass)
            && /[!@#$%^&*()_+\-=\[\]{};:'"<>,./?\\|`~]/.test(pass);

    if (!cumplePass) {
      alert('La contraseña no cumple los requisitos de seguridad.\n\n' +
              'Debe tener:\n' +
              '• Mínimo 8 caracteres\n' +
              '• Al menos 1 mayúscula\n' +
              '• Al menos 1 minúscula\n' +
              '• Al menos 1 número\n' +
              '• Al menos 1 símbolo (!@#$%&*...)');
      document.getElementById('f-pass').focus();
      return false;
    }

    if (!role) {
      alert('Debes seleccionar un rol para el usuario.');
      document.getElementById('f-role').focus();
      return false;
    }

    return true;
  }
</script>

</body>
</html>