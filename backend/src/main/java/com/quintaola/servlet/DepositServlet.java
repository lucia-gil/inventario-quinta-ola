package com.quintaola.servlet;

import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/* ============================================================
   DepositServlet
   ============================================================
   Vista del encargado de deposito (rol Member = 2).
   Muestra las solicitudes APROBADAS (pendientes de entrega) por
   defecto, con filtro opcional para ver también las ENTREGADAS
   (COMPLETED) o ambas juntas, más búsqueda por texto libre.

   URLs:
     GET  /DepositServlet                       -> lista (con filtros opcionales: q, estado)
     POST /DepositServlet (action=entregar)    -> marca una como entregada
   ============================================================ */
@WebServlet(name = "DepositServlet", value = "/DepositServlet")
public class DepositServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo Member, Admin y SuperAdmin pueden entrar aqui
        Integer roleId = (Integer) request.getSession().getAttribute("roleId");
        if (roleId == null || (roleId != 2 && roleId != 4 && roleId != 5)) {
            response.sendRedirect(request.getContextPath() + "/HomeServlet");
            return;
        }

        TransactionDAO txDao = new TransactionDAO();
        RequestDispatcher view;

        try {
            // ─── Filtro de estado: pendientes (default) | entregadas | todas ───
            String estado = request.getParameter("estado");
            if (estado == null || estado.trim().isEmpty()) estado = "pendientes";

            List<Transaction> solicitudes;
            switch (estado) {
                case "entregadas":
                    solicitudes = txDao.getCompleted();
                    break;
                case "todas":
                    solicitudes = new ArrayList<>();
                    solicitudes.addAll(txDao.getApproved());
                    solicitudes.addAll(txDao.getCompleted());
                    break;
                default:
                    estado = "pendientes";
                    solicitudes = txDao.getApproved();
                    break;
            }

            // ─── Búsqueda por texto libre: ID, solicitante o material ───
            String q = request.getParameter("q");
            if (q != null) q = q.trim();
            if (q != null && !q.isEmpty()) {
                String qLower = q.toLowerCase();
                List<Transaction> filtradas = new ArrayList<>();
                for (Transaction t : solicitudes) {
                    String idOriginal   = String.valueOf(t.getId());
                    String idFormateado = String.format("txn-%04d", t.getId());
                    String solicitante  = t.getRequesterName() != null ? t.getRequesterName().toLowerCase() : "";
                    String material     = t.getItemName()      != null ? t.getItemName().toLowerCase()      : "";
                    if (idOriginal.contains(qLower) || idFormateado.contains(qLower)
                            || solicitante.contains(qLower) || material.contains(qLower)) {
                        filtradas.add(t);
                    }
                }
                solicitudes = filtradas;
            }

            request.setAttribute("solicitudes", solicitudes);
            request.setAttribute("filtroEstado", estado);
            request.setAttribute("filtroQ", q != null ? q : "");
            request.setAttribute("activeMenu", "deposit");

            view = request.getRequestDispatcher("deposit.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar solicitudes: " + e.getMessage());
            view = request.getRequestDispatcher("deposit.jsp");
            view.forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null
                ? "" : request.getParameter("action");

        TransactionDAO txDao = new TransactionDAO();

        switch (action) {

            case "entregar":
                try {
                    // Validar permisos otra vez (no confiar solo en la UI)
                    Integer roleId = (Integer) request.getSession().getAttribute("roleId");
                    if (roleId == null || (roleId != 2 && roleId != 4 && roleId != 5)) {
                        response.sendRedirect(request.getContextPath() + "/HomeServlet");
                        return;
                    }

                    int txId = Integer.parseInt(request.getParameter("id"));

                    // Nota opcional del encargado sobre algún imprevisto en la entrega
                    // (retraso, material sustituto, cambio de color, etc.). No se guarda
                    // en la BD por ahora — solo viaja en el correo al solicitante.
                    String notasEntrega = request.getParameter("notas");
                    if (notasEntrega != null) notasEntrega = notasEntrega.trim();

                    // Obtener datos del solicitante ANTES de entregar (los necesitamos para el email)
                    com.quintaola.model.Transaction txEntregar = txDao.getById(txId);

                    // El DAO se encarga de:
                    // 1. Cambiar estado a COMPLETED
                    // 2. Descontar del stock del item
                    // 3. Actualizar el status del item (OK/LOW/UNAVAILABLE) segun stock
                    // 4. Guardar la nota de entrega (si la hay) en delivery_notes
                    boolean ok = txDao.deliver(txId, notasEntrega);

                    if (ok) {
                        // ─── Notificar al solicitante por email (comprobante tipo boleta) ───
                        if (txEntregar != null) {
                            try {
                                com.quintaola.dao.UserDAO userDao = new com.quintaola.dao.UserDAO();
                                com.quintaola.model.User solicitante = userDao.getById(txEntregar.getRequesterId());
                                if (solicitante != null && solicitante.getEmail() != null) {

                                    String itemName = txEntregar.getItemName();
                                    int    cantidad = txEntregar.getQuantity();
                                    String unidad    = txEntregar.getItemUnit();
                                    String fechaHoy   = LocalDate.now()
                                            .format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));

                                    if (notasEntrega != null && !notasEntrega.isEmpty()) {
                                        // Hubo un imprevisto que el encargado quiso avisar
                                        com.quintaola.util.EmailService.enviarEntregaConNota(
                                                solicitante.getEmail(),
                                                solicitante.getName(),
                                                txId,
                                                itemName,
                                                cantidad,
                                                unidad,
                                                fechaHoy,
                                                notasEntrega
                                        );
                                    } else {
                                        // Entrega normal, sin novedades
                                        com.quintaola.util.EmailService.enviarEntrega(
                                                solicitante.getEmail(),
                                                solicitante.getName(),
                                                txId,
                                                itemName,
                                                cantidad,
                                                unidad,
                                                fechaHoy
                                        );
                                    }
                                }
                            } catch (Exception emailEx) {
                                System.err.println("[DepositServlet] No se pudo enviar email de entrega: " + emailEx.getMessage());
                            }
                        }

                        response.sendRedirect(request.getContextPath()
                                + "/DepositServlet?success=Solicitud+entregada+y+stock+actualizado");
                    } else {
                        response.sendRedirect(request.getContextPath()
                                + "/DepositServlet?error=No+se+pudo+entregar");
                    }

                } catch (Exception e) {
                    response.sendRedirect(request.getContextPath()
                            + "/DepositServlet?error=" + e.getMessage().replace(" ", "+"));
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/DepositServlet");
                break;
        }
    }
}