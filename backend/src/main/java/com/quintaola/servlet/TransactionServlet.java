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
 * TransactionServlet — Bandeja de Entrada de Solicitudes Pendientes
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

        // Validar sesión antes de cualquier acción
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        switch (action) {

            case "lista":
                try {
                    // 1. Recuperamos credenciales
                    Integer userIdSession = (Integer) session.getAttribute("userId");
                    Integer roleIdSession = (Integer) session.getAttribute("roleId");
                    int currentUserId = userIdSession != null ? userIdSession : 0;
                    int currentRoleId = roleIdSession != null ? roleIdSession : 0;

                    List<Transaction> todasPendientes;

                    // 2. Lógica: SOLO traemos transacciones PENDIENTES
                    if (currentRoleId == 1) {
                        // Rol 1 (Viewer): Filtramos en memoria solo sus pendientes
                        todasPendientes = txDao.getByUser(currentUserId).stream()
                                .filter(t -> "PENDING".equals(t.getStatus()))
                                .collect(Collectors.toList());
                    } else if (currentRoleId == 4 || currentRoleId == 5) {
                        // Rol 4 y 5 (Admin/SA): Ven TODAS las pendientes de la empresa
                        todasPendientes = txDao.getPendingExcludingSelf(0);
                    } else {
                        // Rol 2 y 3 (Member/Manager): Ven pendientes EXCEPTO las suyas
                        todasPendientes = txDao.getPendingExcludingSelf(currentUserId);
                    }

                    // 3. LÓGICA DE PAGINACIÓN (Súper Profesional)
                    int pageNum = 1;
                    int pageSize = 8; // <-- Muestra 8 solicitudes por página (puedes cambiarlo)

                    if (request.getParameter("page") != null) {
                        try {
                            pageNum = Integer.parseInt(request.getParameter("page"));
                        } catch (NumberFormatException e) {
                            pageNum = 1;
                        }
                    }

                    int totalRecords = todasPendientes.size();
                    int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

                    // Validar límites de página
                    if (pageNum < 1) pageNum = 1;
                    if (pageNum > totalPages && totalPages > 0) pageNum = totalPages;

                    // Extraer la "tajada" (subList) correspondiente a la página actual
                    int startIndex = (pageNum - 1) * pageSize;
                    int endIndex = Math.min(startIndex + pageSize, totalRecords);
                    List<Transaction> listaPaginada = todasPendientes.isEmpty()
                            ? todasPendientes
                            : todasPendientes.subList(startIndex, endIndex);

                    // 4. Enviamos datos a la vista
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
                try {
                    com.quintaola.dao.ItemDAO itemDao = new com.quintaola.dao.ItemDAO();
                    request.setAttribute("items", itemDao.getAll());
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

        switch (action) {

            case "crear":
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
                        notasFinales = "Para " + fecha + " | " + notas;
                    } else {
                        notasFinales = notas;
                    }
                    t.setNotes(notasFinales);

                    txDao.create(t);
                    response.sendRedirect(request.getContextPath() + "/HistoryServlet?action=lista");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=formCrear&error=Error+al+crear+solicitud");
                }
                break;

            case "aprobar":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    String notas = request.getParameter("notas") != null ? request.getParameter("notas") : "";

                    txDao.approve(id, userId, notas);
                    // Como ahora solo hay pendientes, quitamos el status=PENDING de la URL
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista&success=Solicitud+aprobada+correctamente");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista&error=Error+al+aprobar+la+solicitud");
                }
                break;

            case "rechazar":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    String notas = request.getParameter("notas") != null ? request.getParameter("notas") : "Rechazado sin comentarios.";

                    txDao.reject(id, userId, notas);
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista&success=Solicitud+rechazada+correctamente");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista&error=Error+al+rechazar+la+solicitud");
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista");
                break;
        }
    }
}