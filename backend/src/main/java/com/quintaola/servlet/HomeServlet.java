package com.quintaola.servlet;

import com.quintaola.dao.ItemDAO;
import com.quintaola.dao.TransactionDAO;
import com.quintaola.model.Item;
import com.quintaola.model.Transaction;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * ════════════════════════════════════════════════════════════════════
 * HomeServlet — Vista PERSONAL del usuario logueado
 * ════════════════════════════════════════════════════════════════════
 *
 * A diferencia del DashboardServlet (que muestra stats GLOBALES),
 * aquí calculamos stats PERSONALES adaptadas al rol del usuario:
 *
 * Viewer (rol 1):
 *   - Mis pedidos del mes, mis aprobados, mis pendientes
 *
 * Member (rol 2):
 *   - Pedidos por entregar, entregados este mes, items bajo stock
 *
 * Manager (rol 3):
 *   - Pendientes por aprobar, mis aprobadas mes, mis rechazadas mes
 *
 * Administrador (rol 4):
 *   - Items totales, pendientes globales, aprobadas del mes
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "HomeServlet", value = "/HomeServlet")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/AuthServlet?action=formLogin");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");
        Integer roleId = (Integer) session.getAttribute("roleId");
        if (userId == null) userId = 0;
        if (roleId == null) roleId = 0;

        try {
            TransactionDAO txDao = new TransactionDAO();
            ItemDAO itemDao = new ItemDAO();

            // Stats personales adaptadas al rol
            int stat1 = 0, stat2 = 0, stat3 = 0;
            String label1 = "", label2 = "", label3 = "";

            // Para detectar "este mes" comparamos con el inicio del mes actual
            // Los created_at en MySQL vienen como "2026-06-04 14:30:00"
            // Si comparamos contra "2026-06-01" da true para todos los del mes
            java.time.LocalDate hoy = java.time.LocalDate.now();
            String inicioMes = hoy.withDayOfMonth(1).toString();

            // Saludo y fecha dinámica (Con Lucide Icons)
            java.time.LocalTime horaActual = java.time.LocalTime.now();
            int hora = horaActual.getHour();

            String saludoDinamico = "Buenas noches";
            String iconDinamico = "moon"; // Icono de Lucide para la noche

            if (hora >= 6 && hora < 12) {
                saludoDinamico = "Buenos días";
                iconDinamico = "coffee";   // Icono de Lucide para la mañana
            } else if (hora >= 12 && hora < 19) {
                saludoDinamico = "Buenas tardes";
                iconDinamico = "sun";      // Icono de Lucide para la tarde
            }

            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM", new java.util.Locale("es", "ES"));
            String dia = hoy.format(formatter);
            String fechaActual = "Hoy es " + dia.substring(0, 1).toUpperCase() + dia.substring(1);

            request.setAttribute("saludoDinamico", saludoDinamico);
            request.setAttribute("iconDinamico", iconDinamico); // Se envía el nombre del icono
            request.setAttribute("fechaActual", fechaActual);
            // fin uwu

            switch (roleId) {

                case 1: { // Viewer — Solicitante
                    List<Transaction> mias = txDao.getByUser(userId);

                    int mes = 0, aprob = 0, pend = 0;
                    for (Transaction t : mias) {
                        String created = t.getCreatedAt();
                        if (created != null && created.compareTo(inicioMes) >= 0) {
                            mes++;
                        }
                        if ("APPROVED".equals(t.getStatus()) || "COMPLETED".equals(t.getStatus())) {
                            aprob++;
                        }
                        if ("PENDING".equals(t.getStatus())) {
                            pend++;
                        }
                    }

                    stat1 = mes;    label1 = "Mis pedidos este mes";
                    stat2 = aprob;  label2 = "Mis aprobados";
                    stat3 = pend;   label3 = "Mis pendientes";
                    break;
                }

                case 2: { // Member — Encargado de Depósito
                    int aprob = txDao.getApproved().size();

                    int entregadosMes = 0;
                    List<Transaction> todas = txDao.getAll();
                    for (Transaction t : todas) {
                        String created = t.getCreatedAt();
                        if ("COMPLETED".equals(t.getStatus())
                                && created != null && created.compareTo(inicioMes) >= 0) {
                            entregadosMes++;
                        }
                    }

                    int bajoStock = 0;
                    List<Item> items = itemDao.getAll();
                    for (Item it : items) {
                        if ("LOW".equals(it.getStatus()) || "UNAVAILABLE".equals(it.getStatus())) {
                            bajoStock++;
                        }
                    }

                    stat1 = aprob;        label1 = "Pedidos por entregar";
                    stat2 = entregadosMes; label2 = "Entregados este mes";
                    stat3 = bajoStock;    label3 = "Items con bajo stock";
                    break;
                }

                case 3: { // Manager — Aprobador
                    int pend = txDao.getPending().size();

                    int aprobMes = 0, rechMes = 0;
                    List<Transaction> todas = txDao.getAll();
                    for (Transaction t : todas) {
                        String created = t.getCreatedAt();
                        boolean delMes = created != null && created.compareTo(inicioMes) >= 0;
                        if (delMes && "APPROVED".equals(t.getStatus())
                                && t.getApproverId() == userId) {
                            aprobMes++;
                        }
                        if (delMes && "REJECTED".equals(t.getStatus())
                                && t.getApproverId() == userId) {
                            rechMes++;
                        }
                    }

                    stat1 = pend;     label1 = "Pendientes por aprobar";
                    stat2 = aprobMes; label2 = "Aprobadas este mes";
                    stat3 = rechMes;  label3 = "Rechazadas este mes";
                    break;
                }

                case 4: { // Administrador
                    int totalItems = itemDao.getAll().size();
                    int pendientes = txDao.getPending().size();
                    int aprobadosMes = 0;

                    List<Transaction> todas = txDao.getAll();
                    for (Transaction t : todas) {
                        String created = t.getCreatedAt();
                        if (created != null && created.compareTo(inicioMes) >= 0
                                && "APPROVED".equals(t.getStatus())) {
                            aprobadosMes++;
                        }
                    }

                    stat1 = totalItems;   label1 = "Items en inventario";
                    stat2 = pendientes;   label2 = "Solicitudes pendientes";
                    stat3 = aprobadosMes; label3 = "Aprobadas este mes";
                    break;
                }

                default:
                    label1 = "Estadística 1";
                    label2 = "Estadística 2";
                    label3 = "Estadística 3";
                    break;
            }

            // Enviar a la vista
            request.setAttribute("stat1", stat1);
            request.setAttribute("stat2", stat2);
            request.setAttribute("stat3", stat3);
            request.setAttribute("label1", label1);
            request.setAttribute("label2", label2);
            request.setAttribute("label3", label3);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar tus estadísticas: " + e.getMessage());
        }

        request.setAttribute("activeMenu", "home");
        request.getRequestDispatcher("home.jsp").forward(request, response);
    }
}