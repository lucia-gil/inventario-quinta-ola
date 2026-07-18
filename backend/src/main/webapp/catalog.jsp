<%--
    ════════════════════════════════════════════════════════════════════
     catalog.jsp — Vitrina pública de materiales (Rediseño Integrado)
    ════════════════════════════════════════════════════════════════════
     - Navbar y Footer IDÉNTICOS al index.jsp
     - Soporte para fotos de materiales (con fallback a gradiente/ícono)
     - Paginación dinámica integrada con filtros
     - Sin breadcrumb en el hero
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();
    List<Item> items = (List<Item>) request.getAttribute("items");

    // Capturamos sesión de forma pasiva
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String roleName = (String) session.getAttribute("roleName");
    boolean estaLogueado = (userId != null);

    // Contar items por estado
    int totalItems = items != null ? items.size() : 0;
    int itemsOk = 0;
    int itemsBajo = 0;
    int itemsAgotado = 0;
    if (items != null) {
        for (Item it : items) {
            int qty = it.getCachedQuantity();
            int min = it.getMinQuantity();
            if (qty <= 0) itemsAgotado++;
            else if (qty <= min) itemsBajo++;
            else itemsOk++;
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Catálogo de Materiales | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=12" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Layout Base ═════ */
        .public-body {
            background: var(--gray-50);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            margin: 0;
            padding: 0;
            font-family: 'Montserrat', sans-serif;
        }

        /* ─── Navbar público (IDÉNTICO al index.jsp) ─── */
        .public-navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            padding: 0.75rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            z-index: 50;
        }
        .public-navbar-logo {
            height: 56px;
            width: auto;
            object-fit: contain;
        }
        .public-navbar-actions {
            display: flex;
            gap: 1.5rem;
            align-items: center;
            font-size: 0.875rem;
        }
        .public-nav-link {
            color: var(--purple);
            font-weight: 700;
            font-size: 0.9rem;
            text-decoration: none;
            transition: color var(--transition);
        }
        .public-nav-link:hover {
            color: var(--pink);
        }
        .public-nav-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            background: var(--pink);
            color: var(--white);
            padding: 0.625rem 1.25rem;
            border-radius: var(--radius-full);
            font-weight: 700;
            transition: all var(--transition);
            box-shadow: 0 2px 8px rgba(233, 30, 140, 0.25);
            text-decoration: none;
        }
        .public-nav-btn:hover {
            background: var(--purple);
            transform: translateY(-1px);
        }
        .public-nav-btn i { width: 16px; height: 16px; }

        /* ═════ Hero ═════ */
        .catalog-hero {
            background: linear-gradient(135deg, var(--purple) 0%, var(--purple-dark) 60%, var(--pink) 100%);
            padding: 3rem 2.5rem 4rem;
            position: relative;
            overflow: hidden;
            margin-top: 80px; /* Espacio para el navbar fixed */
        }
        .catalog-hero::before {
            content: ''; position: absolute; top: -50px; right: -50px; width: 220px; height: 220px;
            border-radius: 50%; background: var(--yellow); opacity: 0.15;
        }
        .catalog-hero::after {
            content: ''; position: absolute; bottom: -80px; left: 20%; width: 180px; height: 180px;
            border-radius: 50%; background: var(--pink-light); opacity: 0.12;
        }
        .catalog-hero-inner {
            max-width: 1400px; margin: 0 auto; position: relative; z-index: 1;
        }
        .catalog-hero-title {
            color: var(--white); font-size: 2.2rem; font-weight: 800; margin: 0 0 0.5rem;
            letter-spacing: -0.5px;
        }
        .catalog-hero-subtitle {
            color: rgba(255,255,255,0.85); font-size: 1rem; font-weight: 500;
            margin: 0 0 1.5rem; max-width: 640px; line-height: 1.55;
        }
        .catalog-hero-stats {
            display: flex; gap: 1rem; flex-wrap: wrap; margin-top: 1.25rem;
        }
        .hero-stat {
            background: rgba(255,255,255,0.12); backdrop-filter: blur(8px);
            border: 1px solid rgba(255,255,255,0.18); padding: 0.6rem 1.1rem;
            border-radius: var(--radius-full); color: var(--white); font-size: 0.82rem;
            font-weight: 600; display: inline-flex; align-items: center; gap: 0.5rem;
        }
        .hero-stat i { width: 14px; height: 14px; }

        /* ═════ Main & Filters ═════ */
        .catalog-main {
            flex: 1; max-width: 1400px; margin: 0 auto; width: 100%; padding: 2rem 2.5rem 3rem;
        }
        .catalog-filters {
            background: var(--white); border-radius: var(--radius-lg); padding: 1.25rem;
            box-shadow: var(--shadow-sm); border: 1px solid var(--gray-100);
            display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;
            margin-top: -2.5rem; position: relative; z-index: 2; margin-bottom: 2rem;
        }
        .catalog-search-wrap {
            position: relative; flex: 1; min-width: 260px;
        }
        .catalog-search-icon {
            position: absolute; left: 1rem; top: 50%; transform: translateY(-50%);
            color: var(--gray-400); width: 18px; height: 18px; pointer-events: none;
        }
        .catalog-search-input {
            width: 100%; border: 1.5px solid var(--gray-200); border-radius: var(--radius-full);
            padding: 0.7rem 1.25rem 0.7rem 2.85rem; font-size: 0.92rem; color: var(--gray-800);
            outline: none; background: var(--gray-50); transition: all var(--transition);
            font-family: inherit;
        }
        .catalog-search-input:focus {
            border-color: var(--purple); background: var(--white);
            box-shadow: 0 0 0 4px rgba(91, 31, 168, 0.08);
        }
        .filter-chips { display: flex; gap: 0.4rem; flex-wrap: wrap; }
        .filter-chip {
            padding: 0.5rem 1rem; border-radius: var(--radius-full); font-size: 0.78rem;
            font-weight: 700; background: var(--gray-50); border: 1.5px solid var(--gray-200);
            color: var(--gray-600); cursor: pointer; transition: all var(--transition);
            display: inline-flex; align-items: center; gap: 0.35rem;
            font-family: inherit;
        }
        .filter-chip:hover { border-color: var(--purple); color: var(--purple); background: var(--purple-bg); }
        .filter-chip.active { background: var(--purple); border-color: var(--purple); color: var(--white); }
        .filter-chip i { width: 12px; height: 12px; }

        /* ═════ Grid ═════ */
        .catalog-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1.25rem;
        }

        /* ═════ Cards (Soporte Imágenes) ═════ */
        .item-card {
            background: var(--white); border: 1.5px solid var(--gray-100);
            border-radius: var(--radius-lg); overflow: hidden; transition: all var(--transition);
            display: flex; flex-direction: column; position: relative;
        }
        .item-card:hover {
            transform: translateY(-3px); box-shadow: 0 10px 30px rgba(91, 31, 168, 0.12); border-color: var(--purple-bg);
        }

        .item-card-icon-wrap {
            height: 160px; display: flex; align-items: center; justify-content: center;
            position: relative; overflow: hidden; background: var(--gray-100);
        }

        .item-card-image {
            width: 100%; height: 100%; object-fit: cover; position: absolute; top: 0; left: 0; z-index: 0;
            transition: transform 0.5s ease;
        }
        .item-card:hover .item-card-image {
            transform: scale(1.05);
        }

        .item-icon-purple { background: linear-gradient(135deg, #5B1FA8 0%, #7C3AED 100%); }
        .item-icon-pink   { background: linear-gradient(135deg, #E91E8C 0%, #F472B6 100%); }
        .item-icon-blue   { background: linear-gradient(135deg, #3B82F6 0%, #60A5FA 100%); }
        .item-icon-green  { background: linear-gradient(135deg, #16A34A 0%, #22C55E 100%); }
        .item-icon-amber  { background: linear-gradient(135deg, #F59E0B 0%, #FBBF24 100%); }

        .item-card-icon {
            color: var(--white); width: 56px; height: 56px; position: relative; z-index: 1; stroke-width: 1.5;
        }

        .item-card-sku, .item-card-status {
            position: absolute; top: 12px; z-index: 2; padding: 0.25rem 0.7rem;
            border-radius: var(--radius-full); font-weight: 800; letter-spacing: 0.5px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15); backdrop-filter: blur(4px);
        }
        .item-card-sku {
            left: 12px; background: rgba(255,255,255,0.95); color: var(--purple); font-size: 0.68rem; font-family: 'Courier New', monospace;
        }
        .item-card-status {
            right: 12px; font-size: 0.65rem; text-transform: uppercase;
        }

        .status-ok  { background: rgba(255,255,255,0.95); color: var(--green-dark); }
        .status-low { background: rgba(253,230,138,0.95); color: var(--orange-dark); }
        .status-out { background: rgba(239,68,68,0.95);   color: var(--white); }

        .item-card-body { padding: 1.15rem 1.25rem 1rem; display: flex; flex-direction: column; flex: 1; }
        .item-card-title { font-size: 1rem; font-weight: 700; color: var(--gray-800); margin: 0 0 0.4rem; line-height: 1.35; min-height: 2.7em; }
        .item-card-tags { display: flex; flex-wrap: wrap; gap: 0.3rem; margin-bottom: 0.85rem; }
        .item-tag { font-size: 0.68rem; font-weight: 700; color: var(--purple); background: var(--purple-bg); padding: 0.2rem 0.55rem; border-radius: var(--radius-full); }
        .item-card-stock { display: flex; justify-content: space-between; align-items: center; padding: 0.7rem 0; border-top: 1px solid var(--gray-100); margin-top: auto; }
        .stock-label { font-size: 0.72rem; font-weight: 700; color: var(--gray-500); text-transform: uppercase; }
        .stock-value { font-size: 1rem; font-weight: 800; color: var(--gray-800); }
        .stock-unit { font-size: 0.75rem; font-weight: 500; color: var(--gray-500); margin-left: 0.2rem; }

        .item-card-cta {
            display: flex; align-items: center; justify-content: center; gap: 0.4rem; padding: 0.75rem;
            font-size: 0.82rem; font-weight: 700; text-decoration: none; transition: all var(--transition);
            border-top: 1px solid var(--gray-100);
        }
        .item-cta-login { color: var(--gray-600); background: var(--gray-50); }
        .item-cta-login:hover { background: var(--purple-bg); color: var(--purple); }
        .item-cta-request { color: var(--white); background: linear-gradient(135deg, var(--purple) 0%, var(--pink) 100%); }
        .item-cta-request:hover { opacity: 0.92; }

        /* Paginación: ver componente global ".pager" en style.css */
        #pagination-controls {
            grid-column: 1 / -1;
            margin-top: 2.5rem;
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }

        /* ═════ Empty State ═════ */
        .catalog-empty {
            grid-column: 1 / -1; background: var(--white); border-radius: var(--radius-lg);
            border: 2px dashed var(--gray-200); padding: 5rem 2rem; text-align: center;
            display: none;
        }
        .catalog-empty-icon {
            display: inline-flex; align-items: center; justify-content: center; width: 72px; height: 72px;
            background: var(--purple-bg); color: var(--purple); border-radius: 50%; margin-bottom: 1rem;
        }
        .catalog-empty-icon i { width: 32px; height: 32px; }
        .catalog-empty-title { font-size: 1.15rem; font-weight: 700; color: var(--gray-700); margin-bottom: 0.4rem; }
        .catalog-empty-desc { font-size: 0.9rem; color: var(--gray-500); }

        /* ─── FOOTER (IDÉNTICO al index.jsp) ─── */
        .public-footer {
            background: var(--gray-900);
            color: var(--gray-400);
            border-top: 1px solid var(--gray-800);
            padding: 4rem 1.5rem 2rem;
        }
        .public-footer-inner {
            max-width: 72rem;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr;
            gap: 2.5rem;
            margin-bottom: 3rem;
            font-size: 0.875rem;
        }
        @media (min-width: 768px) {
            .public-footer-inner { grid-template-columns: 2fr 1fr 1fr; }
        }
        .public-footer-brand img {
            height: 56px;
            width: auto;
            filter: brightness(0) invert(1);
            margin-bottom: 1.25rem;
        }
        .public-footer-brand p {
            max-width: 24rem;
            line-height: 1.7;
            color: var(--gray-400);
            margin-bottom: 1.25rem;
        }
        .public-footer-social {
            display: flex;
            gap: 0.75rem;
        }
        .public-footer-social a {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: var(--gray-800);
            color: var(--gray-400);
            transition: all var(--transition);
            text-decoration: none;
        }
        .public-footer-social a:hover {
            background: var(--pink);
            color: var(--white);
            transform: translateY(-2px);
        }
        .public-footer-social i { width: 16px; height: 16px; }

        .public-footer-col h4 {
            color: var(--white);
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            margin-bottom: 1rem;
        }
        .public-footer-col ul { list-style: none; padding: 0; }
        .public-footer-col li { margin-bottom: 0.75rem; }
        .public-footer-col a {
            color: var(--gray-400);
            transition: color var(--transition);
            text-decoration: none;
        }
        .public-footer-col a:hover { color: var(--pink-light); }

        .public-footer-bottom {
            max-width: 72rem;
            margin: 0 auto;
            padding-top: 2rem;
            border-top: 1px solid var(--gray-800);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            font-size: 0.75rem;
            color: var(--gray-500);
        }
        @media (min-width: 768px) {
            .public-footer-bottom { flex-direction: row; }
        }
        .public-footer-bottom i {
            width: 12px;
            height: 12px;
            display: inline;
            color: var(--pink);
            fill: var(--pink);
        }

        @media (max-width: 768px) {
            .public-navbar { padding: 0.75rem 1.25rem; }
            .catalog-hero { padding: 2rem 1.25rem 3rem; }
            .catalog-hero-title { font-size: 1.6rem; }
            .catalog-main { padding: 1.5rem 1.25rem 2rem; }
            .catalog-grid { grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 1rem; }
        }
    </style>
</head>

<body class="public-body">

<%-- ═════ NAVBAR PÚBLICO (IDÉNTICO al index.jsp) ═════ --%>
<nav class="public-navbar">
    <div>
        <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Quinta Ola" class="public-navbar-logo"/>
    </div>
    <div class="public-navbar-actions">
        <a href="<%= ctx %>/CatalogServlet" class="public-nav-link">Nuestros productos</a>

        <% if (estaLogueado) { %>
        <a href="<%= ctx %>/HomeServlet" class="public-nav-btn">
            <i data-lucide="layout-dashboard"></i> Ir al Panel
        </a>
        <% } else { %>
        <a href="<%= ctx %>/AuthServlet?action=formLogin" class="public-nav-btn">
            <i data-lucide="log-in"></i> Iniciar sesión
        </a>
        <% } %>
    </div>
</nav>

<%-- ═══════ HERO (sin breadcrumb) ═══════ --%>
<section class="catalog-hero">
    <div class="catalog-hero-inner">
        <h1 class="catalog-hero-title">Catálogo de Materiales</h1>
        <p class="catalog-hero-subtitle">
            Explora en tiempo real los recursos disponibles en los almacenes de Quinta Ola.
        </p>
        <div class="catalog-hero-stats">
            <div class="hero-stat"><i data-lucide="package"></i><span><strong><%= totalItems %></strong> registrados</span></div>
            <div class="hero-stat"><i data-lucide="check-circle"></i><span><strong><%= itemsOk %></strong> disponibles</span></div>
            <% if (itemsBajo > 0) { %>
            <div class="hero-stat"><i data-lucide="alert-triangle"></i><span><strong><%= itemsBajo %></strong> con stock bajo</span></div>
            <% } %>
        </div>
    </div>
</section>

<%-- ═══════ MAIN ═══════ --%>
<main class="catalog-main">

    <%-- Barra de filtros --%>
    <div class="catalog-filters">
        <div class="catalog-search-wrap">
            <i data-lucide="search" class="catalog-search-icon"></i>
            <input type="text" id="catalog-search" onkeyup="manejarFiltros()"
                   placeholder="Buscar material por nombre..."
                   class="catalog-search-input"/>
        </div>

        <div class="filter-chips" id="filter-chips">
            <button class="filter-chip active" data-filter="todos" onclick="seleccionarFiltro(this, 'todos')">
                <i data-lucide="grid-3x3"></i> Todos
            </button>
            <button class="filter-chip" data-filter="ok" onclick="seleccionarFiltro(this, 'ok')">
                <i data-lucide="check-circle"></i> Disponibles
            </button>
            <button class="filter-chip" data-filter="low" onclick="seleccionarFiltro(this, 'low')">
                <i data-lucide="alert-triangle"></i> Stock bajo
            </button>
        </div>
    </div>

    <%-- Grid y Cards --%>
    <div class="catalog-grid" id="catalog-grid">

        <%-- Empty State Dinámico --%>
        <div class="catalog-empty" id="catalog-empty-state">
            <div class="catalog-empty-icon"><i data-lucide="package-x"></i></div>
            <p class="catalog-empty-title">No se encontraron materiales</p>
            <p class="catalog-empty-desc">Intenta ajustar los filtros de búsqueda para ver más resultados.</p>
        </div>

        <% if (items != null && !items.isEmpty()) {
            String[] gradientes = {"item-icon-purple", "item-icon-pink", "item-icon-blue", "item-icon-green", "item-icon-amber"};
            String[] iconos = {"package", "box", "archive", "boxes", "package-2"};
            int idx = 0;

            for (Item item : items) {
                int qty = item.getCachedQuantity();
                int min = item.getMinQuantity();
                String statusKey = (qty <= 0) ? "out" : (qty <= min) ? "low" : "ok";
                String statusLabel = (qty <= 0) ? "Sin stock" : (qty <= min) ? "Stock bajo" : "Disponible";
                String statusClass = (qty <= 0) ? "status-out" : (qty <= min) ? "status-low" : "status-ok";

                String gradiente = gradientes[idx % gradientes.length];
                String icono = iconos[idx % iconos.length];
                idx++;

                java.util.List<String> tags = item.getTags();

                // LÓGICA DE FOTOS: si el item tiene imageUrl en BD, lo mostramos
                String photoUrl = null;
                try {
                    photoUrl = item.getImageUrl();
                } catch(Exception e) {
                    photoUrl = null;
                }
                boolean hasPhoto = (photoUrl != null && !photoUrl.trim().isEmpty());
        %>

        <div class="item-card catalog-item"
             data-name="<%= item.getName().toLowerCase() %>"
             data-status="<%= statusKey %>">

            <%-- Header (Imagen o Fallback de ícono) --%>
            <div class="item-card-icon-wrap <%= !hasPhoto ? gradiente : "" %>">
                <span class="item-card-sku">SKU-<%= String.format("%03d", item.getId()) %></span>
                <span class="item-card-status <%= statusClass %>"><%= statusLabel %></span>

                <% if (hasPhoto) {
                    // Soporta tanto URLs externas (https://...) como rutas relativas (uploads/...)
                    String imgSrc = photoUrl.startsWith("http") ? photoUrl : (ctx + "/" + photoUrl);
                %>
                <img src="<%= imgSrc %>" alt="<%= item.getName() %>" class="item-card-image"
                     onerror="this.style.display='none'; this.parentElement.classList.add('<%= gradiente %>');"/>
                <% } else { %>
                <i data-lucide="<%= icono %>" class="item-card-icon"></i>
                <% } %>
            </div>

            <div class="item-card-body">
                <h3 class="item-card-title"><%= item.getName() %></h3>

                <% if (tags != null && !tags.isEmpty()) { %>
                <div class="item-card-tags">
                    <% int tagCount = 0; for (String tag : tags) { if (tag == null || tag.trim().isEmpty()) continue; if (tagCount >= 2) break; %>
                    <span class="item-tag"><%= tag %></span>
                    <% tagCount++; } %>
                </div>
                <% } %>

                <div class="item-card-stock">
                    <span class="stock-label">Disponibilidad</span>
                    <div>
                        <span class="stock-value"><%= qty %></span>
                        <span class="stock-unit"><%= item.getUnit() != null ? item.getUnit() : "und" %></span>
                    </div>
                </div>
            </div>

            <% if (estaLogueado) { %>
            <a href="<%= ctx %>/TransactionServlet?action=formCrear&itemId=<%= item.getId() %>" class="item-card-cta item-cta-request">
                <i data-lucide="send"></i> Crear solicitud
            </a>
            <% } else { %>
            <a href="<%= ctx %>/AuthServlet?action=formLogin" class="item-card-cta item-cta-login">
                <i data-lucide="lock"></i> Inicia sesión para solicitar
            </a>
            <% } %>
        </div>
        <% } } %>

        <%-- Contenedor de Paginación Dinámica --%>
        <div id="pagination-controls"></div>

    </div>
</main>

<%-- ═════ FOOTER (IDÉNTICO al index.jsp) ═════ --%>
<footer class="public-footer">
    <div class="public-footer-inner">

        <div class="public-footer-brand">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Quinta Ola Logo"/>
            <p>
                Innovando la gestión de inventarios con soluciones modernas, intuitivas
                y escalables para organizaciones que miran hacia el futuro.
            </p>
            <div class="public-footer-social">
                <a href="#" title="Instagram"><i data-lucide="instagram"></i></a>
                <a href="#" title="WhatsApp"><i data-lucide="message-circle"></i></a>
                <a href="#" title="Facebook"><i data-lucide="facebook"></i></a>
                <a href="#" title="LinkedIn"><i data-lucide="linkedin"></i></a>
            </div>
        </div>

        <div class="public-footer-col">
            <h4>Plataforma</h4>
            <ul>
                <li><a href="<%= ctx %>/index.jsp">Inicio</a></li>
                <li><a href="<%= ctx %>/CatalogServlet">Nuestros productos</a></li>
                <% if (!estaLogueado) { %>
                <li><a href="<%= ctx %>/AuthServlet?action=formLogin">Iniciar sesión</a></li>
                <% } else { %>
                <li><a href="<%= ctx %>/HomeServlet">Ir al Panel</a></li>
                <% } %>
            </ul>
        </div>

        <div class="public-footer-col">
            <h4>Soporte</h4>
            <ul>
                <li><a href="#">Centro de ayuda</a></li>
                <li><a href="#">Términos de servicio</a></li>
                <li><a href="#">Política de privacidad</a></li>
            </ul>
        </div>

    </div>

    <div class="public-footer-bottom">
        <p>© 2026 Quinta Ola. Todos los derechos reservados.</p>
        <p>Hecho con <i data-lucide="heart"></i> para la gestión de inventarios</p>
    </div>
</footer>

<%-- ═══════ SCRIPTS DE FILTRADO Y PAGINACIÓN ═══════ --%>
<script>
    // Variables para paginación
    const ITEMS_PER_PAGE = 8; // <-- Cambia este número para mostrar más o menos items por página
    let currentPage = 1;
    let filteredCards = [];
    let allCards = [];

    document.addEventListener("DOMContentLoaded", () => {
        allCards = Array.from(document.getElementsByClassName('catalog-item'));
        manejarFiltros(); // Inicializa la vista
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });

    function seleccionarFiltro(boton, estado) {
        document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
        boton.classList.add('active');
        manejarFiltros();
    }

    function manejarFiltros() {
        const query = document.getElementById('catalog-search').value.toLowerCase().trim();
        const estado = document.querySelector('.filter-chip.active').getAttribute('data-filter');

        filteredCards = allCards.filter(card => {
            const name = card.getAttribute('data-name');
            const status = card.getAttribute('data-status');
            const matchNombre = query === '' || name.includes(query);
            const matchEstado = estado === 'todos' || status === estado;
            return matchNombre && matchEstado;
        });

        document.getElementById('catalog-empty-state').style.display = filteredCards.length === 0 ? 'block' : 'none';

        currentPage = 1;
        renderizarPagina();
    }

    function renderizarPagina() {
        allCards.forEach(c => c.style.display = 'none');

        const startIndex = (currentPage - 1) * ITEMS_PER_PAGE;
        const endIndex = startIndex + ITEMS_PER_PAGE;

        const cardsToShow = filteredCards.slice(startIndex, endIndex);
        cardsToShow.forEach(c => c.style.display = 'flex');

        renderizarControlesPaginacion();
    }

    function renderizarControlesPaginacion() {
        const totalPages = Math.ceil(filteredCards.length / ITEMS_PER_PAGE);
        const container = document.getElementById('pagination-controls');

        if (totalPages <= 1) {
            container.innerHTML = '';
            return;
        }

        const start = (currentPage - 1) * ITEMS_PER_PAGE + 1;
        const end = Math.min(currentPage * ITEMS_PER_PAGE, filteredCards.length);
        const winS = Math.max(1, currentPage - 2);
        const winE = Math.min(totalPages, currentPage + 2);
        const dots = `<span class="pager-dots"><span></span><span></span><span></span></span>`;

        let nav = `<button class="pager-btn ${currentPage === 1 ? 'pager-btn--disabled' : ''}" onclick="cambiarPagina(${currentPage - 1})" ${currentPage === 1 ? 'disabled' : ''}>
                        <i data-lucide="chevron-left"></i>
                    </button>`;

        if (winS > 1) {
            nav += `<button class="pager-btn" onclick="cambiarPagina(1)">1</button>`;
            if (winS > 2) nav += dots;
        }

        for (let i = winS; i <= winE; i++) {
            nav += i === currentPage
                ? `<span class="pager-btn pager-btn--active">${i}</span>`
                : `<button class="pager-btn" onclick="cambiarPagina(${i})">${i}</button>`;
        }

        if (winE < totalPages) {
            if (winE < totalPages - 1) nav += dots;
            nav += `<button class="pager-btn" onclick="cambiarPagina(${totalPages})">${totalPages}</button>`;
        }

        nav += `<button class="pager-btn ${currentPage === totalPages ? 'pager-btn--disabled' : ''}" onclick="cambiarPagina(${currentPage + 1})" ${currentPage === totalPages ? 'disabled' : ''}>
                    <i data-lucide="chevron-right"></i>
                 </button>`;

        container.innerHTML = `
            <div class="pager">
                <div class="pager-info">
                    <span>Mostrando <strong>${start}–${end}</strong> de <strong>${filteredCards.length}</strong> materiales</span>
                    <span class="pager-info-badge"><i data-lucide="waves"></i> ≈ ${ITEMS_PER_PAGE} por ola</span>
                </div>
                <div class="pager-nav">${nav}</div>
            </div>`;

        if (typeof lucide !== 'undefined') lucide.createIcons();
    }

    function cambiarPagina(page) {
        currentPage = page;
        renderizarPagina();
        document.querySelector('.catalog-filters').scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
</script>

</body>
</html>