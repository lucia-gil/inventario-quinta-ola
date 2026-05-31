package com.quintaola.servlet;

import com.quintaola.dao.ItemDAO;
import com.quintaola.model.Item;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "AdminItemServlet", value = "/AdminItemServlet")
public class AdminItemServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Validar sesión y permisos (Solo Admin 4 o SuperAdmin 5)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        Integer roleId = (Integer) session.getAttribute("roleId");
        if (roleId == null || (roleId != 4 && roleId != 5)) {
            response.sendRedirect(request.getContextPath() + "/DashboardServlet");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "formCrear";

        ItemDAO itemDao = new ItemDAO();
        RequestDispatcher view = request.getRequestDispatcher("admin-item.jsp");

        try {
            switch (action) {
                case "formCrear":
                    // Solo renderiza la vista en blanco
                    request.setAttribute("activeMenu", "inventory");
                    view.forward(request, response);
                    break;

                case "formEditar":
                    // Busca el ítem y lo envía a la vista para auto-rellenar los inputs
                    int id = Integer.parseInt(request.getParameter("id"));
                    Item item = itemDao.getById(id);

                    if (item != null) {
                        request.setAttribute("item", item);
                        request.setAttribute("activeMenu", "inventory");
                        view.forward(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/InventoryServlet?error=Material+no+encontrado");
                    }
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/InventoryServlet");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/InventoryServlet?error=Error+al+cargar+el+formulario");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Validar seguridad en POST también
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        ItemDAO itemDao = new ItemDAO();

        try {
            // Recoger datos comunes del formulario
            String name = request.getParameter("nombre");
            String category = request.getParameter("tags");
            String unit = request.getParameter("unidad");
            String imageUrl = request.getParameter("imagen");
            String description = request.getParameter("descripcion");

            int stock = request.getParameter("stock") != null && !request.getParameter("stock").isEmpty()
                    ? Integer.parseInt(request.getParameter("stock")) : 0;
            int minQuantity = request.getParameter("minimo") != null && !request.getParameter("minimo").isEmpty()
                    ? Integer.parseInt(request.getParameter("minimo")) : 0;

            if (imageUrl == null || imageUrl.trim().isEmpty()) {
                imageUrl = "/img/placeholder.png"; // Imagen por defecto si la dejan vacía
            }

            Item item = new Item();
            item.setName(name);
            item.setCategory(category);
            item.setUnit(unit);
            item.setMinQuantity(minQuantity);
            item.setImageUrl(imageUrl);
            item.setDescription(description);

            if ("crear".equals(action)) {
                // Al crear, sí establecemos el stock inicial
                item.setCachedQuantity(stock);

                int newId = itemDao.create(item);
                boolean ok = (newId > 0);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/InventoryServlet?success=Material+creado+exitosamente");
                } else {
                    response.sendRedirect(request.getContextPath() + "/InventoryServlet?error=No+se+pudo+crear+el+material");
                }

            } else if ("actualizar".equals(action)) {
                // Al actualizar, necesitamos el ID, pero NO tocamos el stock (se maneja por transacciones)
                int id = Integer.parseInt(request.getParameter("id"));
                item.setId(id);

                // Conservamos el stock actual que tenga la base de datos
                Item itemActual = itemDao.getById(id);
                item.setCachedQuantity(itemActual.getCachedQuantity());

                boolean ok = itemDao.update(item);
                if (ok) {
                    response.sendRedirect(request.getContextPath() + "/InventoryServlet?success=Material+actualizado+exitosamente");
                } else {
                    response.sendRedirect(request.getContextPath() + "/InventoryServlet?error=No+se+pudo+actualizar+el+material");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/InventoryServlet");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/InventoryServlet?error=Error+al+procesar+el+material");
        }
    }
}