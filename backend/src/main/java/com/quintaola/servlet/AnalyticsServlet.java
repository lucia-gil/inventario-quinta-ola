package com.quintaola.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import com.quintaola.dao.SimpleAnalyticsDAO;

@WebServlet(name = "AnalyticsServlet", value = "/AnalyticsServlet")
public class AnalyticsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. SEGURIDAD: Validar que exista una sesión activa
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        // 2. CONTROL DE ACCESO: Solo Manager (3) y Admin (4).
        //    SuperAdmin (5) NO consume analíticas (es controlador, no operador).
        //    Viewer (1) y Member (2) tampoco entran aquí.
        Integer roleId = (Integer) session.getAttribute("roleId");
        if (roleId == null || (roleId != 3 && roleId != 4)) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        try {
            // 3. PREPARAR Y ENVIAR VISTA
            // Aquí podrías usar los DAO de Analytics que vi en tu captura
            // (ItemsAnalyticsDAO, etc.)
            // si en el futuro decides pasarle la data cruda desde Java en lugar de usar
            // fetch en JS.

            SimpleAnalyticsDAO analyticsDAO = new SimpleAnalyticsDAO();

            List<String> tags_item_name = new ArrayList<>();
            List<Integer> tags_cantidad = new ArrayList<>();
            analyticsDAO.getItemTagDistribution(tags_item_name, tags_cantidad);

            List<Integer> type_in_cantidad = new ArrayList<>();
            List<Integer> type_out_cantidad = new ArrayList<>();
            analyticsDAO.getTransactionsType(type_in_cantidad, type_out_cantidad);

            List<Integer> status_completed_cantidad = new ArrayList<>();
            List<Integer> status_pending_cantidad = new ArrayList<>();
            List<Integer> status_rejected_cantidad = new ArrayList<>();
            analyticsDAO.getTransactionsStatus(
                    status_completed_cantidad,
                    status_pending_cantidad,
                    status_rejected_cantidad);

            request.setAttribute("item_name", tags_item_name.toString());
            request.setAttribute("cantidad", tags_cantidad.toString());
            request.setAttribute("in", type_in_cantidad.toString());
            request.setAttribute("out", type_out_cantidad.toString());
            request.setAttribute("completed", status_completed_cantidad.toString());
            request.setAttribute("pending", status_pending_cantidad.toString());
            request.setAttribute("rejected", status_rejected_cantidad.toString());

            request.setAttribute("activeMenu", "dashboard"); // Mantiene iluminada la pestaña Dashboard
            RequestDispatcher view = request.getRequestDispatcher("analytics.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/DashboardServlet?error=Error+al+cargar+analiticas");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // En principio, la vista de analíticas es de solo lectura (GET).
        // Si no tienes formularios en esa vista, redirigimos el POST por seguridad.
        doGet(request, response);
    }
}