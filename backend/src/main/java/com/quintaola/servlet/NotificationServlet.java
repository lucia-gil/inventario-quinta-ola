package com.quintaola.servlet;

import com.google.gson.Gson;
import com.quintaola.dao.NotificationDAO;
import com.quintaola.model.Notification;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/api/notifications")
public class NotificationServlet extends HttpServlet {

    private final NotificationDAO dao = new NotificationDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        // Manejo de CORS tal cual tus otros servlets
        String origin = req.getHeader("Origin");
        res.setHeader("Access-Control-Allow-Origin", origin != null ? origin : "http://localhost:5173");
        res.setHeader("Access-Control-Allow-Credentials", "true");
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        PrintWriter out = res.getWriter();
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            res.setStatus(401);
            out.print("{\"error\":\"No autorizado\"}");
            return;
        }

        try {
            String userId = (String) session.getAttribute("userId");
            List<Notification> alerts = dao.getByUserId(userId);
            out.print(gson.toJson(alerts));
        } catch (Exception e) {
            res.setStatus(500);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
        out.flush();
    }
}