package com.quintaola.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

/**
 * ════════════════════════════════════════════════════════════════════
 * AppInitializer — Listener que se ejecuta al arrancar la app
 * ════════════════════════════════════════════════════════════════════
 *
 * Tomcat invoca contextInitialized() una sola vez al levantar el
 * contexto de la aplicación. Aprovechamos ese momento para:
 *
 *   1. Cargar las credenciales SMTP del web.xml.
 *   2. Inyectarlas en el EmailService.
 *
 * Así, desde cualquier punto del sistema podemos llamar a
 * EmailService.enviarBienvenida(...) sin pasarle el ServletContext.
 * ════════════════════════════════════════════════════════════════════
 */
@WebListener
public class AppInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AppInitializer] Iniciando servicios...");
        EmailService.init(sce.getServletContext());
        System.out.println("[AppInitializer] Servicios listos.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AppInitializer] Aplicación detenida.");
    }
}