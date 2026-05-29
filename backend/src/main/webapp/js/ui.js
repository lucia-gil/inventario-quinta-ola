/* ============================================================
   QUINTA OLA - ui.js
   ============================================================
   Antes este archivo generaba la navbar, el footer, las tablas
   y los badges desde JavaScript leyendo localStorage. Ya no:
   ahora la navbar es includes/navbar.jsp, el footer es
   includes/footer.jsp, y las tablas se pintan con scriptlets
   en cada JSP. Todo lado servidor.

   Este archivo se mantiene solo por compatibilidad con vistas
   antiguas. NO USAR en JSPs nuevos.

   Aqui solo dejamos QO.init() para inicializar los iconos de
   Lucide (que son visuales, no logica de negocio).
   ============================================================ */

const QO = {

    // Inicializa los iconos de Lucide (los <i data-lucide="..."></i>
    // se convierten en SVG cuando se llama esta funcion).
    init: function() {
        if (window.lucide) {
            lucide.createIcons();
        }
    }
};

// Cuando carga la pagina, dibujamos los iconos automaticamente.
document.addEventListener('DOMContentLoaded', function() {
    QO.init();
});