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
 * HistoryServlet — historial de todas las transacciones.
 */
@WebServlet(name = "HistoryServlet", value = "/HistoryServlet")
public class HistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        TransactionDAO txDao = new TransactionDAO();
        RequestDispatcher view;

        try {
            List<Transaction> transacciones = txDao.getAll();

            request.setAttribute("transacciones", transacciones);
            request.setAttribute("activeMenu", "history");

            view = request.getRequestDispatcher("history.jsp");
            view.forward(request, response);

        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar historial: " + e.getMessage());
            view = request.getRequestDispatcher("history.jsp");
            view.forward(request, response);
        }
    }
}