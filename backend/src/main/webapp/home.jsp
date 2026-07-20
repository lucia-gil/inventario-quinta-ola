<%--
    ════════════════════════════════════════════════════════════════════
     home.jsp — Vista PERSONAL del usuario (rediseño "Ola")
    ════════════════════════════════════════════════════════════════════
     Datos personalizados que recibe del HomeServlet:
     - stat1/stat2/stat3: números calculados desde BD según rol
     - label1/label2/label3: etiquetas adaptadas al rol
     - saludoDinamico / iconDinamico / fechaActual: saludos según la hora
     Iconos: Lucide (cargado globalmente desde footer.jsp)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.DeliveryEntry" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.TextStyle" %>
<%@ page import="java.util.Locale" %>
<%
    String ctx = request.getContextPath();
    String userName = (String) session.getAttribute("userName");
    String roleName = (String) session.getAttribute("roleName");
    Integer roleId  = (Integer) session.getAttribute("roleId");
    if (userName == null) userName = "Usuario";
    if (roleName == null) roleName = "";
    if (roleId == null) roleId = 0;

    Integer stat1 = (Integer) request.getAttribute("stat1");
    Integer stat2 = (Integer) request.getAttribute("stat2");
    Integer stat3 = (Integer) request.getAttribute("stat3");
    String label1 = (String) request.getAttribute("label1");
    String label2 = (String) request.getAttribute("label2");
    String label3 = (String) request.getAttribute("label3");
    if (stat1 == null) stat1 = 0;
    if (stat2 == null) stat2 = 0;
    if (stat3 == null) stat3 = 0;
    if (label1 == null) label1 = "—";
    if (label2 == null) label2 = "—";
    if (label3 == null) label3 = "—";

    // Recuperamos las variables del saludo dinámico
    String saludoDinamico = (String) request.getAttribute("saludoDinamico");
    String iconDinamico = (String) request.getAttribute("iconDinamico");
    String fechaActual = (String) request.getAttribute("fechaActual");
    if (saludoDinamico == null) saludoDinamico = "Hola";
    if (iconDinamico == null) iconDinamico = "hand";
    if (fechaActual == null) fechaActual = "";

    // ─── Widget "Próximas entregas" ───
    List<DeliveryEntry> proximasEntregas = (List<DeliveryEntry>) request.getAttribute("proximasEntregas");
    if (proximasEntregas == null) proximasEntregas = new java.util.ArrayList<DeliveryEntry>();

    LocalDate hoyLD = LocalDate.now();

    // Conteo de entregas por día, para pintar los puntitos en la franja
    int[] conteoPorDia = new int[7];
    for (DeliveryEntry de : proximasEntregas) {
        try {
            LocalDate fechaEntrega = LocalDate.parse(de.getEstimatedDelivery().length() > 10
                    ? de.getEstimatedDelivery().substring(0, 10) : de.getEstimatedDelivery());
            int offset = (int) java.time.temporal.ChronoUnit.DAYS.between(hoyLD, fechaEntrega);
            if (offset >= 0 && offset < 7) conteoPorDia[offset]++;
        } catch (Exception ignored) {}
    }

    request.setAttribute("activeMenu", "home");

    // Título del widget adaptado al rol: el Solicitante ve SUS pedidos,
    // los demás roles ven la operación completa del sistema.
    String deliveryWidgetTitle = (roleId == 1) ? "Mis próximas entregas" : "Próximas entregas";
    String deliveryEmptyText = (roleId == 1)
            ? "No tienes entregas programadas para esta semana."
            : "No hay entregas programadas para esta semana.";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Inicio | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=25" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- ─── HERO DE BIENVENIDA ─── --%>
            <div class="home-hero">
                <div class="home-hero-main">
                    <h2 class="home-hero-title">
                        <span class="home-hero-icon-badge"><i data-lucide="<%= iconDinamico %>"></i></span>
                        <%= saludoDinamico %>, <%= userName %>
                    </h2>
                    <p class="home-hero-sub">
                        <% if (!fechaActual.isEmpty()) { %>
                        <strong><%= fechaActual %>.</strong>
                        <% } %>

                        <% if (roleId == 1) { %>
                        Bienvenido(a) a tu espacio personal.
                        <% } else if (roleId == 2) { %>
                        Bienvenido(a) al panel de depósito.
                        <% } else if (roleId == 3) { %>
                        Bienvenido(a) al panel de aprobaciones.
                        <% } else if (roleId == 4) { %>
                        Bienvenido(a) al panel de administración.
                        <% } else { %>
                        Bienvenida al sistema de inventario de Quinta Ola.
                        <% } %>
                    </p>

                    <%-- Buscador rápido — te manda directo al inventario ya filtrado --%>
                    <div class="home-hero-search">
                        <form action="<%= ctx %>/InventoryServlet" method="GET">
                            <input type="hidden" name="action" value="lista"/>
                            <i data-lucide="search"></i>
                            <input type="text" name="q" placeholder="¿Qué material necesitas hoy?" autocomplete="off"/>
                            <button type="submit" aria-label="Buscar"><i data-lucide="arrow-right"></i></button>
                        </form>
                    </div>
                </div>

                <%-- Se ocultan por completo los botones superiores para el rol de depósito (roleId == 2) --%>
                <% if (roleId != 2) { %>
                <div class="home-hero-actions">
                    <a href="<%= ctx %>/HistoryServlet" class="btn-ghost btn-icon">
                        <i data-lucide="file-text"></i>
                        <span>Ver Historial</span>
                    </a>
                    <a href="<%= ctx %>/TransactionServlet?action=formCrear&origen=home" class="btn-page-primary btn-icon">
                        <i data-lucide="plus"></i>
                        <span>Nueva Solicitud</span>
                    </a>
                </div>
                <% } %>
            </div>

            <%-- ─── STAT CARDS CON DATOS REALES (animadas al cargar) ─── --%>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6" style="margin-top: 1.75rem;">

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label"><%= label1 %></p>
                        <p class="stat-card-value" data-count-target="<%= stat1 %>">0</p>
                    </div>
                    <div class="stat-card-icon stat-icon-blue">
                        <i data-lucide="package"></i>
                    </div>
                </div>

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label"><%= label2 %></p>
                        <p class="stat-card-value" data-count-target="<%= stat2 %>">0</p>
                    </div>
                    <div class="stat-card-icon stat-icon-green">
                        <i data-lucide="check-circle"></i>
                    </div>
                </div>

                <div class="stat-card">
                    <div>
                        <p class="stat-card-label"><%= label3 %></p>
                        <p class="stat-card-value" data-count-target="<%= stat3 %>">0</p>
                    </div>
                    <div class="stat-card-icon stat-icon-pink">
                        <i data-lucide="clock"></i>
                    </div>
                </div>

            </div>

            <%-- ─── PRÓXIMAS ENTREGAS ─── --%>
            <div class="delivery-timeline">
                <div class="delivery-timeline-header">
                    <div class="delivery-timeline-title">
                        <i data-lucide="calendar-clock"></i>
                        <%= deliveryWidgetTitle %>
                    </div>
                    <span class="delivery-timeline-badge">Próximos 7 días</span>
                </div>

                <%-- Franja de 7 días — clickeable: filtra la lista de abajo a ese día --%>
                <div class="delivery-days-strip" id="deliveryDaysStrip">
                    <% for (int i = 0; i < 7; i++) {
                        LocalDate dia = hoyLD.plusDays(i);
                        String isoDia = dia.toString(); // yyyy-MM-dd
                        String dow = dia.getDayOfWeek().getDisplayName(TextStyle.SHORT, new Locale("es", "ES")).toUpperCase();
                        boolean esHoy = (i == 0);
                        boolean tieneEntregas = conteoPorDia[i] > 0;
                        String chipClass = (esHoy ? "is-today " : "") + (tieneEntregas ? "has-deliveries" : "");
                    %>
                    <button type="button" class="delivery-day-chip <%= chipClass %>"
                            data-date="<%= isoDia %>" onclick="filtrarEntregasPorDia('<%= isoDia %>', this)">
                        <span class="delivery-day-dow"><%= dow %></span>
                        <span class="delivery-day-num"><%= dia.getDayOfMonth() %></span>
                        <% if (tieneEntregas) { %>
                        <span class="delivery-day-dot-count"><%= conteoPorDia[i] %></span>
                        <% } %>
                    </button>
                    <% } %>
                </div>
                <p class="delivery-filter-hint" id="deliveryFilterHint" style="display:none;">
                    Mostrando solo ese día — <a href="javascript:void(0)" onclick="limpiarFiltroDia()">ver todos los días</a>
                </p>

                <%-- Lista de entregas --%>
                <% if (proximasEntregas.isEmpty()) { %>
                <div class="delivery-empty">
                    <i data-lucide="package-check"></i>
                    <p><%= deliveryEmptyText %></p>
                </div>
                <% } else { %>
                <div class="delivery-list" id="deliveryList">
                    <% for (DeliveryEntry de : proximasEntregas) {
                        String badgeClass = "delivery-badge--later";
                        String badgeText  = "Programada";
                        String isoEntrega = de.getEstimatedDelivery();
                        if (isoEntrega != null && isoEntrega.length() > 10) isoEntrega = isoEntrega.substring(0, 10);
                        String fechaTexto = isoEntrega;
                        try {
                            LocalDate fechaEntrega = LocalDate.parse(isoEntrega);
                            long offset = java.time.temporal.ChronoUnit.DAYS.between(hoyLD, fechaEntrega);
                            if (offset <= 0)      { badgeClass = "delivery-badge--today"; badgeText = "Hoy"; }
                            else if (offset <= 2) { badgeClass = "delivery-badge--soon";  badgeText = "Pronto"; }
                            fechaTexto = String.format("%02d-%02d-%d",
                                    fechaEntrega.getDayOfMonth(), fechaEntrega.getMonthValue(), fechaEntrega.getYear());
                        } catch (Exception ignored) {}
                    %>
                    <a href="<%= ctx %>/TransactionServlet?action=detalle&id=<%= de.getTransactionId() %>&origen=home"
                       class="delivery-item" data-date="<%= isoEntrega %>">
                        <span class="delivery-item-badge <%= badgeClass %>"><%= badgeText %></span>
                        <div class="delivery-item-main">
                            <div class="delivery-item-name"><%= de.getItemName() %> · <%= de.getQuantity() %> <%= de.getItemUnit() %></div>
                            <div class="delivery-item-sub">Para <%= de.getRequesterName() %> · <%= fechaTexto %></div>
                        </div>
                        <i data-lucide="chevron-right"></i>
                    </a>
                    <% } %>
                </div>
                <p class="delivery-filter-empty" id="deliveryFilterEmpty" style="display:none;">
                    No hay entregas programadas ese día.
                </p>
                <% } %>
            </div>

            <%-- ─── ACCESOS RÁPIDOS ─── --%>
            <div style="margin-top: 1.75rem;">
                <h3 class="text-lg font-bold text-secondary mb-4">Accesos rápidos</h3>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">

                    <a href="<%= ctx %>/HistoryServlet" class="quick-card">
                        <div class="quick-card-icon quick-icon-blue">
                            <i data-lucide="file-text"></i>
                        </div>
                        <h3 class="quick-card-title">Mi Historial</h3>
                        <p class="quick-card-desc">Visualiza tus movimientos</p>
                    </a>

                    <%-- El encargado de depósito (roleId == 2) no ve este acceso rápido --%>
                    <% if (roleId != 2) { %>
                    <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="quick-card">
                        <div class="quick-card-icon quick-icon-pink">
                            <i data-lucide="shopping-cart"></i>
                        </div>
                        <h3 class="quick-card-title">Solicitar Material</h3>
                        <p class="quick-card-desc">Registra un nuevo pedido</p>
                    </a>
                    <% } %>

                    <a href="<%= ctx %>/ProfileServlet" class="quick-card">
                        <div class="quick-card-icon quick-icon-purple">
                            <i data-lucide="user"></i>
                        </div>
                        <h3 class="quick-card-title">Mi Perfil</h3>
                        <p class="quick-card-desc">Gestiona tus datos</p>
                    </a>

                    <%-- Atajo CONTEXTUAL según rol --%>
                    <% if (roleId == 2) { %>
                    <a href="<%= ctx %>/DepositServlet" class="quick-card">
                        <div class="quick-card-icon quick-icon-orange">
                            <i data-lucide="truck"></i>
                        </div>
                        <h3 class="quick-card-title">Entregar Pedidos</h3>
                        <p class="quick-card-desc">Marca solicitudes aprobadas</p>
                    </a>
                    <% } else if (roleId == 3) { %>
                    <a href="<%= ctx %>/TransactionServlet" class="quick-card">
                        <div class="quick-card-icon quick-icon-green">
                            <i data-lucide="check-circle"></i>
                        </div>
                        <h3 class="quick-card-title">Aprobar Solicitudes</h3>
                        <p class="quick-card-desc">Revisa pendientes</p>
                    </a>
                    <% } else if (roleId == 4) { %>
                    <a href="<%= ctx %>/UserServlet" class="quick-card">
                        <div class="quick-card-icon quick-icon-green">
                            <i data-lucide="users"></i>
                        </div>
                        <h3 class="quick-card-title">Miembros</h3>
                        <p class="quick-card-desc">Gestiona usuarios</p>
                    </a>
                    <% } else { %>
                    <a href="<%= ctx %>/InventoryServlet" class="quick-card">
                        <div class="quick-card-icon quick-icon-orange">
                            <i data-lucide="package"></i>
                        </div>
                        <h3 class="quick-card-title">Inventario</h3>
                        <p class="quick-card-desc">Ver catálogo</p>
                    </a>
                    <% } %>

                </div>
            </div>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();

        // ─── Animación de conteo en las stat cards ───
        // Sube cada número desde 0 hasta su valor real al cargar la página.
        var valores = document.querySelectorAll('.stat-card-value[data-count-target]');
        valores.forEach(function (el) {
            var target = parseInt(el.getAttribute('data-count-target'), 10) || 0;
            var duracion = 900; // ms
            var inicio = null;

            function paso(timestamp) {
                if (!inicio) inicio = timestamp;
                var progreso = Math.min((timestamp - inicio) / duracion, 1);
                // easeOutQuad — arranca rápido, desacelera al final
                var facil = 1 - (1 - progreso) * (1 - progreso);
                el.textContent = Math.floor(facil * target);
                if (progreso < 1) {
                    requestAnimationFrame(paso);
                } else {
                    el.textContent = target;
                }
            }
            requestAnimationFrame(paso);
        });
    });

    /**
     * Filtra la lista de "Próximas entregas" a un solo día al hacer clic
     * en su chip de la franja de 7 días. Vuelve a hacer clic en el mismo
     * día (o en "ver todos los días") para quitar el filtro.
     */
    var deliveryDiaSeleccionado = null;

    function filtrarEntregasPorDia(iso, chipEl) {
        // Si ya estaba seleccionado ese mismo día, actúa como "quitar filtro"
        if (deliveryDiaSeleccionado === iso) {
            limpiarFiltroDia();
            return;
        }
        deliveryDiaSeleccionado = iso;

        document.querySelectorAll('.delivery-day-chip').forEach(function (chip) {
            chip.classList.toggle('is-selected', chip === chipEl);
        });

        aplicarFiltroDia();
    }

    function limpiarFiltroDia() {
        deliveryDiaSeleccionado = null;
        document.querySelectorAll('.delivery-day-chip').forEach(function (chip) {
            chip.classList.remove('is-selected');
        });
        aplicarFiltroDia();
    }

    function aplicarFiltroDia() {
        var items = document.querySelectorAll('.delivery-item');
        var visibles = 0;

        items.forEach(function (item) {
            var coincide = !deliveryDiaSeleccionado || item.getAttribute('data-date') === deliveryDiaSeleccionado;
            item.style.display = coincide ? '' : 'none';
            if (coincide) visibles++;
        });

        var hint = document.getElementById('deliveryFilterHint');
        if (hint) hint.style.display = deliveryDiaSeleccionado ? 'block' : 'none';

        var vacioMsg = document.getElementById('deliveryFilterEmpty');
        if (vacioMsg) vacioMsg.style.display = (deliveryDiaSeleccionado && visibles === 0) ? 'block' : 'none';
    }
</script>

</body>
</html>
