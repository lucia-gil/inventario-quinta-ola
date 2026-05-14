package com.quintaola.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/*")
public class SessionFilter implements Filter {

    // Rutas que NO requieren sesión
    private static final String[] RUTAS_PUBLICAS = {
            "/",
            "/index.html",
            "/index.jsp",
            "/pages/show-login.html",
            "/pages/show-signup.html",
            "/pages/catalog.html",
            "/pages/404.html",
            "/pages/403.html",
            "/pages/500.html",
            "/api/auth/login",
            "/api/auth/register",
            "/src/",
            "/img/"
    };

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest  req = (HttpServletRequest)  request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getRequestURI()
                .substring(req.getContextPath().length());

        // Si es ruta pública, dejar pasar
        for (String publica : RUTAS_PUBLICAS) {
            if (path.startsWith(publica)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Verificar sesión
        HttpSession session = req.getSession(false);
        boolean logueado = session != null
                && session.getAttribute("userId") != null;

        if (!logueado) {
            // Sin sesión → redirigir al login
            res.sendRedirect(req.getContextPath() + "/pages/show-login.html");
            return;
        }

        // Verificar acceso por rol a rutas restringidas
        String roleId = (String) session.getAttribute("roleId");

        // Solo SuperAdmin puede ver permisos
        if (path.contains("superadmin-permissions") &&
                !"role-superadmin".equals(roleId)) {
            res.sendRedirect(req.getContextPath() + "/pages/403.html");
            return;
        }

        // Solo Admin y SuperAdmin pueden ver miembros y analytics
        if ((path.contains("admin-users") || path.contains("analytics")) &&
                !roleId.equals("role-admin") && !roleId.equals("role-superadmin")) {
            res.sendRedirect(req.getContextPath() + "/pages/403.html");
            return;
        }

        // Solo encargado de depósito ve deposit-view
        if (path.contains("deposit-view") &&
                !roleId.equals("role-deposito") &&
                !roleId.equals("role-admin") &&
                !roleId.equals("role-superadmin")) {
            res.sendRedirect(req.getContextPath() + "/pages/403.html");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}