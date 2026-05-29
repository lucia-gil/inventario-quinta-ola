package com.quintaola.servlet;

import com.quintaola.dao.ItemDAO;
import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Item;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * DashboardServlet — vista resumen para Admin y Manager.
 * Trae los datos de la BD y los inyecta en dashboard.jsp.
 */
@WebServlet(name = "DashboardServlet", value = "/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        TransactionDAO txDao = new TransactionDAO();
        ItemDAO itemDao = new ItemDAO();
        RequestDispatcher view;

        try {
            // Datos a inyectar
            List<Transaction> todasTx = txDao.getAll();
            List<Transaction> pendientes = txDao.getPending();
            List<Transaction> aprobadas = txDao.getApproved();
            List<Item> items = itemDao.getAll();

            // Contar items con stock bajo
            int lowStock = 0;
            for (Item it : items) {
                if ("LOW".equals(it.getStatus())) lowStock++;
            }

            // Tomar solo las últimas 5 transacciones para mostrar
            List<Transaction> ultimasTx = todasTx.size() > 5
                    ? todasTx.subList(0, 5)
                    : todasTx;

            // Inyectar en el request
            request.setAttribute("totalItems",     items.size());
            request.setAttribute("totalLowStock",  lowStock);
            request.setAttribute("totalPendientes", pendientes.size());
            request.setAttribute("totalAprobadas", aprobadas.size());
            request.setAttribute("ultimasTransacciones", ultimasTx);
            request.setAttribute("activeMenu",     "dashboard");

            view = request.getRequestDispatcher("dashboard.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar dashboard: " + e.getMessage());
            view = request.getRequestDispatcher("dashboard.jsp");
            view.forward(request, response);
        }
    }
}