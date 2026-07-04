package com.quintaola.servlet;

import com.quintaola.dao.ItemDAO;
import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Item;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * ════════════════════════════════════════════════════════════════════
 *  TransactionServlet — Controlador de solicitudes de material
 * ════════════════════════════════════════════════════════════════════
 *
 *  PROPÓSITO:
 *  Maneja TODO el ciclo de vida de las transacciones (solicitudes):
 *    - Listar (para Manager/Admin: las gestionan)
 *    - Crear (Viewer/Member crean solicitudes nuevas)
 *    - Aprobar / Rechazar (solo Manager/Admin/SuperAdmin)
 *
 *  PATRÓN DEL CURSO:
 *  switch-case + action (Clase 7.3 slide 5).
 *
 *  REEMPLAZA AL VIEJO TransactionServlet que era API REST y devolvía JSON.
 *  Ahora hace forward a vistas JSP, como pidió el JP.
 *
 *  URLs:
 *    GET  /TransactionServlet                                 → lista
 *    GET  /TransactionServlet?action=lista                    → lista (con filtro opcional)
 *    GET  /TransactionServlet?action=formCrear                → formulario nuevo
 *    GET  /TransactionServlet?action=formCrear&itemId=5       → formulario con item preseleccionado
 *    POST /TransactionServlet  (action=crear)                 → procesa creación
 *    POST /TransactionServlet  (action=aprobar)               → aprueba solicitud
 *    POST /TransactionServlet  (action=rechazar)              → rechaza solicitud
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "TransactionServlet", value = "/TransactionServlet")
public class TransactionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ─── 1. LEER PARÁMETRO action ───
        String action = request.getParameter("action") == null
                ? "lista"
                : request.getParameter("action");

        TransactionDAO txDao = new TransactionDAO();
        ItemDAO itemDao = new ItemDAO();
        RequestDispatcher view;

        switch (action) {

            // ═══ CASE "lista" → mostrar todas las transacciones ═══
            case "lista":
                try {
                    // Solo Manager(3), Admin(4), SuperAdmin(5) pueden ver el listado completo
                    Integer roleId = (Integer) request.getSession().getAttribute("roleId");
                    if (roleId == null || roleId < 3) {
                        response.sendRedirect(request.getContextPath() + "/HomeServlet");
                        return;
                    }

                    // Obtener filtro opcional por estado
                    String filtroStatus = request.getParameter("status");
                    if (filtroStatus == null) filtroStatus = "";

                    List<Transaction> transacciones;
                    if (filtroStatus.equals("PENDING")) {
                        transacciones = txDao.getPending();
                    } else if (filtroStatus.equals("APPROVED")) {
                        transacciones = txDao.getApproved();
                    } else {
                        transacciones = txDao.getAll();
                    }

                    request.setAttribute("transacciones", transacciones);
                    request.setAttribute("filtroStatus", filtroStatus);
                    request.setAttribute("activeMenu", "transactions");

                    view = request.getRequestDispatcher("transactions.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error al cargar transacciones: " + e.getMessage());
                    view = request.getRequestDispatcher("transactions.jsp");
                    view.forward(request, response);
                }
                break;

            // ═══ CASE "formCrear" → mostrar formulario para crear solicitud ═══
            case "formCrear":
                try {
                    // Cargar la lista de items disponibles para el dropdown
                    List<Item> items = itemDao.getAll();
                    request.setAttribute("items", items);

                    // Si vino con un itemId preseleccionado (desde el catálogo)
                    String itemIdParam = request.getParameter("itemId");
                    if (itemIdParam != null && !itemIdParam.isEmpty()) {
                        try {
                            int itemId = Integer.parseInt(itemIdParam);
                            request.setAttribute("itemPreseleccionado", itemId);
                        } catch (NumberFormatException ignored) {}
                    }

                    request.setAttribute("activeMenu", "transactions");
                    view = request.getRequestDispatcher("request-form.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error al cargar formulario: " + e.getMessage());
                    view = request.getRequestDispatcher("request-form.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/TransactionServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar encoding (Clase 7.3 slide 16)
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null
                ? "" : request.getParameter("action");

        TransactionDAO txDao = new TransactionDAO();

        switch (action) {

            // ═══ CASE "crear" → procesar formulario de nueva solicitud ═══
            case "crear":
                try {
                    Integer userId = (Integer) request.getSession().getAttribute("userId");
                    if (userId == null) {
                        response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                        return;
                    }

                    // Leer datos del formulario
                    int itemId = Integer.parseInt(request.getParameter("itemId"));
                    int cantidad = Integer.parseInt(request.getParameter("cantidad"));
                    String notas = request.getParameter("notas");

                    // Validación básica
                    if (cantidad <= 0) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=formCrear&error=Cantidad+inválida");
                        return;
                    }

                    // Crear el objeto Transaction
                    Transaction tx = new Transaction();
                    tx.setItemId(itemId);
                    tx.setRequesterId(userId);
                    tx.setQuantity(cantidad);
                    tx.setNotes(notas);

                    // Guardar en la BD (el DAO ya crea la notificación automáticamente)
                    boolean ok = txDao.create(tx);

                    if (ok) {
                        // POST-Redirect-GET: redirigir al historial con mensaje
                        response.sendRedirect(request.getContextPath()
                                + "/HistoryServlet?success=Solicitud+creada+correctamente");
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?action=formCrear&error=No+se+pudo+crear");
                    }

                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath()
                            + "/TransactionServlet?action=formCrear&error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            // ═══ CASE "aprobar" → aprobar una solicitud ═══
            case "aprobar":
                try {
                    // Validar permisos
                    Integer roleId = (Integer) request.getSession().getAttribute("roleId");
                    Integer approverId = (Integer) request.getSession().getAttribute("userId");
                    if (roleId == null || roleId < 3) {
                        response.sendRedirect(request.getContextPath() + "/HomeServlet");
                        return;
                    }

                    int txId = Integer.parseInt(request.getParameter("id"));
                    String notas = request.getParameter("notas");
                    if (notas == null) notas = "";

                    boolean ok = txDao.approve(txId, approverId, notas);

                    if (ok) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?success=Solicitud+aprobada");
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?error=No+se+pudo+aprobar");
                    }

                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath()
                            + "/TransactionServlet?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            // ═══ CASE "rechazar" → rechazar una solicitud ═══
            case "rechazar":
                try {
                    Integer roleId = (Integer) request.getSession().getAttribute("roleId");
                    Integer approverId = (Integer) request.getSession().getAttribute("userId");
                    if (roleId == null || roleId < 3) {
                        response.sendRedirect(request.getContextPath() + "/HomeServlet");
                        return;
                    }

                    int txId = Integer.parseInt(request.getParameter("id"));
                    String notas = request.getParameter("notas");
                    if (notas == null || notas.isBlank()) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?error=Debes+indicar+un+motivo+de+rechazo");
                        return;
                    }

                    boolean ok = txDao.reject(txId, approverId, notas);

                    if (ok) {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?success=Solicitud+rechazada");
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/TransactionServlet?error=No+se+pudo+rechazar");
                    }

                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath()
                            + "/TransactionServlet?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/TransactionServlet");
                break;
        }
    }
}