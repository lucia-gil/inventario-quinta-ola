package com.quintaola.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/transactions/*")
public class TransactionServlet extends HttpServlet {

    private final TransactionDAO dao = new TransactionDAO();
    private final Gson gson          = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();
        String path = req.getPathInfo();

        try {
            List<Transaction> list;

            if ("/pending".equals(path)) {
                list = dao.getPending();
            } else if ("/approved".equals(path)) {
                list = dao.getApproved();
            } else if ("/me".equals(path)) {
                HttpSession session = req.getSession(false);
                String userId = (String) session.getAttribute("userId");
                list = dao.getByUser(userId);
            } else {
                list = dao.getAll();
            }

            list.forEach(t -> t.setStatus(t.getStatusFrontend()));
            out.print(gson.toJson(list));

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();

        try {
            Transaction t = gson.fromJson(req.getReader(), Transaction.class);

            HttpSession session = req.getSession(false);
            if (session != null) {
                t.setRequesterId((String) session.getAttribute("userId"));
            }

            if (t.getItemId() == null || t.getQuantity() <= 0) {
                res.setStatus(400);
                out.print("{\"error\":\"Item y cantidad son obligatorios\"}");
                out.flush();
                return;
            }

            boolean creado = dao.create(t);
            if (creado) {
                res.setStatus(201);
                out.print("{\"message\":\"Solicitud creada correctamente\"}");
            } else {
                res.setStatus(500);
                out.print("{\"error\":\"No se pudo crear la solicitud\"}");
            }

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
        out.flush();
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();
        String path = req.getPathInfo();

        try {
            if (path == null) {
                res.setStatus(400);
                out.print("{\"error\":\"Ruta no especificada\"}");
                out.flush();
                return;
            }

            String[] parts = path.split("/");
            String id     = parts[1];
            String action = parts.length > 2 ? parts[2] : "";

            HttpSession session = req.getSession(false);
            String approverId   = session != null ? (String) session.getAttribute("userId") : null;

            JsonObject body = null;
            try {
                body = gson.fromJson(req.getReader(), JsonObject.class);
            } catch (Exception ignored) {}

            String notes = (body != null && body.has("notes"))
                    ? body.get("notes").getAsString() : "";

            boolean ok = switch (action) {
                case "approve" -> dao.approve(id, approverId, notes);
                case "reject"  -> dao.reject(id, approverId, notes);
                case "deliver" -> dao.deliver(id);
                default        -> false;
            };

            if (ok) {
                out.print("{\"message\":\"Operación realizada correctamente\"}");
            } else {
                res.setStatus(404);
                out.print("{\"error\":\"No se encontró la solicitud o ya fue procesada\"}");
            }

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
        out.flush();
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }
}
