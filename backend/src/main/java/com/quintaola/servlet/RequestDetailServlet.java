package com.quintaola.servlet;

import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "RequestDetailServlet", value = "/RequestDetailServlet")
public class RequestDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. SEGURIDAD: Validar que exista una sesión
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        String idParam = request.getParameter("id");
        RequestDispatcher view = request.getRequestDispatcher("request-detail.jsp");

        // 2. VALIDACIÓN DEL PARÁMETRO
        if (idParam == null || idParam.trim().isEmpty()) {
            request.setAttribute("error", "No se especificó un identificador de solicitud válido.");
            view.forward(request, response);
            return;
        }

        try {
            int txId = Integer.parseInt(idParam);
            TransactionDAO txDao = new TransactionDAO();

            // 3. CONSULTA A LA BASE DE DATOS
            // Nota: Asumo que tu TransactionDAO tiene un método getById que devuelve
            // el objeto Transaction con todos sus datos (itemName, requesterName, etc.)
            Transaction tx = txDao.getById(txId);

            if (tx != null) {
                // 4. PASAR DATOS A LA VISTA
                // El JSP espera el objeto bajo el nombre "tx"
                request.setAttribute("tx", tx);

                // Activar el menú lateral
                request.setAttribute("activeMenu", "transactions");

                view.forward(request, response);
            } else {
                request.setAttribute("error", "La solicitud solicitada no existe o fue eliminada.");
                view.forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "El identificador de solicitud no es válido.");
            view.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Ocurrió un error al cargar los detalles de la solicitud.");
            view.forward(request, response);
        }
    }
}