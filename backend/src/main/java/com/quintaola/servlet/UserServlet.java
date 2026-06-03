package com.quintaola.servlet;

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
   - crear (POST)   -> procesa creacion
   - cambiarRol (POST) -> cambia el rol de un usuario
   - approveUser (POST) -> 🛡️ NUEVO: aprueba un usuario pendiente

   Acceso: Administrador (4) y SuperAdmin (5)
   ============================================================ */
@WebServlet(name = "UserServlet", value = "/UserServlet")
public class UserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo Admin (4) y SuperAdmin (5)
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

            // ─── LISTA de todos los usuarios ───
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

            // ─── FORMULARIO para crear usuario nuevo ───
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

        switch (action) {

            // ─── APROBAR USUARIO PENDIENTE ───
            case "approveUser":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));

                    // Llamamos al método (que agregaremos al DAO) para activarlo
                    boolean ok = userDao.approve(userId);

                    if (ok) {
                        request.setAttribute("mensajeExito", "¡El usuario ha sido aprobado y ya puede iniciar sesión!");
                    } else {
                        request.setAttribute("error", "No se pudo aprobar al usuario.");
                    }

                    // Recargamos la lista para mostrar la tabla actualizada
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

            // ─── CREAR usuario nuevo con rol asignado ───
            case "crear":
                try {
                    String name = request.getParameter("name");
                    String email = request.getParameter("email");
                    String dni = request.getParameter("dni");
                    String password = request.getParameter("password");
                    int roleId = Integer.parseInt(request.getParameter("roleId"));

                    // Validaciones basicas
                    if (name == null || name.trim().isEmpty()
                            || email == null || email.trim().isEmpty()
                            || dni == null || dni.length() != 8
                            || password == null || password.length() < 6) {

                        response.sendRedirect(request.getContextPath()
                                + "/UserServlet?action=formCrear&error=Datos+invalidos");
                        return;
                    }

                    // Hashear la password con bcrypt
                    String hash = BCrypt.hashpw(password, BCrypt.gensalt(10));

                    User nuevo = new User();
                    nuevo.setName(name.trim());
                    nuevo.setEmail(email.trim().toLowerCase());
                    nuevo.setDni(dni.trim());
                    nuevo.setPasswordHash(hash);

                    boolean ok = userDao.createWithRole(nuevo, roleId);

                    if (ok) {
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

            // ─── CAMBIAR ROL de un usuario ───
            case "cambiarRol":
                try {
                    int userId = Integer.parseInt(request.getParameter("userId"));
                    int nuevoRolId = Integer.parseInt(request.getParameter("nuevoRolId"));

                    boolean ok = userDao.changeRole(userId, nuevoRolId);

                    if (ok) {
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