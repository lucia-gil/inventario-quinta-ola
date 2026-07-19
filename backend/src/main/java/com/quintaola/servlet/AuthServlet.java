package com.quintaola.servlet;

import com.quintaola.dao.PasswordResetDAO;
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
 * Maneja login, logout, registro, cambio de contraseña obligatorio
 * (contraseña temporal creada por el Superadmin) y recuperación de
 * contraseña vía correo ("Olvidé mi contraseña").
 *
 * URLs:
 * GET  /AuthServlet?action=formLogin           → muestra login.jsp
 * GET  /AuthServlet?action=formSignup          → muestra signup.jsp
 * GET  /AuthServlet?action=formChangePassword  → muestra change-password.jsp
 * GET  /AuthServlet?action=formForgotPassword  → muestra forgot-password.jsp
 * GET  /AuthServlet?action=formResetPassword   → valida token y muestra reset-password.jsp
 * GET  /AuthServlet?action=logout              → cierra sesión y redirige a login
 * POST /AuthServlet  (action=login)             → procesa credenciales
 * POST /AuthServlet  (action=signup)            → registra nuevo usuario
 * POST /AuthServlet  (action=changePassword)    → guarda la nueva contraseña (usuario logueado)
 * POST /AuthServlet  (action=forgotPassword)    → genera token y envía correo de reseteo
 * POST /AuthServlet  (action=resetPassword)     → valida token y guarda la nueva contraseña
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

            case "formChangePassword":
                // Solo accesible si hay una sesión activa (usuario ya logueado
                // con contraseña temporal pendiente de actualizar)
                HttpSession cpSession = request.getSession(false);
                if (cpSession == null || cpSession.getAttribute("userId") == null) {
                    response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                    return;
                }
                view = request.getRequestDispatcher("/change-password.jsp");
                view.forward(request, response);
                break;

            case "formForgotPassword":
                view = request.getRequestDispatcher("/forgot-password.jsp");
                view.forward(request, response);
                break;

            case "formResetPassword":
                String tokenGet = request.getParameter("token");
                if (tokenGet == null || tokenGet.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                    return;
                }
                try {
                    PasswordResetDAO resetDaoGet = new PasswordResetDAO();
                    int uidGet = resetDaoGet.validarToken(tokenGet);
                    if (uidGet == 0) {
                        request.setAttribute("error", "El enlace es inválido o ya expiró. Solicita uno nuevo.");
                        view = request.getRequestDispatcher("/forgot-password.jsp");
                        view.forward(request, response);
                        return;
                    }
                    request.setAttribute("token", tokenGet);
                    view = request.getRequestDispatcher("/reset-password.jsp");
                    view.forward(request, response);
                } catch (Exception e) {
                    request.setAttribute("error", "Ocurrió un error al validar el enlace.");
                    view = request.getRequestDispatcher("/forgot-password.jsp");
                    view.forward(request, response);
                }
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

                        // ─── Forzar cambio de contraseña si es temporal ───
                        if (user.getRequirePasswordChange() == 1) {
                            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formChangePassword");
                            return;
                        }

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

            case "changePassword":
                HttpSession cpSess = request.getSession(false);
                if (cpSess == null || cpSess.getAttribute("userId") == null) {
                    response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                    return;
                }
                try {
                    int cpUserId = (Integer) cpSess.getAttribute("userId");
                    String newPass = request.getParameter("newPassword");
                    String confirmPass = request.getParameter("confirmPassword");

                    String cpError = com.quintaola.util.PasswordValidator.getErrorMessage(newPass);
                    if (cpError != null) {
                        request.setAttribute("error", cpError);
                        view = request.getRequestDispatcher("/change-password.jsp");
                        view.forward(request, response);
                        return;
                    }
                    if (newPass == null || !newPass.equals(confirmPass)) {
                        request.setAttribute("error", "Las contraseñas no coinciden.");
                        view = request.getRequestDispatcher("/change-password.jsp");
                        view.forward(request, response);
                        return;
                    }

                    boolean ok = userDao.updatePassword(cpUserId, newPass);
                    if (ok) {
                        String roleNameCp = (String) cpSess.getAttribute("roleName");
                        String redirect = "SuperAdmin".equals(roleNameCp) ? "/RoleServlet" : "/HomeServlet";
                        response.sendRedirect(request.getContextPath() + redirect);
                    } else {
                        request.setAttribute("error", "No se pudo actualizar la contraseña.");
                        view = request.getRequestDispatcher("/change-password.jsp");
                        view.forward(request, response);
                    }
                } catch (Exception e) {
                    request.setAttribute("error", "Error interno al cambiar la contraseña.");
                    view = request.getRequestDispatcher("/change-password.jsp");
                    view.forward(request, response);
                }
                break;

            case "forgotPassword":
                try {
                    String emailForgot = request.getParameter("email");
                    if (emailForgot == null || emailForgot.trim().isEmpty()) {
                        request.setAttribute("error", "Ingresa un correo válido.");
                        view = request.getRequestDispatcher("/forgot-password.jsp");
                        view.forward(request, response);
                        return;
                    }
                    emailForgot = emailForgot.trim().toLowerCase();
                    User userForgot = userDao.getByEmail(emailForgot);

                    // Por seguridad, siempre mostramos el mismo mensaje exista o no
                    // la cuenta (evita que el form se use para adivinar correos registrados).
                    if (userForgot != null && userForgot.getActivo() == 1) {
                        PasswordResetDAO resetDao = new PasswordResetDAO();
                        String token = resetDao.generarToken(userForgot.getId());
                        try {
                            com.quintaola.util.EmailService.enviarResetPassword(
                                    userForgot.getEmail(), userForgot.getName(), token);
                        } catch (Exception emailEx) {
                            System.err.println("[AuthServlet] Email reset: " + emailEx.getMessage());
                        }
                    }

                    request.setAttribute("success",
                            "Si el correo está registrado, te enviamos un enlace para restablecer tu contraseña.");
                    view = request.getRequestDispatcher("/forgot-password.jsp");
                    view.forward(request, response);
                } catch (Exception e) {
                    request.setAttribute("error", "Ocurrió un error. Intenta de nuevo.");
                    view = request.getRequestDispatcher("/forgot-password.jsp");
                    view.forward(request, response);
                }
                break;

            case "resetPassword":
                try {
                    String tokenPost = request.getParameter("token");
                    String newPass = request.getParameter("newPassword");
                    String confirmPass = request.getParameter("confirmPassword");

                    PasswordResetDAO resetDao = new PasswordResetDAO();
                    int uid = resetDao.validarToken(tokenPost);

                    if (uid == 0) {
                        request.setAttribute("error", "El enlace es inválido o ya expiró. Solicita uno nuevo.");
                        view = request.getRequestDispatcher("/forgot-password.jsp");
                        view.forward(request, response);
                        return;
                    }

                    String rpError = com.quintaola.util.PasswordValidator.getErrorMessage(newPass);
                    if (rpError != null) {
                        request.setAttribute("error", rpError);
                        request.setAttribute("token", tokenPost);
                        view = request.getRequestDispatcher("/reset-password.jsp");
                        view.forward(request, response);
                        return;
                    }
                    if (newPass == null || !newPass.equals(confirmPass)) {
                        request.setAttribute("error", "Las contraseñas no coinciden.");
                        request.setAttribute("token", tokenPost);
                        view = request.getRequestDispatcher("/reset-password.jsp");
                        view.forward(request, response);
                        return;
                    }

                    userDao.updatePassword(uid, newPass);
                    resetDao.marcarUsado(tokenPost);

                    response.sendRedirect(request.getContextPath()
                            + "/AuthServlet?action=formLogin&success=Contraseña+actualizada.+Ya+puedes+iniciar+sesion");
                } catch (Exception e) {
                    request.setAttribute("error", "Ocurrió un error al restablecer la contraseña.");
                    view = request.getRequestDispatcher("/forgot-password.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                break;
        }
    }
}