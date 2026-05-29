package com.quintaola.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Filtro de sesión: protege rutas que requieren autenticación.
 * Adaptado al patrón JSP del curso (rutas tipo /AuthServlet, /DashboardServlet).
 */
@WebFilter("/*")
public class SessionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // ─── URLs públicas que no requieren login ───
        if (path.equals("/")                          ||
                path.equals("/AuthServlet")               ||  // login form
                path.startsWith("/AuthServlet?")          ||
                path.startsWith("/css/")                  ||
                path.startsWith("/js/")                   ||
                path.startsWith("/img/")                  ||
                path.equals("/login.jsp")                 ||
                path.equals("/signup.jsp")) {
            chain.doFilter(request, response);
            return;
        }

        // ─── Validar sesión ───
        HttpSession session = req.getSession(false);
        String roleName = (session != null)
                ? (String) session.getAttribute("roleName")
                : null;

        if (roleName == null) {
            res.sendRedirect(req.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        // ─── Validaciones por rol ───
        if (path.startsWith("/PermissionServlet") && !"SuperAdmin".equals(roleName)) {
            res.sendRedirect(req.getContextPath() + "/HomeServlet");
            return;
        }

        if (path.startsWith("/RoleServlet") && !"SuperAdmin".equals(roleName)) {
            res.sendRedirect(req.getContextPath() + "/HomeServlet");
            return;
        }

        if (path.startsWith("/AuditServlet") && !"SuperAdmin".equals(roleName)) {
            res.sendRedirect(req.getContextPath() + "/HomeServlet");
            return;
        }

        if (path.startsWith("/UserServlet") &&
                !"Administrador".equals(roleName) && !"SuperAdmin".equals(roleName)) {
            res.sendRedirect(req.getContextPath() + "/HomeServlet");
            return;
        }

        chain.doFilter(request, response);
    }
}