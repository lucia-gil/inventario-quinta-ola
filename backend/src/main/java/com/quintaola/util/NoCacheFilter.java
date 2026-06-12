package com.quintaola.util;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * ════════════════════════════════════════════════════════════════════
 * NoCacheFilter — Anti caché del navegador en páginas autenticadas
 * ════════════════════════════════════════════════════════════════════
 *
 * Inyecta cabeceras HTTP que indican al navegador NO cachear las
 * respuestas. Esto evita que al cerrar sesión y darle "atrás" en el
 * navegador, el usuario vea la última pantalla protegida desde caché.
 *
 * Aplica a todas las rutas EXCEPTO recursos estáticos (CSS, JS, imágenes)
 * que sí deben cachearse para rendimiento.
 *
 * Cabeceras usadas:
 *   - Cache-Control: no-store, no-cache, must-revalidate, max-age=0
 *     → "no guardes esto en caché ni en disco"
 *   - Pragma: no-cache
 *     → compatibilidad con HTTP/1.0
 *   - Expires: 0
 *     → indica que el contenido ya está expirado
 * ════════════════════════════════════════════════════════════════════
 */
@WebFilter("/*")
public class NoCacheFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getRequestURI();

        // Permitir caché en recursos estáticos (CSS, JS, imágenes, fuentes)
        boolean esEstatico = path.endsWith(".css")
                || path.endsWith(".js")
                || path.endsWith(".png")
                || path.endsWith(".jpg")
                || path.endsWith(".jpeg")
                || path.endsWith(".gif")
                || path.endsWith(".svg")
                || path.endsWith(".webp")
                || path.endsWith(".ico")
                || path.endsWith(".woff")
                || path.endsWith(".woff2")
                || path.endsWith(".ttf");

        if (!esEstatico) {
            // Aplicar cabeceras anti-caché a TODAS las páginas dinámicas
            res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
            res.setHeader("Pragma", "no-cache");
            res.setDateHeader("Expires", 0);
        }

        chain.doFilter(request, response);
    }
}
