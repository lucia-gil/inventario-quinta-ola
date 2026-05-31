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

                    // Filtramos según el botón que presionó el usuario
                    if ("PENDING".equals(status)) {
                        listaTx = txDao.getPending();
                    } else if ("APPROVED".equals(status)) {
                        listaTx = txDao.getApproved();
                    } else {
                        listaTx = txDao.getAll(); // Todas
                    }

                    request.setAttribute("transacciones", listaTx);
                    request.setAttribute("filtroStatus", status); // Retornamos el filtro para mantener el botón activo
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
                    String proposito = request.getParameter("proposito");
                    String fecha = request.getParameter("needed-by");

                    Transaction t = new Transaction();
                    t.setItemId(itemId);
                    t.setQuantity(quantity);
                    t.setRequesterId(userId);
                    // Se guarda la fecha y proposito en Notes
                    t.setNotes("Para " + fecha + " | " + proposito);

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
/*package com.quintaola.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Transaction;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/api/transactions/*")
public class TransactionServlet extends HttpServlet {

    private final TransactionDAO dao = new TransactionDAO();
    private final Gson gson          = new Gson();

    private void aplicarCORS(HttpServletRequest req, HttpServletResponse res) {
        String origin = req.getHeader("Origin");
        if (origin == null || origin.isEmpty()) {
            origin = "http://localhost:5173";
        }
        res.setHeader("Access-Control-Allow-Origin", origin);
        res.setHeader("Access-Control-Allow-Credentials", "true");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type, Accept");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        aplicarCORS(req, res);
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        PrintWriter out = res.getWriter();
        String path = req.getPathInfo();

        try {
            // Ruta específica con ID: /:id
            if (path != null && path.split("/").length > 1 &&
                    !"pending".equals(path.substring(1)) &&
                    !"approved".equals(path.substring(1)) &&
                    !"me".equals(path.substring(1))) {

                int id = Integer.parseInt(path.split("/")[1]);
                Transaction t = dao.getById(id);
                if (t != null) {
                    t.setStatus(t.getStatusFrontend());
                    out.print(gson.toJson(t));
                } else {
                    res.setStatus(404);
                    out.print("{\"error\":\"No se encontró la transacción\"}");
                }
            }
            // Rutas grupales
            else {
                List<Transaction> list;
                if ("/pending".equals(path)) {
                    list = dao.getPending();
                } else if ("/approved".equals(path)) {
                    list = dao.getApproved();
                } else if ("/me".equals(path)) {
                    HttpSession session = req.getSession(false);
                    if (session == null || session.getAttribute("userId") == null) {
                        res.setStatus(401);
                        out.print("{\"error\":\"Sesión expirada. Vuelve a iniciar sesión.\"}");
                        out.flush();
                        return;
                    }
                    int userId = (Integer) session.getAttribute("userId");
                    list = dao.getByUser(userId);
                } else {
                    list = dao.getAll();
                }

                list.forEach(t -> t.setStatus(t.getStatusFrontend()));
                out.print(gson.toJson(list));
            }

        } catch (NumberFormatException e) {
            res.setStatus(400);
            out.print("{\"error\":\"ID inválido\"}");
        } catch (SQLException e) {
            res.setStatus(500);
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Error SQL";
            out.print("{\"error\":\"SQL: " + msg + "\"}");
            e.printStackTrace();
        } catch (Exception e) {
            res.setStatus(500);
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : e.getClass().getSimpleName();
            out.print("{\"error\":\"" + e.getClass().getSimpleName() + ": " + msg + "\"}");
            e.printStackTrace();
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        aplicarCORS(req, res);
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        PrintWriter out = res.getWriter();

        try {
            Transaction t = gson.fromJson(req.getReader(), Transaction.class);

            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("userId") != null) {
                t.setRequesterId((Integer) session.getAttribute("userId"));
            }

            if (t.getItemId() == 0 || t.getQuantity() <= 0) {
                res.setStatus(400);
                out.print("{\"error\":\"Item y cantidad son obligatorios\"}");
                out.flush();
                return;
            }

            boolean creado = dao.create(t);
            if (creado) {
                res.setStatus(201);
                out.print("{\"message\":\"Solicitud creada correctamente\"}");
            } else {
                res.setStatus(500);
                out.print("{\"error\":\"No se pudo crear la solicitud\"}");
            }

        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
        out.flush();
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        aplicarCORS(req, res);
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        PrintWriter out = res.getWriter();
        String path = req.getPathInfo();

        try {
            if (path == null) {
                res.setStatus(400);
                out.print("{\"error\":\"Ruta no especificada\"}");
                out.flush();
                return;
            }

            String[] parts = path.split("/");
            int id = Integer.parseInt(parts[1]);
            String action = parts.length > 2 ? parts[2] : "";

            HttpSession session = req.getSession(false);
            int approverId = (session != null && session.getAttribute("userId") != null)
                    ? (Integer) session.getAttribute("userId")
                    : 0;

            JsonObject body = null;
            try {
                body = gson.fromJson(req.getReader(), JsonObject.class);
            } catch (Exception ignored) {}

            String notes = (body != null && body.has("notes"))
                    ? body.get("notes").getAsString() : "";

            boolean ok = switch (action) {
                case "approve" -> dao.approve(id, approverId, notes);
                case "reject"  -> dao.reject(id, approverId, notes);
                case "deliver" -> dao.deliver(id);
                default        -> false;
            };

            if (ok) {
                out.print("{\"message\":\"Operación realizada correctamente\"}");
            } else {
                res.setStatus(404);
                out.print("{\"error\":\"No se encontró la solicitud o ya fue procesada\"}");
            }

        } catch (NumberFormatException e) {
            res.setStatus(400);
            out.print("{\"error\":\"ID inválido\"}");
        } catch (SQLException e) {
            res.setStatus(500);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
        out.flush();
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse res) {
        aplicarCORS(req, res);
        res.setStatus(200);
    }
}
*/