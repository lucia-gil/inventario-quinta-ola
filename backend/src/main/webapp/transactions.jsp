<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    List<Transaction> transacciones = (List<Transaction>) request.getAttribute("transacciones");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");

    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (totalRecords == null) totalRecords = 0;

    String error = (String) request.getAttribute("error");
    String success = request.getParameter("success");
    String errParam = request.getParameter("error");

    Integer roleId = (Integer) session.getAttribute("roleId");
    Integer currentUserIdSession = (Integer) session.getAttribute("userId");
    int currentUserId = currentUserIdSession != null ? currentUserIdSession : 0;

    // Solo Manager (3) y Administrador (4) pueden aprobar/rechazar
    boolean puedeAprobar = (roleId != null && (roleId == 3 || roleId == 4));

    // Solo NO-SuperAdmin puede crear solicitudes
    boolean puedeSolicitar = (roleId != null && roleId != 5);

    request.setAttribute("activeMenu", "transactions");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Bandeja de Aprobaciones | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=10" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        .actions-cell {
            display: flex;
            gap: 0.5rem;
            justify-content: center;
        }

        .btn-approve,
        .btn-reject {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.4rem 0.85rem;
            border-radius: var(--radius-sm);
            font-size: 0.75rem;
            font-weight: 700;
            cursor: pointer;
            border: 1px solid;
            transition: all var(--transition);
        }

        .btn-approve {
            background: var(--green-bg);
            color: var(--green-dark);
            border-color: #BBF7D0;
        }
        .btn-approve:hover {
            background: var(--green);
            color: var(--white);
            transform: translateY(-1px);
        }

        .btn-reject {
            background: var(--red-bg);
            color: var(--red-dark);
            border-color: #FECACA;
        }
        .btn-reject:hover {
            background: var(--red);
            color: var(--white);
            transform: translateY(-1px);
        }

        .btn-approve i,
        .btn-reject i { width: 13px; height: 13px; }

        .own-request-tag {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.35rem 0.75rem;
            border-radius: var(--radius-full);
            background: var(--purple-bg);
            color: var(--purple);
            font-size: 0.72rem;
            font-weight: 700;
            font-style: italic;
        }
        .own-request-tag i { width: 13px; height: 13px; }

        .detail-link {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            color: var(--pink);
            font-weight: 700;
            font-size: 0.82rem;
            text-decoration: none;
            transition: color var(--transition);
        }
        .detail-link:hover { color: var(--purple); }
        .detail-link i { width: 14px; height: 14px; }

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
            color: var(--green-dark);
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

        .pagination {
            display: flex;
            gap: 0.4rem;
            align-items: center;
        }

        .pagination a,
        .pagination .pagination-current {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.45rem 0.9rem;
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

        .alert {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            padding: 0.9rem 1.1rem;
            border-radius: var(--radius-sm);
            font-size: 0.88rem;
            font-weight: 600;
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

            <%-- Cabecera --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="inbox" style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        Bandeja de Aprobaciones
                    </h1>
                    <p class="page-subtitle">Solicitudes pendientes que requieren tu atención</p>
                </div>

                <% if (puedeSolicitar) { %>
                <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="btn-page-primary btn-icon">
                    <i data-lucide="plus"></i>
                    Nueva Solicitud
                </a>
                <% } %>
            </div>

            <%-- Alertas --%>
            <% if (success != null) { %>
            <div class="alert alert-success">
                <i data-lucide="check-circle"></i>
                <span><%= success %></span>
            </div>
            <% } %>
            <% if (errParam != null || error != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= errParam != null ? errParam : error %></span>
            </div>
            <% } %>

            <%-- Tabla --%>
            <div class="table-panel">

                <% if (transacciones == null || transacciones.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <i data-lucide="check-check"></i>
                    </div>
                    <p class="empty-state-title">¡Todo al día!</p>
                    <p class="empty-state-desc">No tienes solicitudes pendientes por aprobar.</p>
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
                            <th class="th">Fecha de Entrega</th>
                            <th class="th-center">Detalle</th>
                            <% if (puedeAprobar) { %>
                            <th class="th-center">Acciones</th>
                            <% } %>
                        </tr>
                        </thead>
                        <tbody class="table-body">

                        <% for (Transaction tx : transacciones) { %>
                        <tr class="table-row">
                            <td class="td-id">TXN-<%= String.format("%04d", tx.getId()) %></td>

                            <td class="td">
                                <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                            </td>

                            <td class="td" style="font-weight: 600; color: var(--gray-800);">
                                <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                            </td>

                            <td class="td-center">
                                <%= tx.getQuantity() %> <%= tx.getItemUnit() != null ? tx.getItemUnit() : "" %>
                            </td>

                            <td class="td-light" style="font-family: 'Courier New', monospace; font-size: 0.8rem;">
                                <%= tx.getEstimatedDelivery() != null ? tx.getEstimatedDelivery() : "—" %>
                            </td>

                            <td class="td-center">
                                <a href="<%= ctx %>/TransactionServlet?action=detalle&id=<%= tx.getId() %>"
                                   class="detail-link">
                                    <i data-lucide="eye"></i>
                                    Ver
                                </a>
                            </td>

                            <% if (puedeAprobar) { %>
                            <td class="td-center">
                                <% if (tx.getRequesterId() == currentUserId) { %>
                                <%-- Es la propia solicitud del aprobador → no puede auto-aprobar --%>
                                <span class="own-request-tag" title="No puedes aprobar tus propias solicitudes">
                                        <i data-lucide="user"></i>
                                        Tu solicitud
                                    </span>
                                <% } else { %>
                                <div class="actions-cell">
                                    <form action="<%= ctx %>/TransactionServlet" method="POST"
                                          onsubmit="return confirm('¿Aprobar esta solicitud?');"
                                          style="margin: 0;">
                                        <input type="hidden" name="action" value="aprobar"/>
                                        <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                                        <input type="hidden" name="notas" value="Aprobado"/>
                                        <button type="submit" class="btn-approve">
                                            <i data-lucide="check"></i>
                                            Aprobar
                                        </button>
                                    </form>

                                    <button onclick="rechazarTx(<%= tx.getId() %>)" class="btn-reject">
                                        <i data-lucide="x"></i>
                                        Rechazar
                                    </button>
                                </div>
                                <% } %>
                            </td>
                            <% } %>
                        </tr>
                        <% } %>

                        </tbody>
                    </table>
                </div>

                <%-- Footer con paginación --%>
                <div class="panel-footer">
                    <p class="panel-count-text">
                        Mostrando
                        <strong style="color: var(--gray-800);"><%= transacciones.size() %></strong>
                        de
                        <strong style="color: var(--gray-800);"><%= totalRecords %></strong>
                        pendientes
                    </p>

                    <% if (totalPages > 1) { %>
                    <div class="pagination">
                        <% if (currentPage > 1) { %>
                        <a href="<%= ctx %>/TransactionServlet?action=lista&page=<%= currentPage - 1 %>">
                            <i data-lucide="chevron-left"></i>
                            Anterior
                        </a>
                        <% } %>

                        <span class="pagination-current">
                                Pág <%= currentPage %> de <%= totalPages %>
                            </span>

                        <% if (currentPage < totalPages) { %>
                        <a href="<%= ctx %>/TransactionServlet?action=lista&page=<%= currentPage + 1 %>">
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

        <%-- Form oculto rechazar --%>
        <form id="rejectForm" action="<%= ctx %>/TransactionServlet" method="POST" style="display:none;">
            <input type="hidden" name="action" value="rechazar"/>
            <input type="hidden" name="id" id="rejectTxId"/>
            <input type="hidden" name="notas" id="rejectNotas"/>
        </form>

        <script>
            function rechazarTx(id) {
                const motivo = prompt('Motivo del rechazo (obligatorio):');
                if (motivo && motivo.trim() !== '') {
                    document.getElementById('rejectTxId').value = id;
                    document.getElementById('rejectNotas').value = motivo;
                    document.getElementById('rejectForm').submit();
                } else if (motivo !== null) {
                    alert('El motivo es obligatorio.');
                }
            }

            document.addEventListener('DOMContentLoaded', function () {
                if (typeof lucide !== 'undefined') lucide.createIcons();
            });
        </script>

        <jsp:include page="includes/footer.jsp"/>
    </div>
</div>

</body>
</html>