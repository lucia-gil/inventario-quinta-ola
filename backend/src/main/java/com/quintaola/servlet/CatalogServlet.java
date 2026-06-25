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
 * ════════════════════════════════════════════════════════════════════
 * CatalogServlet — Vitrina Pública de Productos (Accesible sin Login)
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "CatalogServlet", value = "/CatalogServlet")
public class CatalogServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // El catálogo es de acceso público (Filtrado permitido en SessionFilter)
        ItemDAO itemDao = new ItemDAO();

        try {
            // 1. Obtenemos todos los materiales desde el DAO
            List<Item> listaCompleta = itemDao.getAll();

            // ════════════ LÓGICA DE PAGINACIÓN ════════════
            int pageSize = 12; // Cantidad de productos a mostrar por página
            int paginaActual = 1; // Página por defecto

            // Capturamos el parámetro "page" de la URL (ej. CatalogServlet?page=2)
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    paginaActual = Integer.parseInt(pageParam);
                } catch (NumberFormatException e) {
                    paginaActual = 1; // Si el usuario pone letras en la URL, lo devolvemos a la 1
                }
            }

            int totalItems = listaCompleta.size();
            // Calculamos el total de páginas necesarias
            int totalPaginas = (int) Math.ceil((double) totalItems / pageSize);

            // Validaciones de seguridad para la página
            if (paginaActual < 1) paginaActual = 1;
            if (paginaActual > totalPaginas && totalPaginas > 0) paginaActual = totalPaginas;

            // Calculamos desde dónde y hasta dónde cortar la lista
            int startIndex = (paginaActual - 1) * pageSize;
            int endIndex = Math.min(startIndex + pageSize, totalItems);

            // Cortamos la lista usando subList
            List<Item> itemsPaginados = listaCompleta.subList(startIndex, endIndex);
            // ══════════════════════════════════════════════

            // 2. Enviamos la sub-lista y las variables de paginación al JSP
            request.setAttribute("items", itemsPaginados);
            request.setAttribute("paginaActual", paginaActual);
            request.setAttribute("totalPaginas", totalPaginas);

            // 3. Redirección interna hacia la vista pública
            RequestDispatcher view = request.getRequestDispatcher("catalog.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            // Si ocurre algún error imprevisto, registramos en consola y resguardamos en el index
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}