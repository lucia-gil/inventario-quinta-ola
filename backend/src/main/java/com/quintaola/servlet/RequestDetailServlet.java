package com.quintaola.servlet;

import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/* ============================================================
   RequestDetailServlet
   ============================================================
   Controlador para ver el detalle individual de una transaccion
   (solicitud de material).

   La URL viene como: /RequestDetailServlet?id=5
   Si no llega id o es invalido, redirige al historial.

   Patron: tiene un solo case "ver" en el switch porque por ahora
   solo muestra. Las acciones de aprobar/rechazar las hace el
   TransactionServlet, que es quien ya tiene esa logica.
   ============================================================ */
@WebServlet(name = "RequestDetailServlet", value = "/RequestDetailServlet")
public class RequestDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // El id de la transaccion viene como parametro de URL
        String idParam = request.getParameter("id");

        // Si no llega id, no tiene sentido seguir, mandamos al historial
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/HistoryServlet");
            return;
        }

        TransactionDAO txDao = new TransactionDAO();
        RequestDispatcher view;

        try {
            // Parseamos el id a entero (puede tirar NumberFormatException)
            int txId = Integer.parseInt(idParam);

            // Pedimos al DAO la transaccion con todos sus joins
            Transaction tx = txDao.getById(txId);

            // Si no existe esa transaccion, mostramos un error en la vista
            if (tx == null) {
                request.setAttribute("error", "La solicitud TXN-" + idParam + " no existe.");
            } else {
                // Pasamos el objeto al JSP para que lo pinte
                request.setAttribute("tx", tx);
            }

            request.setAttribute("activeMenu", "history");

            // Reenviamos al JSP de detalle
            view = request.getRequestDispatcher("request-detail.jsp");
            view.forward(request, response);

        } catch (NumberFormatException e) {
            // Si el id no es numerico, mandamos al historial
            response.sendRedirect(request.getContextPath() + "/HistoryServlet");
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar solicitud: " + e.getMessage());
            view = request.getRequestDispatcher("request-detail.jsp");
            view.forward(request, response);
        }
    }
}
