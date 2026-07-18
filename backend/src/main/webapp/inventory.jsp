<%--
    ════════════════════════════════════════════════════════════════════
     inventory.jsp — Vista del inventario (rediseño Quinta Ola)
    ════════════════════════════════════════════════════════════════════
     Reglas de visibilidad:
     - Viewer (1): vista catálogo (tarjetas con botón "Solicitar")
     - Member (2): vista admin tabla (Editar/Desactivar) — NO solicita
     - Manager (3): vista admin tabla solo-lectura
     - Administrador (4) y SuperAdmin (5): vista admin tabla CRUD
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();

    List<Item> items = (List<Item>) request.getAttribute("items");
    Integer totalItems = (Integer) request.getAttribute("totalItems");
    if (totalItems == null) totalItems = 0;

    String filtroTexto = (String) request.getAttribute("filtroTexto");
    String filtroTag   = (String) request.getAttribute("filtroTag");
    String filtroStock = (String) request.getAttribute("filtroStock");
    if (filtroTexto == null) filtroTexto = "";
    if (filtroTag   == null) filtroTag   = "";
    if (filtroStock == null) filtroStock = "";

    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");
    String errorParam = request.getParameter("error");

    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    int roleId = roleIdSession != null ? roleIdSession : 0;

    // ─── REGLAS DE VISIBILIDAD ───
    // Solo Viewer (1) ve la vista catálogo con botones "Solicitar"
    boolean esCatalogo = (roleId == 1);

    // Member (2), Admin (4), SA (5) pueden hacer CRUD de items
    boolean esAdmin = (roleId == 2 || roleId == 4 || roleId == 5);

    // Botón "Añadir Material": Member, Admin, SA
    boolean puedeAgregarMaterial = (roleId == 2 || roleId == 4 || roleId == 5);

    String pageTitle, pageSubtitle;
    if (esCatalogo) {
        pageTitle    = "Catálogo de Materiales";
        pageSubtitle = "Selecciona materiales y agrégalos a tu solicitud.";
    } else if (roleId == 2) {
        pageTitle    = "Gestión de Stock";
        pageSubtitle = "Administra el catálogo: añade, edita o desactiva materiales del depósito.";
    } else {
        pageTitle    = "Lista de Materiales";
        pageSubtitle = "Listado de materiales y stock actual en tiempo real.";
    }

    // ─── PAGINACIÓN ───
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPagesObj  = (Integer) request.getAttribute("totalPages");
    Integer pageSizeObj    = (Integer) request.getAttribute("pageSize");

    int pageSize = pageSizeObj != null ? pageSizeObj : 8;
    int currentPage = currentPageObj != null ? currentPageObj : 1;

    List<Item> itemsToShow = items;
    int totalPages;

    if (currentPageObj == null && items != null && !items.isEmpty()) {
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try { currentPage = Integer.parseInt(pageParam); } catch (Exception ignored) {}
        }
        if (currentPage < 1) currentPage = 1;

        totalPages = (int) Math.ceil((double) items.size() / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        int start = (currentPage - 1) * pageSize;
        int end = Math.min(start + pageSize, items.size());
        itemsToShow = items.subList(start, end);
    } else if (totalPagesObj != null) {
        totalPages = totalPagesObj;
    } else {
        totalPages = 1;
    }

    // Ventana de páginas visibles para el paginador "Ola"
    int _winS = Math.max(1, currentPage - 2);
    int _winE = Math.min(totalPages, currentPage + 2);

    // URL base de paginación, preservando filtros activos
    String _pUrlInv = ctx + "/InventoryServlet?action=lista";
    if (!filtroTexto.isEmpty()) _pUrlInv += "&q=" + java.net.URLEncoder.encode(filtroTexto, "UTF-8");
    if (!filtroTag.isEmpty())   _pUrlInv += "&tag=" + java.net.URLEncoder.encode(filtroTag, "UTF-8");
    if (!filtroStock.isEmpty()) _pUrlInv += "&stock=" + filtroStock;

    request.setAttribute("activeMenu", "inventory");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Inventario | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=17" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>

        /* 1. Ocultar la flecha nativa de la etiqueta details */
        .css-modal-wrapper summary {
            list-style: none;
            outline: none;
        }
        .css-modal-wrapper summary::-webkit-details-marker {
            display: none;
        }

        /* 2. El fondo oscuro pantalla completa */
        .css-modal-wrapper[open] .css-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 12, 23, 0.5);
            backdrop-filter: blur(4px);
            z-index: 99999;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: default;
            animation: fadeInModal 0.2s ease-out;
        }

        /* 3. Truco: Botón invisible para cerrar al hacer clic afuera */
        .css-modal-close-overlay-trigger {
            position: absolute;
            inset: 0;
            z-index: 1;
            cursor: default;
        }

        /* 4. Tarjeta Blanca del Modal */
        .css-modal-card {
            background: #ffffff;
            padding: 2rem;
            border-radius: 16px;
            width: 92%;
            max-width: 400px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            text-align: center;
            position: relative;
            z-index: 10;
        }

        .css-modal-card h3 {
            margin: 0.75rem 0 0.5rem 0;
            font-size: 1.25rem;
            font-weight: 700;
            color: #1f2937;
        }

        .css-modal-card p {
            font-size: 0.88rem;
            color: #6b7280;
            line-height: 1.4;
            margin-bottom: 1rem;
        }

        /* 5. Botones de acción del modal */
        .css-modal-actions {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 1.5rem;
            position: relative;
            z-index: 20;
        }

        .btn-cancel-modal {
            display: inline-flex;
            align-items: center;
            padding: 0.6rem 1.2rem;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 700;
            background: var(--gray-100, #f3f4f6);
            color: var(--gray-700, #4b5563);
            cursor: pointer;
            border: 1px solid var(--gray-200, #e5e7eb);
            transition: all 0.2s;
        }
        .btn-cancel-modal:hover {
            background: var(--gray-200, #e5e7eb);
        }

        /* 6. Estilos de los iconos circulares */
        .modal-icon-container {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto;
        }
        /* Usa los colores de tu sistema, o añade fallbacks si no existen */
        .modal-icon-container.text-purple { background: var(--purple-bg, #f3e8ff); color: var(--purple, #5b1fa8); }
        .modal-icon-container.text-pink { background: var(--pink-bg, #fce7f3); color: var(--pink, #e91e8c); }

        /* 7. Animación suave de entrada */
        @keyframes fadeInModal {
            from { opacity: 0; transform: scale(0.95); }
            to { opacity: 1; transform: scale(1); }
        }
        .filter-bar {
            display: flex;
            gap: 0.75rem;
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: 1rem;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--gray-100);
            flex-wrap: wrap;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        .filter-search {
            position: relative;
            flex-grow: 1;
            min-width: 250px;
            flex-direction: row;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .filter-search > i {
            position: absolute;
            left: 0.95rem; top: 50%;
            transform: translateY(-50%);
            color: var(--gray-400);
            width: 16px; height: 16px;
            pointer-events: none;
            z-index: 2;
        }
        .filter-search input {
            width: 100%;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-full);
            padding: 0.6rem 1rem 0.6rem 2.65rem;
            font-size: 0.875rem;
            outline: none;
            transition: all var(--transition);
            background: var(--gray-50);
            font-family: inherit;
        }
        .filter-search input:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }

        .filter-select {
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.6rem 0.9rem;
            font-size: 0.85rem;
            background: var(--gray-50);
            color: var(--gray-700);
            font-family: inherit;
            cursor: pointer;
            outline: none;
            transition: all var(--transition);
            min-width: 170px;
        }
        .filter-select:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }

        .filter-actions { display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap; }

        @media (max-width: 640px) {
            .filter-search { min-width: 100%; }
            .filter-actions { width: 100%; }
            .filter-select { flex: 1 1 140px; min-width: 0; }
            .filter-actions .btn-page-primary { flex: 1 1 100%; justify-content: center; }
        }

        .catalog-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 1.25rem;
        }
        .catalog-card-img-placeholder {
            display: flex; align-items: center; justify-content: center;
            width: 100%; height: 100%;
            background: linear-gradient(135deg, var(--purple-bg) 0%, var(--pink-bg) 100%);
            color: var(--purple);
        }
        .catalog-card-img-placeholder i { width: 48px; height: 48px; }
        .catalog-card-row {
            display: flex; justify-content: space-between;
            align-items: flex-start; gap: 0.5rem; margin-bottom: 0.5rem;
        }
        .catalog-card-stock {
            font-size: 0.82rem; color: var(--gray-500);
            margin: 0.4rem 0 1rem;
            display: flex; align-items: center; gap: 0.4rem;
        }
        .catalog-card-stock i { width: 14px; height: 14px; color: var(--purple); }

        .item-cell { display: flex; align-items: center; gap: 0.75rem; }
        .item-cell-img {
            width: 40px; height: 40px;
            border-radius: var(--radius-sm);
            object-fit: cover;
            border: 1px solid var(--gray-100);
            flex-shrink: 0;
        }
        .item-cell-img-fallback {
            width: 40px; height: 40px;
            border-radius: var(--radius-sm);
            background: linear-gradient(135deg, var(--purple-bg) 0%, var(--pink-bg) 100%);
            display: flex; align-items: center; justify-content: center;
            color: var(--purple); flex-shrink: 0;
        }
        .item-cell-img-fallback i { width: 18px; height: 18px; }
        .item-cell-name {
            font-weight: 700; color: var(--gray-800); font-size: 0.9rem;
        }

        /* ── Fila desactivada (mismo tratamiento que Miembros) ─────────────── */
        .row-deactivated { opacity: 0.55; background: var(--gray-50); }
        .row-deactivated .item-cell-name { text-decoration: line-through; }
        .stock-deactivated {
            display: inline-flex; align-items: center; gap: 0.28rem;
            padding: 0.28rem 0.65rem; border-radius: var(--radius-full);
            font-size: 0.7rem; font-weight: 700; white-space: nowrap;
            background: var(--gray-200); color: var(--gray-700);
        }
        .stock-deactivated i { width: 11px; height: 11px; }
        .btn-reactivate-row {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.45rem 0.85rem; border-radius: var(--radius-sm); border: none;
            background: linear-gradient(135deg, var(--green) 0%, var(--green-dark) 100%);
            color: var(--white); font-size: 0.78rem; font-weight: 700;
            cursor: pointer; transition: all var(--transition); text-decoration: none; font-family: inherit;
        }
        .btn-reactivate-row:hover { transform: translateY(-1px); box-shadow: 0 3px 10px rgba(34,197,94,0.3); }
        .btn-reactivate-row i { width: 13px; height: 13px; }

        .tag-chip {
            display: inline-block;
            padding: 0.25rem 0.65rem;
            font-size: 0.68rem; font-weight: 700;
            color: var(--purple);
            background: var(--purple-bg);
            border-radius: var(--radius-full);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-right: 0.3rem; margin-bottom: 0.2rem;
        }

        .row-actions {
            display: flex; justify-content: center; gap: 0.5rem;
        }
        .btn-edit-row, .btn-delete-row {
            display: inline-flex; align-items: center; gap: 0.35rem;
            padding: 0.4rem 0.85rem;
            border-radius: var(--radius-sm);
            font-size: 0.75rem; font-weight: 700;
            cursor: pointer; border: 1px solid;
            transition: all var(--transition);
            text-decoration: none;
        }
        .btn-edit-row {
            background: var(--white); color: var(--purple);
            border-color: var(--gray-200);
        }
        .btn-edit-row:hover {
            background: var(--purple-bg); border-color: var(--purple);
        }
        .btn-delete-row {
            background: var(--white); color: var(--red-dark);
            border-color: #FECACA;
        }
        .btn-delete-row:hover {
            background: var(--red); color: var(--white); border-color: var(--red);
        }
        .btn-edit-row i, .btn-delete-row i { width: 13px; height: 13px; }

        .empty-state { padding: 4rem 2rem; text-align: center; }
        .empty-state-icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 64px; height: 64px;
            background: var(--purple-bg); color: var(--purple);
            border-radius: 50%; margin-bottom: 1rem;
        }
        .empty-state-icon i { width: 30px; height: 30px; }
        .empty-state-title {
            font-size: 1.05rem; font-weight: 700;
            color: var(--gray-700); margin-bottom: 0.4rem;
        }
        .empty-state-desc { font-size: 0.88rem; color: var(--gray-500); }

        /* Paginación: ver componente global ".pager" en style.css */

        .alert {
            display: flex; align-items: center; gap: 0.6rem;
            padding: 0.9rem 1.1rem;
            border-radius: var(--radius-sm);
            font-size: 0.88rem; font-weight: 600;
            margin-bottom: 1.25rem;
            border: 1px solid;
        }
        .alert-error   { background: var(--red-bg);   color: var(--red-dark);   border-color: #FECACA; }
        .alert-success { background: var(--green-bg); color: var(--green-dark); border-color: #BBF7D0; }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }
    </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <a id="modal-cerrar" style="display:block;height:0;overflow:hidden;"></a>

            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="<%= esCatalogo ? "shopping-bag" : "package" %>"
                           style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        <%= pageTitle %>
                    </h1>
                    <p class="page-subtitle"><%= pageSubtitle %></p>
                </div>

                <% if (puedeAgregarMaterial) { %>
                <a href="<%= ctx %>/AdminItemServlet?action=formCrear" class="btn-page-primary btn-icon">
                    <i data-lucide="plus"></i>
                    Añadir Material
                </a>
                <% } %>
            </div>

            <% if (success != null) { %>
            <div class="alert alert-success">
                <i data-lucide="check-circle"></i>
                <span><%= success %></span>
            </div>
            <% } %>
            <% if (error != null || errorParam != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= error != null ? error : errorParam %></span>
            </div>
            <% } %>

            <%-- FILTROS --%>
            <form action="<%= ctx %>/InventoryServlet" method="GET" class="filter-bar">
                <input type="hidden" name="action" value="lista"/>

                <div class="filter-search">
                    <i data-lucide="search"></i>
                    <input type="text" name="q"
                           value="<%= filtroTexto %>"
                           placeholder="Buscar materiales..."/>
                </div>

                <div class="filter-actions">
                    <select name="tag" class="filter-select">
                        <option value="" <%= filtroTag.isEmpty() ? "selected" : "" %>>Todas las etiquetas</option>
                        <%
                            List<String> tagsDisp = (List<String>) request.getAttribute("tagsDisponibles");
                            if (tagsDisp != null) {
                                for (String tagName : tagsDisp) {
                        %>
                        <option value="<%= tagName %>" <%= tagName.equals(filtroTag) ? "selected" : "" %>>
                            <%= tagName %>
                        </option>
                        <% } } %>
                    </select>

                    <select name="stock" class="filter-select">
                        <option value=""             <%= filtroStock.isEmpty()              ? "selected" : "" %>>Todos los stocks</option>
                        <option value="OK"           <%= "OK".equals(filtroStock)           ? "selected" : "" %>>OK (En Stock)</option>
                        <option value="LOW"          <%= "LOW".equals(filtroStock)          ? "selected" : "" %>>Bajo Stock</option>
                        <option value="UNAVAILABLE"  <%= "UNAVAILABLE".equals(filtroStock)  ? "selected" : "" %>>Sin Stock</option>
                        <% if (esAdmin) { %>
                        <option value="INACTIVE"     <%= "INACTIVE".equals(filtroStock)     ? "selected" : "" %>>Desactivados</option>
                        <% } %>
                    </select>

                    <button type="submit" class="btn-page-primary btn-icon">
                        <i data-lucide="filter"></i>
                        Filtrar
                    </button>
                </div>
            </form>

            <%-- ════════ VISTA CATÁLOGO (solo Viewer) ════════ --%>
            <% if (esCatalogo) { %>

            <% if (itemsToShow == null || itemsToShow.isEmpty()) { %>
            <div class="table-panel">
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i data-lucide="package-x"></i>
                    </div>
                    <p class="empty-state-title">Sin resultados</p>
                    <p class="empty-state-desc">No hay materiales que coincidan con tu búsqueda.</p>
                </div>
            </div>
            <% } else { %>

            <div class="catalog-grid">
                <% for (Item item : itemsToShow) {
                    String s = item.getStatus();
                    String stockClass, stockTxt;
                    if ("OK".equals(s))               { stockClass = "stock-ok";   stockTxt = "OK"; }
                    else if ("LOW".equals(s))         { stockClass = "stock-low";  stockTxt = "Bajo"; }
                    else if ("UNAVAILABLE".equals(s)) { stockClass = "stock-none"; stockTxt = "Sin Stock"; }
                    else                              { stockClass = "stock-ok";   stockTxt = s; }
                %>
                <div class="catalog-card">
                    <div class="catalog-card-img">
                        <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) { %>
                        <img src="<%= item.getImageUrl() %>"
                             alt="<%= item.getName() %>"
                             onerror="this.outerHTML='<div class=\'catalog-card-img-placeholder\'><i data-lucide=\'package\'></i></div>'; if(typeof lucide!=='undefined')lucide.createIcons();"/>
                        <% } else { %>
                        <div class="catalog-card-img-placeholder">
                            <i data-lucide="package"></i>
                        </div>
                        <% } %>
                    </div>

                    <div class="catalog-card-body">
                        <div class="catalog-card-row">
                            <h3 class="catalog-card-title"><%= item.getName() %></h3>
                            <span class="<%= stockClass %>"><%= stockTxt %></span>
                        </div>

                        <div class="catalog-card-stock">
                            <i data-lucide="layers"></i>
                            Stock: <strong style="color: var(--gray-700);"><%= item.getCachedQuantity() %></strong>&nbsp;<%= item.getUnit() %>
                        </div>

                        <<% if ("UNAVAILABLE".equals(s)) { %>
                        <span class="catalog-card-btn" style="background: var(--gray-300); cursor: not-allowed; pointer-events: none;">
                            <i data-lucide="x-circle"></i>
                            No disponible
                        </span>
                        <% } else { %>
                        <a href="<%= ctx %>/TransactionServlet?action=formCrear&itemId=<%= item.getId() %>&origen=inventory" class="catalog-card-btn">
                            <i data-lucide="plus"></i>
                            Solicitar
                        </a>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>

            <% if (totalPages > 1) { %>
            <div class="pager" style="margin-top: 1.25rem; border-radius: var(--radius-lg); border: 1px solid var(--gray-100); box-shadow: var(--shadow-sm);">
                <div class="pager-info">
                    <span>Mostrando <strong><%= itemsToShow.size() %></strong> de <strong><%= request.getAttribute("totalFiltrados") != null ? request.getAttribute("totalFiltrados") : 0 %></strong> materiales</span>
                    <span class="pager-info-badge"><i data-lucide="waves"></i> ≈ <%= pageSize %> por ola</span>
                </div>
                <div class="pager-nav">
                    <% if (currentPage > 1) { %><a href="<%= _pUrlInv %>&page=<%= currentPage-1 %>" class="pager-btn"><i data-lucide="chevron-left"></i></a>
                    <% } else { %><span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-left"></i></span><% } %>
                    <% if (_winS > 1) { %><a href="<%= _pUrlInv %>&page=1" class="pager-btn">1</a><% if (_winS > 2) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %><% } %>
                    <% for (int _p = _winS; _p <= _winE; _p++) { %>
                    <% if (_p == currentPage) { %><span class="pager-btn pager-btn--active"><%= _p %></span>
                    <% } else { %><a href="<%= _pUrlInv %>&page=<%= _p %>" class="pager-btn"><%= _p %></a><% } %>
                    <% } %>
                    <% if (_winE < totalPages) { %><% if (_winE < totalPages-1) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %><a href="<%= _pUrlInv %>&page=<%= totalPages %>" class="pager-btn"><%= totalPages %></a><% } %>
                    <% if (currentPage < totalPages) { %><a href="<%= _pUrlInv %>&page=<%= currentPage+1 %>" class="pager-btn"><i data-lucide="chevron-right"></i></a>
                    <% } else { %><span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-right"></i></span><% } %>
                </div>
            </div>
            <% } %>

            <% } %>

            <% } else { %>

            <%-- ════════ VISTA TABLA (Member/Manager/Admin/SuperAdmin) ════════ --%>
            <div class="table-panel">

                <% if (itemsToShow == null || itemsToShow.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i data-lucide="package-x"></i>
                    </div>
                    <p class="empty-state-title">Sin materiales</p>
                    <p class="empty-state-desc">No hay materiales que coincidan con tu búsqueda.</p>
                </div>
                <% } else { %>

                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th">Material</th>
                            <th class="th">Tags</th>
                            <th class="th-center">Stock</th>
                            <th class="th-center">Mínimo</th>
                            <th class="th-center">Estado</th>
                            <% if (esAdmin) { %>
                            <th class="th-center" style="width: 220px;">Acciones</th>
                            <% } %>
                        </tr>
                        </thead>
                        <tbody class="table-body">

                        <% for (Item item : itemsToShow) {
                            boolean itemInactivo = !item.isActivo();
                        %>
                        <tr class="table-row <%= itemInactivo ? "row-deactivated" : "" %>">
                            <td class="td">
                                <div class="item-cell">
                                    <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) { %>
                                    <img src="<%= item.getImageUrl() %>"
                                         alt="<%= item.getName() %>"
                                         class="item-cell-img"
                                         onerror="this.style.display='none'"/>
                                    <% } else { %>
                                    <div class="item-cell-img-fallback">
                                        <i data-lucide="package"></i>
                                    </div>
                                    <% } %>
                                    <span class="item-cell-name"><%= item.getName() %></span>
                                </div>
                            </td>

                            <td class="td">
                                <% if (item.getTags() != null && !item.getTags().isEmpty()) {
                                    for (String tag : item.getTags()) { %>
                                <span class="tag-chip"><%= tag %></span>
                                <% } } else { %>
                                <span style="color: var(--gray-300); font-size: 0.8rem;">—</span>
                                <% } %>
                            </td>

                            <td class="td-center" style="font-weight: 700; color: var(--gray-800);">
                                <%= item.getCachedQuantity() %>&nbsp;<span style="font-weight: 500; color: var(--gray-500); font-size: 0.8rem;"><%= item.getUnit() %></span>
                            </td>

                            <td class="td-center" style="color: var(--gray-600);">
                                <%= item.getMinQuantity() %>
                            </td>

                            <td class="td-center">
                                <% if (itemInactivo) { %>
                                <span class="stock-deactivated"><i data-lucide="ban"></i>Desactivado</span>
                                <% } else {
                                    String st = item.getStatus();
                                    String badgeClass, badgeText;
                                    if ("OK".equals(st))               { badgeClass = "stock-ok";   badgeText = "OK"; }
                                    else if ("LOW".equals(st))         { badgeClass = "stock-low";  badgeText = "Stock Bajo"; }
                                    else if ("UNAVAILABLE".equals(st)) { badgeClass = "stock-none"; badgeText = "Sin Stock"; }
                                    else                               { badgeClass = "stock-ok";   badgeText = st; }
                                %>
                                <span class="<%= badgeClass %>"><%= badgeText %></span>
                                <% } %>
                            </td>

                            <% if (esAdmin) { %>
                            <td class="td-center">
                                <div class="row-actions" style="display:flex; align-items:center; gap:0.5rem; justify-content:center;">

                                    <% if (itemInactivo) { %>
                                    <%-- MATERIAL DESACTIVADO: solo se puede reactivar --%>
                                    <a href="#modal-reactivar-<%= item.getId() %>" class="btn-reactivate-row">
                                        <i data-lucide="rotate-ccw"></i>
                                        Reactivar
                                    </a>

                                    <% } else { %>

                                    <%-- BOTÓN EDITAR (Se queda igual) --%>
                                    <a href="<%= ctx %>/AdminItemServlet?action=formEditar&id=<%= item.getId() %>"
                                       class="btn-edit-row">
                                        <i data-lucide="pencil"></i>
                                        Editar
                                    </a>

                                    <a href="#modal-desactivar-<%= item.getId() %>" class="btn-delete-row">
                                        <i data-lucide="trash-2"></i>
                                        Desactivar
                                    </a>
                                    <% } %>

                                </div>
                            </td>
                            <% } %>
                        </tr>
                        <% } %>

                        </tbody>
                    </table>
                </div>

                <div class="pager">
                    <div class="pager-info">
                        <span>Mostrando <strong><%= itemsToShow.size() %></strong> de <strong><%= request.getAttribute("totalFiltrados") != null ? request.getAttribute("totalFiltrados") : 0 %></strong> items</span>
                        <span class="pager-info-badge"><i data-lucide="waves"></i> ≈ <%= pageSize %> por ola</span>
                    </div>

                    <% if (totalPages > 1) { %>
                    <div class="pager-nav">
                        <% if (currentPage > 1) { %><a href="<%= _pUrlInv %>&page=<%= currentPage-1 %>" class="pager-btn"><i data-lucide="chevron-left"></i></a>
                        <% } else { %><span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-left"></i></span><% } %>
                        <% if (_winS > 1) { %><a href="<%= _pUrlInv %>&page=1" class="pager-btn">1</a><% if (_winS > 2) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %><% } %>
                        <% for (int _p = _winS; _p <= _winE; _p++) { %>
                        <% if (_p == currentPage) { %><span class="pager-btn pager-btn--active"><%= _p %></span>
                        <% } else { %><a href="<%= _pUrlInv %>&page=<%= _p %>" class="pager-btn"><%= _p %></a><% } %>
                        <% } %>
                        <% if (_winE < totalPages) { %><% if (_winE < totalPages-1) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %><a href="<%= _pUrlInv %>&page=<%= totalPages %>" class="pager-btn"><%= totalPages %></a><% } %>
                        <% if (currentPage < totalPages) { %><a href="<%= _pUrlInv %>&page=<%= currentPage+1 %>" class="pager-btn"><i data-lucide="chevron-right"></i></a>
                        <% } else { %><span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-right"></i></span><% } %>
                    </div>
                    <% } %>
                </div>

                <% } %>

            </div><%-- /table-panel --%>

            <%-- ═══════ MODALES — Confirmación Desactivar / Reactivar ═══════ --%>
            <% if (esAdmin && itemsToShow != null) {
                for (Item mItem : itemsToShow) {
                    boolean mInactivo = !mItem.isActivo();
            %>
            <% if (mInactivo) { %>
            <div id="modal-reactivar-<%= mItem.getId() %>" class="modal-overlay">
                <div class="modal-box">
                    <div class="modal-icon modal-icon--purple"><i data-lucide="rotate-ccw"></i></div>
                    <h3 class="modal-title">¿Reactivar material?</h3>
                    <p class="modal-desc">
                        "<strong class="modal-name"><%= mItem.getName() %></strong>" volverá a estar
                        disponible en el inventario y en el catálogo de solicitudes.
                    </p>
                    <div class="modal-btns">
                        <a href="#modal-cerrar" class="btn-modal-cancel">Cancelar</a>
                        <form action="<%= ctx %>/AdminItemServlet" method="POST" class="modal-form">
                            <input type="hidden" name="action" value="reactivar"/>
                            <input type="hidden" name="id" value="<%= mItem.getId() %>"/>
                            <button type="submit" class="btn-modal-ok btn-modal-ok--purple">
                                <i data-lucide="rotate-ccw"></i>Sí, reactivar
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div id="modal-desactivar-<%= mItem.getId() %>" class="modal-overlay">
                <div class="modal-box">
                    <div class="modal-icon modal-icon--red"><i data-lucide="alert-triangle"></i></div>
                    <h3 class="modal-title">¿Desactivar material?</h3>
                    <p class="modal-desc">
                        "<strong class="modal-name"><%= mItem.getName() %></strong>" ya no estará disponible
                        en el inventario activo ni en el catálogo de solicitudes. Podrás reactivarlo cuando quieras.
                    </p>
                    <div class="modal-btns">
                        <a href="#modal-cerrar" class="btn-modal-cancel">Cancelar</a>
                        <form action="<%= ctx %>/AdminItemServlet" method="POST" class="modal-form">
                            <input type="hidden" name="action" value="desactivar"/>
                            <input type="hidden" name="id" value="<%= mItem.getId() %>"/>
                            <button type="submit" class="btn-modal-ok btn-modal-ok--red">
                                <i data-lucide="alert-triangle"></i>Sí, desactivar
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
            <% } } %>

            <% } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });
</script>

</body>
</html>