package com.quintaola.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;

/**
 * ════════════════════════════════════════════════════════════════════
 * SessionFilter — Protección global por sesión + rol
 * ════════════════════════════════════════════════════════════════════
 *
 * Política de SuperAdmin (estricta):
 *   El SA es controlador, no operador. Solo accede a:
 *     - Roles (RoleServlet, roles-list.jsp)
 *     - Auditoría (AuditServlet, audit-list.jsp)
 *     - Permisos (PermissionServlet, permissions.jsp)
 *     - Su perfil, notificaciones
 *
 *   Sobre UserServlet:
 *     El SA puede usar UserServlet vía POST (cambiar rol, desactivar,
 *     etc. desde roles-list.jsp) y vía GET solo para action=formCrear,
 *     pero NO puede ver admin-users.jsp ni GET /UserServlet directos.
 *
 * Política de Administrador:
 *   Operativo: gestiona usuarios, items, analytics, aprueba solicitudes.
 *
 * Política de Manager:
 *   Solicita y aprueba solicitudes (no las suyas).
 *
 * Política de Member:
 *   Despacha y gestiona items. NO solicita.
 *
 * Política de Viewer:
 *   Solo solicita y ve su historial.
 * ════════════════════════════════════════════════════════════════════
 */
@WebFilter("/*")
public class SessionFilter implements Filter {

    private static final String R_VIEWER     = "Viewer";
    private static final String R_MEMBER     = "Member";
    private static final String R_MANAGER    = "Manager";
    private static final String R_ADMIN      = "Administrador";
    private static final String R_SUPERADMIN = "SuperAdmin";

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

        // ─── 1. Rutas públicas (sin sesión) ───
        if (esRutaPublica(path)) {
            chain.doFilter(request, response);
            return;
        }

        // ─── 2. Validar sesión activa ───
        HttpSession session = req.getSession(false);
        String roleName = (session != null)
                ? (String) session.getAttribute("roleName")
                : null;

        if (roleName == null) {
            // JSP inexistente → 404 amigable; recurso protegido → login
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

        String method = req.getMethod();
        String actionParam = req.getParameter("action");

        // ─── 3. Redirección JSP → Servlet ───
        // Si el usuario pega la URL de una JSP interna directamente,
        // lo redirigimos a su servlet para que los datos se carguen.
        // Excepción: admin-users.jsp NO se redirige para SA (debe ver 403).
        String redirectServlet = mapearJspAServlet(path);
        if (redirectServlet != null) {
            // Validamos permiso al servlet destino antes de redirigir
            if (!tienePermisoSobreRuta(redirectServlet, roleName, "GET", null)) {
                res.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            res.sendRedirect(req.getContextPath() + redirectServlet);
            return;
        }

        // ─── 4. Validar permisos por ruta + rol + método ───
        if (!tienePermisoSobreRuta(path, roleName, method, actionParam)) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * Rutas accesibles sin login.
     */
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

    /**
     * Si el path es una JSP interna que necesita datos del servlet,
     * devuelve la URL del servlet para redirigir. Si no aplica, null.
     */
    private String mapearJspAServlet(String path) {
        switch (path) {
            case "/deposit.jsp":       return "/DepositServlet";
            case "/transactions.jsp":  return "/TransactionServlet";
            case "/inventory.jsp":     return "/InventoryServlet";
            case "/history.jsp":       return "/HistoryServlet";
            case "/admin-users.jsp":   return "/UserServlet";
            case "/roles-list.jsp":    return "/RoleServlet";
            case "/audit-list.jsp":    return "/AuditServlet";
            case "/admin-item.jsp":    return "/AdminItemServlet";
            case "/analytics.jsp":     return "/AnalyticsServlet";
            case "/notifications.jsp": return "/NotificationServlet";
            case "/home.jsp":          return "/HomeServlet";
            case "/dashboard.jsp":     return "/DashboardServlet";
            case "/profile.jsp":       return "/ProfileServlet";
            default:                    return null;
        }
    }

    /**
     * ════════════════════════════════════════════════════════════════
     * Tabla maestra de permisos por ruta + rol + método HTTP.
     * ════════════════════════════════════════════════════════════════
     */
    private boolean tienePermisoSobreRuta(String path, String roleName,
                                          String method, String actionParam) {

        // ════════════════════════════════════════════
        // RUTAS EXCLUSIVAS DEL SUPERADMIN
        // ════════════════════════════════════════════
        if (path.startsWith("/AuditServlet"))      return R_SUPERADMIN.equals(roleName);
        if (path.startsWith("/RoleServlet"))       return R_SUPERADMIN.equals(roleName);
        if (path.startsWith("/PermissionServlet")) return R_SUPERADMIN.equals(roleName);

        // ════════════════════════════════════════════
        // GESTIÓN DE USUARIOS (UserServlet)
        //   - Admin: acceso completo (GET y POST).
        //   - SuperAdmin: solo POSTs (acciones desde roles-list) y
        //     GET action=formCrear (crear usuario desde roles-list).
        //     NO puede ver la lista de admin-users.
        // ════════════════════════════════════════════
        if (path.startsWith("/UserServlet")) {
            if (R_ADMIN.equals(roleName)) return true;

            if (R_SUPERADMIN.equals(roleName)) {
                if ("POST".equalsIgnoreCase(method)) return true;
                if ("formCrear".equals(actionParam)) return true;
                return false;
            }
            return false;
        }

        // ════════════════════════════════════════════
        // DESPACHO DE MATERIALES: solo Member
        // ════════════════════════════════════════════
        if (path.startsWith("/DepositServlet")) {
            return R_MEMBER.equals(roleName);
        }

        // ════════════════════════════════════════════
        // GESTIÓN DE ITEMS (admin-item):
        //   Member y Admin. SuperAdmin NO.
        // ════════════════════════════════════════════
        if (path.startsWith("/AdminItemServlet")) {
            return R_MEMBER.equals(roleName) || R_ADMIN.equals(roleName);
        }

        // ════════════════════════════════════════════
        // ANALÍTICAS: solo Admin. SuperAdmin NO.
        // ════════════════════════════════════════════
        if (path.startsWith("/AnalyticsServlet")) {
            return R_ADMIN.equals(roleName);
        }

        // ════════════════════════════════════════════
        // TRANSACCIONES (solicitudes):
        //   Viewer, Manager, Admin. NO Member, NO SuperAdmin.
        // ════════════════════════════════════════════
        if (path.startsWith("/TransactionServlet")
                || path.startsWith("/RequestDetailServlet")) {
            if (R_MEMBER.equals(roleName))     return false;
            if (R_SUPERADMIN.equals(roleName)) return false;
            return true;
        }

        // ════════════════════════════════════════════
        // INVENTARIO: todos menos SuperAdmin.
        // ════════════════════════════════════════════
        if (path.startsWith("/InventoryServlet")) {
            return !R_SUPERADMIN.equals(roleName);
        }

        // ════════════════════════════════════════════
        // HISTORIAL: los que solicitan (no Member, no SA)
        // ════════════════════════════════════════════
        if (path.startsWith("/HistoryServlet")) {
            if (R_MEMBER.equals(roleName))     return false;
            if (R_SUPERADMIN.equals(roleName)) return false;
            return true;
        }

        // Profile, Notifications, Home, Dashboard → cualquier logueado
        return true;
    }
}