package com.quintaola.servlet;

import com.quintaola.dao.RoleDAO;
import com.quintaola.dao.UserDAO;
import com.quintaola.model.Role;
import com.quintaola.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;

@WebServlet(name = "RoleServlet", value = "/RoleServlet")
public class RoleServlet extends HttpServlet {

    /** Usuarios por página en cada tabla de rol */
    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        RoleDAO roleDao = new RoleDAO();
        UserDAO userDao = new UserDAO();
        RequestDispatcher view;

        try {
            // ── Filtros ──────────────────────────────────────────────────────
            String searchQ = request.getParameter("q") != null
                    ? request.getParameter("q").trim() : "";

            int rolFilter = 0;
            String rolParam = request.getParameter("rol");
            if (rolParam != null && !rolParam.trim().isEmpty()) {
                try { rolFilter = Integer.parseInt(rolParam); }
                catch (NumberFormatException ignored) {}
            }

            // ── Roles del sistema ─────────────────────────────────────────────
            List<Role> roles = roleDao.getAll();

            // ── Procesar usuarios por rol (filtrar, ordenar, paginar) ─────────
            Map<Integer, List<User>> pagedUsuariosPorRol = new HashMap<>();
            Map<Integer, Integer>   totalsByRole         = new HashMap<>();
            Map<Integer, Integer>   totalPagesByRole     = new HashMap<>();
            Map<Integer, Integer>   pagesByRole          = new HashMap<>();

            String qLower = searchQ.toLowerCase();

            for (Role rol : roles) {

                // Obtener todos los usuarios de este rol
                List<User> todos = roleDao.getUsersByRole(rol.getId());

                // Filtrar por búsqueda (nombre o DNI)
                List<User> filtered = new ArrayList<>();
                for (User u : todos) {
                    boolean nameMatch = u.getName() != null
                            && u.getName().toLowerCase().contains(qLower);
                    boolean dniMatch  = u.getDni() != null
                            && u.getDni().contains(searchQ);
                    if (searchQ.isEmpty() || nameMatch || dniMatch) {
                        filtered.add(u);
                    }
                }

                // Ordenar A-Z por primera letra del nombre
                filtered.sort((a, b) -> {
                    String na = a.getName() != null ? a.getName() : "";
                    String nb = b.getName() != null ? b.getName() : "";
                    return na.compareToIgnoreCase(nb);
                });

                // Calcular paginación para este rol
                int total      = filtered.size();
                int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
                if (totalPages < 1) totalPages = 1;

                int page = 1;
                String pageParam = request.getParameter("page_" + rol.getId());
                if (pageParam != null && !pageParam.trim().isEmpty()) {
                    try { page = Math.max(1, Integer.parseInt(pageParam)); }
                    catch (NumberFormatException ignored) {}
                }
                page = Math.min(page, totalPages);

                int from = (page - 1) * PAGE_SIZE;
                int to   = Math.min(from + PAGE_SIZE, total);
                List<User> paged = (from < total) ? filtered.subList(from, to) : Collections.emptyList();

                pagedUsuariosPorRol.put(rol.getId(), paged);
                totalsByRole.put(rol.getId(), total);
                totalPagesByRole.put(rol.getId(), totalPages);
                pagesByRole.put(rol.getId(), page);
            }

            Map<Integer, String> inactiveStatus = userDao.getInactiveUsersStatus();

            // ── Atributos para la vista ───────────────────────────────────────
            request.setAttribute("roles",               roles);
            request.setAttribute("pagedUsuariosPorRol", pagedUsuariosPorRol);
            request.setAttribute("totalsByRole",        totalsByRole);
            request.setAttribute("totalPagesByRole",    totalPagesByRole);
            request.setAttribute("pagesByRole",         pagesByRole);
            request.setAttribute("inactiveStatus",      inactiveStatus);
            request.setAttribute("activeMenu",          "roles");
            request.setAttribute("searchQ",             searchQ);
            request.setAttribute("rolFilter",           rolFilter);

            view = request.getRequestDispatcher("roles-list.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar roles: " + e.getMessage());
            view = request.getRequestDispatcher("roles-list.jsp");
            view.forward(request, response);
        }
    }
}