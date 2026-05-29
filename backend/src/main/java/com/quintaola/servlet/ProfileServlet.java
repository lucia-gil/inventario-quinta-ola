package com.quintaola.servlet;

import com.quintaola.dao.UserDAO;
import com.quintaola.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * ProfileServlet — perfil del usuario logueado.
 * Patrón MVC del curso (Clase 7.2): switch-case + forward a JSP.
 *
 * URLs:
 *   GET  /ProfileServlet                          → muestra perfil (action=ver)
 *   POST /ProfileServlet (action=cambiarPassword) → cambia contraseña
 */
@WebServlet(name = "ProfileServlet", value = "/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null
                ? "ver"
                : request.getParameter("action");

        UserDAO userDao = new UserDAO();
        RequestDispatcher view;

        switch (action) {
            case "ver":
                try {
                    // Obtener ID del usuario logueado desde la sesión
                    Integer userId = (Integer) request.getSession().getAttribute("userId");
                    if (userId == null) {
                        response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                        return;
                    }

                    // Obtener datos completos desde la BD
                    User usuario = userDao.getById(userId);

                    // Inyectar en el request para la vista
                    request.setAttribute("usuario", usuario);
                    request.setAttribute("activeMenu", "profile");

                    view = request.getRequestDispatcher("profile.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error al cargar perfil: " + e.getMessage());
                    view = request.getRequestDispatcher("profile.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/ProfileServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null
                ? "" : request.getParameter("action");

        switch (action) {
            case "cambiarPassword":
                // Por ahora redirige al perfil. En el Sprint 3 implementamos el cambio real.
                response.sendRedirect(request.getContextPath()
                        + "/ProfileServlet?success=Funcionalidad+en+desarrollo");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/ProfileServlet");
                break;
        }
    }
}