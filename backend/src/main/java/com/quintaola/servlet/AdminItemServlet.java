package com.quintaola.servlet;

import com.quintaola.dao.AuditDAO;
import com.quintaola.dao.ItemDAO;
import com.quintaola.model.Item;
import com.quintaola.util.DatabaseConnection;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

@WebServlet(name = "AdminItemServlet", value = "/AdminItemServlet")
// ¡MUY IMPORTANTE PARA SUBIR IMÁGENES! Mismo patrón que ProfileServlet.
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1 MB en memoria, después a disco
        maxFileSize       = 1024 * 1024 * 5,  // 5 MB máximo por foto
        maxRequestSize    = 1024 * 1024 * 10  // 10 MB máximo por petición
)
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
            String[] tagsArr   = request.getParameterValues("tags"); // ahora soporta múltiples etiquetas
            String unit        = request.getParameter("unidad");
            String imageUrl    = request.getParameter("imagen");
            String description = request.getParameter("descripcion");

            int stock = request.getParameter("stock") != null && !request.getParameter("stock").isEmpty()
                    ? Integer.parseInt(request.getParameter("stock")) : 0;
            int minQuantity = request.getParameter("minimo") != null && !request.getParameter("minimo").isEmpty()
                    ? Integer.parseInt(request.getParameter("minimo")) : 0;

            if (imageUrl != null) imageUrl = imageUrl.trim();

            // ─── Imagen subida desde el equipo: si hay archivo, manda sobre la URL manual ───
            try {
                String imagenSubida = procesarImagenSubida(request);
                if (imagenSubida != null) imageUrl = imagenSubida;
            } catch (IllegalArgumentException validacionImg) {
                String idParam = request.getParameter("id");
                String redirectTarget = "actualizar".equals(action) && idParam != null
                        ? ctx + "/AdminItemServlet?action=formEditar&id=" + idParam
                        : ctx + "/AdminItemServlet?action=formCrear";
                response.sendRedirect(redirectTarget + "&error="
                        + java.net.URLEncoder.encode(validacionImg.getMessage(), "UTF-8"));
                return;
            }

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
                    if (tagsArr != null) {
                        for (String t : tagsArr) {
                            if (t != null && !t.trim().isEmpty()) {
                                itemDao.assignTag(newId, t.trim(), actorId);
                            }
                        }
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
                    // Reemplazamos el set completo de etiquetas por el que llegó del picker
                    // (permite tener varias, y también quitarlas todas si el usuario las borró).
                    itemDao.clearTags(id);
                    if (tagsArr != null) {
                        for (String t : tagsArr) {
                            if (t != null && !t.trim().isEmpty()) {
                                itemDao.assignTag(id, t.trim(), actorId);
                            }
                        }
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

    // ────────────────────────────────────────────────────────────────────────
    // MÉTODO PARA SUBIR Y GUARDAR LA IMAGEN DEL MATERIAL
    // Mismo patrón/límites que ProfileServlet.procesarAvatar().
    // Devuelve la ruta relativa (ej: "/uploads/items/item_123.jpg") si el
    // usuario subió un archivo válido, o null si no subió ningún archivo
    // (en ese caso el llamador debe usar la URL manual como antes).
    // Lanza IllegalArgumentException con un mensaje ya listo para mostrar
    // al usuario si el archivo no pasa las validaciones.
    // ────────────────────────────────────────────────────────────────────────
    private String procesarImagenSubida(HttpServletRequest request) throws Exception {

        final long MAX_BYTES = 5L * 1024 * 1024; // 5 MB
        final String MAX_MB_TEXT = "5 MB";

        Part filePart;
        try {
            filePart = request.getPart("imagenFile");
        } catch (IllegalStateException ex) {
            // Disparado por: archivo más grande que maxFileSize del @MultipartConfig
            throw new IllegalArgumentException(
                    "La imagen excede el tamaño máximo permitido (" + MAX_MB_TEXT + "). Elige una imagen más pequeña.");
        }

        // No subieron ningún archivo — el llamador debe usar la URL manual
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        // Validar tamaño (doble barrera por si acaso)
        if (filePart.getSize() > MAX_BYTES) {
            double sizeMb = filePart.getSize() / (1024.0 * 1024.0);
            String sizeFmt = String.format("%.1f", sizeMb).replace(",", ".");
            throw new IllegalArgumentException(
                    "Tu imagen pesa " + sizeFmt + " MB y el máximo permitido es " + MAX_MB_TEXT + ". Usa una imagen más pequeña.");
        }

        // Validar extensión (seguridad básica)
        String fileName = filePart.getSubmittedFileName();
        String ext = "";
        if (fileName != null && fileName.contains(".")) {
            ext = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
        }

        if (!ext.equals(".jpg") && !ext.equals(".jpeg") && !ext.equals(".png") && !ext.equals(".webp")) {
            throw new IllegalArgumentException("Formato no permitido. Solo JPG, PNG o WEBP.");
        }

        // Crear carpeta si no existe (uploads/items)
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "items";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Generar nombre único y guardar
        String newFileName = "item_" + System.currentTimeMillis()
                + "_" + Math.abs(new java.util.Random().nextInt(9999)) + ext;
        String filePath = uploadPath + File.separator + newFileName;
        filePart.write(filePath);

        return "/uploads/items/" + newFileName;
    }
}