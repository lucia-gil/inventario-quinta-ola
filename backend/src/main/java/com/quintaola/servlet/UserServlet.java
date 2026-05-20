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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.Base64;

@WebServlet("/api/users/*")
@MultipartConfig // Permite recibir formularios con archivos (FormData)
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
    // Sirve para refrescar los datos del perfil (incluido el avatar)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        aplicarCORS(res);
        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo(); // "/id-del-usuario"

        if (pathInfo == null || pathInfo.equals("/")) {
            res.setStatus(400);
            out.print("{\"error\":\"ID de usuario requerido\"}");
            return;
        }

        String userId = pathInfo.substring(1);

        try {
            User user = userDAO.getById(userId);
            if (user != null) {
                // Quitamos el password hash por seguridad antes de enviarlo al cliente
                user.setPasswordHash(null);
                out.print(gson.toJson(user));
            } else {
                res.setStatus(404);
                out.print("{\"error\":\"Usuario no encontrado\"}");
            }
        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error en la base de datos: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    // ── POST /api/users/me/avatar ──────────────────────────────────
    // Recibe el archivo seleccionado del frontend, lo convierte a texto y lo guarda
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        aplicarCORS(res);
        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo(); // "/me/avatar"

        if (!"/me/avatar".equals(pathInfo)) {
            res.setStatus(404);
            out.print("{\"error\":\"Ruta no encontrada\"}");
            return;
        }

        // Verificar sesión activa
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.setStatus(401);
            out.print("{\"error\":\"No autorizado. Inicie sesión.\"}");
            return;
        }

        String userId = (String) session.getAttribute("userId");

        try {
            // Obtenemos el archivo enviado en el campo 'avatar'
            Part filePart = req.getPart("avatar");
            if (filePart == null || filePart.getSize() == 0) {
                res.setStatus(400);
                out.print("{\"error\":\"No se subió ningún archivo\"}");
                return;
            }

            // Convertir la imagen cargada a una cadena Base64 legible por el navegador
            String contentType = filePart.getContentType(); // image/png, image/jpeg
            byte[] imageBytes;
            try (InputStream is = filePart.getInputStream()) {
                imageBytes = is.readAllBytes();
            }

            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            String avatarUrlString = "data:" + contentType + ";base64," + base64Image;

            // Guardar en la base de datos usando el DAO
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