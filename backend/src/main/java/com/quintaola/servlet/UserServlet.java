package com.quintaola.servlet;

import com.quintaola.dao.AuditDAO;
import com.quintaola.dao.RoleDAO;
import com.quintaola.dao.UserDAO;
import com.quintaola.dao.NotificationDAO;
import com.quintaola.model.Role;
import com.quintaola.model.User;
import com.quintaola.model.Notification;
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
                    // ── Filtros opcionales ────────────────────────────────────
                    String searchQ = request.getParameter("q") != null
                            ? request.getParameter("q").trim() : "";

                    int rolFilter = 0;
                    String rolParam = request.getParameter("rol");
                    if (rolParam != null && !rolParam.trim().isEmpty()) {
                        try { rolFilter = Integer.parseInt(rolParam); }
                        catch (NumberFormatException ignored) {}
                    }

                    // ── Paginación: 15 registros por página ───────────────────
                    final int PAGE_SIZE = 15;
                    int currentPage = 1;
                    String pageParam = request.getParameter("page");
                    if (pageParam != null && !pageParam.trim().isEmpty()) {
                        try { currentPage = Math.max(1, Integer.parseInt(pageParam)); }
                        catch (NumberFormatException ignored) {}
                    }
                    int offset = (currentPage - 1) * PAGE_SIZE;

                    // Usa los métodos filtrados del DAO
                    List<User> usuarios   = userDao.getPageFiltered(offset, PAGE_SIZE, searchQ, rolFilter);
                    int        totalCount = userDao.countFiltered(searchQ, rolFilter);
                    int        totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
                    if (totalPages < 1) totalPages = 1;
                    currentPage = Math.min(currentPage, totalPages);
                    // ─────────────────────────────────────────────────────────

                    List<Role>           roles          = roleDao.getAll();
                    Map<Integer, String> inactiveStatus = userDao.getInactiveUsersStatus();

                    request.setAttribute("usuarios",       usuarios);
                    request.setAttribute("roles",          roles);
                    request.setAttribute("inactiveStatus", inactiveStatus);
                    request.setAttribute("activeMenu",     "members");

                    // Atributos de paginación
                    request.setAttribute("currentPage", currentPage);
                    request.setAttribute("totalPages",  totalPages);
                    request.setAttribute("totalCount",  totalCount);

                    // Atributos de filtros (para mantener estado del formulario)
                    request.setAttribute("searchQ",   searchQ);
                    request.setAttribute("rolFilter", rolFilter);

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

        UserDAO  userDao  = new UserDAO();
        AuditDAO auditDao = new AuditDAO();

        HttpSession sesion = request.getSession(false);
        Integer actorId         = (Integer) sesion.getAttribute("userId");
        Integer actorRoleId     = (Integer) sesion.getAttribute("roleId");
        String  actorRole       = (String)  sesion.getAttribute("roleName");
        if (actorRole == null) actorRole = "Usuario";

        String redirectTo   = request.getParameter("redirectTo");
        String redirectBase = "roles".equals(redirectTo) ? "/RoleServlet" : "/UserServlet";
        String ctx          = request.getContextPath();

        switch (action) {

            case "approveUser":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));
                    User aprobado = userDao.getById(userId);
                    boolean ok = userDao.approve(userId);
                    if (ok) {
                        try {
                            auditDao.log(actorId, "APROBAR_USUARIO", "USER", userId,
                                    String.format("El %s aprobó la cuenta del usuario '%s' (id=%d, email=%s)",
                                            actorRole,
                                            aprobado != null ? aprobado.getName() : "desconocido",
                                            userId,
                                            aprobado != null ? aprobado.getEmail() : "—"));
                        } catch (Exception ignored) {}
                        if (aprobado != null && aprobado.getEmail() != null) {
                            try {
                                com.quintaola.util.EmailService.enviarAprobacion(aprobado.getEmail(), aprobado.getName());
                            } catch (Exception emailEx) {
                                System.err.println("[UserServlet] Email aprobación: " + emailEx.getMessage());
                            }
                        }
                        response.sendRedirect(ctx + redirectBase + "?success=Usuario+aprobado.+Ya+puede+iniciar+sesion");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+aprobar+al+usuario");
                    }
                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            case "rejectUser":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));
                    User aRechazar = userDao.getById(userId);
                    boolean ok = userDao.disable(userId);
                    if (ok && aRechazar != null) {
                        try {
                            auditDao.log(actorId, "RECHAZAR_USUARIO", "USER", userId,
                                    String.format("El %s rechazó la cuenta del usuario '%s' (id=%d, email=%s)",
                                            actorRole, aRechazar.getName(), userId, aRechazar.getEmail()));
                        } catch (Exception ignored) {}
                        if (aRechazar.getEmail() != null) {
                            try {
                                com.quintaola.util.EmailService.enviarRechazo(aRechazar.getEmail(), aRechazar.getName());
                            } catch (Exception emailEx) {
                                System.err.println("[UserServlet] Email rechazo: " + emailEx.getMessage());
                            }
                        }
                        response.sendRedirect(ctx + redirectBase + "?success=Solicitud+de+registro+rechazada");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+rechazar+al+usuario");
                    }
                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            case "desactivarUsuario":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));
                    if (actorRoleId == null || actorRoleId != 5) {
                        response.sendRedirect(ctx + redirectBase + "?error=Solo+el+SuperAdmin+puede+desactivar+usuarios"); return;
                    }
                    if (actorId != null && actorId == userId) {
                        response.sendRedirect(ctx + redirectBase + "?error=No+puedes+desactivarte+a+ti+mismo"); return;
                    }
                    User aDesactivar = userDao.getById(userId);
                    if (aDesactivar == null) {
                        response.sendRedirect(ctx + redirectBase + "?error=Usuario+no+encontrado"); return;
                    }
                    if (aDesactivar.getRoleId() == 5) {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+puede+desactivar+al+SuperAdmin"); return;
                    }
                    boolean ok = userDao.disable(userId);
                    if (ok) {
                        try {
                            auditDao.log(actorId, "DESACTIVAR_USUARIO", "USER", userId,
                                    String.format("El %s desactivó la cuenta de '%s' (id=%d, email=%s, rol=%s).",
                                            actorRole, aDesactivar.getName(), userId,
                                            aDesactivar.getEmail(), aDesactivar.getRoleName()));
                        } catch (Exception ignored) {}
                        response.sendRedirect(ctx + redirectBase + "?success=Usuario+desactivado+correctamente");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+desactivar");
                    }
                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            case "reactivarUsuario":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));
                    if (actorRoleId == null || actorRoleId != 5) {
                        response.sendRedirect(ctx + redirectBase + "?error=Solo+el+SuperAdmin+puede+reactivar+usuarios"); return;
                    }
                    User aReactivar = userDao.getById(userId);
                    if (aReactivar == null) {
                        response.sendRedirect(ctx + redirectBase + "?error=Usuario+no+encontrado"); return;
                    }
                    boolean ok = userDao.enable(userId);
                    if (ok) {
                        try {
                            auditDao.log(actorId, "REACTIVAR_USUARIO", "USER", userId,
                                    String.format("El %s reactivó la cuenta de '%s' (id=%d, email=%s).",
                                            actorRole, aReactivar.getName(), userId, aReactivar.getEmail()));
                        } catch (Exception ignored) {}
                        response.sendRedirect(ctx + redirectBase + "?success=Usuario+reactivado+correctamente");
                    } else {
                        response.sendRedirect(ctx + redirectBase + "?error=No+se+pudo+reactivar");
                    }
                } catch (Exception e) {
                    response.sendRedirect(ctx + redirectBase + "?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            case "crear":
                try {
                    String name     = request.getParameter("name");
                    String email    = request.getParameter("email");
                    String dni      = request.getParameter("dni");
                    String password = request.getParameter("password");
                    int    roleId   = Integer.parseInt(request.getParameter("roleId"));

                    if (actorRoleId != null && actorRoleId == 4 && roleId >= 4) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=No+tienes+permiso+para+crear+ese+rol"); return;
                    }
                    String passError = com.quintaola.util.PasswordValidator.getErrorMessage(password);
                    if (passError != null) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=" + passError.replace(" ", "+")); return;
                    }
                    if (name == null || !name.trim().matches("[\\p{L}\\s'\\-]{2,100}") || !name.matches(".*\\p{L}.*")) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=Nombre+invalido.+Debe+contener+al+menos+una+letra"); return;
                    }
                    if (dni == null || !dni.matches("\\d{8}")) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=DNI+debe+tener+8+digitos"); return;
                    }
                    if (email == null || !email.trim().toLowerCase().matches("^[\\w.+\\-]+@[\\w\\-]+(\\.[\\w\\-]+)+$")) {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=Email+invalido"); return;
                    }

                    User nuevo = new User();
                    nuevo.setName        (name.trim());
                    nuevo.setEmail       (email.trim().toLowerCase());
                    nuevo.setDni         (dni.trim());
                    nuevo.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt(10)));

                    int nuevoId = userDao.createWithRole(nuevo, roleId);
                    if (nuevoId > 0) {
                        try {
                            RoleDAO rdao = new RoleDAO();
                            Role rolAsignado = rdao.getById(roleId);
                            auditDao.log(actorId, "CREAR_USUARIO", "USER", 0,
                                    String.format("El %s creó al usuario '%s' (email=%s, dni=%s) con rol '%s'",
                                            actorRole, nuevo.getName(), nuevo.getEmail(), nuevo.getDni(),
                                            rolAsignado != null ? rolAsignado.getName() : "roleId=" + roleId));
                        } catch (Exception ignored) {}

                        // ─── Enviar credenciales por correo al nuevo usuario ───
                        try {
                            com.quintaola.util.EmailService.enviarCredenciales(nuevo.getEmail(), nuevo.getName(), password);
                        } catch (Exception emailEx) {
                            System.err.println("[UserServlet] Email credenciales: " + emailEx.getMessage());
                        }

                        // ─── Notificación de seguridad para el nuevo usuario ───
                        try {
                            NotificationDAO notifDao = new NotificationDAO();
                            Notification alerta = new Notification();
                            alerta.setUserId(nuevoId);
                            alerta.setType("request_rejected");
                            alerta.setTitle("Actualización de seguridad obligatoria");
                            alerta.setMessage("Tu cuenta fue creada con una contraseña temporal. Cámbiala en tu primer inicio de sesión.");
                            alerta.setRelatedId(0);
                            notifDao.crear(alerta);
                        } catch (Exception notifEx) {
                            System.err.println("[UserServlet] Notificación seguridad: " + notifEx.getMessage());
                        }

                        String redirect = (actorRoleId != null && actorRoleId == 5)
                                ? "/RoleServlet?success=Usuario+creado+correctamente"
                                : "/UserServlet?success=Usuario+creado+correctamente";
                        response.sendRedirect(ctx + redirect);
                    } else {
                        response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=No+se+pudo+crear");
                    }
                } catch (Exception e) {
                    String msg = e.getMessage();
                    if (msg != null && msg.contains("Duplicate")) msg = "Email o DNI ya registrado";
                    response.sendRedirect(ctx + "/UserServlet?action=formCrear&error=" + msg.replace(" ", "+"));
                }
                break;

            case "cambiarRol":
                try {
                    int userId     = Integer.parseInt(request.getParameter("userId"));
                    int nuevoRolId = Integer.parseInt(request.getParameter("nuevoRolId"));

                    User afectado = userDao.getById(userId);
                    if (afectado == null) {
                        response.sendRedirect(ctx + redirectBase + "?error=Usuario+no+encontrado"); return;
                    }
                    if (actorId != null && actorId == userId) {
                        response.sendRedirect(ctx + redirectBase + "?error=No+puedes+cambiar+tu+propio+rol"); return;
                    }
                    if (actorRoleId != null && actorRoleId == 4) {
                        if (afectado.getRoleId() >= 4) {
                            response.sendRedirect(ctx + redirectBase + "?error=No+tienes+permiso+para+modificar+a+ese+usuario"); return;
                        }
                        if (nuevoRolId >= 4) {
                            response.sendRedirect(ctx + redirectBase + "?error=No+puedes+asignar+ese+rol"); return;
                        }
                    }
                    boolean ok = userDao.changeRole(userId, nuevoRolId);
                    if (ok) {
                        try {
                            RoleDAO rdao = new RoleDAO();
                            Role rolNuevo = rdao.getById(nuevoRolId);
                            auditDao.log(actorId, "CAMBIO_ROL", "USER", userId,
                                    String.format("El %s cambió el rol de '%s' (id=%d) de '%s' a '%s'",
                                            actorRole, afectado.getName(), userId,
                                            afectado.getRoleName(),
                                            rolNuevo != null ? rolNuevo.getName() : "roleId=" + nuevoRolId));
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