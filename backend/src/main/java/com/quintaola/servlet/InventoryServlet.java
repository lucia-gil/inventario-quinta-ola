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

/**
 * ════════════════════════════════════════════════════════════════════
 *  InventoryServlet — Controlador de la página de inventario
 * ════════════════════════════════════════════════════════════════════
 *
 *  PROPÓSITO:
 *  Listar materiales del inventario. Aplica los filtros que vengan
 *  como parámetros (búsqueda, tag, estado) y muestra solo los
 *  resultados que coinciden.
 *
 *  PATRÓN DEL CURSO:
 *  switch-case + action (Clasecita 7.3 slide 5), aunque por ahora solo
 *  tiene un case ("lista"). Cuando agreguemos "desactivar" será otro case.
 *
 *  URLs:
 *    GET /InventoryServlet                                        → lista todos
 *    GET /InventoryServlet?action=lista&q=cemento&tag=&stock=OK   → con filtros
 *
 *  Se hace el filtro aquí en Java, no en JavaScript.
 *     Leo los parámetros con request.getParameter(),
 *      itero la lista en Java y solo paso los que pasan el filtro a la vista.
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "InventoryServlet", value = "/InventoryServlet")
public class InventoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ─── 1. LEER PARÁMETRO action ───
        String action = request.getParameter("action") == null
                ? "lista"
                : request.getParameter("action");

        ItemDAO itemDao = new ItemDAO();
        RequestDispatcher view;

        switch (action) {

            // CASE "lista" → mostrar el inventario filtrado
            case "lista":
                try {
                    // 1.1. Obtener TODOS los items desde la BD
                    List<Item> todosLosItems = itemDao.getAll();

                    // 1.2. Leer parámetros de filtro (pueden ser null o "")
                    // Esto reemplaza el filter() de JavaScript que tenías antes
                    String filtroTexto = request.getParameter("q");
                    String filtroTag   = request.getParameter("tag");
                    String filtroStock = request.getParameter("stock");

                    // 1.3. Normalizar (si llega null, tratar como "")
                    if (filtroTexto == null) filtroTexto = "";
                    if (filtroTag   == null) filtroTag = "";
                    if (filtroStock == null) filtroStock = "";

                    // 1.4. Aplicar los filtros en Java
                    // Equivalente al .filter() del JS pero del lado servidor
                    List<Item> itemsFiltrados = new ArrayList<>();

                    for (Item item : todosLosItems) {
                        // Filtro 1: texto (busca en nombre y SKU)
                        boolean matchTexto = filtroTexto.isEmpty()
                                || item.getName().toLowerCase().contains(filtroTexto.toLowerCase());

                        // Filtro 2: etiqueta (busca en la lista de tags del item)
                        boolean matchTag = filtroTag.isEmpty()
                                || (item.getTags() != null && item.getTags().contains(filtroTag));

                        // Filtro 3: estado de stock
                        boolean matchStock = filtroStock.isEmpty()
                                || filtroStock.equals(item.getStatus());

                        // Si pasa los 3 filtros, lo agregamos
                        if (matchTexto && matchTag && matchStock) {
                            itemsFiltrados.add(item);
                        }
                    }

                    // 1.5. INYECTAR datos en el request para la vista (Clase 7.2 slide 49)
                    request.setAttribute("items", itemsFiltrados);
                    request.setAttribute("totalItems", todosLosItems.size());

                    // Devolvemos también los filtros aplicados para preservarlos en los inputs
                    request.setAttribute("filtroTexto", filtroTexto);
                    request.setAttribute("filtroTag", filtroTag);
                    request.setAttribute("filtroStock", filtroStock);

                    request.setAttribute("activeMenu", "inventory");

                    // 1.6. REENVIAR a la vista con forward (Clase 7.2 slide 51)
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