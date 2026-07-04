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
 * HistoryServlet — Controlador de la página "Historial" con Paginación
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "HistoryServlet", value = "/HistoryServlet")
public class HistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

                    // 1.2. Decidir qué registros traer según el rol
                    List<Transaction> todasLasTx;
                    if (roleId != null && roleId == 1) {
                        todasLasTx = txDao.getByUser(userId);
                    } else {
                        todasLasTx = txDao.getAll();
                    }

                    // 1.3. Leer filtros de búsqueda
                    String filtroTexto  = request.getParameter("q");
                    String filtroStatus = request.getParameter("status");

                    if (filtroTexto == null) filtroTexto = "";
                    if (filtroStatus == null) filtroStatus = "";

                    // 1.4. Aplicar filtros en memoria
                    List<Transaction> txFiltradas = new ArrayList<>();
                    for (Transaction tx : todasLasTx) {

                        boolean matchTexto = filtroTexto.isEmpty();
                        if (!matchTexto) {
                            String txt = filtroTexto.toLowerCase();
                            String itemName = tx.getItemName() != null ? tx.getItemName().toLowerCase() : "";
                            String reqName  = tx.getRequesterName() != null ? tx.getRequesterName().toLowerCase() : "";
                            String idStr    = String.valueOf(tx.getId());
                            matchTexto = itemName.contains(txt) || reqName.contains(txt) || idStr.contains(txt);
                        }

                        boolean matchStatus = filtroStatus.isEmpty();
                        if (!matchStatus) {
                            String statusActual = tx.getStatus();
                            matchStatus = filtroStatus.equalsIgnoreCase(statusActual)
                                    || filtroStatus.equalsIgnoreCase(conducirStatus(statusActual));
                        }

                        if (matchTexto && matchStatus) {
                            txFiltradas.add(tx);
                        }
                    }

                    // ─── 📦 LÓGICA DE PAGINACIÓN POR OLAS ───
                    int pageNum = 1;
                    int pageSize = 15; // Tamaño de registros por página

                    if (request.getParameter("page") != null) {
                        try {
                            pageNum = Integer.parseInt(request.getParameter("page"));
                        } catch (NumberFormatException e) {
                            pageNum = 1;
                        }
                    }

                    int totalRecords = txFiltradas.size();
                    int totalPages = (int) Math.ceil((double) totalRecords / pageSize);

                    if (pageNum < 1) pageNum = 1;
                    if (pageNum > totalPages && totalPages > 0) pageNum = totalPages;

                    int startIndex = (pageNum - 1) * pageSize;
                    int endIndex = Math.min(startIndex + pageSize, totalRecords);

                    List<Transaction> listaPaginada = txFiltradas.isEmpty()
                            ? txFiltradas
                            : txFiltradas.subList(startIndex, endIndex);

                    // 1.5. Inyectar datos en el alcance del Request
                    request.setAttribute("transacciones", listaPaginada);
                    request.setAttribute("totalTransacciones", totalRecords);
                    request.setAttribute("currentPage", pageNum);
                    request.setAttribute("totalPages", totalPages);

                    // Preservar estados de los filtros
                    request.setAttribute("filtroTexto", filtroTexto);
                    request.setAttribute("filtroStatus", filtroStatus);
                    request.setAttribute("activeMenu", "history");

                    // 1.6. Redirigir a la vista
                    view = request.getRequestDispatcher("history.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    request.setAttribute("error", "Error al cargar el historial: " + e.getMessage());
                    view = request.getRequestDispatcher("history.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/HistoryServlet");
                break;
        }
    }

    private String conducirStatus(String status) {
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