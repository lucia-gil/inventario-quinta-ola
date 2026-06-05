package com.quintaola.servlet;

import com.quintaola.dao.ItemDAO;
import com.quintaola.model.Item;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminItemServlet", value = "/AdminItemServlet")
public class AdminItemServlet extends HttpServlet {

    // Roles permitidos: Member (2), Administrador (4), SuperAdmin (5)
    private boolean tienePermiso(HttpSession session) {
        if (session == null) return false;
        Integer roleId = (Integer) session.getAttribute("roleId");
        return roleId != null && (roleId == 2 || roleId == 4 || roleId == 5);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        if (!tienePermiso(session)) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "formCrear";

        ItemDAO itemDao = new ItemDAO();
        RequestDispatcher view = request.getRequestDispatcher("admin-item.jsp");

        try {
            // Cargar tags reales para los selects
            List<String> tagsDisponibles = itemDao.getAllTagNames();
            request.setAttribute("tagsDisponibles", tagsDisponibles);
            request.setAttribute("activeMenu", "inventory");

            switch (action) {
                case "formCrear":
                    view.forward(request, response);
                    break;

                case "formEditar":
                    int id = Integer.parseInt(request.getParameter("id"));
                    Item item = itemDao.getById(id);

                    if (item != null) {
                        request.setAttribute("item", item);
                        view.forward(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/InventoryServlet?error=Material+no+encontrado");
                    }
                    break;

                default:
                    response.sendRedirect(request.getContextPath() + "/InventoryServlet");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/InventoryServlet?error=Error+al+cargar+el+formulario");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        if (!tienePermiso(session)) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        ItemDAO itemDao = new ItemDAO();

        Integer actorId = (Integer) session.getAttribute("userId");

        try {
            // ─── DESACTIVAR (delete suave) ───
            if ("desactivar".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = itemDao.disable(id);
                if (ok) {
                    response.sendRedirect(request.getContextPath()
                            + "/InventoryServlet?success=Material+desactivado");
                } else {
                    response.sendRedirect(request.getContextPath()
                            + "/InventoryServlet?error=No+se+pudo+desactivar");
                }
                return;
            }

            // Datos comunes del form
            String name        = request.getParameter("nombre");
            String tagName     = request.getParameter("tags");
            String tagNuevo    = request.getParameter("tagNuevo");
            String unit        = request.getParameter("unidad");
            String imageUrl    = request.getParameter("imagen");
            String description = request.getParameter("descripcion");

            int stock = request.getParameter("stock") != null && !request.getParameter("stock").isEmpty()
                    ? Integer.parseInt(request.getParameter("stock")) : 0;
            int minQuantity = request.getParameter("minimo") != null && !request.getParameter("minimo").isEmpty()
                    ? Integer.parseInt(request.getParameter("minimo")) : 0;

            if (imageUrl == null || imageUrl.trim().isEmpty()) {
                imageUrl = "/img/placeholder.png";
            }

            // Si el usuario escribió un tag nuevo, ese gana
            String tagFinal = (tagNuevo != null && !tagNuevo.trim().isEmpty())
                    ? tagNuevo.trim()
                    : tagName;

            Item item = new Item();
            item.setName(name);
            item.setUnit(unit);
            item.setMinQuantity(minQuantity);
            item.setImageUrl(imageUrl);
            item.setDescription(description);

            if ("crear".equals(action)) {
                // Stock inicial
                item.setCachedQuantity(stock);

                // Estado inicial calculado según stock vs minimo
                String estadoInicial;
                if (stock <= 0) estadoInicial = "UNAVAILABLE";
                else if (stock <= minQuantity) estadoInicial = "LOW";
                else estadoInicial = "OK";
                item.setStatus(estadoInicial);

                int newId = itemDao.create(item);
                if (newId > 0) {
                    // Asignar tag al item recién creado
                    if (tagFinal != null && !tagFinal.trim().isEmpty()) {
                        itemDao.assignTag(newId, tagFinal, actorId);
                    }
                    response.sendRedirect(request.getContextPath()
                            + "/InventoryServlet?success=Material+creado+exitosamente");
                } else {
                    response.sendRedirect(request.getContextPath()
                            + "/AdminItemServlet?action=formCrear&error=No+se+pudo+crear");
                }

            } else if ("actualizar".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                item.setId(id);

                // Conservar stock actual de la BD
                Item itemActual = itemDao.getById(id);
                if (itemActual != null) {
                    item.setCachedQuantity(itemActual.getCachedQuantity());
                }

                boolean ok = itemDao.update(item);
                if (ok) {
                    // Reemplazar tags: borrar y volver a asignar
                    if (tagFinal != null && !tagFinal.trim().isEmpty()) {
                        itemDao.clearTags(id);
                        itemDao.assignTag(id, tagFinal, actorId);
                    }
                    response.sendRedirect(request.getContextPath()
                            + "/InventoryServlet?success=Material+actualizado");
                } else {
                    response.sendRedirect(request.getContextPath()
                            + "/InventoryServlet?error=No+se+pudo+actualizar");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/InventoryServlet");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/InventoryServlet?error=Error+al+procesar+el+material");
        }
    }
}