package com.quintaola.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/*")
public class SessionFilter implements Filter {

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

        for (String publica : RUTAS_PUBLICAS) {
            if (path.startsWith(publica)) {
                chain.doFilter(request, response);
                return;
            }
        }

        HttpSession session = req.getSession(false);
        boolean logueado = session != null
                && session.getAttribute("userId") != null;

        if (!logueado) {
            // Para /api/* devolver JSON 401, para HTML redirigir al login
            if (path.startsWith("/api/")) {
                res.setStatus(401);
                res.setContentType("application/json");
                res.setCharacterEncoding("UTF-8");
                res.getWriter().write("{\"error\":\"Sesión expirada. Vuelve a iniciar sesión.\"}");
                return;
            }
            res.sendRedirect(req.getContextPath() + "/pages/show-login.html");
            return;
        }

        // Ahora comparamos por roleName (más legible) en lugar de roleId numérico
        String roleName = (String) session.getAttribute("roleName");

        if (roleName == null) {
            res.sendRedirect(req.getContextPath() + "/pages/show-login.html");
            return;
        }

        // Solo SuperAdmin ve permisos
        if (path.contains("superadmin-permissions") &&
                !"SuperAdmin".equals(roleName)) {
            res.sendRedirect(req.getContextPath() + "/pages/403.html");
            return;
        }

        // Solo Administrador y SuperAdmin ven miembros y analytics
        if ((path.contains("admin-users") || path.contains("analytics")) &&
                !"Administrador".equals(roleName) && !"SuperAdmin".equals(roleName)) {
            res.sendRedirect(req.getContextPath() + "/pages/403.html");
            return;
        }

        // Member (depósito), Administrador y SuperAdmin ven deposit-view
        if (path.contains("deposit-view") &&
                !"Member".equals(roleName) &&
                !"Administrador".equals(roleName) &&
                !"SuperAdmin".equals(roleName)) {
            res.sendRedirect(req.getContextPath() + "/pages/403.html");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}