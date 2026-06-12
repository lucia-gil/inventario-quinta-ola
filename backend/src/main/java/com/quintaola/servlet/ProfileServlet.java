package com.quintaola.servlet;

import com.quintaola.dao.UserDAO;
import com.quintaola.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;

/**
 * ════════════════════════════════════════════════════════════════════
 * ProfileServlet — Controlador de la página "Mi Perfil"
 * ════════════════════════════════════════════════════════════════════
 *
 * PROPOSITO:
 * Este servlet es el "controlador" en el patrón MVC
 * Su trabajo es:
 * 1. Recibir la petición del navegador cuando el usuario quiere ver su perfil
 * 2. Pedirle al UserDAO los datos del usuario logueado
 * 3. Pasar esos datos al profile.jsp mediante request.setAttribute()
 * 4. Reenviar la ejecución al JSP con RequestDispatcher.forward()
 *
 * PATRÓN DEL CURSO:
 * Usa switch-case con parámetro "action".
 * Esto permite que UN solo servlet maneje varias operaciones.
 *
 * URLs que escucha:
 * GET  /ProfileServlet                          → muestra perfil
 * POST /ProfileServlet (action=cambiarPassword) → cambia contraseña
 * POST /ProfileServlet (action=uploadAvatar)    → sube foto perfil
 *
 * El usuario lo sacamos de la SESIÓN. AuthServlet guardó el userId al hacer login,
 * y aquí lo leo con session.getAttribute("userId").
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "ProfileServlet", value = "/ProfileServlet")
// ¡MUY IMPORTANTE PARA SUBIR IMÁGENES (Sprint Actual)!
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 2,       // 2 MB máximo por foto
        maxRequestSize = 1024 * 1024 * 5     // 5 MB máximo por petición
)
public class ProfileServlet extends HttpServlet {

    /* ────────────────────────────────────────────────────────────────
     * doGet: se ejecuta cuando el navegador hace GET /ProfileServlet
     * Maneja: ver perfil (default) o cualquier futura acción GET
     * ──────────────────────────────────────────────────────────────── */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ─── 1. LEER PARÁMETRO action ───
        String action = request.getParameter("action") == null
                ? "ver"
                : request.getParameter("action");

        // ─── 2. INSTANCIAR EL DAO ───
        UserDAO userDao = new UserDAO();
        RequestDispatcher view;

        // ─── 3. ENRUTAR SEGÚN LA ACCIÓN ───
        switch (action) {

            case "ver":
                try {
                    // 3.1. Obtener el ID del usuario logueado desde la SESIÓN
                    Integer userId = (Integer) request.getSession().getAttribute("userId");

                    // 3.2. Si no hay sesión válida, mandar al login
                    if (userId == null) {
                        response.sendRedirect(request.getContextPath()
                                + "/AuthServlet?action=formLogin");
                        return;
                    }

                    // 3.3. Pedirle al DAO los datos completos del usuario
                    User usuario = userDao.getById(userId);

                    // 3.4. INYECTAR los datos en el request para la vista
                    request.setAttribute("usuario", usuario);
                    request.setAttribute("activeMenu", "profile");

                    // 3.5. REDIRIGIR al JSP con forward
                    view = request.getRequestDispatcher("profile.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    // Si algo falla, se va a mostrar el error en la misma vista
                    request.setAttribute("error", "Error al cargar perfil: " + e.getMessage());
                    view = request.getRequestDispatcher("profile.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/ProfileServlet");
                break;
        }
    }

    /* ────────────────────────────────────────────────────────────────
     * doPost: se ejecuta cuando llega un formulario POST
     * ──────────────────────────────────────────────────────────────── */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar UTF-8 ANTES de leer parámetros (Clase 7.3 pagina 16)
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String action = request.getParameter("action") == null
                ? "" : request.getParameter("action");

        try {
            switch (action) {
                case "cambiarPassword":
                    procesarPassword(request, response, userId);
                    break;

                case "uploadAvatar":
                    procesarAvatar(request, response, userId);
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/ProfileServlet");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=Ocurrió+un+error+al+procesar+tu+solicitud");
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // MÉTODO PARA SUBIR Y GUARDAR LA IMAGEN
    // ────────────────────────────────────────────────────────────────────────
    private void procesarAvatar(HttpServletRequest request, HttpServletResponse response, int userId) throws Exception {
        Part filePart = request.getPart("avatarFile");

        // 1. Validar que enviaron un archivo
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=No+seleccionaste+ninguna+imagen");
            return;
        }

        // 2. Validar extensión (seguridad básica)
        String fileName = filePart.getSubmittedFileName();
        String ext = "";
        if (fileName != null && fileName.contains(".")) {
            ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
        }

        if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".webp")) {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=Formato+inválido.+Usa+JPG,+PNG+o+WEBP");
            return;
        }

        // 3. Crear carpeta si no existe en el servidor (uploads/avatars)
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "avatars";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // 4. Generar nombre único para la foto
        String newFileName = "avatar_" + userId + "_" + System.currentTimeMillis() + ext;
        String filePath = uploadPath + File.separator + newFileName;
        filePart.write(filePath);

        // 5. Guardar la ruta relativa en la BD usando UserDAO
        String avatarUrlDb = "/uploads/avatars/" + newFileName;
        UserDAO userDao = new UserDAO();
        boolean ok = userDao.updateAvatar(userId, avatarUrlDb);

        if (ok) {
            // Actualizar la sesión para que cambie en todo el sistema (navbar)
            request.getSession().setAttribute("avatarUrl", avatarUrlDb);
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?success=Foto+de+perfil+actualizada");
        } else {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=Error+al+guardar+en+la+base+de+datos");
        }
    }

    // ────────────────────────────────────────────────────────────────────────
    // MÉTODO PARA CAMBIAR CONTRASEÑA
    // ────────────────────────────────────────────────────────────────────────
    // ────────────────────────────────────────────────────────────────────────
    // MÉTODO PARA CAMBIAR CONTRASEÑA
    // ────────────────────────────────────────────────────────────────────────
    private void procesarPassword(HttpServletRequest request, HttpServletResponse response, int userId) throws Exception {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword     = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // ─── 1. Validar política de contraseñas para la nueva ───
        String passError = com.quintaola.util.PasswordValidator.getErrorMessage(newPassword);
        if (passError != null) {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=" + passError.replace(" ", "+"));
            return;
        }

        // ─── 2. Validar que las nuevas coincidan ───
        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=Las+contraseñas+nuevas+no+coinciden");
            return;
        }

        // ─── 3. Validar que la nueva sea distinta a la actual ───
        if (newPassword.equals(currentPassword)) {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=La+nueva+contraseña+debe+ser+distinta+a+la+actual");
            return;
        }

        UserDAO userDao = new UserDAO();
        User user = userDao.getById(userId);

        // ─── 4. Verificar contraseña actual con BCrypt ───
        if (!org.mindrot.jbcrypt.BCrypt.checkpw(currentPassword, user.getPasswordHash())) {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=La+contraseña+actual+es+incorrecta");
            return;
        }

        // ─── 5. Guardar nueva contraseña ───
        boolean ok = userDao.updatePassword(userId, newPassword);

        if (ok) {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?success=Contraseña+cambiada+con+éxito");
        } else {
            response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=No+se+pudo+cambiar+la+contraseña");
        }
    }
}