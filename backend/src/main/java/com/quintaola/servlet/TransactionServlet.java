package com.quintaola.servlet;

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
 *
 * Reglas de permisos:
 * - Viewer (1), Member (2): solo solicitan
 * - Manager (3), Administrador (4): solicitan + aprueban,
 *   PERO no pueden aprobar/rechazar las suyas propias
 * - SuperAdmin (5): NO solicita ni aprueba (solo audita)
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

        // 🚫 SuperAdmin no puede operar transacciones
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
                        // Viewer: solo sus pendientes
                        todasPendientes = txDao.getByUser(currentUserId).stream()
                                .filter(t -> "PENDING".equals(t.getStatus()))
                                .collect(Collectors.toList());
                    } else if (currentRoleId == 3 || currentRoleId == 4) {
                        // Manager y Administrador: ven todas las pendientes
                        // EXCEPTO las suyas propias (segregación de funciones)
                        todasPendientes = txDao.getPendingExcludingSelf(currentUserId);
                    } else {
                        // Member (2): ve todas las pendientes excluyendo las suyas
                        todasPendientes = txDao.getPendingExcludingSelf(currentUserId);
                    }

                    // Paginación
                    int pageNum = 1;
                    int pageSize = 8;

                    if (request.getParameter("page") != null) {
                        try {
                            pageNum = Integer.parseInt(request.getParameter("page"));
                        } catch (NumberFormatException e) {
                            pageNum = 1;
                        }
                    }

                    int totalRecords = todasPendientes.size();
                    int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

                    if (pageNum < 1) pageNum = 1;
                    if (pageNum > totalPages && totalPages > 0) pageNum = totalPages;

                    int startIndex = (pageNum - 1) * pageSize;
                    int endIndex = Math.min(startIndex + pageSize, totalRecords);
                    List<Transaction> listaPaginada = todasPendientes.isEmpty()
                            ? todasPendientes
                            : todasPendientes.subList(startIndex, endIndex);

                    request.setAttribute("transacciones", listaPaginada);
                    request.setAttribute("currentPage", pageNum);
                    request.setAttribute("totalPages", totalPages);
                    request.setAttribute("totalRecords", totalRecords);
                    request.setAttribute("activeMenu", "transactions");

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
                // 🛡Member (2) y SuperAdmin (5) NO solicitan materiales
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
                        try {
                            int itemIdPre = Integer.parseInt(itemIdParam);
                            request.setAttribute("itemPreseleccionado", itemIdPre);
                        } catch (NumberFormatException ignored) {}
                    }

                } catch (Exception e) {
                    System.out.println("Error cargando items: " + e.getMessage());
                }
                request.setAttribute("activeMenu", "inventory");
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

        Integer userId = (Integer) session.getAttribute("userId");
        Integer roleIdGuard = (Integer) session.getAttribute("roleId");
        int roleGuard = roleIdGuard != null ? roleIdGuard : 0;

        // 🚫 SuperAdmin no opera transacciones
        if (roleGuard == 5) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        switch (action) {

            case "crear":
                // Member (2) NO puede crear solicitudes (es operador, no consumidor)
                if (roleGuard == 2) {
                    response.sendRedirect(request.getContextPath()
                            + "/HomeServlet?error=No+tienes+permiso+para+crear+solicitudes");
                    return;
                }
                try {
                    int itemId = Integer.parseInt(request.getParameter("itemId"));
                    int quantity = Integer.parseInt(request.getParameter("cantidad"));
                    String notas = request.getParameter("notas");
                    String fecha = request.getParameter("neededBy");

                    Transaction t = new Transaction();
                    t.setItemId(itemId);
                    t.setQuantity(quantity);
                    t.setRequesterId(userId);

                    String notasFinales = "";
                    if (fecha != null && !fecha.trim().isEmpty()) {
                        notasFinales = "Fecha de entrega estimada:  " + fecha + " | " + notas;
                        t.setEstimatedDelivery(fecha);
                    } else {
                        notasFinales = notas;
                        t.setEstimatedDelivery(null);
                    }
                    t.setNotes(notasFinales);
                    txDao.create(t);
                    response.sendRedirect(request.getContextPath() + "/HistoryServlet?action=lista");

                } catch (java.sql.SQLException sqlEx) {
                    String msg = sqlEx.getMessage();
                    if (msg != null && msg.contains("Stock insuficiente")) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=formCrear&error=" + msg.replace(" ", "+"));
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=formCrear&error=Error+al+crear+solicitud");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath()
                            + "/TransactionServlet?action=formCrear&error=Error+al+crear+solicitud");
                }
                break;

            case "aprobar":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    String notas = request.getParameter("notas") != null
                            ? request.getParameter("notas") : "";

                    // 🛡️ Solo Manager (3) y Administrador (4) pueden aprobar
                    if (roleGuard != 3 && roleGuard != 4) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=No+tienes+permiso+para+aprobar");
                        return;
                    }

                    // 🛡️ Segregación de funciones: no puedes aprobar tus propias solicitudes
                    Transaction txExistente = txDao.getById(id);
                    if (txExistente != null && txExistente.getRequesterId() == userId) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=No+puedes+aprobar+tus+propias+solicitudes");
                        return;
                    }

                    txDao.approve(id, userId, notas);
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

            case "rechazar":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    String notas = request.getParameter("notas") != null
                            ? request.getParameter("notas") : "Rechazado sin comentarios.";

                    // 🛡️ Solo Manager (3) y Administrador (4) pueden rechazar
                    if (roleGuard != 3 && roleGuard != 4) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=No+tienes+permiso+para+rechazar");
                        return;
                    }

                    // 🛡️ Segregación de funciones: no puedes rechazar tus propias solicitudes
                    Transaction txExistente = txDao.getById(id);
                    if (txExistente != null && txExistente.getRequesterId() == userId) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=lista&error=No+puedes+rechazar+tus+propias+solicitudes");
                        return;
                    }

                    txDao.reject(id, userId, notas);
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