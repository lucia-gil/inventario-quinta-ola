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
import java.util.ArrayList;
import java.util.List;

/**
 * DashboardServlet — vista resumen.
 * Trae los datos de la BD y los inyecta en dashboard.jsp.
 * Muestra vista global para Admin/Manager/Depósito y vista personal para Solicitantes.
 */
@WebServlet(name = "DashboardServlet", value = "/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener datos de la sesión actual
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        Integer roleId = (Integer) session.getAttribute("roleId");

        TransactionDAO txDao = new TransactionDAO();
        ItemDAO itemDao = new ItemDAO();
        RequestDispatcher view;

        try {
            List<Transaction> todasTx;
            List<Transaction> pendientes = new ArrayList<>();
            List<Transaction> aprobadas = new ArrayList<>();

            // 🛡️ LÓGICA CONDICIONAL DE ROLES
            if (roleId != null && roleId == 1) {
                // ROL 1: Solicitante (Solo ve sus propias cosas)
                todasTx = txDao.getByUser(userId);

                // Filtrar pendientes y aprobadas de sus propias transacciones
                for (Transaction t : todasTx) {
                    if ("PENDING".equals(t.getStatus())) pendientes.add(t);
                    if ("APPROVED".equals(t.getStatus())) aprobadas.add(t);
                }
            } else {
                // OTROS ROLES: Admin, Aprobador, Depósito (Ven la vista global)
                todasTx = txDao.getAll();
                pendientes = txDao.getPending();
                aprobadas = txDao.getApproved();
            }

            // Datos del inventario (esto sí es igual para todos)
            List<Item> items = itemDao.getAll();
            int lowStock = 0;
            for (Item it : items) {
                if ("LOW".equals(it.getStatus())) lowStock++;
            }

            // Tomar solo las últimas 5 transacciones para mostrar en la tablita del dashboard
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