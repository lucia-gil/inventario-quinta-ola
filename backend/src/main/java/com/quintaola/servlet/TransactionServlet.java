package com.quintaola.servlet;

import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * ════════════════════════════════════════════════════════════════════
 * TransactionServlet — Controlador de Solicitudes y Aprobaciones
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
                    // Leemos el filtro que manda el JSP (Todas, Pendientes, Aprobadas)
                    String status = request.getParameter("status");
                    if (status == null) status = "";

                    List<Transaction> listaTx;

                    // 1. Recuperamos las credenciales de la sesión actual
                    Integer userIdSession = (Integer) session.getAttribute("userId");
                    Integer roleIdSession = (Integer) session.getAttribute("roleId");
                    int currentUserId = userIdSession != null ? userIdSession : 0;
                    int currentRoleId = roleIdSession != null ? roleIdSession : 0;

                    // 2. Lógica de visibilidad por Roles
                    if (currentRoleId == 1) {
                        // 👁 VIEWER (Rol 1): Solo ve su propio historial
                        listaTx = txDao.getByUser(currentUserId);
                    } else if (currentRoleId == 4 || currentRoleId == 5) {
                        // ADMIN & SUPERADMIN (Roles 4 y 5): Ven TODO (enviamos 0 para saltar el filtro)
                        if ("PENDING".equals(status)) {
                            listaTx = txDao.getPendingExcludingSelf(0);
                        } else if ("APPROVED".equals(status)) {
                            listaTx = txDao.getApprovedExcludingSelf(0);
                        } else {
                            listaTx = txDao.getAllExcludingSelf(0);
                        }
                    } else {
                        // MEMBER & MANAGER (Roles 2 y 3): Ven todas EXCEPTO las que ellos mismos crearon
                        if ("PENDING".equals(status)) {
                            listaTx = txDao.getPendingExcludingSelf(currentUserId);
                        } else if ("APPROVED".equals(status)) {
                            listaTx = txDao.getApprovedExcludingSelf(currentUserId);
                        } else {
                            listaTx = txDao.getAllExcludingSelf(currentUserId);
                        }
                    }

                    request.setAttribute("transacciones", listaTx);
                    request.setAttribute("filtroStatus", status);
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

                    // 1. Usamos los NOMBRES EXACTOS que están en el atributo 'name' del JSP
                    String notas = request.getParameter("notas");
                    String fecha = request.getParameter("neededBy");

                    Transaction t = new Transaction();
                    t.setItemId(itemId);
                    t.setQuantity(quantity);
                    t.setRequesterId(userId);

                    // 2. Lógica inteligente para armar la nota
                    String notasFinales = "";
                    if (fecha != null && !fecha.trim().isEmpty()) {
                        notasFinales = "Para " + fecha + " | " + notas;
                    } else {
                        notasFinales = notas; // Si no hay fecha, solo guardamos el texto
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
                    // Capturamos el parámetro "notas" enviado desde tu formulario oculto
                    String notas = request.getParameter("notas") != null ? request.getParameter("notas") : "";

                    txDao.approve(id, userId, notas);

                    // Redirigimos con mensaje de éxito visible en el JSP
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista&status=PENDING&success=Solicitud+aprobada+correctamente");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista&error=Error+al+aprobar+la+solicitud");
                }
                break;

            case "rechazar":
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    // Capturamos el motivo del rechazo del prompt JS
                    String notas = request.getParameter("notas") != null ? request.getParameter("notas") : "Rechazado sin comentarios.";

                    txDao.reject(id, userId, notas);

                    // Redirigimos con mensaje de éxito visible en el JSP
                    response.sendRedirect(request.getContextPath() + "/TransactionServlet?action=lista&status=PENDING&success=Solicitud+rechazada+correctamente");
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