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
import java.util.Map;

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
                    Map<Integer, String> inactiveStatus = userDao.getInactiveUsersStatus();

                    request.setAttribute("usuarios", usuarios);
                    request.setAttribute("roles", roles);
                    request.setAttribute("inactiveStatus", inactiveStatus);
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

        HttpSession sesion = request.getSession();
        Integer actorId = (Integer) sesion.getAttribute("userId");
        Integer actorRoleId = (Integer) sesion.getAttribute("roleId");
        String actorRole = (String) sesion.getAttribute("roleName");
        if (actorRole == null) actorRole = "Usuario";

        // ─── DETECTAR DESDE DÓNDE VINO LA ACCIÓN ───
        // Si el form envió redirectTo=roles, regresa a /RoleServlet.
        // Si no, sigue el comportamiento por defecto (admin-users).
        String redirectTo = request.getParameter("redirectTo");
        String redirectBase;
        if ("roles".equals(redirectTo)) {
            redirectBase = "/RoleServlet";
        } else {
            redirectBase = "/UserServlet";
        }
        String ctx = request.getContextPath();

        switch (action) {

            // ─── APROBAR USUARIO PENDIENTE ───
            case "approveUser":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));

                    boolean ok = userDao.approve(userId);

                    if (ok) {
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

                        response.sendRedirect(ctx + redirectBase + "?success=Usuario+aprobado.+Ya+puede+iniciar+sesion");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+aprobar+al+usuario");
                    }

                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            // ─── RECHAZAR USUARIO PENDIENTE ───
            case "rejectUser":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));

                    User aRechazar = userDao.getById(userId);
                    boolean ok = userDao.disable(userId);

                    if (ok && aRechazar != null) {
                        try {
                            String detalles = String.format(
                                    "El %s rechazó la cuenta del usuario '%s' (id=%d, email=%s)",
                                    actorRole,
                                    aRechazar.getName(),
                                    userId,
                                    aRechazar.getEmail()
                            );
                            auditDao.log(actorId, "RECHAZAR_USUARIO", "USER", userId, detalles);
                        } catch (Exception ignored) {}

                        response.sendRedirect(ctx + redirectBase + "?success=Solicitud+de+registro+rechazada");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+rechazar+al+usuario");
                    }

                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            // ─── DESACTIVAR USUARIO (solo SuperAdmin) ───
            case "desactivarUsuario":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));

                    if (actorRoleId == null || actorRoleId != 5) {
                        response.sendRedirect(ctx + redirectBase + "?error=Solo+el+SuperAdmin+puede+desactivar+usuarios");
                        return;
                    }

                    if (actorId != null && actorId == userId) {
                        response.sendRedirect(ctx + redirectBase + "?error=No+puedes+desactivarte+a+ti+mismo");
                        return;
                    }

                    User aDesactivar = userDao.getById(userId);
                    if (aDesactivar == null) {
                        response.sendRedirect(ctx + redirectBase + "?error=Usuario+no+encontrado");
                        return;
                    }

                    if (aDesactivar.getRoleId() == 5) {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+puede+desactivar+al+SuperAdmin");
                        return;
                    }

                    boolean ok = userDao.disable(userId);

                    if (ok) {
                        try {
                            String detalles = String.format(
                                    "El %s desactivó la cuenta de '%s' (id=%d, email=%s, rol=%s). El usuario ya no podrá iniciar sesión.",
                                    actorRole,
                                    aDesactivar.getName(),
                                    userId,
                                    aDesactivar.getEmail(),
                                    aDesactivar.getRoleName()
                            );
                            auditDao.log(actorId, "DESACTIVAR_USUARIO", "USER", userId, detalles);
                        } catch (Exception ignored) {}

                        response.sendRedirect(ctx + redirectBase + "?success=Usuario+desactivado+correctamente");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+desactivar");
                    }

                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            // ─── REACTIVAR USUARIO (solo SuperAdmin) ───
            case "reactivarUsuario":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));

                    if (actorRoleId == null || actorRoleId != 5) {
                        response.sendRedirect(ctx + redirectBase + "?error=Solo+el+SuperAdmin+puede+reactivar+usuarios");
                        return;
                    }

                    User aReactivar = userDao.getById(userId);
                    if (aReactivar == null) {
                        response.sendRedirect(ctx + redirectBase + "?error=Usuario+no+encontrado");
                        return;
                    }

                    boolean ok = userDao.enable(userId);

                    if (ok) {
                        try {
                            String detalles = String.format(
                                    "El %s reactivó la cuenta de '%s' (id=%d, email=%s). El usuario ya puede iniciar sesión nuevamente.",
                                    actorRole,
                                    aReactivar.getName(),
                                    userId,
                                    aReactivar.getEmail()
                            );
                            auditDao.log(actorId, "REACTIVAR_USUARIO", "USER", userId, detalles);
                        } catch (Exception ignored) {}

                        response.sendRedirect(ctx + redirectBase + "?success=Usuario+reactivado+correctamente");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+reactivar");
                    }

                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
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

                    if (actorRoleId != null && actorRoleId == 4 && roleId >= 4) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=No+tienes+permiso+para+crear+ese+rol");
                        return;
                    }

                    // ─── Validar política de contraseñas ───
                    String passError = com.quintaola.util.PasswordValidator.getErrorMessage(password);
                    if (passError != null) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=" + passError.replace(" ", "+"));
                        return;
                    }

                    // ─── Validar nombre (solo letras, espacios, guiones, apóstrofes) ───
                    if (name == null || !name.trim().matches("[\\p{L}\\s'\\-]{2,100}")) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=Nombre+invalido.+Solo+letras+y+espacios");
                        return;
                    }

                    // ─── Validar DNI (8 dígitos) ───
                    if (dni == null || !dni.matches("\\d{8}")) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=DNI+debe+tener+8+digitos");
                        return;
                    }

                    // ─── Validar email ───
                    if (email == null || !email.trim().toLowerCase().matches("^[\\w.+\\-]+@[\\w\\-]+(\\.[\\w\\-]+)+$")) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=Email+invalido");
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
                            auditDao.log(actorId, "CREAR_USUARIO", "USER", 0, detalles);
                        } catch (Exception ignored) {}

                        String redirect = (actorRoleId != null && actorRoleId == 5)
                                ? "/RoleServlet?success=Usuario+creado+correctamente"
                                : "/UserServlet?success=Usuario+creado+correctamente";

                        response.sendRedirect(ctx + redirect);
                    } else {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=No+se+pudo+crear");
                    }

                } catch (Exception e) {
                    String msg = e.getMessage();
                    if (msg != null && msg.contains("Duplicate")) {
                        msg = "Email o DNI ya registrado";
                    }
                    response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=" + msg.replace(" ", "+"));
                }
                break;

            // ─── CAMBIAR ROL ───
            case "cambiarRol":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));
                    int nuevoRolId = Integer.parseInt(request.getParameter("nuevoRolId"));

                    User afectado = userDao.getById(userId);
                    if (afectado == null) {
                        response.sendRedirect(ctx + redirectBase + "?error=Usuario+no+encontrado");
                        return;
                    }
                    String rolAnterior = afectado.getRoleName();
                    String nombreAfectado = afectado.getName();

                    if (actorId != null && actorId == userId) {
                        response.sendRedirect(ctx + redirectBase + "?error=No+puedes+cambiar+tu+propio+rol");
                        return;
                    }

                    if (actorRoleId != null && actorRoleId == 4) {
                        if (afectado.getRoleId() >= 4) {
                            response.sendRedirect(ctx + redirectBase + "?error=No+tienes+permiso+para+modificar+a+ese+usuario");
                            return;
                        }
                        if (nuevoRolId >= 4) {
                            response.sendRedirect(ctx + redirectBase + "?error=No+puedes+asignar+ese+rol");
                            return;
                        }
                    }

                    boolean ok = userDao.changeRole(userId, nuevoRolId);

                    if (ok) {
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

                        response.sendRedirect(ctx + redirectBase + "?success=Rol+actualizado+correctamente");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+cambiar+el+rol");
                    }

                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            default:
                response.sendRedirect(ctx + "/UserServlet");
                break;
        }
    }

    private boolean tienePermiso(HttpServletRequest request) {
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        return roleId != null && (roleId == 4 || roleId == 5);
    }
}