<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String ctx = request.getContextPath(); %>

<footer class="footer">
    <div class="footer-inner">
        <div class="footer-brand">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png" class="h-14"/>
            <p class="footer-desc">
                Sistema de gestión de inventarios interno de Quinta Ola.
            </p>
        </div>
        <div class="space-y-4">
            <h4 class="footer-col-title">Menú</h4>
            <ul class="space-y-3">
                <li><a href="<%= ctx %>/HomeServlet"      class="footer-link">Inicio</a></li>
                <li><a href="<%= ctx %>/DashboardServlet" class="footer-link">Dashboard</a></li>
                <li><a href="<%= ctx %>/HistoryServlet"   class="footer-link">Historial</a></li>
                <li><a href="<%= ctx %>/InventoryServlet" class="footer-link">Inventario</a></li>
            </ul>
        </div>
        <div class="space-y-4">
            <h4 class="footer-col-title">Mi Cuenta</h4>
            <ul class="space-y-3">
                <li><a href="<%= ctx %>/ProfileServlet" class="footer-link">Mi Perfil</a></li>
                <li><a href="<%= ctx %>/AuthServlet?action=logout" class="footer-link">Cerrar Sesión</a></li>
            </ul>
        </div>
    </div>
    <div class="footer-bottom">
        <p>© 2026 Quinta Ola — Sistema de Inventarios</p>
    </div>
</footer>

<%-- ════════════════════════════════════════════════════════════════
     LUCIDE ICONS — carga global (una sola vez por página)
     ════════════════════════════════════════════════════════════════
     Cualquier <i data-lucide="nombre-del-icono"></i> se renderiza
     automáticamente como SVG cuando se llama a lucide.createIcons().
     ════════════════════════════════════════════════════════════════ --%>
<script src="https://unpkg.com/lucide@latest"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
    });
</script>