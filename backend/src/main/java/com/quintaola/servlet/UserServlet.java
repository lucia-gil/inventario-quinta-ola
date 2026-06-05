package com.quintaola.servlet;

import com.quintaola.dao.AuditDAO;
import com.quintaola.dao.RoleDAO;
import com.quintaola.dao.UserDAO;
import com.quintaola.model.Role;
import com.quintaola.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.util.List;

/* ============================================================
   UserServlet
   ============================================================
   Gestion de usuarios para Admin y SuperAdmin:
   - lista          -> tabla de todos los usuarios
   - formCrear      -> form para crear usuario con rol
   - crear (POST)   -> procesa creacion + registra en audit_log
   - cambiarRol (POST) -> cambia rol + registra en audit_log
   - approveUser (POST) -> aprueba usuario pendiente + audit_log

   Acceso: Administrador (4) y SuperAdmin (5)
   ============================================================ */
@WebServlet(name = "UserServlet", value = "/UserServlet")
public class UserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!tienePermiso(request)) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        String action = request.getParameter("action") == null
                ? "lista" : request.getParameter("action");

        UserDAO userDao = new UserDAO();
        RoleDAO roleDao = new RoleDAO();
        RequestDispatcher view;

        switch (action) {

            case "lista":
                try {
                    List<User> usuarios = userDao.getAll();
                    List<Role> roles = roleDao.getAll();

                    request.setAttribute("usuarios", usuarios);
                    request.setAttribute("roles", roles);
                    request.setAttribute("activeMenu", "members");

                    view = request.getRequestDispatcher("admin-users.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error al cargar usuarios: " + e.getMessage());
                    view = request.getRequestDispatcher("admin-users.jsp");
                    view.forward(request, response);
                }
                break;

            case "formCrear":
                try {
                    List<Role> roles = roleDao.getAll();
                    request.setAttribute("roles", roles);
                    request.setAttribute("activeMenu", "members");

                    view = request.getRequestDispatcher("user-form.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath()
                            + "/UserServlet?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/UserServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if (!tienePermiso(request)) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        String action = request.getParameter("action") == null
                ? "" : request.getParameter("action");

        UserDAO userDao = new UserDAO();
        AuditDAO auditDao = new AuditDAO();

        // ── Datos del usuario en sesión (actor de la auditoría) ──
        HttpSession sesion = request.getSession();
        Integer actorId = (Integer) sesion.getAttribute("userId");
        String actorRole = (String) sesion.getAttribute("roleName");
        if (actorRole == null) actorRole = "Usuario";

        switch (action) {

            // ─── APROBAR USUARIO PENDIENTE ───
            case "approveUser":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));

                    boolean ok = userDao.approve(userId);

                    if (ok) {
                        // 🛡️ AUDITORÍA: registrar la aprobación
                        try {
                            User aprobado = userDao.getById(userId);
                            String detalles = String.format(
                                    "El %s aprobó la cuenta del usuario '%s' (id=%d, email=%s)",
                                    actorRole,
                                    aprobado != null ? aprobado.getName() : "desconocido",
                                    userId,
                                    aprobado != null ? aprobado.getEmail() : "—"
                            );
                            auditDao.log(actorId, "APROBAR_USUARIO", "USER", userId, detalles);
                        } catch (Exception ignored) {}

                        request.setAttribute("mensajeExito", "¡El usuario ha sido aprobado y ya puede iniciar sesión!");
                    } else {
                        request.setAttribute("error", "No se pudo aprobar al usuario.");
                    }

                    List<User> usuarios = userDao.getAll();
                    request.setAttribute("usuarios", usuarios);
                    request.setAttribute("activeMenu", "members");

                    RequestDispatcher view = request.getRequestDispatcher("admin-users.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error del servidor: " + e.getMessage());
                    try {
                        List<User> usuarios = userDao.getAll();
                        request.setAttribute("usuarios", usuarios);
                    } catch (Exception ignored) {}
                    RequestDispatcher view = request.getRequestDispatcher("admin-users.jsp");
                    view.forward(request, response);
                }
                break;

            // ─── CREAR usuario nuevo ───
            case "crear":
                try {
                    String name = request.getParameter("name");
                    String email = request.getParameter("email");
                    String dni = request.getParameter("dni");
                    String password = request.getParameter("password");
                    int roleId = Integer.parseInt(request.getParameter("roleId"));

                    if (name == null || name.trim().isEmpty()
                            || email == null || email.trim().isEmpty()
                            || dni == null || dni.length() != 8
                            || password == null || password.length() < 6) {

                        response.sendRedirect(request.getContextPath()
                                + "/UserServlet?action=formCrear&error=Datos+invalidos");
                        return;
                    }

                    String hash = BCrypt.hashpw(password, BCrypt.gensalt(10));

                    User nuevo = new User();
                    nuevo.setName(name.trim());
                    nuevo.setEmail(email.trim().toLowerCase());
                    nuevo.setDni(dni.trim());
                    nuevo.setPasswordHash(hash);

                    boolean ok = userDao.createWithRole(nuevo, roleId);

                    if (ok) {
                        // 🛡️ AUDITORÍA: registrar la creación
                        try {
                            RoleDAO rdao = new RoleDAO();
                            Role rolAsignado = rdao.getById(roleId);
                            String nombreRol = rolAsignado != null ? rolAsignado.getName() : ("roleId=" + roleId);

                            String detalles = String.format(
                                    "El %s creó al usuario '%s' (email=%s, dni=%s) con rol '%s'",
                                    actorRole,
                                    nuevo.getName(),
                                    nuevo.getEmail(),
                                    nuevo.getDni(),
                                    nombreRol
                            );
                            // entityId = 0 porque no tenemos el id del nuevo usuario en este punto
                            auditDao.log(actorId, "CREAR_USUARIO", "USER", 0, detalles);
                        } catch (Exception ignored) {}

                        response.sendRedirect(request.getContextPath()
                                + "/RoleServlet?success=Usuario+creado+correctamente");
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/UserServlet?action=formCrear&error=No+se+pudo+crear");
                    }

                } catch (Exception e) {
                    String msg = e.getMessage();
                    if (msg != null && msg.contains("Duplicate")) {
                        msg = "Email o DNI ya registrado";
                    }
                    response.sendRedirect(request.getContextPath()
                            + "/UserServlet?action=formCrear&error=" + msg.replace(" ", "+"));
                }
                break;

            // ─── CAMBIAR ROL ───
            case "cambiarRol":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));
                    int nuevoRolId = Integer.parseInt(request.getParameter("nuevoRolId"));

                    // 1. Capturar el rol anterior ANTES del cambio (para el log)
                    User afectado = userDao.getById(userId);
                    String rolAnterior = afectado != null ? afectado.getRoleName() : "?";
                    String nombreAfectado = afectado != null ? afectado.getName() : "usuario";

                    // 2. Aplicar el cambio
                    boolean ok = userDao.changeRole(userId, nuevoRolId);

                    if (ok) {
                        // 3. 🛡️ AUDITORÍA: registrar el cambio
                        try {
                            RoleDAO rdao = new RoleDAO();
                            Role rolNuevo = rdao.getById(nuevoRolId);
                            String nombreRolNuevo = rolNuevo != null ? rolNuevo.getName() : ("roleId=" + nuevoRolId);

                            String detalles = String.format(
                                    "El %s cambió el rol de '%s' (id=%d) de '%s' a '%s'",
                                    actorRole,
                                    nombreAfectado,
                                    userId,
                                    rolAnterior,
                                    nombreRolNuevo
                            );
                            auditDao.log(actorId, "CAMBIO_ROL", "USER", userId, detalles);
                        } catch (Exception ignored) {}

                        response.sendRedirect(request.getContextPath()
                                + "/RoleServlet?success=Rol+actualizado+correctamente");
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/RoleServlet?error=No+se+pudo+cambiar+el+rol");
                    }

                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath()
                            + "/RoleServlet?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/UserServlet");
                break;
        }
    }

    // ─── Helper: validar que sea Admin o SuperAdmin ───
    private boolean tienePermiso(HttpServletRequest request) {
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        return roleId != null && (roleId == 4 || roleId == 5);
    }
}