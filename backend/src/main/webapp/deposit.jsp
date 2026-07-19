<%--
    ════════════════════════════════════════════════════════════════════
     deposit.jsp — Vista del encargado de depósito (rediseño Quinta Ola)
    ════════════════════════════════════════════════════════════════════
     CAMBIOS DE ESTA ITERACIÓN:
     - Buscador + filtro de estado (Pendientes / Entregadas / Todas),
       usando el componente global ".filter-bar" de style.css.
     - Botón "Limpiar filtros" cuando hay algo activo.
     - Nueva columna "Estado" en la tabla (relevante ahora que se
       pueden ver también las entregadas).
     - La acción de la fila se adapta: solo se puede "Marcar Entregada"
       si la solicitud sigue APROBADA; si ya está COMPLETED, se muestra
       un texto en vez del botón.
     - Paginación y modales ahora preservan los filtros activos.
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    List<Transaction> solicitudes = (List<Transaction>) request.getAttribute("solicitudes");
    String error = (String) request.getAttribute("error");
    String errParam = request.getParameter("error");
    String success = request.getParameter("success");

    String filtroEstado = (String) request.getAttribute("filtroEstado");
    String filtroQ       = (String) request.getAttribute("filtroQ");
    if (filtroEstado == null) filtroEstado = "pendientes";
    if (filtroQ == null) filtroQ = "";

    // ─── PAGINACIÓN client-side (8 por página), preservando filtros ───
    int pageSize = 8;
    int currentPage = 1;
    int totalPages = 1;
    int totalSolicitudes = solicitudes != null ? solicitudes.size() : 0;
    List<Transaction> solicitudesPagina = solicitudes;

    if (solicitudes != null && !solicitudes.isEmpty()) {
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            try { currentPage = Integer.parseInt(pageParam); } catch (Exception ignored) {}
        }
        if (currentPage < 1) currentPage = 1;

        totalPages = (int) Math.ceil((double) totalSolicitudes / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        int start = (currentPage - 1) * pageSize;
        int end   = Math.min(start + pageSize, totalSolicitudes);
        solicitudesPagina = solicitudes.subList(start, end);
    }

    // Ventana de páginas visibles para el paginador "Ola"
    int _winS = Math.max(1, currentPage - 2);
    int _winE = Math.min(totalPages, currentPage + 2);

    // URL base de paginación, preservando filtros activos
    String _pUrlDep = ctx + "/DepositServlet?estado=" + filtroEstado;
    if (!filtroQ.isEmpty()) _pUrlDep += "&q=" + java.net.URLEncoder.encode(filtroQ, "UTF-8");

    boolean hayFiltrosActivos = !"pendientes".equals(filtroEstado) || !filtroQ.isEmpty();

    request.setAttribute("activeMenu", "deposit");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Depósito | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=23" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Alertas ═════ */
        .alert {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            padding: 0.9rem 1.1rem;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 600;
            margin-bottom: 1rem;
            border: 1px solid;
        }
        .alert-success {
            background: var(--green-bg);
            color: var(--green-dark);
            border-color: #BBF7D0;
        }
        .alert-error {
            background: var(--red-bg);
            color: var(--red-dark);
            border-color: #FECACA;
        }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }

        /* ═════ Info banner ═════ */
        .info-banner {
            display: flex;
            align-items: flex-start;
            gap: 0.85rem;
            padding: 1.1rem 1.25rem;
            border-radius: var(--radius-md);
            background: linear-gradient(135deg, var(--blue-bg) 0%, var(--purple-bg) 100%);
            border: 1px solid #BFDBFE;
            margin-bottom: 1.5rem;
        }
        .info-banner-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 38px;
            height: 38px;
            background: var(--blue);
            color: var(--white);
            border-radius: var(--radius-sm);
            flex-shrink: 0;
        }
        .info-banner-icon i { width: 18px; height: 18px; }
        .info-banner-title {
            font-size: 0.92rem;
            font-weight: 800;
            color: var(--blue-dark);
            margin-bottom: 0.3rem;
        }
        .info-banner-desc {
            font-size: 0.83rem;
            color: var(--gray-700);
            line-height: 1.55;
        }
        .info-banner-desc strong { color: var(--blue-dark); }

        /* ═════ Tabla — acción columna ═════ */
        .row-actions {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 0.55rem;
        }

        .btn-deliver {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white);
            padding: 0.45rem 0.95rem;
            border-radius: var(--radius-full);
            font-size: 0.75rem;
            font-weight: 700;
            border: none;
            cursor: pointer;
            transition: all var(--transition);
            box-shadow: 0 3px 10px rgba(233, 30, 140, 0.25);
        }
        .btn-deliver:hover {
            transform: translateY(-1px);
            box-shadow: 0 5px 14px rgba(233, 30, 140, 0.4);
        }
        .btn-deliver i { width: 13px; height: 13px; }

        .detail-link {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            color: var(--gray-500);
            font-weight: 700;
            font-size: 0.78rem;
            text-decoration: none;
            transition: color var(--transition);
        }
        .detail-link:hover { color: var(--pink); }
        .detail-link i { width: 13px; height: 13px; }

        /* ═════ Empty state ═════ */
        .empty-state {
            padding: 4rem 2rem;
            text-align: center;
        }
        .empty-state-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 64px;
            height: 64px;
            background: var(--green-bg);
            color: var(--green);
            border-radius: 50%;
            margin-bottom: 1rem;
        }
        .empty-state-icon i { width: 30px; height: 30px; }
        .empty-state-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--gray-700);
            margin-bottom: 0.4rem;
        }
        .empty-state-desc {
            font-size: 0.88rem;
            color: var(--gray-500);
        }

        /* Buscador + paginación: ver componentes globales ".filter-bar" y ".pager" en style.css */

        /* ═════ Botones de descarga de inventario ═════ */
        .download-group {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        .btn-download-csv,
        .btn-download-xlsx {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.5rem 1rem;
            border-radius: var(--radius-full);
            font-size: 0.78rem;
            font-weight: 700;
            cursor: pointer;
            transition: all var(--transition);
            text-decoration: none;
            border: 1.5px solid;
        }
        .btn-download-csv {
            background: var(--white);
            border-color: var(--purple);
            color: var(--purple);
        }
        .btn-download-csv:hover {
            background: var(--purple-bg);
        }
        .btn-download-xlsx {
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            border-color: transparent;
            color: var(--white);
            box-shadow: 0 3px 10px rgba(233, 30, 140, 0.25);
        }
        .btn-download-xlsx:hover {
            transform: translateY(-1px);
            box-shadow: 0 5px 14px rgba(233, 30, 140, 0.4);
        }
        .btn-download-csv i,
        .btn-download-xlsx i { width: 14px; height: 14px; }

        .download-label {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            color: var(--gray-500);
            margin-right: 0.5rem;
        }
        .download-label i { width: 13px; height: 13px; color: var(--purple); }

        /* ═════ Campo de notas dentro del modal de entrega ═════ */
        .modal-notes-label {
            display: block;
            text-align: left;
            font-size: 0.7rem;
            font-weight: 700;
            color: var(--gray-500);
            text-transform: uppercase;
            letter-spacing: 0.4px;
            margin: 0.9rem 0 0.4rem;
        }
        .modal-notes-input {
            width: 100%;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.65rem 0.75rem;
            font-size: 0.85rem;
            font-family: inherit;
            color: var(--gray-800);
            background: var(--gray-50);
            resize: vertical;
            min-height: 64px;
            outline: none;
            transition: all var(--transition);
            box-sizing: border-box;
        }
        .modal-notes-input:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91,31,168,0.1);
        }
        .modal-notes-input::placeholder { color: var(--gray-400); }
    </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <a id="modal-cerrar" style="display:block;height:0;overflow:hidden;"></a>

            <div class="page-header" style="display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:1rem;">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="package"
                           style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        Gestión de Depósito
                    </h1>
                    <p class="page-subtitle">
                        <% if ("entregadas".equals(filtroEstado)) { %>
                        Historial de solicitudes ya entregadas.
                        <% } else if ("todas".equals(filtroEstado)) { %>
                        Todas las solicitudes aprobadas y entregadas.
                        <% } else { %>
                        Solicitudes aprobadas listas para entrega física.
                        <% } %>
                    </p>
                </div>

                <div class="download-group">
                    <span class="download-label">
                        <i data-lucide="download"></i>
                        Inventario actual
                    </span>
                    <a href="<%= ctx %>/ReportServlet?action=inventario&format=csv"
                       class="btn-download-csv"
                       title="Descargar inventario actual en formato CSV">
                        <i data-lucide="file-text"></i>
                        CSV
                    </a>
                    <a href="<%= ctx %>/ReportServlet?action=inventario&format=xlsx"
                       class="btn-download-xlsx"
                       title="Descargar inventario actual en formato Excel">
                        <i data-lucide="file-spreadsheet"></i>
                        Excel
                    </a>
                </div>
            </div>

            <% if (success != null) { %>
            <div class="alert alert-success">
                <i data-lucide="check-circle"></i>
                <span><%= success %></span>
            </div>
            <% } %>
            <% if (errParam != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= errParam %></span>
            </div>
            <% } %>
            <% if (error != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <div class="info-banner">
                <div class="info-banner-icon">
                    <i data-lucide="info"></i>
                </div>
                <div>
                    <p class="info-banner-title">¿Cómo funciona la entrega?</p>
                    <p class="info-banner-desc">
                        El stock <strong>ya fue descontado del inventario cuando esta solicitud fue aprobada</strong>.
                        Al marcarla como entregada solo confirmas que el material salió físicamente del depósito y
                        se cierra el ciclo de la solicitud. <strong>No se vuelve a tocar el inventario</strong>.
                    </p>
                </div>
            </div>

            <%-- ═══════ BUSCADOR + FILTROS (componente global "Ola") ═══════ --%>
            <form action="<%= ctx %>/DepositServlet" method="GET" class="filter-bar">

                <div class="filter-search">
                    <i data-lucide="search"></i>
                    <input type="text" name="q"
                           value="<%= filtroQ %>"
                           placeholder="Buscar por ID, solicitante o material..."/>
                </div>

                <div class="filter-actions">
                    <select name="estado" class="filter-select">
                        <option value="pendientes" <%= "pendientes".equals(filtroEstado) ? "selected" : "" %>>Pendientes de entrega</option>
                        <option value="entregadas" <%= "entregadas".equals(filtroEstado) ? "selected" : "" %>>Entregadas</option>
                        <option value="todas"      <%= "todas".equals(filtroEstado)      ? "selected" : "" %>>Todas</option>
                    </select>

                    <button type="submit" class="btn-page-primary btn-icon">
                        <i data-lucide="filter"></i>
                        Filtrar
                    </button>

                    <% if (hayFiltrosActivos) { %>
                    <a href="<%= ctx %>/DepositServlet" class="btn-clear-filter">
                        <i data-lucide="x"></i>
                        Limpiar
                    </a>
                    <% } %>
                </div>
            </form>

            <div class="table-panel">

                <% if (solicitudesPagina == null || solicitudesPagina.isEmpty()) { %>

                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i data-lucide="<%= hayFiltrosActivos ? "search-x" : "party-popper" %>"></i>
                    </div>
                    <p class="empty-state-title">
                        <%= hayFiltrosActivos ? "Sin resultados" : "¡Todo al día!" %>
                    </p>
                    <p class="empty-state-desc">
                        <% if (hayFiltrosActivos) { %>
                        No hay solicitudes que coincidan con tu búsqueda o filtro.
                        <% } else { %>
                        No hay solicitudes pendientes de entrega en este momento.
                        <% } %>
                    </p>
                </div>

                <% } else { %>

                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th">ID</th>
                            <th class="th">Solicitante</th>
                            <th class="th">Material</th>
                            <th class="th-center">Cantidad</th>
                            <th class="th">Aprobada por</th>
                            <th class="th">Fecha aprobación</th>
                            <th class="th-center">Estado</th>
                            <th class="th-center" style="width: 220px;">Acción</th>
                        </tr>
                        </thead>
                        <tbody class="table-body">

                        <% for (Transaction tx : solicitudesPagina) {
                            boolean yaEntregada = "COMPLETED".equals(tx.getStatus());
                        %>
                        <tr class="table-row">

                            <td class="td-id">
                                TXN-<%= String.format("%04d", tx.getId()) %>
                            </td>

                            <td class="td"><%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %></td>

                            <td class="td" style="font-weight: 600; color: var(--gray-800);"><%= tx.getItemName() != null ? tx.getItemName() : "—" %></td>

                            <td class="td-center" style="font-weight: 700; color: var(--gray-800);">
                                <%= tx.getQuantity() %>
                                <span style="font-weight: 500; color: var(--gray-500); font-size: 0.8rem;">
                                    <%= tx.getItemUnit() != null ? tx.getItemUnit() : "" %>
                                </span>
                            </td>

                            <td class="td"><%= tx.getApproverName() != null ? tx.getApproverName() : "—" %></td>

                            <td class="td-light" style="font-size: 0.85rem;"><%= tx.getCreatedAt() != null ? tx.getCreatedAt() : "—" %></td>

                            <td class="td-center">
                                <% if (yaEntregada) { %>
                                <span class="status-delivered">Entregada</span>
                                <% } else { %>
                                <span class="status-approved">Aprobada</span>
                                <% } %>
                            </td>

                            <td class="td-center">
                                <div class="row-actions">

                                    <% if (yaEntregada) { %>
                                    <span style="color: var(--gray-400); font-size: 0.78rem; font-style: italic;">— Ya entregada —</span>
                                    <% } else { %>
                                    <a href="#modal-entregar-<%= tx.getId() %>" class="btn-deliver">
                                        <i data-lucide="package-check"></i>
                                        Marcar Entregada
                                    </a>
                                    <% } %>

                                    <a href="<%= ctx %>/TransactionServlet?action=detalle&id=<%= tx.getId() %>&origen=despacho"
                                       class="detail-link">
                                        <i data-lucide="eye"></i>
                                        Ver
                                    </a>

                                </div>
                            </td>

                        </tr>
                        <% } %>

                        </tbody>
                    </table>
                </div>

                <div class="pager">
                    <div class="pager-info">
                        <span>Mostrando <strong><%= solicitudesPagina.size() %></strong> de <strong><%= totalSolicitudes %></strong> solicitudes</span>
                        <span class="pager-info-badge"><i data-lucide="waves"></i> ≈ 8 por ola</span>
                    </div>
                    <% if (totalPages > 1) { %>
                    <div class="pager-nav">
                        <% if (currentPage > 1) { %><a href="<%= _pUrlDep %>&page=<%= currentPage-1 %>" class="pager-btn"><i data-lucide="chevron-left"></i></a>
                        <% } else { %><span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-left"></i></span><% } %>
                        <% if (_winS > 1) { %><a href="<%= _pUrlDep %>&page=1" class="pager-btn">1</a><% if (_winS > 2) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %><% } %>
                        <% for (int _p = _winS; _p <= _winE; _p++) { %>
                        <% if (_p == currentPage) { %><span class="pager-btn pager-btn--active"><%= _p %></span>
                        <% } else { %><a href="<%= _pUrlDep %>&page=<%= _p %>" class="pager-btn"><%= _p %></a><% } %>
                        <% } %>
                        <% if (_winE < totalPages) { %><% if (_winE < totalPages-1) { %><span class="pager-dots"><span></span><span></span><span></span></span><% } %><a href="<%= _pUrlDep %>&page=<%= totalPages %>" class="pager-btn"><%= totalPages %></a><% } %>
                        <% if (currentPage < totalPages) { %><a href="<%= _pUrlDep %>&page=<%= currentPage+1 %>" class="pager-btn"><i data-lucide="chevron-right"></i></a>
                        <% } else { %><span class="pager-btn pager-btn--disabled"><i data-lucide="chevron-right"></i></span><% } %>
                    </div>
                    <% } %>
                </div>

                <% } %>

            </div><%-- /table-panel --%>

            <%-- ═══════ MODALES — Confirmación de entrega (solo para las APROBADAS) ═══════ --%>
            <% if (solicitudesPagina != null) {
                for (Transaction mTx : solicitudesPagina) {
                    if (!"COMPLETED".equals(mTx.getStatus())) {
            %>
            <div id="modal-entregar-<%= mTx.getId() %>" class="modal-overlay">
                <div class="modal-box">
                    <div class="modal-icon modal-icon--purple"><i data-lucide="package-check"></i></div>
                    <h3 class="modal-title">¿Confirmas la entrega física?</h3>
                    <p class="modal-desc">
                        "<strong class="modal-name"><%= mTx.getItemName() %></strong>" para
                        <strong class="modal-name"><%= mTx.getRequesterName() %></strong> —
                        <%= mTx.getQuantity() %> <%= mTx.getItemUnit() %>
                    </p>

                    <form action="<%= ctx %>/DepositServlet" method="POST">
                        <input type="hidden" name="action" value="entregar"/>
                        <input type="hidden" name="id" value="<%= mTx.getId() %>"/>

                        <label class="modal-notes-label" for="notas-<%= mTx.getId() %>">
                            ¿Algún imprevisto? (opcional)
                        </label>
                        <textarea id="notas-<%= mTx.getId() %>" name="notas" class="modal-notes-input"
                                  placeholder="Ej: retraso de 2 días, llegó de otro color..."></textarea>

                        <div class="modal-btns" style="margin-top: 1.1rem;">
                            <a href="#modal-cerrar" class="btn-modal-cancel">Cancelar</a>
                            <button type="submit" class="btn-modal-ok btn-modal-ok--purple">
                                <i data-lucide="package-check"></i>Sí, entregar
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            <%      }
            }
            } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });

    function validarYSubirAvatar(input) {
        const file = input.files[0];
        if (!file) return;

        const MAX_BYTES = 5 * 1024 * 1024;
        const TIPOS_PERMITIDOS = ['image/jpeg', 'image/png', 'image/webp'];

        if (TIPOS_PERMITIDOS.indexOf(file.type) === -1) {
            mostrarAlertaAvatar('Formato no permitido', 'Solo se aceptan imágenes en formato JPG, PNG o WEBP.', 'error');
            input.value = '';
            return;
        }

        if (file.size > MAX_BYTES) {
            const sizeMb = (file.size / (1024 * 1024)).toFixed(1);
            mostrarAlertaAvatar('Imagen demasiado grande', 'Tu imagen pesa ' + sizeMb + ' MB. El máximo permitido es 5 MB.', 'error');
            input.value = '';
            return;
        }

        document.getElementById('avatar-form').submit();
    }

    function mostrarAlertaAvatar(titulo, mensaje, tipo) {
        const previa = document.getElementById('avatar-alert-dynamic');
        if (previa) previa.remove();

        const colorBg     = tipo === 'error' ? 'var(--red-bg)'     : 'var(--green-bg)';
        const colorTxt    = tipo === 'error' ? 'var(--red-dark)'   : 'var(--green-dark)';
        const colorBorder = tipo === 'error' ? '#FECACA'           : '#BBF7D0';
        const icono       = tipo === 'error' ? 'alert-triangle'    : 'check-circle';

        const html = `
            <div id="avatar-alert-dynamic" style="display: flex; align-items: flex-start; gap: 0.7rem; padding: 1rem 1.2rem; margin-bottom: 1.25rem; background: ${colorBg}; color: ${colorTxt}; border: 1px solid ${colorBorder}; border-radius: var(--radius-sm); font-size: 0.88rem; font-weight: 600; animation: slideDown 0.3s ease;">
                <i data-lucide="${icono}" style="width: 20px; height: 20px; flex-shrink: 0; margin-top: 2px;"></i>
                <div style="flex: 1;">
                    <div style="font-weight: 800; margin-bottom: 0.2rem; font-size: 0.92rem;">${titulo}</div>
                    <div style="font-weight: 500; line-height: 1.5;">${mensaje}</div>
                </div>
                <button onclick="this.parentElement.remove()" style="background: none; border: none; cursor: pointer; color: ${colorTxt}; padding: 0; opacity: 0.6;">
                    <i data-lucide="x" style="width: 16px; height: 16px;"></i>
                </button>
            </div>
        `;

        const pageHeader = document.querySelector('.page-header');
        if (pageHeader) {
            pageHeader.insertAdjacentHTML('afterend', html);
            if (typeof lucide !== 'undefined') lucide.createIcons();
            window.scrollTo({ top: 0, behavior: 'smooth' });
            setTimeout(() => {
                const el = document.getElementById('avatar-alert-dynamic');
                if (el) {
                    el.style.transition = 'opacity 0.4s';
                    el.style.opacity = '0';
                    setTimeout(() => el.remove(), 400);
                }
            }, 6000);
        }
    }
</script>

<style>
    @keyframes slideDown {
        from { opacity: 0; transform: translateY(-10px); }
        to   { opacity: 1; transform: translateY(0); }
    }
</style>

</body>
</html>
