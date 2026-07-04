<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    List<Transaction> transacciones = (List<Transaction>) request.getAttribute("transacciones");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");

    int _page  = currentPage != null ? currentPage : 1;
    int _total = totalPages != null ? totalPages : 1;
    int _count = totalRecords != null ? totalRecords : 0;

    int _pageSize = 15;

    int _from = (_count == 0) ? 0 : ((_page - 1) * _pageSize) + 1;
    int _to   = Math.min(_page * _pageSize, _count);

    // ventana deslizante
    int _win = 2;
    int _winS = Math.max(1, _page - _win);
    int _winE = Math.min(_total, _page + _win);

    // Captura de parámetros para el buscador y persistencia en la paginación
    String searchParam = request.getParameter("search");
    String fechaParam = request.getParameter("fechaEntrega");

    String _pUrl = ctx + "/TransactionServlet?action=lista";
    if (searchParam != null && !searchParam.trim().isEmpty()) {
        _pUrl += "&search=" + java.net.URLEncoder.encode(searchParam, "UTF-8");
    }
    if (fechaParam != null && !fechaParam.trim().isEmpty()) {
        _pUrl += "&fechaEntrega=" + java.net.URLEncoder.encode(fechaParam, "UTF-8");
    }

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

        /* Estilos del contenedor de filtros */
        .search-container {
            background: var(--white);
            padding: 1.25rem;
            border-radius: var(--radius-sm);
            border: 1px solid var(--gray-200);
            margin-bottom: 1.25rem;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }
        .search-form {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            align-items: flex-end;
        }
        .search-group {
            flex: 1;
            min-width: 260px;
        }
        .date-group {
            min-width: 180px;
        }
        .filter-label {
            display: block;
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--gray-600);
            margin-bottom: 0.4rem;
        }
        .filter-input {
            width: 100%;
            padding: 0.5rem 0.75rem;
            border: 1px solid var(--gray-300);
            border-radius: var(--radius-sm);
            font-size: 0.85rem;
            color: var(--gray-800);
            background-color: var(--white);
            transition: border-color var(--transition);
            height: 38px;
            box-sizing: border-box;
        }
        .filter-input:focus {
            outline: none;
            border-color: var(--purple-light);
        }
        .search-actions {
            display: flex;
            gap: 0.5rem;
        }
        .btn-search {
            height: 38px;
            padding: 0 1.25rem;
            font-size: 0.85rem;
            font-weight: 700;
            background: var(--purple);
            color: var(--white);
            border: none;
            border-radius: var(--radius-sm);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            transition: background var(--transition);
        }
        .btn-search:hover {
            background: var(--purple-light);
        }
        .btn-clear {
            height: 38px;
            padding: 0 1rem;
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--gray-600);
            background: var(--white);
            border: 1px solid var(--gray-300);
            border-radius: var(--radius-sm);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            transition: all var(--transition);
            box-sizing: border-box;
        }
        .btn-clear:hover {
            border-color: var(--purple-light);
            color: var(--purple);
            background: var(--purple-bg);
        }

        .pag-ola-bar {
            display: flex; align-items: center;
            justify-content: space-between;
            padding: 0.8rem 1.25rem 0.95rem;
            flex-wrap: wrap; gap: 0.6rem;
            border-top: 2.5px solid transparent;
            border-image: linear-gradient(
                    90deg, var(--purple-light), var(--pink), var(--purple-light)
            ) 1;
            background: linear-gradient(180deg, rgba(109,40,217,0.03) 0%, transparent 100%);
        }
        .pag-ola-info {
            display: flex; align-items: center; gap: 0.5rem;
            font-size: 0.8rem; color: var(--gray-500);
        }
        .pag-ola-info strong { color: var(--gray-700); }
        .pag-ola-tag {
            font-size: 0.67rem; font-weight: 700;
            background: var(--purple-bg); color: var(--purple);
            padding: 0.17rem 0.55rem;
            border-radius: var(--radius-full); letter-spacing: 0.3px;
        }
        .pag-ola-controls { display: flex; align-items: center; gap: 0.22rem; }
        .pag-btn {
            display: inline-flex; align-items: center; justify-content: center;
            gap: 0.2rem; min-width: 32px; height: 32px; padding: 0 0.6rem;
            border-radius: 999px;
            font-size: 0.78rem; font-weight: 600;
            color: var(--gray-600); background: var(--white);
            border: 1.5px solid var(--gray-200);
            text-decoration: none;
            transition: border-color 0.15s, color 0.15s, background 0.15s, transform 0.15s, box-shadow 0.15s;
            white-space: nowrap; line-height: 1;
        }
        .pag-btn:hover {
            border-color: var(--purple-light); color: var(--purple);
            background: var(--purple-bg);
            transform: translateY(-1px);
            box-shadow: 0 2px 8px rgba(109,40,217,0.14);
        }
        .pag-btn--active {
            background: linear-gradient(135deg, var(--purple) 0%, var(--purple-light) 100%);
            color: #fff !important; border-color: transparent !important;
            box-shadow: 0 3px 10px rgba(109,40,217,0.32);
            cursor: default; pointer-events: none;
        }
        .pag-btn--disabled { opacity: 0.32; cursor: not-allowed; pointer-events: none; }
        .pag-btn i { width: 12px; height: 12px; }
        .pag-ellipsis {
            color: var(--gray-400); font-size: 0.78rem;
            padding: 0 0.18rem; user-select: none;
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

        /* ════ Modal personalizado para Aprobar/Rechazar en la tabla ════ */
        .modal-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(15, 23, 42, 0.4); display: none; align-items: center; justify-content: center;
            z-index: 9999; backdrop-filter: blur(2px); opacity: 0; animation: fadeIn 0.2s forwards;
        }
        @keyframes fadeIn { to { opacity: 1; } }
        .modal-content {
            background: var(--white); padding: 1.5rem; border-radius: var(--radius-md);
            width: 90%; max-width: 420px; box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            border: 1px solid var(--gray-200); transform: translateY(15px); animation: slideUp 0.2s forwards ease-out;
        }
        @keyframes slideUp { to { transform: translateY(0); } }
        .modal-header { font-weight: 700; font-size: 1.15rem; margin-bottom: 0.25rem; color: var(--gray-800); display: flex; align-items: center; gap: 0.4rem; }
        .modal-desc { font-size: 0.88rem; color: var(--gray-600); margin-bottom: 1rem; }
        .modal-textarea {
            width: 100%; padding: 0.75rem; border: 1px solid var(--gray-300);
            border-radius: var(--radius-sm); font-family: inherit; font-size: 0.9rem; margin-bottom: 1.25rem; box-sizing: border-box; resize: vertical;
        }
        .modal-textarea:focus { outline: none; border-color: var(--purple-light); box-shadow: 0 0 0 2px rgba(109,40,217,0.1); }
        .modal-actions { display: flex; justify-content: flex-end; gap: 0.6rem; }
        .btn-modal-cancel {
            padding: 0.5rem 1rem; background: var(--gray-100); color: var(--gray-700);
            border: 1px solid var(--gray-200); border-radius: var(--radius-sm); cursor: pointer; font-weight: 600; font-size: 0.85rem; transition: all 0.15s;
        }
        .btn-modal-cancel:hover { background: var(--gray-200); }
        .btn-modal-confirm {
            padding: 0.5rem 1rem; color: #fff; border: none; border-radius: var(--radius-sm); cursor: pointer; font-weight: 600; font-size: 0.85rem; display: flex; align-items: center; gap: 0.3rem; transition: all 0.15s;
        }
        .btn-modal-confirm.approve { background: var(--green); }
        .btn-modal-confirm.approve:hover { background: var(--green-dark); }
        .btn-modal-confirm.reject { background: var(--red); }
        .btn-modal-confirm.reject:hover { background: var(--red-dark); }
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
                <a href="<%= ctx %>/TransactionServlet?action=formCrear&origen=transactions" class="btn-page-primary btn-icon">
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

            <%-- Formulario / Caja de búsqueda Única y Filtro de Fecha --%>
            <div class="search-container">
                <form action="<%= ctx %>/TransactionServlet" method="GET" class="search-form">
                    <input type="hidden" name="action" value="lista" />

                    <div class="search-group">
                        <label class="filter-label" for="search">Búsqueda rápida</label>
                        <input type="text" id="search" name="search" class="filter-input"
                               placeholder="ID solicitud, material o solicitante..."
                               value="<%= searchParam != null ? searchParam : "" %>" />
                    </div>

                    <div class="date-group">
                        <label class="filter-label" for="fechaEntrega">Fecha de entrega</label>
                        <input type="date" id="fechaEntrega" name="fechaEntrega" class="filter-input"
                               value="<%= fechaParam != null ? fechaParam : "" %>" />
                    </div>

                    <div class="search-actions">
                        <button type="submit" class="btn-search">
                            <i data-lucide="search" style="width: 16px; height: 16px;"></i>
                            Filtrar
                        </button>
                        <% if ((searchParam != null && !searchParam.trim().isEmpty()) || (fechaParam != null && !fechaParam.trim().isEmpty())) { %>
                        <a href="<%= ctx %>/TransactionServlet?action=lista" class="btn-clear">
                            <i data-lucide="x" style="width: 16px; height: 16px;"></i>
                            Limpiar
                        </a>
                        <% } %>
                    </div>
                </form>
            </div>

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

                            <td class="td-light">
                                <%
                                    Object deliveryObj = tx.getEstimatedDelivery();
                                    if (deliveryObj != null) {
                                        String displayDate = deliveryObj.toString();
                                        try {
                                            if (deliveryObj instanceof java.time.LocalDate) {
                                                displayDate = ((java.time.LocalDate) deliveryObj).format(java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy"));
                                            } else if (deliveryObj instanceof java.util.Date) {
                                                displayDate = new java.text.SimpleDateFormat("dd-MM-yyyy").format((java.util.Date) deliveryObj);
                                            } else if (displayDate.matches("\\d{4}-\\d{2}-\\d{2}")) {
                                                java.time.LocalDate ld = java.time.LocalDate.parse(displayDate);
                                                displayDate = ld.format(java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy"));
                                            }
                                        } catch (Exception e) {}
                                        out.print(displayDate);
                                    } else {
                                        out.print("—");
                                    }
                                %>
                            </td>

                            <td class="td-center">
                                <a href="<%= ctx %>/TransactionServlet?action=detalle&id=<%= tx.getId() %>&origen=lista" class="detail-link">
                                    <i data-lucide="eye"></i>
                                    Ver
                                </a>
                            </td>

                            <% if (puedeAprobar) { %>
                            <td class="td-center">
                                <% if (tx.getRequesterId() == currentUserId) { %>
                                <span class="own-request-tag" title="No puedes aprobar tus propias solicitudes">
                                        <i data-lucide="user"></i>
                                        Tu solicitud
                                </span>
                                <% } else { %>
                                <div class="actions-cell">
                                    <button type="button" onclick="abrirModal('aprobar', <%= tx.getId() %>)" class="btn-approve">
                                        <i data-lucide="check"></i>
                                        Aprobar
                                    </button>

                                    <button type="button" onclick="abrirModal('rechazar', <%= tx.getId() %>)" class="btn-reject">
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
                <div class="pag-ola-bar">

                    <div class="pag-ola-info">
                        <span>
                            Mostrando
                            <strong><%= _from %>–<%= _to %></strong>
                            de
                            <strong><%= _count %></strong>
                            solicitudes
                        </span>

                        <span class="pag-ola-tag">
                            ≈ 15 por ola
                        </span>
                    </div>

                    <% if (_total > 1) { %>

                    <div class="pag-ola-controls">

                        <% if (_page > 1) { %>
                        <a href="<%= _pUrl %>&page=<%= _page-1 %>" class="pag-btn">
                            <i data-lucide="chevron-left"></i>
                        </a>
                        <% } else { %>
                        <span class="pag-btn pag-btn--disabled">
                            <i data-lucide="chevron-left"></i>
                        </span>
                        <% } %>


                        <% if (_winS > 1) { %>

                        <a href="<%= _pUrl %>&page=1" class="pag-btn">1</a>

                        <% if (_winS > 2) { %>
                        <span class="pag-ellipsis">…</span>
                        <% } %>

                        <% } %>


                        <% for(int _p = _winS; _p <= _winE; _p++){ %>

                        <% if(_p == _page){ %>

                        <span class="pag-btn pag-btn--active">
                                    <%= _p %>
                                </span>

                        <% }else{ %>

                        <a href="<%= _pUrl %>&page=<%= _p %>" class="pag-btn">
                            <%= _p %>
                        </a>

                        <% } %>

                        <% } %>


                        <% if (_winE < _total) { %>

                        <% if (_winE < _total-1) { %>
                        <span class="pag-ellipsis">…</span>
                        <% } %>

                        <a href="<%= _pUrl %>&page=<%= _total %>" class="pag-btn">
                            <%= _total %>
                        </a>

                        <% } %>


                        <% if (_page < _total) { %>

                        <a href="<%= _pUrl %>&page=<%= _page+1 %>" class="pag-btn">
                            <i data-lucide="chevron-right"></i>
                        </a>

                        <% } else { %>

                        <span class="pag-btn pag-btn--disabled">
                            <i data-lucide="chevron-right"></i>
                        </span>

                        <% } %>

                    </div>

                    <% } %>

                </div>

                <% } %>

            </div>

        </main>

        <%-- ════ Modal Estilizado Interactivo (Reemplaza los Prompts) ════ --%>
        <div id="actionModal" class="modal-overlay">
            <div class="modal-content">
                <div id="modalTitle" class="modal-header">
                    <i id="modalIcon" data-lucide="info"></i>
                    <span id="modalTitleText">Título</span>
                </div>
                <div id="modalDesc" class="modal-desc">Descripción</div>

                <form id="modalForm" action="<%= ctx %>/TransactionServlet" method="POST" style="margin:0;">
                    <input type="hidden" name="action" id="modalAction" value="">
                    <input type="hidden" name="id" id="modalTxId" value="">

                    <textarea id="modalNotas" name="notas" class="modal-textarea" rows="3" placeholder="Comentarios..."></textarea>

                    <div class="modal-actions">
                        <button type="button" onclick="cerrarModal()" class="btn-modal-cancel">Cancelar</button>
                        <button type="submit" id="btnModalSubmit" class="btn-modal-confirm">Confirmar</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            const modal = document.getElementById('actionModal');
            const modalTitleText = document.getElementById('modalTitleText');
            const modalDesc = document.getElementById('modalDesc');
            const modalAction = document.getElementById('modalAction');
            const modalTxId = document.getElementById('modalTxId');
            const modalNotas = document.getElementById('modalNotas');
            const btnModalSubmit = document.getElementById('btnModalSubmit');
            const modalForm = document.getElementById('modalForm');
            const modalIcon = document.getElementById('modalIcon');

            function abrirModal(tipo, id) {
                modalTxId.value = id;
                modalAction.value = tipo;
                modalNotas.value = '';

                if (tipo === 'aprobar') {
                    modalTitleText.innerText = 'Aprobar Solicitud';
                    modalDesc.innerText = 'Puedes agregar un comentario de aprobación (opcional):';
                    modalNotas.required = false;
                    modalNotas.placeholder = 'Ej: Todo correcto, proceder...';
                    btnModalSubmit.innerHTML = '<i data-lucide="check"></i> Sí, Aprobar';
                    btnModalSubmit.className = 'btn-modal-confirm approve';
                    modalIcon.setAttribute('data-lucide', 'check-circle');
                    modalIcon.style.color = 'var(--green)';
                } else {
                    modalTitleText.innerText = 'Rechazar Solicitud';
                    modalDesc.innerText = 'Indica el motivo por el cual rechazas esta solicitud (obligatorio):';
                    modalNotas.required = true;
                    modalNotas.placeholder = 'Motivo del rechazo...';
                    btnModalSubmit.innerHTML = '<i data-lucide="x"></i> Sí, Rechazar';
                    btnModalSubmit.className = 'btn-modal-confirm reject';
                    modalIcon.setAttribute('data-lucide', 'alert-triangle');
                    modalIcon.style.color = 'var(--red)';
                }

                if (typeof lucide !== 'undefined') lucide.createIcons();
                modal.style.display = 'flex';
                setTimeout(() => modalNotas.focus(), 100);
            }

            function cerrarModal() {
                modal.style.display = 'none';
            }

            modalForm.addEventListener('submit', function(e) {
                if (modalAction.value === 'aprobar' && modalNotas.value.trim() === '') {
                    modalNotas.value = 'Aprobado desde la tabla general.';
                }
            });

            document.addEventListener('DOMContentLoaded', function () {
                if (typeof lucide !== 'undefined') lucide.createIcons();
            });
        </script>

        <jsp:include page="includes/footer.jsp"/>
    </div>
</div>

</body>
</html>