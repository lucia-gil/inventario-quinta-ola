package com.quintaola.servlet;

import com.quintaola.dao.AuditDAO;
import com.quintaola.model.AuditLog;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * ════════════════════════════════════════════════════════════════════
 * AuditServlet — Acceso a la bitácora (solo SuperAdmin)
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "AuditServlet", value = "/AuditServlet")
public class AuditServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo SuperAdmin
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        AuditDAO auditDao = new AuditDAO();
        RequestDispatcher view;

        try {
            String filtroEntidad = request.getParameter("entity");
            List<AuditLog> registros;

            if (filtroEntidad != null && !filtroEntidad.isEmpty()) {
                registros = auditDao.getByEntity(filtroEntidad);
            } else {
                registros = auditDao.getAll();
            }

            request.setAttribute("registros", registros);
            request.setAttribute("filtroEntidad", filtroEntidad);
            request.setAttribute("activeMenu", "audit");

            view = request.getRequestDispatcher("audit-list.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar la bitácora: " + e.getMessage());
            view = request.getRequestDispatcher("audit-list.jsp");
            view.forward(request, response);
        }
    }
}