package com.quintaola.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;

/**
 * ════════════════════════════════════════════════════════════════════
 * SessionFilter — Protección global de rutas
 * ════════════════════════════════════════════════════════════════════
 *
 * Reglas:
 *   1. Forwards internos de Tomcat (error handler): pasan sin tocar.
 *   2. Rutas públicas (login, signup, css/js/img): pasan sin sesión.
 *   3. JSPs inexistentes sin sesión: devuelven 404 (no login).
 *   4. Recursos protegidos existentes sin sesión: redirigen a login.
 *   5. Rutas restringidas a roles: muestran 403 si no se cumple el rol.
 *
 * ════════════════════════════════════════════════════════════════════
 */
@WebFilter("/*")
public class SessionFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // ─── 0. Forwards internos de Tomcat (error pages, includes) ───
        if (req.getAttribute("jakarta.servlet.error.status_code") != null
                || req.getAttribute("jakarta.servlet.error.exception") != null
                || !DispatcherType.REQUEST.equals(req.getDispatcherType())) {
            chain.doFilter(request, response);
            return;
        }

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // ─── 1. Rutas públicas ───
        if (esRutaPublica(path)) {
            chain.doFilter(request, response);
            return;
        }

        // ─── 2. Validar sesión ───
        HttpSession session = req.getSession(false);
        String roleName = (session != null)
                ? (String) session.getAttribute("roleName")
                : null;

        if (roleName == null) {
            // Si pidió una JSP que NO existe, devolver 404 (no login).
            // Si pidió un recurso existente, redirigir a login.
            if (path.endsWith(".jsp")) {
                String realPath = req.getServletContext().getRealPath(path);
                if (realPath == null || !new File(realPath).exists()) {
                    res.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
            }
            res.sendRedirect(req.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        // ─── 3. Validaciones por rol ───
        if (path.startsWith("/PermissionServlet") && !"SuperAdmin".equals(roleName)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (path.startsWith("/RoleServlet") && !"SuperAdmin".equals(roleName)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (path.startsWith("/AuditServlet") && !"SuperAdmin".equals(roleName)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        if (path.startsWith("/UserServlet") &&
                !"Administrador".equals(roleName) && !"SuperAdmin".equals(roleName)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean esRutaPublica(String path) {
        return path.equals("/")
                || path.equals("/index.jsp")
                || path.equals("/AuthServlet")
                || path.startsWith("/AuthServlet?")
                || path.equals("/CatalogServlet")
                || path.startsWith("/CatalogServlet?")
                || path.equals("/catalog.jsp")
                || path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/img/")
                || path.startsWith("/uploads/")
                || path.equals("/favicon.ico")
                || path.equals("/login.jsp")
                || path.equals("/signup.jsp")
                || path.equals("/403.jsp")
                || path.equals("/404.jsp")
                || path.equals("/500.jsp");
    }
}