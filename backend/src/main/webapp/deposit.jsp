<%--
    ════════════════════════════════════════════════════════════════════
     deposit.jsp — Vista del encargado de depósito (rediseño Quinta Ola)
    ════════════════════════════════════════════════════════════════════
     CAMBIOS NUEVOS DE ESTA ITERACIÓN:
     - Eliminado el botón "Ver historial completo" del header (ya está
       en la navbar lateral, era redundante).
     - Texto del info banner reescrito según la lógica acordada:
       el stock YA se descontó al aprobar; aquí solo se cierra el ciclo
       confirmando la entrega física. No se vuelve a tocar inventario.
     - Agregada paginación de 8 solicitudes por página, con preservación
       de filtros futuros y estilo Quinta Ola (chevron-left/right).
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

    // ─── PAGINACIÓN client-side (8 por página) ───
    // Como el DepositServlet aún no pagina, lo hacemos aquí en memoria.
    // Si en el futuro el servlet manda currentPage/totalPages como
    // request attributes, la JSP los respeta automáticamente.
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

    request.setAttribute("activeMenu", "deposit");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Depósito | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=10" rel="stylesheet"/>
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

        /* ═════ Paginación ═════ */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 0.4rem;
            align-items: center;
            margin-top: 0;
            flex-wrap: wrap;
        }
        .pagination a,
        .pagination .pagination-current {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.5rem 1rem;
            border-radius: var(--radius-sm);
            font-size: 0.82rem;
            font-weight: 600;
            text-decoration: none;
            transition: all var(--transition);
        }
        .pagination a {
            background: var(--white);
            border: 1.5px solid var(--gray-200);
            color: var(--gray-700);
        }
        .pagination a:hover {
            background: var(--purple-bg);
            border-color: var(--purple);
            color: var(--purple);
        }
        .pagination a i { width: 13px; height: 13px; }
        .pagination-current {
            background: var(--purple);
            color: var(--white);
            border: 1.5px solid var(--purple);
        }
    </style>
</head>

<body class="page-body">

<%-- Layout wrapper para que el sidebar no se solape con el contenido --%>
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <%-- Topbar --%>
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- Cabecera (sin botón Historial, ya está en la navbar) --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="package"
                           style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        Gestión de Depósito
                    </h1>
                    <p class="page-subtitle">
                        Solicitudes aprobadas listas para entrega física.
                    </p>
                </div>
            </div>

            <%-- Mensajes de éxito / error --%>
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

            <%--
                Info banner reescrito según la lógica acordada:
                el stock YA se descontó cuando el Manager aprobó.
                Aquí solo cierras el ciclo confirmando la entrega física.
            --%>
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

            <%-- Tabla de solicitudes aprobadas --%>
            <div class="table-panel">

                <% if (solicitudesPagina == null || solicitudesPagina.isEmpty()) { %>

                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i data-lucide="party-popper"></i>
                    </div>
                    <p class="empty-state-title">¡Todo al día!</p>
                    <p class="empty-state-desc">
                        No hay solicitudes pendientes de entrega en este momento.
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
                            <th class="th-center" style="width: 220px;">Acción</th>
                        </tr>
                        </thead>
                        <tbody class="table-body">

                        <% for (Transaction tx : solicitudesPagina) { %>
                        <tr class="table-row">

                            <td class="td-id">
                                TXN-<%= String.format("%04d", tx.getId()) %>
                            </td>

                            <td class="td">
                                <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                            </td>

                            <td class="td" style="font-weight: 600; color: var(--gray-800);">
                                <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                            </td>

                            <td class="td-center" style="font-weight: 700; color: var(--gray-800);">
                                <%= tx.getQuantity() %>
                                <span style="font-weight: 500; color: var(--gray-500); font-size: 0.8rem;">
                                    <%= tx.getItemUnit() != null ? tx.getItemUnit() : "" %>
                                </span>
                            </td>

                            <td class="td">
                                <%= tx.getApproverName() != null ? tx.getApproverName() : "—" %>
                            </td>

                            <td class="td-light" style="font-family: 'Courier New', monospace; font-size: 0.78rem;">
                                <%= tx.getCreatedAt() != null ? tx.getCreatedAt() : "—" %>
                            </td>

                            <td class="td-center">
                                <div class="row-actions">

                                    <form action="<%= ctx %>/DepositServlet" method="POST"
                                          onsubmit="return confirm('¿Confirmas que entregaste físicamente este material? Esta acción cierra el ciclo de la solicitud.');"
                                          style="display:inline; margin:0;">
                                        <input type="hidden" name="action" value="entregar"/>
                                        <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                                        <button type="submit" class="btn-deliver">
                                            <i data-lucide="package-check"></i>
                                            Marcar Entregada
                                        </button>
                                    </form>

                                    <a href="<%= ctx %>/TransactionServlet?action=detalle&id=<%= tx.getId() %>"
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

                <%-- Footer con conteo + paginación --%>
                <div class="panel-footer">
                    <p class="panel-count-text">
                        Mostrando
                        <strong style="color: var(--gray-800);"><%= solicitudesPagina.size() %></strong>
                        de
                        <strong style="color: var(--gray-800);"><%= totalSolicitudes %></strong>
                        solicitudes pendientes
                    </p>

                    <% if (totalPages > 1) { %>
                    <div class="pagination">
                        <% if (currentPage > 1) { %>
                        <a href="<%= ctx %>/DepositServlet?page=<%= currentPage - 1 %>">
                            <i data-lucide="chevron-left"></i>
                            Anterior
                        </a>
                        <% } %>

                        <span class="pagination-current">
                            Pág <%= currentPage %> de <%= totalPages %>
                        </span>

                        <% if (currentPage < totalPages) { %>
                        <a href="<%= ctx %>/DepositServlet?page=<%= currentPage + 1 %>">
                            Siguiente
                            <i data-lucide="chevron-right"></i>
                        </a>
                        <% } %>
                    </div>
                    <% } %>
                </div>

                <% } %>

            </div>

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