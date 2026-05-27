package com.quintaola.servlet;

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