package com.quintaola.servlet;

import com.quintaola.dao.ItemDAO;
import com.quintaola.model.Item;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * InventoryServlet — listado de inventario.
 * Patrón MVC del curso (Clase 7.2 y 7.3).
 *
 * URLs:
 *   GET /InventoryServlet                  → lista todos los items
 *   GET /InventoryServlet?action=lista     → igual que arriba
 */
@WebServlet(name = "InventoryServlet", value = "/InventoryServlet")
public class InventoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null
                ? "lista"
                : request.getParameter("action");

        ItemDAO itemDao = new ItemDAO();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                try {
                    List<Item> items = itemDao.getAll();

                    request.setAttribute("items", items);
                    request.setAttribute("activeMenu", "inventory");

                    view = request.getRequestDispatcher("inventory.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error al cargar inventario: " + e.getMessage());
                    view = request.getRequestDispatcher("inventory.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/InventoryServlet");
                break;
        }
    }
}