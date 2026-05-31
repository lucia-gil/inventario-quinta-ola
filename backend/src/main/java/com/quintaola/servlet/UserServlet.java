package com.quintaola.servlet;

import com.quintaola.dao.UserDAO;
import com.quintaola.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.Base64;
import java.util.List;

@WebServlet(name = "UserServlet", value = "/UserServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
        maxFileSize = 1024 * 1024 * 5,       // 5 MB máximo para el avatar
        maxRequestSize = 1024 * 1024 * 10    // 10 MB máximo por petición
)
public class UserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Validar sesión
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "lista";

        try {
            switch (action) {
                case "lista":
                    // Según tu PDF de reglas: Solo el Administrador (Rol 4) y SuperAdmin (5) ven los miembros
                    Integer roleId = (Integer) session.getAttribute("roleId");
                    if (roleId == null || roleId < 4) {
                        response.sendRedirect(request.getContextPath() + "/HomeServlet");
                        return;
                    }

                    // Cargamos todos los usuarios para la tabla
                    List<User> usuarios = userDAO.getAll();
                    request.setAttribute("usuarios", usuarios);
                    request.setAttribute("activeMenu", "members");

                    // El PDF indica que la vista se llama admin-users
                    RequestDispatcher view = request.getRequestDispatcher("admin-users.jsp");
                    view.forward(request, response);
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/DashboardServlet");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/DashboardServlet?error=Error+al+cargar+usuarios");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Validar sesión
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        String action = request.getParameter("action");
        int userId = (Integer) session.getAttribute("userId");

        if ("updateAvatar".equals(action)) {
            try {
                Part filePart = request.getPart("avatar");
                if (filePart == null || filePart.getSize() == 0) {
                    response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=No+se+selecciono+ningun+archivo");
                    return;
                }

                String contentType = filePart.getContentType();
                byte[] imageBytes;
                try (InputStream is = filePart.getInputStream()) {
                    imageBytes = is.readAllBytes();
                }

                // Mantengo tu misma lógica de conversión a Base64
                String base64Image = Base64.getEncoder().encodeToString(imageBytes);
                String avatarUrlString = "data:" + contentType + ";base64," + base64Image;

                boolean ok = userDAO.updateAvatar(userId, avatarUrlString);

                if (ok) {
                    // Si todo sale bien, redirigimos de vuelta al perfil con un mensaje de éxito
                    response.sendRedirect(request.getContextPath() + "/ProfileServlet?success=Avatar+actualizado+correctamente");
                } else {
                    response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=No+se+pudo+actualizar+el+avatar");
                }

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/ProfileServlet?error=Error+de+servidor+al+subir+imagen");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
        }
    }
}

/*package com.quintaola.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.quintaola.dao.UserDAO;
import com.quintaola.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.Base64;

@WebServlet("/api/users/*")
@MultipartConfig
public class UserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final Gson gson       = new Gson();

    private void aplicarCORS(HttpServletResponse res) {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
    }

    // ── GET /api/users/:id ─────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        aplicarCORS(res);
        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            res.setStatus(400);
            out.print("{\"error\":\"ID de usuario requerido\"}");
            return;
        }

        try {
            int userId = Integer.parseInt(pathInfo.substring(1));
            User user = userDAO.getById(userId);

            if (user != null) {
                // Quitamos el password hash por seguridad
                user.setPasswordHash(null);
                out.print(gson.toJson(user));
            } else {
                res.setStatus(404);
                out.print("{\"error\":\"Usuario no encontrado\"}");
            }
        } catch (NumberFormatException e) {
            res.setStatus(400);
            out.print("{\"error\":\"ID de usuario inválido\"}");
        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error en la base de datos: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    // ── POST /api/users/me/avatar ──────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        aplicarCORS(res);
        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo();

        if (!"/me/avatar".equals(pathInfo)) {
            res.setStatus(404);
            out.print("{\"error\":\"Ruta no encontrada\"}");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.setStatus(401);
            out.print("{\"error\":\"No autorizado. Inicie sesión.\"}");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        try {
            Part filePart = req.getPart("avatar");
            if (filePart == null || filePart.getSize() == 0) {
                res.setStatus(400);
                out.print("{\"error\":\"No se subió ningún archivo\"}");
                return;
            }

            String contentType = filePart.getContentType();
            byte[] imageBytes;
            try (InputStream is = filePart.getInputStream()) {
                imageBytes = is.readAllBytes();
            }

            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            String avatarUrlString = "data:" + contentType + ";base64," + base64Image;

            boolean ok = userDAO.updateAvatar(userId, avatarUrlString);

            if (ok) {
                JsonObject jsonResponse = new JsonObject();
                jsonResponse.addProperty("message", "Avatar actualizado");
                jsonResponse.addProperty("avatarUrl", avatarUrlString);
                out.print(gson.toJson(jsonResponse));
            } else {
                res.setStatus(500);
                out.print("{\"error\":\"No se pudo actualizar el avatar en el sistema\"}");
            }

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error de base de datos: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) {
        aplicarCORS(res);
        res.setStatus(200);
    }
}
 */