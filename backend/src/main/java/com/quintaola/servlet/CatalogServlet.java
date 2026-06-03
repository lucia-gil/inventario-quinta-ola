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
            // Obtenemos los materiales desde el DAO
            List<Item> listaItems = itemDao.getAll();
            request.setAttribute("items", listaItems);

            // Redirección interna hacia la vista pública
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