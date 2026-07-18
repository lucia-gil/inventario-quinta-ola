package com.quintaola.servlet;

import com.quintaola.dao.AuditDAO;
import com.quintaola.dao.ItemDAO;
import com.quintaola.model.Item;
import com.quintaola.util.DatabaseConnection;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

@WebServlet(name = "AdminItemServlet", value = "/AdminItemServlet")
public class AdminItemServlet extends HttpServlet {

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
            List<String> tagsDisponibles = itemDao.getAllTagNames();
            request.setAttribute("tagsDisponibles", tagsDisponibles);
            request.setAttribute("activeMenu", "inventory");

            switch (action) {
                case "formCrear":
                    view.forward(request, response);
                    break;

                case "formEditar":
                    int id   = Integer.parseInt(request.getParameter("id"));
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
        String ctx = request.getContextPath();

        Integer actorId  = (Integer) session.getAttribute("userId");
        String actorRole = (String)  session.getAttribute("roleName");
        if (actorRole == null) actorRole = "Usuario";

        try {

            // ─── DESACTIVAR ────────────────────────────────────────────────────
            if ("desactivar".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = itemDao.disable(id);
                if (ok) {
                    // Auditoría
                    try {
                        new AuditDAO().log(actorId, "DESACTIVAR_ITEM", "ITEM", id,
                                String.format("El %s desactivó el ítem id=%d", actorRole, id));
                    } catch (Exception ignored) {}
                    response.sendRedirect(ctx + "/InventoryServlet?success=Material+desactivado");
                } else {
                    response.sendRedirect(ctx + "/InventoryServlet?error=No+se+pudo+desactivar");
                }
                return;
            }

            // ─── REACTIVAR ─────────────────────────────────────────────────────
            if ("reactivar".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = itemDao.reactivate(id);
                if (ok) {
                    // Auditoría
                    try {
                        new AuditDAO().log(actorId, "REACTIVAR_ITEM", "ITEM", id,
                                String.format("El %s reactivó el ítem id=%d", actorRole, id));
                    } catch (Exception ignored) {}
                    // Vuelve al filtro de "Desactivados" para que el admin vea
                    // el resultado inmediato de la acción que acaba de hacer.
                    response.sendRedirect(ctx + "/InventoryServlet?action=lista&stock=INACTIVE&success=Material+reactivado");
                } else {
                    response.sendRedirect(ctx + "/InventoryServlet?action=lista&stock=INACTIVE&error=No+se+pudo+reactivar");
                }
                return;
            }

            // ─── ENTRADA DE STOCK ──────────────────────────────────────────────
            if ("entrada".equals(action)) {
                String itemIdStr   = request.getParameter("itemId");
                String cantidadStr = request.getParameter("cantidad");
                String notas       = request.getParameter("notas");
                if (notas == null) notas = "";

                int itemId;
                try { itemId = Integer.parseInt(itemIdStr); }
                catch (Exception e) {
                    response.sendRedirect(ctx + "/InventoryServlet?error=Item+invalido");
                    return;
                }

                int cantidad;
                try { cantidad = Integer.parseInt(cantidadStr); }
                catch (Exception e) {
                    response.sendRedirect(ctx + "/AdminItemServlet?action=formEditar&id="
                            + itemIdStr + "&error=Cantidad+invalida");
                    return;
                }

                if (cantidad <= 0) {
                    response.sendRedirect(ctx + "/AdminItemServlet?action=formEditar&id="
                            + itemId + "&error=La+cantidad+debe+ser+mayor+a+0");
                    return;
                }

                String sqlTxn = """
                    INSERT INTO transactions
                      (item_id, requester_id, approver_id, type, quantity, status, notes,
                       processed_at, delivered_at)
                    VALUES (?, ?, ?, 'IN', ?, 'COMPLETED', ?, NOW(), NOW())
                    """;
                String sqlStock = """
                    UPDATE items
                    SET cached_quantity = cached_quantity + ?,
                        status = CASE
                            WHEN (cached_quantity + ?) <= 0             THEN 'UNAVAILABLE'
                            WHEN (cached_quantity + ?) <= min_quantity   THEN 'LOW'
                            ELSE 'OK'
                        END
                    WHERE id = ?
                    """;

                try (Connection conn = DatabaseConnection.getConnection()) {
                    conn.setAutoCommit(false);
                    try {
                        try (PreparedStatement ps = conn.prepareStatement(sqlTxn)) {
                            ps.setInt   (1, itemId);
                            ps.setInt   (2, actorId);
                            ps.setInt   (3, actorId);
                            ps.setInt   (4, cantidad);
                            ps.setString(5, notas.isEmpty() ? null : notas);
                            ps.executeUpdate();
                        }
                        try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
                            ps.setInt(1, cantidad);
                            ps.setInt(2, cantidad);
                            ps.setInt(3, cantidad);
                            ps.setInt(4, itemId);
                            ps.executeUpdate();
                        }
                        conn.commit();
                    } catch (Exception e) {
                        conn.rollback();
                        throw e;
                    }
                }

                // Auditoría
                try {
                    new AuditDAO().log(actorId, "ENTRADA_STOCK", "ITEM", itemId,
                            String.format("El %s registró entrada de %d unidad(es) al ítem id=%d. Motivo: %s",
                                    actorRole, cantidad, itemId,
                                    notas.isEmpty() ? "sin especificar" : notas));
                } catch (Exception ignored) {}

                response.sendRedirect(ctx + "/AdminItemServlet?action=formEditar&id="
                        + itemId + "&success=Entrada+de+" + cantidad + "+unidades+registrada");
                return;
            }

            // ─── Datos comunes del form (crear / actualizar) ───────────────────
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

            if (imageUrl != null) imageUrl = imageUrl.trim();

            if ("actualizar".equals(action)) {
                if (imageUrl == null || imageUrl.isEmpty()) {
                    int idTmp = Integer.parseInt(request.getParameter("id"));
                    Item itemTmp = itemDao.getById(idTmp);
                    if (itemTmp != null && itemTmp.getImageUrl() != null
                            && !itemTmp.getImageUrl().trim().isEmpty()) {
                        imageUrl = itemTmp.getImageUrl();
                    } else {
                        imageUrl = "/img/placeholder.png";
                    }
                }
            } else {
                if (imageUrl == null || imageUrl.isEmpty()) {
                    imageUrl = "/img/placeholder.png";
                }
            }

            String tagFinal = (tagNuevo != null && !tagNuevo.trim().isEmpty())
                    ? tagNuevo.trim() : tagName;

            Item item = new Item();
            item.setName(name);
            item.setUnit(unit);
            item.setMinQuantity(minQuantity);
            item.setImageUrl(imageUrl);
            item.setDescription(description);

            // ─── CREAR ────────────────────────────────────────────────────────
            if ("crear".equals(action)) {
                item.setCachedQuantity(stock);
                String estadoInicial;
                if (stock <= 0) estadoInicial = "UNAVAILABLE";
                else if (stock <= minQuantity) estadoInicial = "LOW";
                else estadoInicial = "OK";
                item.setStatus(estadoInicial);

                int newId = itemDao.create(item);
                if (newId > 0) {
                    if (tagFinal != null && !tagFinal.trim().isEmpty()) {
                        itemDao.assignTag(newId, tagFinal, actorId);
                    }
                    // Auditoría
                    try {
                        new AuditDAO().log(actorId, "CREAR_ITEM", "ITEM", newId,
                                String.format("El %s creó el ítem '%s' (id=%d, stock=%d, unidad=%s)",
                                        actorRole, name, newId, stock, unit));
                    } catch (Exception ignored) {}
                    response.sendRedirect(ctx + "/InventoryServlet?success=Material+creado+exitosamente");
                } else {
                    response.sendRedirect(ctx + "/AdminItemServlet?action=formCrear&error=No+se+pudo+crear");
                }

                // ─── ACTUALIZAR ───────────────────────────────────────────────────
            } else if ("actualizar".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                item.setId(id);

                Item itemActual = itemDao.getById(id);
                if (itemActual != null) {
                    item.setCachedQuantity(itemActual.getCachedQuantity());
                }

                boolean ok = itemDao.update(item);
                if (ok) {
                    if (tagFinal != null && !tagFinal.trim().isEmpty()) {
                        itemDao.clearTags(id);
                        itemDao.assignTag(id, tagFinal, actorId);
                    }
                    // Auditoría
                    try {
                        new AuditDAO().log(actorId, "ACTUALIZAR_ITEM", "ITEM", id,
                                String.format("El %s actualizó el ítem '%s' (id=%d)",
                                        actorRole, name, id));
                    } catch (Exception ignored) {}
                    response.sendRedirect(ctx + "/InventoryServlet?success=Material+actualizado");
                } else {
                    response.sendRedirect(ctx + "/InventoryServlet?error=No+se+pudo+actualizar");
                }

            } else {
                response.sendRedirect(ctx + "/InventoryServlet");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(ctx + "/InventoryServlet?error=Error+al+procesar+el+material");
        }
    }
}