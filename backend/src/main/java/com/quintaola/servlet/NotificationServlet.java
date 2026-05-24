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
            // Obtenemos el atributo de sesión de forma segura sin importar si es Integer o String
            Object userIdObj = session.getAttribute("userId");
            if (userIdObj == null) {
                res.setStatus(401);
                out.print("{\"error\":\"No autorizado\"}");
                return;
            }

            String userId = userIdObj.toString(); // Convierte a String limpiamente sin romper nada
            List<Notification> alerts = dao.getByUserId(userId);

            // Enviamos la lista convertida a JSON
            out.print(gson.toJson(alerts));

        } catch (Exception e) {
            System.out.println("ERROR EN NOTIFICATION_SERVLET: " + e.getMessage());
            e.printStackTrace();
            res.setStatus(500);
            // IMPORTANTE: Devolvemos un array vacío en caso de error extremo para que el JS no se muera
            out.print("[]");
        }
        out.flush();
    }
}