package com.quintaola.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.quintaola.dao.UserDAO;
import com.quintaola.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet("/api/auth/*")
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final Gson gson       = new Gson();

    // ── POST /api/auth/register ───────────────────────────────────
    // ── POST /api/auth/login ──────────────────────────────────────
    // ── POST /api/auth/logout ─────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo(); // "/register" | "/login" | "/logout"

        if (pathInfo == null) {
            res.setStatus(400);
            out.print("{\"error\":\"Ruta no especificada\"}");
            out.flush();
            return;
        }

        switch (pathInfo) {
            case "/register" -> handleRegister(req, res, out);
            case "/login"    -> handleLogin(req, res, out);
            case "/logout"   -> handleLogout(req, res, out);
            default -> {
                res.setStatus(404);
                out.print("{\"error\":\"Ruta no encontrada\"}");
            }
        }
        out.flush();
    }

    // ── GET /api/auth/me — obtener usuario de la sesión ──────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo();

        if ("/me".equals(pathInfo)) {
            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("userId") != null) {
                JsonObject user = new JsonObject();
                user.addProperty("userId",   (String) session.getAttribute("userId"));
                user.addProperty("userName", (String) session.getAttribute("userName"));
                user.addProperty("userEmail",(String) session.getAttribute("userEmail"));
                user.addProperty("userRole", (String) session.getAttribute("userRole"));
                user.addProperty("roleId",   (String) session.getAttribute("roleId"));
                out.print(gson.toJson(user));
            } else {
                res.setStatus(401);
                out.print("{\"error\":\"No hay sesión activa\"}");
            }
        }
        out.flush();
    }

    // ── REGISTER ──────────────────────────────────────────────────
    private void handleRegister(HttpServletRequest req,
                                HttpServletResponse res,
                                PrintWriter out) throws IOException {
        try {
            User user = gson.fromJson(req.getReader(), User.class);

            // Validaciones básicas
            if (user.getName()  == null || user.getName().isBlank() ||
                    user.getEmail() == null || user.getEmail().isBlank() ||
                    user.getDni()   == null || user.getDni().isBlank()   ||
                    user.getPasswordHash() == null || user.getPasswordHash().isBlank()) {
                res.setStatus(400);
                out.print("{\"error\":\"Todos los campos son obligatorios\"}");
                return;
            }

            if (!user.getDni().matches("\\d{8}")) {
                res.setStatus(400);
                out.print("{\"error\":\"El DNI debe tener exactamente 8 dígitos\"}");
                return;
            }

            boolean registrado = userDAO.register(user);
            if (registrado) {
                res.setStatus(201);
                out.print("{\"message\":\"Usuario registrado correctamente\"}");
            } else {
                res.setStatus(500);
                out.print("{\"error\":\"No se pudo registrar el usuario\"}");
            }

        } catch (SQLException e) {
            if (e.getMessage().contains("Duplicate entry")) {
                res.setStatus(409);
                out.print("{\"error\":\"El correo o DNI ya están registrados\"}");
            } else {
                res.setStatus(500);
                out.print("{\"error\":\"Error al registrar: " + e.getMessage() + "\"}");
            }
        }
    }

    // ── LOGIN ─────────────────────────────────────────────────────
    private void handleLogin(HttpServletRequest req,
                             HttpServletResponse res,
                             PrintWriter out) throws IOException {
        try {
            JsonObject body = gson.fromJson(req.getReader(), JsonObject.class);

            if (body == null || !body.has("email") || !body.has("password")) {
                res.setStatus(400);
                out.print("{\"error\":\"Email y contraseña son obligatorios\"}");
                return;
            }

            String email    = body.get("email").getAsString();
            String password = body.get("password").getAsString();

            User user = userDAO.login(email, password);

            if (user == null) {
                res.setStatus(401);
                out.print("{\"error\":\"Correo o contraseña incorrectos\"}");
                return;
            }

            // Crear sesión
            HttpSession session = req.getSession(true);
            session.setAttribute("userId",    user.getId());
            session.setAttribute("userName",  user.getName());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userRole",  user.getRoleName());
            session.setAttribute("roleId",    user.getRoleId());
            session.setMaxInactiveInterval(30 * 60); // 30 minutos

            // Determinar redirección según rol
            String redirect = switch (user.getRoleId()) {
                case "role-deposito"    -> "/pages/deposit-view.html";
                case "role-superadmin"  -> "/pages/superadmin-permissions.html";
                default                 -> "/pages/home.html";
            };

            JsonObject response = new JsonObject();
            response.addProperty("message",  "Login exitoso");
            response.addProperty("userId",   user.getId());
            response.addProperty("userName", user.getName());
            response.addProperty("userRole", user.getRoleName());
            response.addProperty("roleId",   user.getRoleId());
            response.addProperty("redirect", redirect);

            out.print(gson.toJson(response));

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error al iniciar sesión: " + e.getMessage() + "\"}");
        }
    }

    // ── LOGOUT ────────────────────────────────────────────────────
    private void handleLogout(HttpServletRequest req,
                              HttpServletResponse res,
                              PrintWriter out) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        out.print("{\"message\":\"Sesión cerrada correctamente\"}");
    }

    // ── OPTIONS — CORS ────────────────────────────────────────────
    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }
}