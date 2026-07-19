<%--
    ════════════════════════════════════════════════════════════════════
     request-detail.jsp — Detalle de Solicitud (rediseño Quinta Ola)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    Transaction tx = (Transaction) request.getAttribute("tx");
    String error = (String) request.getAttribute("error");

    Integer userIdSession = (Integer) session.getAttribute("userId");
    int userId = userIdSession != null ? userIdSession : 0;

    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    int rol = roleIdSession != null ? roleIdSession : 0;

    // "origen" en la URL manda siempre que lo reconozcamos — así el sidebar
    // resalta la sección correcta sin importar qué activeMenu haya puesto
    // el servlet por defecto (ej: TransactionServlet siempre marca
    // "transactions" salvo que sepa manejar el caso de "despacho").
    String origenParam = request.getParameter("origen");
    String activeMenu;
    if ("historial".equals(origenParam))      activeMenu = "history";
    else if ("despacho".equals(origenParam))  activeMenu = "deposit";
    else if ("lista".equals(origenParam))     activeMenu = "transactions";
    else                                       activeMenu = (String) request.getAttribute("activeMenu");

    if (activeMenu != null) {
        request.setAttribute("activeMenu", activeMenu);
        session.setAttribute("activeMenu", activeMenu);
    }

    // Manager (3) y Administrador (4) aprueban, PERO no sus propias solicitudes.
    // SuperAdmin (5) no aprueba nada.
    boolean puedeAprobar = false;
    if (tx != null && (rol == 3 || rol == 4)) {
        puedeAprobar = (tx.getRequesterId() != userId);
    }

    boolean esMia = (tx != null && tx.getRequesterId() == userId);

    String success = request.getParameter("success");
    String errParam = request.getParameter("error");

    // ─── Helper para extraer motivo de rechazo de las notas ───
    // Tu sistema guarda notas como texto libre; si fue rechazo el motivo está ahí.
    String motivoRechazo = null;
    if (tx != null && "REJECTED".equals(tx.getStatus())) {
        motivoRechazo = tx.getNotes();
    }

    // ─── Fechas seguras (compatibles con tu modelo) ───
    String fechaCreacion = tx != null ? tx.getCreatedAt() : null;
    String fechaProcesada = null;
    String fechaEntregada = null;

    if (tx != null) {
        try { fechaProcesada = (String) tx.getClass().getMethod("getProcessedAt").invoke(tx); } catch (Exception ignored) {}
        try { fechaEntregada = (String) tx.getClass().getMethod("getDeliveredAt").invoke(tx); } catch (Exception ignored) {}
        if (fechaProcesada == null) {
            try { fechaProcesada = (String) tx.getClass().getMethod("getUpdatedAt").invoke(tx); } catch (Exception ignored) {}
        }
    }
