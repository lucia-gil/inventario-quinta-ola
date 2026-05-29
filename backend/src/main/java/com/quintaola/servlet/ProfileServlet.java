package com.quintaola.servlet;

import com.quintaola.dao.UserDAO;
import com.quintaola.model.User;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * ════════════════════════════════════════════════════════════════════
 *  ProfileServlet — Controlador de la página "Mi Perfil"
 * ════════════════════════════════════════════════════════════════════
 *
 *  PROPOSITO:
 *  Este servlet es el "controlador" en el patrón MVC
 *  Su trabajo es:
 *    1. Recibir la petición del navegador cuando el usuario quiere ver su perfil
 *    2. Pedirle al UserDAO los datos del usuario logueado
 *    3. Pasar esos datos al profile.jsp mediante request.setAttribute()
 *    4. Reenviar la ejecución al JSP con RequestDispatcher.forward()
 *
 *  PATRÓN DEL CURSO:
 *  Usa switch-case con parámetro "action".
 *  Esto permite que UN solo servlet maneje varias operaciones.
 *
 *  URLs que escucha:
 *    GET  /ProfileServlet                          → muestra perfil
 *    POST /ProfileServlet (action=cambiarPassword) → cambia contraseña
 *
 *  El usuario lo sacamos de la SESIÓN. AuthServlet guardó el userId al hacer login,
 *      y aquí lo leo con session.getAttribute("userId").
 * ════════════════════════════════════════════════════════════════════
 */
@WebServlet(name = "ProfileServlet", value = "/ProfileServlet")
public class ProfileServlet extends HttpServlet {

    /* ────────────────────────────────────────────────────────────────
     *  doGet: se ejecuta cuando el navegador hace GET /ProfileServlet
     *  Maneja: ver perfil (default) o cualquier futura acción GET
     * ──────────────────────────────────────────────────────────────── */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ─── 1. LEER PARÁMETRO action ───
        // Si no llega action, asumimos "ver" (mostrar perfil)
        String action = request.getParameter("action") == null
                ? "ver"
                : request.getParameter("action");

        // ─── 2. INSTANCIAR EL DAO ───
        // El DAO es el "modelo" que habla con la BD (Clase 7.2 slide 42)
        UserDAO userDao = new UserDAO();
        RequestDispatcher view;

        // ─── 3. ENRUTAR SEGÚN LA ACCIÓN ───
        switch (action) {

            // CASE "ver" → mostrar la página de perfil
            case "ver":
                try {
                    // 3.1. Obtener el ID del usuario logueado desde la SESIÓN
                    // AuthServlet guardó este atributo al hacer login
                    Integer userId = (Integer) request.getSession().getAttribute("userId");

                    // 3.2. Si no hay sesión válida, mandar al login
                    if (userId == null) {
                        response.sendRedirect(request.getContextPath()
                                + "/AuthServlet?action=formLogin");
                        return;
                    }

                    // 3.3. Pedirle al DAO los datos completos del usuario
                    // Esto ejecuta un SELECT en la tabla users
                    User usuario = userDao.getById(userId);

                    // 3.4. INYECTAR los datos en el request para la vista
                    // El JSP los leerá con request.getAttribute("usuario")
                    // Compañeros esto se enseño en la clase 7.2 slide 49)
                    request.setAttribute("usuario", usuario);
                    request.setAttribute("activeMenu", "profile");

                    // 3.5. REDIRIGIR al JSP con forward
                    // forward NO cambia la URL del navegador (se enseño en la clase 7.2 slide 50)
                    view = request.getRequestDispatcher("profile.jsp");
                    view.forward(request, response);

                } catch (Exception e) {
                    // Si algo falla, se va a mostrar el error en la misma vista
                    request.setAttribute("error", "Error al cargar perfil: " + e.getMessage());
                    view = request.getRequestDispatcher("profile.jsp");
                    view.forward(request, response);
                }
                break;

            default:
                // Cualquier action desconocida → redirigir al perfil
                response.sendRedirect(request.getContextPath() + "/ProfileServlet");
                break;
        }
    }

    /* ────────────────────────────────────────────────────────────────
     *  doPost: se ejecuta cuando llega un formulario POST
     *  Por ahora solo prepara el cambio de contraseña
     * ──────────────────────────────────────────────────────────────── */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar UTF-8 ANTES de leer parámetros (Clase 7.3 pagina 16)
        // Sin esto, las tildes y ñ llegan como caracteres raros
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null
                ? "" : request.getParameter("action");

        switch (action) {
            case "cambiarPassword":
                // TODO: Implementar en Sprint 3
                // Por ahora solo redirige con un mensaje
                response.sendRedirect(request.getContextPath()
                        + "/ProfileServlet?success=Funcionalidad+en+desarrollo");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/ProfileServlet");
                break;
        }
    }
}