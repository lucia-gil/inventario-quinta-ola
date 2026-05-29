package com.quintaola.servlet;

import com.quintaola.dao.NotificationDAO;
import com.quintaola.model.Notification;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/* ============================================================
   NotificationServlet
   ============================================================
   Maneja las notificaciones del usuario logueado.

   URLs:
     GET  /NotificationServlet                  -> lista del usuario
     POST /NotificationServlet (action=marcar)  -> marca una como leida
   ============================================================ */
@WebServlet(name = "NotificationServlet", value = "/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer userId = (Integer) request.getSession().getAttribute("userId");
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        // El PDF dice: SuperAdmin no tiene notificaciones, solo cambio de contrasena
        if (roleId != null && roleId == 5) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        NotificationDAO notifDao = new NotificationDAO();
        RequestDispatcher view;

        try {
            // Traer todas las notifs del usuario, ordenadas mas reciente primero
            List<Notification> notifs = notifDao.getByUserId(userId);

            request.setAttribute("notificaciones", notifs);
            request.setAttribute("activeMenu", "notifications");

            view = request.getRequestDispatcher("notifications.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar notificaciones: " + e.getMessage());
            view = request.getRequestDispatcher("notifications.jsp");
            view.forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null
                ? "" : request.getParameter("action");

        NotificationDAO notifDao = new NotificationDAO();

        switch (action) {

            case "marcar":
                try {
                    int notifId = Integer.parseInt(request.getParameter("id"));
                    notifDao.markAsRead(notifId);
                    response.sendRedirect(request.getContextPath() + "/NotificationServlet");
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath()
                            + "/NotificationServlet?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/NotificationServlet");
                break;
        }
    }
}