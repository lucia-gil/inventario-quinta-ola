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

    // Constante: items por página
    private static final int PAGE_SIZE = 8;

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
                    String filtroTexto = request.getParameter("q");
                    String filtroTag   = request.getParameter("tag");
                    String filtroStock = request.getParameter("stock");

                    if (filtroTexto == null) filtroTexto = "";
                    if (filtroTag   == null) filtroTag = "";
                    if (filtroStock == null) filtroStock = "";

                    // "Desactivados" es una fuente de datos distinta (activo=0),
                    // no un valor del enum status (OK/LOW/UNAVAILABLE), así que
                    // se resuelve aparte en vez de filtrar sobre getAll().
                    boolean filtrandoInactivos = "INACTIVE".equals(filtroStock);

                    List<Item> todosLosItems = filtrandoInactivos
                            ? itemDao.getAllInactive()
                            : itemDao.getAll();

                    // ─── 2. FILTRADO ───
                    List<Item> itemsFiltrados = new ArrayList<>();

                    for (Item item : todosLosItems) {
                        String itemName = item.getName() != null ? item.getName().toLowerCase() : "";

                        boolean matchTexto = filtroTexto.isEmpty()
                                || itemName.contains(filtroTexto.toLowerCase());

                        boolean matchTag = filtroTag.isEmpty()
                                || (item.getTags() != null && item.getTags().contains(filtroTag));

                        // Si el filtro es "INACTIVE", todosLosItems ya viene
                        // pre-filtrado desde getAllInactive() — no hay status
                        // de stock que comparar en ese caso.
                        boolean matchStock = filtrandoInactivos
                                || filtroStock.isEmpty()
                                || filtroStock.equals(item.getStatus());

                        if (matchTexto && matchTag && matchStock) {
                            itemsFiltrados.add(item);
                        }
                    }

                    // ─── 3. PAGINACIÓN ───
                    int totalFiltrados = itemsFiltrados.size();
                    int totalPages = (int) Math.ceil((double) totalFiltrados / PAGE_SIZE);
                    if (totalPages < 1) totalPages = 1;

                    int currentPage = 1;
                    String pageParam = request.getParameter("page");
                    if (pageParam != null && !pageParam.trim().isEmpty()) {
                        try {
                            currentPage = Integer.parseInt(pageParam);
                        } catch (NumberFormatException e) {
                            currentPage = 1;
                        }
                    }
                    if (currentPage < 1) currentPage = 1;
                    if (currentPage > totalPages) currentPage = totalPages;

                    int start = (currentPage - 1) * PAGE_SIZE;
                    int end   = Math.min(start + PAGE_SIZE, totalFiltrados);
                    List<Item> itemsPaginados = totalFiltrados > 0
                            ? itemsFiltrados.subList(start, end)
                            : itemsFiltrados;

                    // ─── 4. ENVIAR A LA VISTA ───
                    request.setAttribute("items",          itemsPaginados);
                    request.setAttribute("totalFiltrados", totalFiltrados);
                    request.setAttribute("totalItems",     todosLosItems.size());
                    request.setAttribute("filtroTexto",    filtroTexto);
                    request.setAttribute("filtroTag",      filtroTag);
                    request.setAttribute("filtroStock",    filtroStock);
                    request.setAttribute("currentPage",    currentPage);
                    request.setAttribute("totalPages",     totalPages);
                    request.setAttribute("pageSize",       PAGE_SIZE);

                    // Tags reales para el select de filtro
                    List<String> tagsDisponibles = new ArrayList<>();
                    try { tagsDisponibles = itemDao.getAllTagNames(); } catch (Exception ignored) {}
                    request.setAttribute("tagsDisponibles", tagsDisponibles);

                    request.setAttribute("activeMenu",     "inventory");

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