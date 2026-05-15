package com.quintaola.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.quintaola.dao.ItemDAO;
import com.quintaola.model.Item;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/items/*")
public class ItemServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final Gson gson = new Gson();

    // ── GET /api/items ────────────────────────────────────────────
    // ── GET /api/items/admin ──────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo(); // null o "/admin"

        try {
            List<Item> items = (pathInfo != null && pathInfo.equals("/admin"))
                    ? itemDAO.getAllAdmin()
                    : itemDAO.getAll();

            // Traducir status a español antes de mandar al frontend
            items.forEach(item -> item.getStatusName());

            out.print(gson.toJson(items));

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error al obtener materiales: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    // ── POST /api/items ───────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();

        try {
            // Leer el JSON que manda el frontend
            Item item = gson.fromJson(req.getReader(), Item.class);

            if (item.getName() == null || item.getName().isBlank()) {
                res.setStatus(400);
                out.print("{\"error\":\"El nombre del material es obligatorio\"}");
                out.flush();
                return;
            }

            boolean creado = itemDAO.create(item);

            if (creado) {
                res.setStatus(201);
                out.print("{\"message\":\"Material creado correctamente\"}");
            } else {
                res.setStatus(500);
                out.print("{\"error\":\"No se pudo crear el material\"}");
            }

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error al crear material: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    // ── PUT /api/items/{id} ───────────────────────────────────────
    // ── PUT /api/items/{id}/disable ───────────────────────────────
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo(); // "/uuid" o "/uuid/disable"

        try {
            if (pathInfo == null) {
                res.setStatus(400);
                out.print("{\"error\":\"ID requerido\"}");
                out.flush();
                return;
            }

            String[] parts = pathInfo.split("/");
            // parts[0] = "", parts[1] = id, parts[2] = "disable" (opcional)

            String id = parts[1];

            // Deshabilitar ítem
            if (parts.length == 3 && parts[2].equals("disable")) {
                boolean deshabilitado = itemDAO.disable(id);
                if (deshabilitado) {
                    out.print("{\"message\":\"Material deshabilitado correctamente\"}");
                } else {
                    res.setStatus(404);
                    out.print("{\"error\":\"Material no encontrado\"}");
                }
                out.flush();
                return;
            }

            // Actualizar ítem
            Item item = gson.fromJson(req.getReader(), Item.class);
            item.setId(id);

            boolean actualizado = itemDAO.update(item);
            if (actualizado) {
                out.print("{\"message\":\"Material actualizado correctamente\"}");
            } else {
                res.setStatus(404);
                out.print("{\"error\":\"Material no encontrado\"}");
            }

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error al actualizar: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    // ── OPTIONS — para CORS ───────────────────────────────────────
    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }
}