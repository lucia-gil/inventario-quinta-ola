package com.quintaola.servlet;

import com.quintaola.dao.UserDAO;
import com.quintaola.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * AuthServlet — patrón MVC del curso (Clase 7.2 y 7.3).
 *
 * Maneja login, logout y registro mediante un parámetro `action`.
 *
 * URLs:
 * GET  /AuthServlet?action=formLogin    → muestra login.jsp
 * GET  /AuthServlet?action=formSignup   → muestra signup.jsp
 * GET  /AuthServlet?action=logout       → cierra sesión y redirige a login
 * POST /AuthServlet  (action=login)     → procesa credenciales
 * POST /AuthServlet  (action=signup)    → registra nuevo usuario
 */
@WebServlet(name = "AuthServlet", value = "/AuthServlet")
public class AuthServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null
                ? "formLogin"
                : request.getParameter("action");

        RequestDispatcher view;

        switch (action) {
            case "formLogin":
                view = request.getRequestDispatcher("/login.jsp");
                view.forward(request, response);
                break;

            case "formSignup":
                view = request.getRequestDispatcher("signup.jsp");
                view.forward(request, response);
                break;

            case "logout":
                HttpSession session = request.getSession(false);
                if (session != null) session.invalidate();
                response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar encoding (Clase 7.3, slide 16)
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null
                ? "" : request.getParameter("action");

        UserDAO userDao = new UserDAO();
        RequestDispatcher view;

        switch (action) {
            case "login":
                String email    = request.getParameter("email");
                String password = request.getParameter("password");

                try {
                    User user = userDao.login(email, password);

                    if (user == null) {
                        request.setAttribute("error", "Correo o contraseña incorrectos");
                        view = request.getRequestDispatcher("login.jsp");
                        view.forward(request, response);

                        // 🛡NUEVO: Validar si la cuenta está pendiente de aprobación
                        // Nota: Si en tu modelo User la propiedad es boolean, usa !user.isActivo()
                    } else if (user.getActivo() == 0) {
                        request.setAttribute("error", "Tu cuenta está pendiente de aprobación por un Administrador.");
                        view = request.getRequestDispatcher("/login.jsp");
                        view.forward(request, response);

                    } else {
                        // Login OK: guardar en sesión
                        HttpSession sess = request.getSession();
                        sess.setAttribute("userId",    user.getId());
                        sess.setAttribute("userName",  user.getName());
                        sess.setAttribute("userEmail", user.getEmail());
                        sess.setAttribute("roleId",    user.getRoleId());
                        sess.setAttribute("roleName",  user.getRoleName());

                        // Guardamos el avatar en la sesión para que el Topbar lo renderice desde el inicio
                        sess.setAttribute("avatarUrl",  user.getAvatarUrl());

                        // Redirigir según rol — todos van a HomeServlet excepto SuperAdmin
                        // (SuperAdmin no tiene Home porque su perfil es exclusivo de auditoría)
                        String redirect = "SuperAdmin".equals(user.getRoleName())
                                ? "/RoleServlet"   // SuperAdmin → directo a Roles
                                : "/HomeServlet";  // Todos los demás → Inicio

                        response.sendRedirect(request.getContextPath() + redirect);
                    }
                } catch (Exception e) {
                    request.setAttribute("error", "Error del servidor: " + e.getMessage());
                    view = request.getRequestDispatcher("/login.jsp");
                    view.forward(request, response);
                }
                break;

            case "register":
                try {
                    String nombres = request.getParameter("nombres");
                    String apellidos = request.getParameter("apellidos");
                    String dni = request.getParameter("dni");
                    String emailReg = request.getParameter("email");
                    String passReg = request.getParameter("password");

                    // ─── 1. Validar política de contraseñas ───
                    String passError = com.quintaola.util.PasswordValidator.getErrorMessage(passReg);
                    if (passError != null) {
                        request.setAttribute("error", passError);
                        view = request.getRequestDispatcher("/signup.jsp");
                        view.forward(request, response);
                        return;
                    }

                    // ─── 2. Sanear nombres y apellidos (solo letras, espacios y acentos) ───
                    if (nombres == null || !nombres.trim().matches("[\\p{L}\\s'\\-]{2,50}")) {
                        request.setAttribute("error", "Los nombres solo pueden contener letras, espacios, guiones y apóstrofes (2-50 caracteres).");
                        view = request.getRequestDispatcher("/signup.jsp");
                        view.forward(request, response);
                        return;
                    }
                    if (apellidos == null || !apellidos.trim().matches("[\\p{L}\\s'\\-]{2,50}")) {
                        request.setAttribute("error", "Los apellidos solo pueden contener letras, espacios, guiones y apóstrofes (2-50 caracteres).");
                        view = request.getRequestDispatcher("/signup.jsp");
                        view.forward(request, response);
                        return;
                    }

                    // ─── 3. Validar DNI (8 dígitos exactos) ───
                    if (dni == null || !dni.matches("\\d{8}")) {
                        request.setAttribute("error", "El DNI debe tener exactamente 8 dígitos.");
                        view = request.getRequestDispatcher("/signup.jsp");
                        view.forward(request, response);
                        return;
                    }

                    // ─── 4. Validar email básico ───
                    if (emailReg == null || !emailReg.trim().toLowerCase().matches("^[\\w.+\\-]+@[\\w\\-]+(\\.[\\w\\-]+)+$")) {
                        request.setAttribute("error", "Ingresa un correo electrónico válido.");
                        view = request.getRequestDispatcher("/signup.jsp");
                        view.forward(request, response);
                        return;
                    }

                    // ─── 5. Crear el usuario ───
                    User newUser = new User();
                    newUser.setName(nombres.trim() + " " + apellidos.trim());
                    newUser.setDni(dni.trim());
                    newUser.setEmail(emailReg.trim().toLowerCase());
                    newUser.setPasswordHash(passReg);
                    newUser.setRoleId(1);
                    newUser.setActivo(0);

                    boolean ok = userDao.register(newUser);

                    if (ok) {
                        userDao.createAdminNotification("user_approval", "Nuevo registro pendiente",
                                "El usuario " + newUser.getName() + " espera aprobación.");
                        request.setAttribute("success",
                                "¡Registro exitoso! Tu cuenta ha sido creada y está pendiente de aprobación por un Administrador.");
                        view = request.getRequestDispatcher("/signup.jsp");
                        view.forward(request, response);
                    } else {
                        request.setAttribute("error", "No se pudo crear la cuenta. ¿Quizás el correo o DNI ya existen?");
                        view = request.getRequestDispatcher("/signup.jsp");
                        view.forward(request, response);
                    }
                } catch (Exception e) {
                    String msg = e.getMessage();
                    if (msg != null && msg.contains("Duplicate")) {
                        msg = "Ese correo o DNI ya está registrado.";
                    } else {
                        msg = "Error al crear la cuenta. Por favor intenta de nuevo.";
                    }
                    request.setAttribute("error", msg);
                    view = request.getRequestDispatcher("/signup.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                break;
        }
    }
}