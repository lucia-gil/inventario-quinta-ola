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
            case "formSignup":
                // ─── Si YA hay sesión activa, no mostrar el form de auth ───
                //     Redirigimos al destino que corresponde según el rol:
                //     SuperAdmin → /RoleServlet, todos los demás → /HomeServlet.
                //     Esto evita que un usuario logueado vuelva a ver el login
                //     pegando la URL en el navegador (mejora de UX reportada por testers).
                HttpSession activeSession = request.getSession(false);
                if (activeSession != null && activeSession.getAttribute("userId") != null) {
                    String roleName = (String) activeSession.getAttribute("roleName");
                    String redirectTo = "SuperAdmin".equals(roleName)
                            ? "/RoleServlet"
                            : "/HomeServlet";
                    response.sendRedirect(request.getContextPath() + redirectTo);
                    return;
                }

                // Si no hay sesión, mostramos el form correspondiente
                if ("formLogin".equals(action)) {
                    view = request.getRequestDispatcher("/login.jsp");
                } else {
                    view = request.getRequestDispatcher("/signup.jsp");
                }
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
                        HttpSession oldSession = request.getSession(false);

                        if (oldSession != null) {
                            oldSession.invalidate();
                        }

                        HttpSession sess = request.getSession(true);

                        sess.setAttribute("userId", user.getId());
                        sess.setAttribute("userName", user.getName());
                        sess.setAttribute("userEmail", user.getEmail());
                        sess.setAttribute("roleId", user.getRoleId());
                        sess.setAttribute("roleName", user.getRoleName());
                        sess.setAttribute("avatarUrl", user.getAvatarUrl());

                        // Redirigir según rol — todos van a HomeServlet excepto SuperAdmin
                        // (SuperAdmin no tiene Home porque su perfil es exclusivo de auditoría)
                        String redirect = "SuperAdmin".equals(user.getRoleName())
                                ? "/RoleServlet"   // SuperAdmin → directo a Roles
                                : "/HomeServlet";  // Todos los demás → Inicio

                        response.sendRedirect(request.getContextPath() + redirect);
                    }
                } catch (Exception e) {
                    // Imprime el error real en la consola de la nube para ti
                    System.err.println("[SECURITY ALERT] Error en login: " + e.getMessage());
                    e.printStackTrace();

                    // Al atacante le mostramos un mensaje totalmente genérico
                    request.setAttribute("error", "Ocurrió un error interno en el servidor. Inténtelo más tarde.");
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

                    // ─── 2. Sanear nombres y apellidos (deben tener letras reales) ───
                    if (nombres == null
                            || !nombres.trim().matches("[\\p{L}\\s'\\-]{2,50}")
                            || !nombres.matches(".*\\p{L}.*")) {
                        request.setAttribute("error", "Los nombres deben contener al menos una letra. Solo se permiten letras, espacios, guiones y apóstrofes (2-50 caracteres).");
                        view = request.getRequestDispatcher("/signup.jsp");
                        view.forward(request, response);
                        return;
                    }
                    if (apellidos == null
                            || !apellidos.trim().matches("[\\p{L}\\s'\\-]{2,50}")
                            || !apellidos.matches(".*\\p{L}.*")) {
                        request.setAttribute("error", "Los apellidos deben contener al menos una letra. Solo se permiten letras, espacios, guiones y apóstrofes (2-50 caracteres).");
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

                        // ─── Email de bienvenida al nuevo usuario ───
                        try {
                            com.quintaola.util.EmailService.enviarBienvenida(
                                    newUser.getEmail(),
                                    newUser.getName()
                            );
                        } catch (Exception emailEx) {
                            // No bloqueamos el registro si falla el email
                            System.err.println("[AuthServlet] No se pudo enviar email de bienvenida: " + emailEx.getMessage());
                        }

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
                    if (msg != null && (msg.contains("Duplicate") || msg.contains("ya está registrado"))) {
                        msg = "Ese correo o DNI ya está registrado.";
                    } else {
                        // System.err para tus logs internos de la nube
                        System.err.println("[SECURITY ALERT] Error en registro: " + e.getMessage());
                        msg = "Error interno al procesar la cuenta. Por favor intente de nuevo.";
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