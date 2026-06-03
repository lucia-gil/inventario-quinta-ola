package com.quintaola.servlet;

import com.quintaola.dao.RoleDAO;
import com.quintaola.model.Role;
import com.quintaola.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/* ============================================================
   RoleServlet
   ============================================================
   Solo accesible para SuperAdmin.
   Muestra los 5 roles del sistema con la lista de usuarios
   que pertenecen a cada uno.

   No tiene crear/editar/eliminar porque los roles son fijos.
   Lo unico que se hace es VER y luego desde ahi cambiar
   usuarios de rol (eso lo maneja UserServlet).

   URLs:
     GET /RoleServlet           -> lista de roles + usuarios
   ============================================================ */
@WebServlet(name = "RoleServlet", value = "/RoleServlet")
public class RoleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo SuperAdmin puede entrar
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || roleId != 5) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        RoleDAO roleDao = new RoleDAO();
        RequestDispatcher view;

        try {
            // 1. Traer los 5 roles del sistema
            List<Role> roles = roleDao.getAll();

            // 2. Para cada rol, traer su lista de usuarios
            // Lo guardamos en un Map donde la clave es el roleId
            Map<Integer, List<User>> usuariosPorRol = new HashMap<>();
            for (Role rol : roles) {
                List<User> usuarios = roleDao.getUsersByRole(rol.getId());
                usuariosPorRol.put(rol.getId(), usuarios);
            }

            // 3. Inyectar todo a la vista
            request.setAttribute("roles", roles);
            request.setAttribute("usuariosPorRol", usuariosPorRol);
            request.setAttribute("activeMenu", "roles");

            view = request.getRequestDispatcher("roles-list.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar roles: " + e.getMessage());
            view = request.getRequestDispatcher("roles-list.jsp");
            view.forward(request, response);
        }
    }
}