package com.quintaola.servlet;

import com.quintaola.dao.AuditDAO;           // ← NUEVO
import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * ════════════════════════════════════════════════════════════════════
 * TransactionServlet — Bandeja de Aprobaciones y Solicitudes
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "TransactionServlet", value = "/TransactionServlet")
public class TransactionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null
                ? "lista"
                : request.getParameter("action");

        TransactionDAO txDao = new TransactionDAO();
        RequestDispatcher view;

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        Integer roleIdGuard = (Integer) session.getAttribute("roleId");
        int roleGuard = roleIdGuard != null ? roleIdGuard : 0;

        if (roleGuard == 5) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        switch (action) {

            case "lista":
                try {
                    Integer userIdSession = (Integer) session.getAttribute("userId");
                    Integer roleIdSession = (Integer) session.getAttribute("roleId");
                    int currentUserId = userIdSession != null ? userIdSession : 0;
                    int currentRoleId = roleIdSession != null ? roleIdSession : 0;

                    List<Transaction> todasPendientes;

                    if (currentRoleId == 1) {
                        todasPendientes = txDao.getByUser(currentUserId).stream()
                                .filter(t -> "PENDING".equals(t.getStatus()))
                                .collect(Collectors.toList());
                    } else if (currentRoleId == 3 || currentRoleId == 4) {
                        todasPendientes = txDao.getPendingExcludingSelf(currentUserId);
                    } else {
                        todasPendientes = txDao.getPendingExcludingSelf(currentUserId);
                    }

                    String search = request.getParameter("search");
                    String fechaEntrega = request.getParameter("fechaEntrega");

                    if (search != null && !search.trim().isEmpty()) {
                        String sLower = search.trim().toLowerCase();
                        todasPendientes = todasPendientes.stream()
                                .filter(t -> {
                                    String idOriginal  = String.valueOf(t.getId());
                                    String idFormateado = String.format("txn-%04d", t.getId());
                                    String solicitante  = t.getRequesterName() != null ? t.getRequesterName().toLowerCase() : "";
                                    String material     = t.getItemName()      != null ? t.getItemName().toLowerCase()      : "";
                                    return idOriginal.contains(sLower) || idFormateado.contains(sLower)
                                            || solicitante.contains(sLower) || material.contains(sLower);
                                })
                                .collect(Collectors.toList());
                    }

                    if (fechaEntrega != null && !fechaEntrega.trim().isEmpty()) {
                        String fTrim = fechaEntrega.trim();
                        todasPendientes = todasPendientes.stream()
                                .filter(t -> t.getEstimatedDelivery() != null
                                        && t.getEstimatedDelivery().toString().contains(fTrim))
                                .collect(Collectors.toList());
                    }

                    int pageNum  = 1;
                    int pageSize = 15;
                    if (request.getParameter("page") != null) {
                        try { pageNum = Integer.parseInt(request.getParameter("page")); }
                        catch (NumberFormatException e) { pageNum = 1; }
                    }

                    int totalRecords = todasPendientes.size();
                    int totalPages   = (int) Math.ceil((double) totalRecords / pageSize);
                    if (pageNum < 1) pageNum = 1;
                    if (pageNum > totalPages && totalPages > 0) pageNum = totalPages;

                    int startIndex = (pageNum - 1) * pageSize;
                    int endIndex   = Math.min(startIndex + pageSize, totalRecords);
                    List<Transaction> listaPaginada = todasPendientes.isEmpty()
                            ? todasPendientes
                            : todasPendientes.subList(startIndex, endIndex);

                    request.setAttribute("transacciones",  listaPaginada);
                    request.setAttribute("currentPage",    pageNum);
                    request.setAttribute("totalPages",     totalPages);
                    request.setAttribute("totalRecords",   totalRecords);
                    request.setAttribute("activeMenu",     "transactions");

                    view = request.getRequestDispatcher("transactions.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error al cargar las solicitudes: " + e.getMessage());
                    view = request.getRequestDispatcher("transactions.jsp");
                    view.forward(request, response);
                }
                break;

            case "detalle":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Transaction tx = txDao.getById(id);
                    if (tx != null) {
                        request.setAttribute("tx", tx);
                        String origen = request.getParameter("origen");
                        if ("historial".equals(origen)) {
                            request.setAttribute("activeMenu", "history");
                        } else {
                            request.setAttribute("activeMenu", "transactions");
                        }
                        view = request.getRequestDispatcher("request-detail.jsp");
                        view.forward(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista");
                    }
                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista");
                }
                break;

            case "formCrear":
                if (roleGuard == 2) {
                    response.sendRedirect(request.getContextPath()
                            + "/InventoryServlet?error=No+puedes+crear+solicitudes+como+Encargado+de+Deposito");
                    return;
                }
                try {
                    com.quintaola.dao.ItemDAO itemDao = new com.quintaola.dao.ItemDAO();
                    request.setAttribute("items", itemDao.getAll());
                    String itemIdParam = request.getParameter("itemId");
                    if (itemIdParam != null && !itemIdParam.trim().isEmpty()) {
                        try { request.setAttribute("itemPreseleccionado", Integer.parseInt(itemIdParam)); }
                        catch (NumberFormatException ignored) {}
                    }
                    request.setAttribute("cantidadPrevia", request.getParameter("cantidad"));
                    request.setAttribute("notasPrevias",   request.getParameter("notas"));
                    request.setAttribute("fechaPrevia",    request.getParameter("neededBy"));
                    request.setAttribute("error",          request.getParameter("error"));
                } catch (Exception e) {
                    System.out.println("Error cargando items: " + e.getMessage());
                }
                String origen = request.getParameter("origen");
                if ("inventory".equals(origen)) {
                    request.setAttribute("activeMenu", "inventory");
                } else if ("home".equals(origen)) {
                    request.setAttribute("activeMenu", "home");
                } else {
                    request.setAttribute("activeMenu", "transactions");
                }
                view = request.getRequestDispatcher("request-form.jsp");
                view.forward(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        TransactionDAO txDao = new TransactionDAO();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        Integer userId     = (Integer) session.getAttribute("userId");
        Integer roleIdGuard = (Integer) session.getAttribute("roleId");
        int     roleGuard   = roleIdGuard != null ? roleIdGuard : 0;

        // Actor para auditoría
        String actorRole = (String) session.getAttribute("roleName");
        if (actorRole == null) actorRole = "Usuario";

        if (roleGuard == 5) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        switch (action) {

            // ─── CREAR SOLICITUD ──────────────────────────────────────────────
            case "crear":
                if (roleGuard == 2) {
                    response.sendRedirect(request.getContextPath()
                            + "/HomeServlet?error=No+tienes+permiso+para+crear+solicitudes");
                    return;
                }

                String itemIdStr  = request.getParameter("itemId");
                String cantidadStr = request.getParameter("cantidad");
                String notasStr   = request.getParameter("notas");
                String fechaStr   = request.getParameter("neededBy");

                try {
                    if (itemIdStr == null || itemIdStr.trim().isEmpty()) {
                        throw new Exception("Por favor, selecciona un material válido del catálogo.");
                    }
                    int itemId   = Integer.parseInt(itemIdStr);
                    int quantity = Integer.parseInt(cantidadStr);
                    if (quantity < 1) {
                        throw new Exception("Cantidad no válida. El pedido debe ser de al menos 1 unidad.");
                    }

                    Transaction t = new Transaction();
                    t.setItemId(itemId);
                    t.setQuantity(quantity);
                    t.setRequesterId(userId);

                    String notasFinales = "";
                    if (fechaStr != null && !fechaStr.trim().isEmpty()) {
                        notasFinales = "Fecha de entrega estimada:  " + fechaStr + " | " + notasStr;
                        t.setEstimatedDelivery(fechaStr);
                    } else {
                        notasFinales = notasStr;
                        t.setEstimatedDelivery(null);
                    }
                    t.setNotes(notasFinales);

                    boolean creado  = txDao.create(t);
                    int     nuevaId = creado ? t.getId() : 0;

                    // ── Auditoría de creación de solicitud ──────────────────────
                    try {
                        final String _actorRole = actorRole;
                        new AuditDAO().log(userId, "CREAR_SOLICITUD", "TRANSACTION", nuevaId,
                                String.format("El %s creó la solicitud id=%d (itemId=%d, cantidad=%d)",
                                        _actorRole, nuevaId, itemId, quantity));
                    } catch (Exception ignored) {}
                    // ───────────────────────────────────────────────────────────

                    // Notificar a aprobadores en segundo plano
                    new Thread(() -> {
                        try {
                            com.quintaola.dao.UserDAO userDao = new com.quintaola.dao.UserDAO();
                            com.quintaola.model.User solicitante = userDao.getById(userId);
                            String nombreSolicitante = solicitante != null ? solicitante.getName() : "Usuario desconocido";
                            int requestIdParaEmail = nuevaId > 0 ? nuevaId : 0;
                            for (com.quintaola.model.User aprobador : userDao.getApprovers()) {
                                if (aprobador.getId() == userId) continue;
                                if (aprobador.getEmail() == null || aprobador.getEmail().isEmpty()) continue;
                                try {
                                    com.quintaola.util.EmailService.enviarNuevaSolicitud(
                                            aprobador.getEmail(), aprobador.getName(),
                                            nombreSolicitante, requestIdParaEmail);
                                } catch (Exception emailEx) {
                                    System.err.println("[TransactionServlet] Email a aprobador falló: " + emailEx.getMessage());
                                }
                            }
                        } catch (Exception notifyEx) {
                            System.err.println("[TransactionServlet] No se pudo notificar a aprobadores: " + notifyEx.getMessage());
                        }
                    }).start();

                    response.sendRedirect(request.getContextPath()
                            + "/HistoryServlet?action=lista&success=Solicitud+registrada+correctamente");

                } catch (Exception e) {
                    String msg = e.getMessage();
                    String errorMsg = "Error al crear la solicitud.";
                    if (msg != null && (msg.contains("Stock") || msg.contains("Cantidad")
                            || msg.contains("material") || msg.contains("selecciona"))) {
                        errorMsg = msg;
                    }
                    String redirectUrl = request.getContextPath() + "/TransactionServlet?action=formCrear"
                            + "&error="    + java.net.URLEncoder.encode(errorMsg, "UTF-8")
                            + "&itemId="   + (itemIdStr   != null ? itemIdStr : "")
                            + "&cantidad=" + (cantidadStr != null ? cantidadStr : "")
                            + "&notas="    + (notasStr    != null ? java.net.URLEncoder.encode(notasStr, "UTF-8") : "")
                            + "&neededBy=" + (fechaStr    != null ? java.net.URLEncoder.encode(fechaStr, "UTF-8") : "");
                    response.sendRedirect(redirectUrl);
                }
                break;

            // ─── APROBAR ──────────────────────────────────────────────────────
            case "aprobar":
                try {
                    int id    = Integer.parseInt(request.getParameter("id"));
                    String notas = request.getParameter("notas") != null
                            ? request.getParameter("notas") : "";

                    if (roleGuard != 3 && roleGuard != 4) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=No+tienes+permiso+para+aprobar");
                        return;
                    }

                    Transaction txExistente = txDao.getById(id);
                    if (txExistente != null && txExistente.getRequesterId() == userId) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=No+puedes+aprobar+tus+propias+solicitudes");
                        return;
                    }

                    txDao.approve(id, userId, notas);

                    // ── Auditoría ───────────────────────────────────────────────
                    try {
                        new AuditDAO().log(userId, "APROBAR", "TRANSACTION", id,
                                String.format("El %s aprobó la solicitud id=%d (ítem: %s, cantidad: %d)",
                                        actorRole, id,
                                        txExistente != null && txExistente.getItemName() != null
                                                ? txExistente.getItemName() : "—",
                                        txExistente != null ? txExistente.getQuantity() : 0));
                    } catch (Exception ignored) {}
                    // ───────────────────────────────────────────────────────────

                    new Thread(() -> {
                        try {
                            com.quintaola.dao.UserDAO userDao = new com.quintaola.dao.UserDAO();
                            com.quintaola.model.User solicitante = userDao.getById(txExistente.getRequesterId());
                            if (solicitante != null && solicitante.getEmail() != null) {
                                com.quintaola.util.EmailService.enviarSolicitudAprobada(
                                        solicitante.getEmail(), solicitante.getName(), id);
                            }
                        } catch (Exception emailEx) {
                            System.err.println("[TransactionServlet] No se pudo enviar email de aprobación: " + emailEx.getMessage());
                        }
                    }).start();

                    response.sendRedirect(request.getContextPath()
                            + "/TransactionServlet?action=lista&success=Solicitud+aprobada+y+stock+descontado");

                } catch (java.sql.SQLException sqlEx) {
                    String msg = sqlEx.getMessage();
                    if (msg != null && (msg.contains("Stock insuficiente") || msg.contains("ya fue procesada"))) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=" + msg.replace(" ", "+"));
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=Error+al+aprobar+la+solicitud");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath()
                            + "/TransactionServlet?action=lista&error=Error+al+aprobar+la+solicitud");
                }
                break;

            // ─── RECHAZAR ─────────────────────────────────────────────────────
            case "rechazar":
                try {
                    int id    = Integer.parseInt(request.getParameter("id"));
                    String notas = request.getParameter("notas") != null
                            ? request.getParameter("notas") : "Rechazado sin comentarios.";

                    if (roleGuard != 3 && roleGuard != 4) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=No+tienes+permiso+para+rechazar");
                        return;
                    }

                    Transaction txExistente = txDao.getById(id);
                    if (txExistente != null && txExistente.getRequesterId() == userId) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=No+puedes+rechazar+tus+propias+solicitudes");
                        return;
                    }

                    txDao.reject(id, userId, notas);

                    // ── Auditoría ───────────────────────────────────────────────
                    try {
                        new AuditDAO().log(userId, "RECHAZAR", "TRANSACTION", id,
                                String.format("El %s rechazó la solicitud id=%d. Motivo: %s",
                                        actorRole, id, notas));
                    } catch (Exception ignored) {}
                    // ───────────────────────────────────────────────────────────

                    new Thread(() -> {
                        try {
                            com.quintaola.dao.UserDAO userDao = new com.quintaola.dao.UserDAO();
                            com.quintaola.model.User solicitante = userDao.getById(txExistente.getRequesterId());
                            if (solicitante != null && solicitante.getEmail() != null) {
                                com.quintaola.util.EmailService.enviarSolicitudRechazada(
                                        solicitante.getEmail(), solicitante.getName(), id, notas);
                            }
                        } catch (Exception emailEx) {
                            System.err.println("[TransactionServlet] No se pudo enviar email de rechazo: " + emailEx.getMessage());
                        }
                    }).start();

                    response.sendRedirect(request.getContextPath()
                            + "/TransactionServlet?action=lista&success=Solicitud+rechazada+correctamente");

                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath()
                            + "/TransactionServlet?action=lista&error=Error+al+rechazar+la+solicitud");
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista");
                break;
        }
    }
}