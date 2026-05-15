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
            res.sendRedirect(req.getContextPath() + "/pages/show-login.html");
            return;
        }

        String roleId = (String) session.getAttribute("roleId");

        if (path.contains("superadmin-permissions") &&
                !"role-superadmin".equals(roleId)) {
            res.sendRedirect(req.getContextPath() + "/pages/403.html");
            return;
        }

        if ((path.contains("admin-users") || path.contains("analytics")) &&
                !roleId.equals("role-admin") && !roleId.equals("role-superadmin")) {
            res.sendRedirect(req.getContextPath() + "/pages/403.html");
            return;
        }

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