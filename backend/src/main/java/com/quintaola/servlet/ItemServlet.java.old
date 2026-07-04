package com.quintaola.servlet;

import com.google.gson.Gson;
import com.quintaola.dao.ItemDAO;
import com.quintaola.model.Item;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/items/*")
public class ItemServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final Gson gson       = new Gson();

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/inventorydb";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "lucia1234";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Access-Control-Allow-Origin", "*");

        PrintWriter out = res.getWriter();
        String pathInfo = req.getPathInfo();

        try {
            List<Item> items = (pathInfo != null && pathInfo.equals("/admin"))
                    ? itemDAO.getAllAdmin()
                    : itemDAO.getAll();

            items.forEach(item -> item.setStatus(item.getStatusFrontend()));
            out.print(gson.toJson(items));

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error al obtener materiales: " + e.getMessage() + "\"}");
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
            Item item = gson.fromJson(req.getReader(), Item.class);

            if (item.getName() == null || item.getName().isBlank()) {
                res.setStatus(400);
                out.print("{\"error\":\"El nombre del material es obligatorio\"}");
                out.flush();
                return;
            }

            // La BD genera el ID. create() devuelve el ID nuevo (0 si falló).
            int newId = itemDAO.create(item);

            if (newId > 0) {
                if (item.getCategory() != null && !item.getCategory().isBlank()) {
                    guardarRelacionTag(newId, item.getCategory());
                }
                res.setStatus(201);
                out.print("{\"message\":\"Material creado correctamente\",\"id\":" + newId + "}");
            } else {
                res.setStatus(500);
                out.print("{\"error\":\"No se pudo crear el material\"}");
            }

        } catch (Exception e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error al crear material: " + e.getMessage() + "\"}");
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
        String pathInfo = req.getPathInfo();

        try {
            if (pathInfo == null) {
                res.setStatus(400);
                out.print("{\"error\":\"ID requerido\"}");
                out.flush();
                return;
            }

            String[] parts = pathInfo.split("/");
            int id = Integer.parseInt(parts[1]);

            // Disable
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

            // Update
            Item item = gson.fromJson(req.getReader(), Item.class);
            item.setId(id);

            boolean actualizado = itemDAO.update(item);
            if (actualizado) {
                if (item.getCategory() != null && !item.getCategory().isBlank()) {
                    guardarRelacionTag(id, item.getCategory());
                }
                out.print("{\"message\":\"Material actualizado correctamente\"}");
            } else {
                res.setStatus(404);
                out.print("{\"error\":\"Material no encontrado\"}");
            }

        } catch (NumberFormatException e) {
            res.setStatus(400);
            out.print("{\"error\":\"ID inválido\"}");
        } catch (Exception e) {
            res.setStatus(500);
            out.print("{\"error\":\"Error al actualizar: " + e.getMessage() + "\"}");
        }
        out.flush();
    }

    private void guardarRelacionTag(int itemId, String categoryName) {
        String selectTagSql = "SELECT id FROM tags WHERE name = ?";
        String deleteOldSql = "DELETE FROM item_tags WHERE item_id = ?";
        String insertTagSql = "INSERT INTO item_tags (item_id, tag_id) VALUES (?, ?)";

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            int tagId = 0;
            try (PreparedStatement ps = conn.prepareStatement(selectTagSql)) {
                ps.setString(1, categoryName);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        tagId = rs.getInt("id");
                    }
                }
            }

            if (tagId > 0) {
                try (PreparedStatement psDelete = conn.prepareStatement(deleteOldSql)) {
                    psDelete.setInt(1, itemId);
                    psDelete.executeUpdate();
                }
                try (PreparedStatement psInsert = conn.prepareStatement(insertTagSql)) {
                    psInsert.setInt(1, itemId);
                    psInsert.setInt(2, tagId);
                    psInsert.executeUpdate();
                    System.out.println("ÉXITO: Relación guardada en item_tags para item: " + itemId + " con tag: " + tagId);
                }
            } else {
                System.out.println("⚠️ ALERTA: No se encontró tag con nombre: '" + categoryName + "'");
            }
        } catch (SQLException e) {
            System.err.println("ERROR SQL en guardarRelacionTag: " + e.getMessage());
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");
        res.setStatus(200);
    }
}