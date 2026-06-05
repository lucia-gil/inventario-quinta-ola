<%--
    ════════════════════════════════════════════════════════════════════
     deposit.jsp — Vista del encargado de depósito (rediseño Quinta Ola)
    ════════════════════════════════════════════════════════════════════
     CAMBIOS DE ESTILO REALIZADOS:
     - Agregado layout-wrapper + main-content para que el sidebar no
       solape el contenido (estaba traslapado en la captura).
     - Incluido topbar.jsp (faltaba la barra superior).
     - Reemplazados emojis por iconos que se ven mas profesionales
       Lucide (package, info, check-circle, alert-circle, party-popper,
       eye, arrow-right) consistentes con el resto del sistema.
     - Cache buster CSS de v=3 a v=10.
     - Alertas usando clases del sistema (.alert-success / .alert-error)
       con iconos Lucide en vez de emojis y colores planos.
     - Info banner rediseñado en gradient azul-morado con icono info.
     - Tabla con badges TXN morados, link "Ver" con color del sistema,
       botón "Marcar Entregada" con gradient pink-purple, icono y hover.
     - Empty state cuando no hay solicitudes: icono party-popper en
       círculo verde + título y descripción amigables.
     - Header con icono package Lucide y botón "Ver historial completo"
       con icono history y flecha que se desplaza al hover.
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

        /* ═════ Botón ghost con icono ═════ */
        .btn-ghost-icon {
            display: inline-flex;
            align-items: center;
            gap: 0.45rem;
        }
        .btn-ghost-icon i {
            width: 14px;
            height: 14px;
            transition: transform var(--transition);
        }
        .btn-ghost-icon:hover i.arrow { transform: translateX(3px); }
    </style>
</head>

<body class="page-body">

<%-- Layout wrapper para que el sidebar no se solape con el contenido --%>
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <%-- Topbar que faltaba en el diseño anterior --%>
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- Cabecera con icono Lucide --%>
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
                <a href="<%= ctx %>/HistoryServlet" class="btn-ghost btn-ghost-icon">
                    <i data-lucide="history"></i>
                    Ver historial completo
                    <i data-lucide="arrow-right" class="arrow"></i>
                </a>
            </div>

            <%-- Mensajes de éxito / error con iconos Lucide --%>
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

            <%-- Info banner azul-morado con icono Lucide --%>
            <div class="info-banner">
                <div class="info-banner-icon">
                    <i data-lucide="info"></i>
                </div>
                <div>
                    <p class="info-banner-title">Recuerda antes de entregar</p>
                    <p class="info-banner-desc">
                        Cuando marques una solicitud como entregada, el stock del material se
                        descontará automáticamente del inventario. Asegúrate de haber entregado
                        físicamente el material antes de confirmar.
                    </p>
                </div>
            </div>

            <%-- Tabla de solicitudes aprobadas --%>
            <div class="table-panel">

                <% if (solicitudes == null || solicitudes.isEmpty()) { %>

                <%-- Empty state con icono party-popper en círculo verde --%>
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

                        <% for (Transaction tx : solicitudes) { %>
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

                                    <%-- Botón para marcar como entregada --%>
                                    <form action="<%= ctx %>/DepositServlet" method="POST"
                                          onsubmit="return confirm('¿Confirmas que entregaste físicamente este material? Esto descontará del stock.');"
                                          style="display:inline; margin:0;">
                                        <input type="hidden" name="action" value="entregar"/>
                                        <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                                        <button type="submit" class="btn-deliver">
                                            <i data-lucide="package-check"></i>
                                            Marcar Entregada
                                        </button>
                                    </form>

                                    <%-- Link al detalle --%>
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

                <div class="panel-footer">
                    <p class="panel-count-text">
                        <strong style="color: var(--gray-800);"><%= solicitudes.size() %></strong>
                        solicitudes pendientes de entrega
                    </p>
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