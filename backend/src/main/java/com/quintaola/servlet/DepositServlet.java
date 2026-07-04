package com.quintaola.servlet;

import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/* ============================================================
   DepositServlet
   ============================================================
   Vista del encargado de deposito (rol Member = 2).
   Muestra todas las solicitudes APROBADAS pero aun no entregadas,
   y permite marcarlas como entregadas (lo que descuenta del stock).

   URLs:
     GET  /DepositServlet                       -> lista aprobadas pendientes de entregar
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
            // Traemos solo las solicitudes APROBADAS (no las pendientes, no las entregadas)
            List<Transaction> aprobadas = txDao.getApproved();

            request.setAttribute("solicitudes", aprobadas);
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

                    // El DAO se encarga de:
                    // 1. Cambiar estado a COMPLETED
                    // 2. Descontar del stock del item
                    // 3. Actualizar el status del item (OK/LOW/UNAVAILABLE) segun stock
                    boolean ok = txDao.deliver(txId);

                    if (ok) {
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