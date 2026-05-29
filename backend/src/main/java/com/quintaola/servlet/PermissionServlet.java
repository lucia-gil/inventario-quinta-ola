package com.quintaola.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "PermissionServlet", value = "/PermissionServlet")
public class PermissionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("activeMenu", "permissions");
        request.getRequestDispatcher("permissions.jsp").forward(request, response);
    }
}