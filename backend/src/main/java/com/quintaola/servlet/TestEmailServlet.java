package com.quintaola.servlet;

import com.quintaola.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * ⚠️ SERVLET DE PRUEBA — eliminar antes del entregable.
 *
 * URL: http://localhost:8080/inventario/TestEmailServlet?email=tucorreo@gmail.com
 */
@WebServlet(name = "TestEmailServlet", value = "/TestEmailServlet")
public class TestEmailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        res.setContentType("text/html;charset=UTF-8");
        PrintWriter out = res.getWriter();

        String destinatario = req.getParameter("email");
        if (destinatario == null || destinatario.isEmpty()) {
            out.println("<h2>Falta el parámetro ?email=...</h2>");
            out.println("<p>Usa: <code>/TestEmailServlet?email=tucorreo@gmail.com</code></p>");
            return;
        }

        out.println("<h2>Enviando correo de prueba a: " + destinatario + "</h2>");
        out.println("<p>Mira la consola de Tomcat para ver los logs.</p>");

        boolean ok = EmailService.enviarBienvenida(destinatario, "Lucía Gil");

        if (ok) {
            out.println("<h3 style='color:green'>✓ Correo enviado. Revisa tu bandeja de entrada (y spam).</h3>");
        } else {
            out.println("<h3 style='color:red'>✗ Falló el envío. Revisa la consola de Tomcat.</h3>");
        }
    }
}