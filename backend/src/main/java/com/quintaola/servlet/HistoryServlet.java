package com.quintaola.servlet;

import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * ════════════════════════════════════════════════════════════════════
 *  HistoryServlet — Controlador de la página "Historial"
 * ════════════════════════════════════════════════════════════════════
 *
 *  PROPÓSITO:
 *  Mostrar el historial de transacciones (solicitudes de material).
 *  Aplica filtros opcionales y muestra resultados según el rol:
 *    - Viewer: solo SUS propias transacciones
 *    - Resto: TODAS las transacciones del sistema uwu
 *
 *  PATRÓN DEL CURSO:
 *  switch-case + action (Clase de prof brenda 7.3 slide 5).
 *  Por ahora solo tiene un case ("lista"). En sprints siguientes
 *  podríamos agregar "exportar" para descargar CSV, etc.
 *
 *  URLs:
 *    GET /HistoryServlet                              → lista todo (con filtros opcionales)
 *    GET /HistoryServlet?q=cemento&status=Pendiente   → con filtros
 *
 *  Un Viewer ve solo lo suyo por seguridad y privacidad. Leo el roleId de la sesión y si es 1
 *      (Viewer), llamo a getByUserId(userId) en vez de getAll().
 *      La decisión la toma el servidor, no el navegador.
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "HistoryServlet", value = "/HistoryServlet")
public class HistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ─── 1. LEER PARÁMETRO action ───
        String action = request.getParameter("action") == null
                ? "lista"
                : request.getParameter("action");

        TransactionDAO txDao = new TransactionDAO();
        RequestDispatcher view;

        switch (action) {

            case "lista":
                try {
                    // 1.1. Leer datos de la sesión
                    Integer userId = (Integer) request.getSession().getAttribute("userId");
                    Integer roleId = (Integer) request.getSession().getAttribute("roleId");

                    if (userId == null) {
                        response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
                        return;
                    }

                    // 1.2. DECIDIR QUÉ TRAER SEGÚN EL ROL
                    // Si es Viewer (roleId=1), solo sus transacciones
                    // Para los demás, TODAS las del sistema
                    List<Transaction> todasLasTx;
                    if (roleId != null && roleId == 1) {
                        // Viewer: solo las del usuario logueado
                        todasLasTx = txDao.getByUser(userId);
                    } else {
                        // Resto de roles: todas las del sistema
                        todasLasTx = txDao.getAll();
                    }

                    // 1.3. Leer filtros (pueden ser null o "")
                    String filtroTexto  = request.getParameter("q");
                    String filtroStatus = request.getParameter("status");

                    if (filtroTexto == null) filtroTexto = "";
                    if (filtroStatus == null) filtroStatus = "";

                    // 1.4. Aplicar filtros en Java
                    List<Transaction> txFiltradas = new ArrayList<>();
                    for (Transaction tx : todasLasTx) {

                        // Filtro 1: texto (busca en nombre del item, solicitante y ID)
                        boolean matchTexto = filtroTexto.isEmpty();
                        if (!matchTexto) {
                            String txt = filtroTexto.toLowerCase();
                            String itemName = tx.getItemName() != null ? tx.getItemName().toLowerCase() : "";
                            String reqName  = tx.getRequesterName() != null ? tx.getRequesterName().toLowerCase() : "";
                            String idStr    = String.valueOf(tx.getId());
                            matchTexto = itemName.contains(txt) || reqName.contains(txt) || idStr.contains(txt);
                        }

                        // Filtro 2: estado (acepta tanto "Pendiente" como "PENDING")
                        boolean matchStatus = filtroStatus.isEmpty();
                        if (!matchStatus) {
                            String statusActual = tx.getStatus();
                            // Comparar contra ambos formatos
                            matchStatus = filtroStatus.equalsIgnoreCase(statusActual)
                                    || filtroStatus.equalsIgnoreCase(traducirStatus(statusActual));
                        }

                        if (matchTexto && matchStatus) {
                            txFiltradas.add(tx);
                        }
                    }

                    // 1.5. INYECTAR datos en el request
                    request.setAttribute("transacciones", txFiltradas);
                    request.setAttribute("totalTransacciones", todasLasTx.size());

                    // Preservar filtros para los inputs
                    request.setAttribute("filtroTexto", filtroTexto);
                    request.setAttribute("filtroStatus", filtroStatus);

                    request.setAttribute("activeMenu", "history");

                    // 1.6. FORWARD a la vista
                    view = request.getRequestDispatcher("history.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error al cargar historial: " + e.getMessage());
                    view = request.getRequestDispatcher("history.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/HistoryServlet");
                break;
        }
    }

    /**
     * Helper: traduce el status técnico de la BD ("PENDING") al label
     * visible para el usuario ("Pendiente"). Usado para el filtro.
     */
    private String traducirStatus(String status) {
        if (status == null) return "";
        return switch (status) {
            case "PENDING"   -> "Pendiente";
            case "APPROVED"  -> "Aprobada";
            case "REJECTED"  -> "Rechazada";
            case "COMPLETED" -> "Entregada";
            default          -> status;
        };
    }
}