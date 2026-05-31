package com.quintaola.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

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

        // 2. CONTROL DE ACCESO: Solo Manager (3), Admin (4) y SuperAdmin (5)
        Integer roleId = (Integer) session.getAttribute("roleId");
        if (roleId == null || roleId < 3) {
            // Si un Solicitante (1) o Depósito (2) intenta entrar, lo pateamos al dashboard
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
            return;
        }

        try {
            // 3. PREPARAR Y ENVIAR VISTA
            // Aquí podrías usar los DAO de Analytics que vi en tu captura (ItemsAnalyticsDAO, etc.)
            // si en el futuro decides pasarle la data cruda desde Java en lugar de usar fetch en JS.

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