%>
<%!
    private String traducirStatus(String s) {
        if (s == null) return "Desconocido";
        switch (s) {
            case "PENDING":   return "Pendiente";
            case "APPROVED":  return "Aprobada";
            case "REJECTED":  return "Rechazada";
            case "COMPLETED": return "Entregada";
            default:          return s;
        }
    }

    private String claseBadgeStatus(String s) {
        if (s == null) return "status-badge";
        switch (s) {
            case "PENDING":   return "status-pending";
            case "APPROVED":  return "status-approved";
            case "REJECTED":  return "status-rejected";
            case "COMPLETED": return "status-delivered";
            default:          return "status-badge";
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Detalle de Solicitud | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=21" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Estilos específicos del detalle ═════ */

        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 360px;
            gap: 1.5rem;
            align-items: start;
        }
        @media (max-width: 1024px) { .detail-grid { grid-template-columns: 1fr; } }

        .detail-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }

        .detail-card-header {
            padding: 1.25rem 1.5rem;
            background: linear-gradient(135deg, var(--purple) 0%, var(--purple-dark) 100%);
            color: var(--white);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .detail-card-header-id {
            font-family: 'Courier New', monospace;
            font-size: 1.15rem;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        .detail-card-header-sub {
            font-size: 0.78rem;
            opacity: 0.85;
            margin-top: 0.2rem;
        }

        .detail-card-body { padding: 1.75rem; }

        .info-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem 2rem;
            margin-bottom: 1.5rem;
        }
        @media (max-width: 540px) { .info-row { grid-template-columns: 1fr; } }

        .info-cell .label {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: var(--gray-500);
            margin-bottom: 0.35rem;
        }
        .info-cell .label i { width: 13px; height: 13px; color: var(--pink); }

        .info-cell .value {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
        }

        /* ═════ Caja motivo rechazo ═════ */
        .reject-box {
            background: var(--red-bg);
            border: 1px solid #FECACA;
            border-left: 4px solid var(--red);
            border-radius: var(--radius-md);
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            gap: 0.85rem;
            align-items: flex-start;
        }
        .reject-box-icon {
            flex-shrink: 0;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: var(--red);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .reject-box-icon i { width: 18px; height: 18px; }
        .reject-box-title {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--red-dark);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.3rem;
        }
        .reject-box-text {
            font-size: 0.9rem;
            color: var(--gray-800);
            line-height: 1.55;
            font-weight: 500;
        }

        /* ═════ Caja notas (azul) ═════ */
        .notes-box {
            background: var(--blue-bg);
            border: 1px solid #BFDBFE;
            border-radius: var(--radius-md);
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
        }
        .notes-box-title {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: var(--blue-dark);
            margin-bottom: 0.4rem;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }
        .notes-box-title i { width: 13px; height: 13px; }
        .notes-box-text {
            font-size: 0.9rem;
            color: var(--gray-700);
            line-height: 1.6;
        }

        /* ═════ Caja de nota de entrega (imprevistos, ámbar) ═════ */
        .delivery-notes-box {
            background: var(--yellow-bg);
            border: 1px solid #FDE68A;
            border-left: 4px solid var(--orange);
            border-radius: var(--radius-md);
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            gap: 0.85rem;
            align-items: flex-start;
        }
        .delivery-notes-box-icon {
            flex-shrink: 0;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: var(--orange);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .delivery-notes-box-icon i { width: 18px; height: 18px; }
        .delivery-notes-box-title {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--orange-dark);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.3rem;
        }
        .delivery-notes-box-text {
            font-size: 0.9rem;
            color: var(--gray-800);
            line-height: 1.55;
            font-weight: 500;
        }

        /* ═════ Bloque acciones aprobar/rechazar ═════ */
        .actions-section {
            border-top: 1px solid var(--gray-100);
            padding-top: 1.5rem;
            margin-top: 0.5rem;
        }
        .actions-section h3 {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 1rem;
        }
        .actions-row {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
        }

        .btn-approve-big,
        .btn-reject-big {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            border-radius: var(--radius-full);
            font-size: 0.88rem;
            font-weight: 700;
            border: none;
            cursor: pointer;
            transition: all var(--transition);
        }

        .btn-approve-big {
            background: var(--green);
            color: var(--white);
            box-shadow: 0 4px 12px rgba(34, 197, 94, 0.25);
        }
        .btn-approve-big:hover {
            background: var(--green-dark);
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(34, 197, 94, 0.4);
        }

        .btn-reject-big {
            background: var(--red);
            color: var(--white);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.25);
        }
        .btn-reject-big:hover {
            background: var(--red-dark);
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(239, 68, 68, 0.4);
        }
        .btn-approve-big i,
        .btn-reject-big i { width: 16px; height: 16px; }

        /* ═════ Tag "Tu solicitud" cuando no puede auto-aprobar ═════ */
        .own-info {
            display: flex;
            align-items: flex-start;
            gap: 0.85rem;
            padding: 1rem 1.25rem;
            background: var(--purple-bg);
            border: 1px solid #DDD6FE;
            border-left: 4px solid var(--purple);
            border-radius: var(--radius-md);
            margin-top: 1rem;
        }
        .own-info-icon {
            flex-shrink: 0;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: var(--purple);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .own-info-icon i { width: 18px; height: 18px; }
        .own-info-title {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--purple);
            margin-bottom: 0.2rem;
        }
        .own-info-desc {
            font-size: 0.82rem;
            color: var(--gray-700);
            line-height: 1.5;
        }

        /* ═════ TIMELINE ═════ */
        .timeline {
            position: relative;
            padding-left: 1.5rem;
        }
        .timeline::before {
            content: '';
            position: absolute;
            left: 11px;
            top: 14px;
            bottom: 14px;
            width: 2px;
            background: var(--gray-200);
        }

        .timeline-step {
            position: relative;
            padding-bottom: 1.25rem;
        }
        .timeline-step:last-child { padding-bottom: 0; }

        .timeline-dot {
            position: absolute;
            left: -1.5rem;
            top: 2px;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: var(--white);
            border: 2px solid var(--gray-300);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray-400);
        }
        .timeline-dot i { width: 12px; height: 12px; }

        .timeline-step.done .timeline-dot {
            background: var(--green);
            border-color: var(--green);
            color: var(--white);
        }
        .timeline-step.current .timeline-dot {
            background: var(--purple);
            border-color: var(--purple);
            color: var(--white);
            box-shadow: 0 0 0 4px rgba(91, 31, 168, 0.15);
        }
        .timeline-step.rejected .timeline-dot {
            background: var(--red);
            border-color: var(--red);
            color: var(--white);
        }
        .timeline-step.pending .timeline-dot {
            background: var(--white);
            border-color: var(--gray-300);
            color: var(--gray-400);
            border-style: dashed;
        }

        .timeline-content {
            padding-left: 0.4rem;
        }

        .timeline-title {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--gray-800);
            margin-bottom: 0.15rem;
        }
        .timeline-step.pending .timeline-title { color: var(--gray-400); }
        .timeline-step.rejected .timeline-title { color: var(--red-dark); }

        .timeline-date {
            font-size: 0.72rem;
            color: var(--gray-500);
            font-family: 'Courier New', monospace;
            font-weight: 600;
        }
        .timeline-actor {
            font-size: 0.78rem;
            color: var(--gray-600);
            margin-top: 0.15rem;
            font-style: italic;
        }

        /* ═════ Card "¿Qué sigue ahora?" ═════ */
        .next-card {
            background: linear-gradient(135deg, var(--pink-bg) 0%, var(--purple-bg) 100%);
            border: 1px solid #FBCFE8;
            border-radius: var(--radius-lg);
            padding: 1.25rem;
            display: flex;
            gap: 0.85rem;
            align-items: flex-start;
        }

        .next-card-icon {
            flex-shrink: 0;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--white);
            color: var(--pink);
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: var(--shadow-sm);
        }
        .next-card-icon i { width: 20px; height: 20px; }

        .next-card-title {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--purple);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.3rem;
        }
        .next-card-text {
            font-size: 0.88rem;
            color: var(--gray-700);
            line-height: 1.55;
        }

        /* ═════ Alertas ═════ */
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

            <%-- Header --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="file-text" style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        Detalle de Solicitud
                    </h1>
                    <p class="page-subtitle">Información completa y trazabilidad del pedido</p>
                </div>
                <%-- "Volver" usa el historial real del navegador — así respeta
                     de dónde vino el usuario sin asumir un destino fijo que
                     podría no tener permiso (ej: TransactionServlet es solo
                     para Manager/Administrador, pero cualquier rol puede
                     terminar en esta página). El href es solo un respaldo
                     por si no hay historial (ej: entró por link directo). --%>
                <a href="<%= ctx %>/HomeServlet" class="btn-ghost btn-icon"
                   onclick="if (document.referrer && document.referrer.indexOf(window.location.host) !== -1) { history.back(); return false; }">
                    <i data-lucide="arrow-left"></i>
                    Volver
                </a>
            </div>

            <%-- Alertas --%>
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

            <% if (tx == null) { %>
            <div class="detail-card" style="padding: 4rem; text-align: center;">
                <i data-lucide="file-x" style="width: 56px; height: 56px; color: var(--gray-300); margin: 0 auto 1rem;"></i>
                <p style="color: var(--gray-500); font-weight: 600;">No se encontró la solicitud.</p>
            </div>
            <% } else { %>

            <div class="detail-grid">

                <%-- ═══════ COLUMNA IZQUIERDA: Datos principales ═══════ --%>
                <div class="detail-card">

                    <div class="detail-card-header">
                        <div>
                            <div class="detail-card-header-id">
                                TXN-<%= String.format("%04d", tx.getId()) %>
                            </div>
                            <div class="detail-card-header-sub">
                                Creada el <%= fechaCreacion != null ? fechaCreacion : "—" %>
                            </div>
                        </div>
                        <span class="<%= claseBadgeStatus(tx.getStatus()) %>" style="font-size: 0.85rem; padding: 0.5rem 1rem;">
                            <%= traducirStatus(tx.getStatus()) %>
                        </span>
                    </div>

                    <div class="detail-card-body">

                        <%-- Si fue rechazada, mostrar motivo destacado --%>
                        <% if ("REJECTED".equals(tx.getStatus()) && motivoRechazo != null && !motivoRechazo.isEmpty()) { %>
                        <div class="reject-box">
                            <div class="reject-box-icon">
                                <i data-lucide="x-octagon"></i>
                            </div>
                            <div>
                                <div class="reject-box-title">Motivo del rechazo</div>
                                <div class="reject-box-text"><%= motivoRechazo %></div>
                            </div>
                        </div>
                        <% } %>

                        <%-- Si el depósito dejó una nota de imprevisto al entregar, mostrarla destacada --%>
                        <% if ("COMPLETED".equals(tx.getStatus()) && tx.getDeliveryNotes() != null && !tx.getDeliveryNotes().trim().isEmpty()) { %>
                        <div class="delivery-notes-box">
                            <div class="delivery-notes-box-icon">
                                <i data-lucide="alert-triangle"></i>
                            </div>
                            <div>
                                <div class="delivery-notes-box-title">Aviso del encargado de depósito</div>
                                <div class="delivery-notes-box-text"><%= tx.getDeliveryNotes() %></div>
                            </div>
                        </div>
                        <% } %>

                        <%-- Grid info principal --%>
                        <div class="info-row">

                            <div class="info-cell">
                                <div class="label">
                                    <i data-lucide="user"></i>
                                    Solicitante
                                </div>
                                <div class="value">
                                    <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                                </div>
                            </div>

                            <div class="info-cell">
                                <div class="label">
                                    <i data-lucide="package"></i>
                                    Material solicitado
                                </div>
                                <div class="value">
                                    <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                                </div>
                            </div>

                            <div class="info-cell">
                                <div class="label">
                                    <i data-lucide="hash"></i>
                                    Cantidad
                                </div>
                                <div class="value">
                                    <%= tx.getQuantity() %> <%= tx.getItemUnit() != null ? tx.getItemUnit() : "" %>
                                </div>
                            </div>

                            <div class="info-cell">
                                <div class="label">
                                    <i data-lucide="repeat"></i>
                                    Tipo de movimiento
                                </div>
                                <div class="value">
                                    <%= "IN".equals(tx.getType()) ? "Ingreso (IN)" : "Salida (OUT)" %>
                                </div>
                            </div>

                            <% if (tx.getApproverName() != null && !tx.getApproverName().isEmpty()) { %>
                            <div class="info-cell">
                                <div class="label">
                                    <i data-lucide="shield-check"></i>
                                    Procesada por
                                </div>
                                <div class="value"><%= tx.getApproverName() %></div>
                            </div>
                            <% } %>

                            <% if (tx.getEstimatedDelivery() != null && !tx.getEstimatedDelivery().isEmpty()) { %>
                            <div class="info-cell">
                                <div class="label">
                                    <i data-lucide="calendar"></i>
                                    Fecha estimada de entrega
                                </div>
                                <div class="value"><%= tx.getEstimatedDelivery() %></div>
                            </div>
                            <% } %>

                        </div>

                        <%-- Notas / Propósito --%>
                        <% if (!"REJECTED".equals(tx.getStatus())) { %>
                        <div class="notes-box">
                            <div class="notes-box-title">
                                <i data-lucide="message-square"></i>
                                Notas / Propósito
                            </div>
                            <div class="notes-box-text">
                                <%= tx.getNotes() != null && !tx.getNotes().isEmpty()
                                        ? tx.getNotes()
                                        : "Sin notas adicionales." %>
                            </div>
                        </div>
                        <% } %>

                        <%-- Acciones / Mensaje "Tu solicitud" --%>
                        <% if ("PENDING".equals(tx.getStatus())) { %>

                        <% if (esMia && (rol == 3 || rol == 4)) { %>
                        <%-- Aprobador viendo su propia solicitud --%>
                        <div class="own-info">
                            <div class="own-info-icon">
                                <i data-lucide="info"></i>
                            </div>
                            <div>
                                <div class="own-info-title">Esta es tu propia solicitud</div>
                                <div class="own-info-desc">
                                    Por política de segregación de funciones, no puedes aprobar
                                    ni rechazar tus propios pedidos. Otro aprobador deberá revisarla.
                                </div>
                            </div>
                        </div>
                        <% } else if (puedeAprobar) { %>
                        <div class="actions-section">
                            <h3>¿Qué quieres hacer con esta solicitud?</h3>

                            <form id="decisionForm" action="<%= ctx %>/TransactionServlet" method="POST" style="margin: 0;">
                                <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                                <input type="hidden" name="action" id="formAction" value=""/>
                                <input type="hidden" name="notas" id="notaFinal" value=""/>

                                <div class="actions-row">
                                    <button type="button" class="btn-approve-big" onclick="prepararAprobacion()" id="btnAprobar">
                                        <i data-lucide="check"></i>
                                        <span>Aprobar Solicitud</span>
                                    </button>

                                    <button type="button" class="btn-reject-big" onclick="prepararRechazo()" id="btnRechazar">
                                        <i data-lucide="x"></i>
                                        <span>Rechazar Solicitud</span>
                                    </button>
                                </div>

                                <div id="cajaAprobacion" style="display: none; margin-top: 1rem; background: var(--green-bg); padding: 1.25rem; border-radius: var(--radius-md); border: 1px solid #BBF7D0; border-left: 4px solid var(--green);">
                                    <label for="notasAprobacion" style="font-weight: 700; color: var(--green-dark); font-size: 0.85rem; display: block; margin-bottom: 0.5rem; text-transform: uppercase;">
                                        Comentarios de aprobación (Opcional)
                                    </label>
                                    <textarea id="notasAprobacion" rows="3" class="form-control" style="width: 100%; padding: 0.75rem; border: 1px solid var(--gray-300); border-radius: var(--radius-sm); font-family: inherit; font-size: 0.9rem;" placeholder="Ej: Material listo para recoger..."></textarea>
                                </div>

                                <div id="cajaRechazo" style="display: none; margin-top: 1rem; background: var(--red-bg); padding: 1.25rem; border-radius: var(--radius-md); border: 1px solid #FECACA; border-left: 4px solid var(--red);">
                                    <label for="notasRechazo" style="font-weight: 700; color: var(--red-dark); font-size: 0.85rem; display: block; margin-bottom: 0.5rem; text-transform: uppercase;">
                                        Motivo de rechazo (Obligatorio)
                                    </label>
                                    <textarea id="notasRechazo" rows="3" class="form-control" style="width: 100%; padding: 0.75rem; border: 1px solid var(--gray-300); border-radius: var(--radius-sm); font-family: inherit; font-size: 0.9rem;" placeholder="Escribe aquí por qué se rechaza la solicitud..."></textarea>
                                </div>
                            </form>
                        </div>

                        <script>
                            const cajaAprobacion = document.getElementById('cajaAprobacion');
                            const cajaRechazo = document.getElementById('cajaRechazo');
                            const btnAprobar = document.getElementById('btnAprobar');
                            const btnRechazar = document.getElementById('btnRechazar');
                            const notasAprobacion = document.getElementById('notasAprobacion');
                            const notasRechazo = document.getElementById('notasRechazo');
                            const notaFinal = document.getElementById('notaFinal');
                            const formAction = document.getElementById('formAction');
                            const decisionForm = document.getElementById('decisionForm');

                            function prepararAprobacion() {
                                if (cajaAprobacion.style.display === 'none') {
                                    // Mostrar caja de aprobar, ocultar la de rechazar
                                    cajaAprobacion.style.display = 'block';
                                    cajaRechazo.style.display = 'none';
                                    notasRechazo.required = false;

                                    // Cambiar textos de botones
                                    btnAprobar.querySelector('span').innerText = 'Confirmar Aprobación';
                                    btnRechazar.querySelector('span').innerText = 'Rechazar Solicitud';
                                    notasAprobacion.focus();
                                } else {
                                    // Si ya está abierta y vuelve a hacer clic, enviamos
                                    formAction.value = 'aprobar';
                                    // Si dejó el comentario vacío, le ponemos un texto por defecto para la DB
                                    notaFinal.value = notasAprobacion.value.trim() !== '' ? notasAprobacion.value.trim() : 'Aprobada sin comentarios adicionales';
                                    decisionForm.submit();
                                }
                            }

                            function prepararRechazo() {
                                if (cajaRechazo.style.display === 'none') {
                                    // Mostrar caja de rechazar, ocultar la de aprobar
                                    cajaRechazo.style.display = 'block';
                                    cajaAprobacion.style.display = 'none';
                                    notasRechazo.required = true;

                                    // Cambiar textos de botones
                                    btnRechazar.querySelector('span').innerText = 'Confirmar Rechazo';
                                    btnAprobar.querySelector('span').innerText = 'Aprobar Solicitud';
                                    notasRechazo.focus();
                                } else {
                                    // Si ya está abierta, validamos que no esté vacía
                                    if (notasRechazo.value.trim() === "") {
                                        notasRechazo.reportValidity(); // Muestra burbuja nativa del navegador pidiendo texto
                                    } else {
                                        formAction.value = 'rechazar';
                                        notaFinal.value = notasRechazo.value.trim();
                                        decisionForm.submit();
                                    }
                                }
                            }
                        </script>
                        <% } %>

                        <% } %>

                        <%-- Acción de entrega — solo Depósito, Admin o SuperAdmin, y solo si está APROBADA --%>
                        <% if ("APPROVED".equals(tx.getStatus()) && (rol == 2 || rol == 4 || rol == 5)) { %>
                        <div class="actions-section">
                            <h3>¿Ya se entregó el material?</h3>
                            <div class="actions-row">
                                <a href="#modal-entregar-detalle" class="btn-approve-big"
                                   onclick="return abrirModalSinHistorial(this);">
                                    <i data-lucide="package-check"></i>
                                    Marcar como Entregada
                                </a>
                            </div>
                        </div>
                        <% } %>

                    </div>
                </div>

                <%-- ═══════ COLUMNA DERECHA: Timeline + ¿Qué sigue? ═══════ --%>
                <div>

                    <%-- Timeline --%>
                    <div class="detail-card" style="margin-bottom: 1.5rem;">
                        <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--gray-100); background: var(--gray-50);">
                            <div style="display: flex; align-items: center; gap: 0.6rem; font-size: 0.95rem; font-weight: 700; color: var(--purple);">
                                <i data-lucide="git-branch" style="width: 18px; height: 18px; color: var(--pink);"></i>
                                Flujo de la solicitud
                            </div>
                        </div>
                        <div class="detail-card-body">

                            <div class="timeline">

                                <%-- Paso 1: Creada (siempre done) --%>
                                <div class="timeline-step done">
                                    <div class="timeline-dot"><i data-lucide="check"></i></div>
                                    <div class="timeline-content">
                                        <div class="timeline-title">Solicitud creada</div>
                                        <div class="timeline-date"><%= fechaCreacion != null ? fechaCreacion : "—" %></div>
                                        <div class="timeline-actor">por <%= tx.getRequesterName() %></div>
                                    </div>
                                </div>

                                <%-- Paso 2: Revisada --%>
                                <%
                                    String status = tx.getStatus();
                                    String paso2Class;
                                    String paso2Icon;
                                    String paso2Title;
                                    if ("PENDING".equals(status)) {
                                        paso2Class = "pending";
                                        paso2Icon = "clock";
                                        paso2Title = "Pendiente de revisión";
                                    } else if ("REJECTED".equals(status)) {
                                        paso2Class = "rejected";
                                        paso2Icon = "x";
                                        paso2Title = "Solicitud rechazada";
                                    } else {
                                        paso2Class = "done";
                                        paso2Icon = "check";
                                        paso2Title = "Solicitud aprobada";
                                    }
                                %>

                                <div class="timeline-step <%= paso2Class %>">
                                    <div class="timeline-dot"><i data-lucide="<%= paso2Icon %>"></i></div>
                                    <div class="timeline-content">
                                        <div class="timeline-title"><%= paso2Title %></div>
                                        <% if (!"PENDING".equals(status)) { %>
                                        <div class="timeline-date"><%= fechaProcesada != null ? fechaProcesada : "—" %></div>
                                        <% if (tx.getApproverName() != null) { %>
                                        <div class="timeline-actor">por <%= tx.getApproverName() %></div>
                                        <% } %>
                                        <% } else { %>
                                        <div class="timeline-date">Esperando aprobador</div>
                                        <% } %>
                                    </div>
                                </div>

                                <%-- Paso 3: Entregada (solo si no fue rechazada) --%>
                                <% if (!"REJECTED".equals(status)) {
                                    String paso3Class;
                                    String paso3Icon;
                                    if ("COMPLETED".equals(status)) {
                                        paso3Class = "done";
                                        paso3Icon = "check";
                                    } else if ("APPROVED".equals(status)) {
                                        paso3Class = "current";
                                        paso3Icon = "truck";
                                    } else {
                                        paso3Class = "pending";
                                        paso3Icon = "truck";
                                    }
                                %>
                                <div class="timeline-step <%= paso3Class %>">
                                    <div class="timeline-dot"><i data-lucide="<%= paso3Icon %>"></i></div>
                                    <div class="timeline-content">
                                        <div class="timeline-title">
                                            <% if ("COMPLETED".equals(status)) { %>
                                            Material entregado
                                            <% } else if ("APPROVED".equals(status)) { %>
                                            En preparación para entrega
                                            <% } else { %>
                                            Pendiente de entrega
                                            <% } %>
                                        </div>
                                        <% if ("COMPLETED".equals(status)) { %>
                                        <div class="timeline-date"><%= fechaEntregada != null ? fechaEntregada : "—" %></div>
                                        <div class="timeline-actor">por el encargado de depósito</div>
                                        <% } else if ("APPROVED".equals(status)) { %>
                                        <div class="timeline-date">El depósito procesará el envío</div>
                                        <% } else { %>
                                        <div class="timeline-date">—</div>
                                        <% } %>
                                    </div>
                                </div>
                                <% } %>

                            </div>

                        </div>
                    </div>

                    <%-- ¿Qué sigue ahora? --%>
                    <div class="next-card">
                        <div class="next-card-icon">
                            <i data-lucide="compass"></i>
                        </div>
                        <div>
                            <div class="next-card-title">¿Qué sigue ahora?</div>
                            <div class="next-card-text">
                                <%
                                    if ("PENDING".equals(tx.getStatus())) {
                                        if (esMia) {
                                            out.print("Tu solicitud está esperando que un aprobador la revise. Te notificaremos cuando haya una decisión.");
                                        } else if (rol == 3 || rol == 4) {
                                            out.print("Esta solicitud espera tu decisión. Puedes aprobarla o rechazarla con un comentario.");
                                        } else {
                                            out.print("La solicitud está pendiente de aprobación por un coordinador o administrador.");
                                        }
                                    } else if ("APPROVED".equals(tx.getStatus())) {
                                        if (esMia) {
                                            out.print("¡Tu solicitud fue aprobada! El material ya está reservado y el encargado de depósito lo entregará en los próximos días.");
                                        } else if (rol == 2) {
                                            out.print("Esta solicitud está aprobada y lista para entregar. Puedes marcarla como entregada desde Despacho.");
                                        } else {
                                            out.print("La solicitud fue aprobada y el stock ya fue reservado. El encargado de depósito procesará la entrega en los próximos días.");
                                        }
                                    } else if ("REJECTED".equals(tx.getStatus())) {
                                        if (esMia) {
                                            out.print("Tu solicitud fue rechazada. Revisa el motivo y, si lo consideras, puedes crear una nueva solicitud con los ajustes necesarios.");
                                        } else {
                                            out.print("Esta solicitud fue rechazada y no procederá. El solicitante puede crear una nueva si lo desea.");
                                        }
                                    } else if ("COMPLETED".equals(tx.getStatus())) {
                                        if (esMia) {
                                            out.print("¡Recibiste tu material! La entrega fue completada y ya puedes usarlo.");
                                        } else if (rol == 2) {
                                            out.print("Entregaste este material correctamente. El stock ya quedó actualizado en el sistema.");
                                        } else {
                                            out.print("Solicitud completada: el material fue entregado al solicitante y el stock fue actualizado en el sistema.");
                                        }
                                    } else {
                                        out.print("Estado actual: " + traducirStatus(tx.getStatus()));
                                    }
                                %>
                            </div>
                        </div>
                    </div>

                </div>

            </div>

            <%-- ═══════ MODAL — Confirmación de entrega ═══════ --%>
            <% if ("APPROVED".equals(tx.getStatus()) && (rol == 2 || rol == 4 || rol == 5)) { %>
            <div id="modal-entregar-detalle" class="modal-overlay">
                <div class="modal-box">
                    <div class="modal-icon modal-icon--purple"><i data-lucide="package-check"></i></div>
                    <h3 class="modal-title">¿Confirmas la entrega física?</h3>
                    <p class="modal-desc">
                        "<strong class="modal-name"><%= tx.getItemName() %></strong>" para
                        <strong class="modal-name"><%= tx.getRequesterName() %></strong> —
                        <%= tx.getQuantity() %> <%= tx.getItemUnit() %>
                    </p>

                    <form action="<%= ctx %>/DepositServlet" method="POST">
                        <input type="hidden" name="action" value="entregar"/>
                        <input type="hidden" name="id" value="<%= tx.getId() %>"/>

                        <label class="modal-notes-label" for="notas-detalle">
                            ¿Algún imprevisto? (opcional)
                        </label>
                        <textarea id="notas-detalle" name="notas" class="modal-notes-input"
                                  placeholder="Ej: retraso de 2 días, llegó de otro color..."></textarea>

                        <div class="modal-btns" style="margin-top: 1.1rem;">
                            <a href="#modal-cerrar" class="btn-modal-cancel"
                               onclick="return abrirModalSinHistorial(this);">Cancelar</a>
                            <button type="submit" class="btn-modal-ok btn-modal-ok--purple">
                                <i data-lucide="package-check"></i>Sí, entregar
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            <% } %>

            <% } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();
    });

    /**
     * Abre/cierra el modal (anclas #modal-X) sin dejar una entrada nueva
     * en el historial del navegador. Así "Volver" (que usa history.back())
     * no se queda atrapado entre los estados abierto/cerrado del modal —
     * simplemente lo ignora y va a la página anterior real.
     */
    function abrirModalSinHistorial(link) {
        history.replaceState(null, '', link.getAttribute('href'));
        return false;
    }
</script>

</body>
</html>