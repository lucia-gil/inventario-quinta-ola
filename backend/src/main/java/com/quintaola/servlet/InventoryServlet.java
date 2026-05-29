package com.quintaola.servlet;

import com.quintaola.dao.ItemDAO;
import com.quintaola.model.Item;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "InventoryServlet", value = "/InventoryServlet")
public class InventoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ─── 0. SEGURIDAD: Validar sesión activa ───
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        // ─── 1. LEER PARÁMETRO action ───
        String action = request.getParameter("action") == null
                ? "lista"
                : request.getParameter("action");

        ItemDAO itemDao = new ItemDAO();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                try {
                    List<Item> todosLosItems = itemDao.getAll();

                    String filtroTexto = request.getParameter("q");
                    String filtroTag   = request.getParameter("tag");
                    String filtroStock = request.getParameter("stock");

                    if (filtroTexto == null) filtroTexto = "";
                    if (filtroTag   == null) filtroTag = "";
                    if (filtroStock == null) filtroStock = "";

                    List<Item> itemsFiltrados = new ArrayList<>();

                    for (Item item : todosLosItems) {
                        // PREVENCIÓN DE NULL: Evita el error 500 si un item no tiene nombre en la BD
                        String itemName = item.getName() != null ? item.getName().toLowerCase() : "";

                        boolean matchTexto = filtroTexto.isEmpty() || itemName.contains(filtroTexto.toLowerCase());

                        boolean matchTag = filtroTag.isEmpty()
                                || (item.getTags() != null && item.getTags().contains(filtroTag));

                        boolean matchStock = filtroStock.isEmpty()
                                || filtroStock.equals(item.getStatus());

                        if (matchTexto && matchTag && matchStock) {
                            itemsFiltrados.add(item);
                        }
                    }

                    request.setAttribute("items", itemsFiltrados);
                    request.setAttribute("totalItems", todosLosItems.size());
                    request.setAttribute("filtroTexto", filtroTexto);
                    request.setAttribute("filtroTag", filtroTag);
                    request.setAttribute("filtroStock", filtroStock);
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