<%--
    ════════════════════════════════════════════════════════════════════
     audit-list.jsp — Bitácora de Auditoría (SuperAdmin)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.AuditLog" %>
<%
    String ctx = request.getContextPath();
    List<AuditLog> registros = (List<AuditLog>) request.getAttribute("registros");
    String filtroEntidad = (String) request.getAttribute("filtroEntidad");
    String error = (String) request.getAttribute("error");

    request.setAttribute("activeMenu", "audit");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Bitácora de Auditoría | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=10" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Estilos de auditoría ═════ */

        .audit-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        @media (max-width: 768px) {
            .audit-stats { grid-template-columns: 1fr; }
        }

        .audit-stat {
            background: var(--white);
            border: 1px solid var(--gray-100);
            border-radius: var(--radius-md);
            padding: 1.1rem 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.85rem;
            box-shadow: var(--shadow-sm);
        }

        .audit-stat-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 42px;
            height: 42px;
            border-radius: var(--radius-sm);
            flex-shrink: 0;
        }
        .audit-stat-icon i { width: 20px; height: 20px; }

        .audit-stat-icon.purple { background: var(--purple-bg); color: var(--purple); }
        .audit-stat-icon.pink   { background: var(--pink-bg);   color: var(--pink); }
        .audit-stat-icon.yellow { background: var(--yellow-bg); color: var(--orange-dark); }

        .audit-stat-value {
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--gray-800);
            line-height: 1;
        }

        .audit-stat-label {
            font-size: 0.78rem;
            color: var(--gray-500);
            font-weight: 600;
            margin-top: 0.25rem;
        }

        /* ── Filtros ── */
        .audit-filters {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
        }

        .filter-chip {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.45rem 0.9rem;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-full);
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--gray-700);
            background: var(--white);
            transition: all var(--transition);
            cursor: pointer;
        }

        .filter-chip:hover {
            border-color: var(--purple);
            color: var(--purple);
        }

        .filter-chip.active {
            background: var(--purple);
            border-color: var(--purple);
            color: var(--white);
        }

        .filter-chip i { width: 14px; height: 14px; }

        /* ── Tabla bitácora ── */
        .audit-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }

        .action-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.3rem 0.75rem;
            border-radius: var(--radius-full);
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.3px;
        }
        .action-badge i { width: 12px; height: 12px; }

        .action-CAMBIO_ROL   { background: var(--yellow-bg); color: var(--orange-dark); }
        .action-CREAR_USUARIO{ background: var(--green-bg);  color: var(--green-dark); }
        .action-APROBAR      { background: var(--blue-bg);   color: var(--blue-dark); }
        .action-RECHAZAR     { background: var(--red-bg);    color: var(--red-dark); }
        .action-default      { background: var(--gray-100);  color: var(--gray-600); }

        .entity-tag {
            display: inline-block;
            padding: 0.2rem 0.6rem;
            font-size: 0.7rem;
            font-weight: 700;
            color: var(--purple);
            background: var(--purple-bg);
            border-radius: var(--radius-sm);
            font-family: 'Courier New', monospace;
        }

        .actor-cell {
            display: flex;
            align-items: center;
            gap: 0.65rem;
        }

        .actor-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.72rem;
            font-weight: 700;
            flex-shrink: 0;
        }

        .actor-info-name {
            font-weight: 700;
            color: var(--gray-800);
            font-size: 0.85rem;
        }

        .actor-info-role {
            font-size: 0.7rem;
            color: var(--gray-500);
            font-weight: 600;
        }

        .details-cell {
            font-size: 0.85rem;
            color: var(--gray-700);
            line-height: 1.5;
            max-width: 400px;
        }

        .empty-state {
            padding: 4rem 2rem;
            text-align: center;
        }

        .empty-state i {
            width: 56px;
            height: 56px;
            color: var(--gray-300);
            margin: 0 auto 1rem;
        }

        .empty-state h3 {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--gray-700);
            margin-bottom: 0.4rem;
        }

        .empty-state p {
            font-size: 0.88rem;
            color: var(--gray-500);
        }

        .info-banner {
            display: flex;
            gap: 0.85rem;
            align-items: flex-start;
            background: linear-gradient(135deg, var(--purple-bg) 0%, var(--pink-bg) 100%);
            border: 1px solid var(--pink-light);
            border-radius: var(--radius-md);
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
        }

        .info-banner-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: var(--radius-sm);
            background: var(--purple);
            color: var(--white);
            flex-shrink: 0;
        }
        .info-banner-icon i { width: 18px; height: 18px; }

        .info-banner-title {
            font-size: 0.88rem;
            font-weight: 700;
            color: var(--purple);
            margin-bottom: 0.25rem;
        }

        .info-banner-text {
            font-size: 0.82rem;
            color: var(--gray-700);
            line-height: 1.55;
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
            background: var(--red-bg);
            color: var(--red-dark);
            border-color: #FECACA;
        }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }
    </style>
</head>

<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- Header --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i data-lucide="search" style="display:inline-block; width:24px; height:24px; vertical-align:middle; margin-right:8px; color:var(--purple);"></i>
                        Bitácora de Auditoría
                    </h1>
                    <p class="page-subtitle">
                        Historial de todos los cambios críticos del sistema
                    </p>
                </div>
            </div>

            <%-- Info banner --%>
            <div class="info-banner">
                <div class="info-banner-icon">
                    <i data-lucide="lock"></i>
                </div>
                <div>
                    <p class="info-banner-title">Registro inmutable</p>
                    <p class="info-banner-text">
                        Esta bitácora se actualiza automáticamente cada vez que un SuperAdmin
                        o Administrador realiza acciones críticas (creación de usuarios, cambios de rol,
                        aprobaciones). Los registros no se pueden editar ni eliminar.
                    </p>
                </div>
            </div>

            <% if (error != null) { %>
            <div class="alert">
                <i data-lucide="alert-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <%-- Stats --%>
            <% int totalRegistros = registros != null ? registros.size() : 0;
                int countCambios = 0, countCreaciones = 0, countOtros = 0;
                if (registros != null) {
                    for (AuditLog a : registros) {
                        if ("CAMBIO_ROL".equals(a.getAction())) countCambios++;
                        else if ("CREAR_USUARIO".equals(a.getAction())) countCreaciones++;
                        else countOtros++;
                    }
                }
            %>
            <div class="audit-stats">
                <div class="audit-stat">
                    <div class="audit-stat-icon purple">
                        <i data-lucide="file-text"></i>
                    </div>
                    <div>
                        <div class="audit-stat-value"><%= totalRegistros %></div>
                        <div class="audit-stat-label">Total de registros</div>
                    </div>
                </div>

                <div class="audit-stat">
                    <div class="audit-stat-icon yellow">
                        <i data-lucide="refresh-cw"></i>
                    </div>
                    <div>
                        <div class="audit-stat-value"><%= countCambios %></div>
                        <div class="audit-stat-label">Cambios de rol</div>
                    </div>
                </div>

                <div class="audit-stat">
                    <div class="audit-stat-icon pink">
                        <i data-lucide="user-plus"></i>
                    </div>
                    <div>
                        <div class="audit-stat-value"><%= countCreaciones %></div>
                        <div class="audit-stat-label">Usuarios creados</div>
                    </div>
                </div>
            </div>

            <%-- Filtros --%>
            <div class="audit-filters">
                <a href="<%= ctx %>/AuditServlet"
                   class="filter-chip <%= filtroEntidad == null ? "active" : "" %>">
                    <i data-lucide="list"></i>
                    Todos
                </a>
                <a href="<%= ctx %>/AuditServlet?entity=USER"
                   class="filter-chip <%= "USER".equals(filtroEntidad) ? "active" : "" %>">
                    <i data-lucide="users"></i>
                    Usuarios
                </a>
                <a href="<%= ctx %>/AuditServlet?entity=TRANSACTION"
                   class="filter-chip <%= "TRANSACTION".equals(filtroEntidad) ? "active" : "" %>">
                    <i data-lucide="repeat"></i>
                    Transacciones
                </a>
                <a href="<%= ctx %>/AuditServlet?entity=ITEM"
                   class="filter-chip <%= "ITEM".equals(filtroEntidad) ? "active" : "" %>">
                    <i data-lucide="package"></i>
                    Items
                </a>
            </div>

            <%-- Tabla bitácora --%>
            <div class="audit-card">

                <% if (registros == null || registros.isEmpty()) { %>
                <div class="empty-state">
                    <i data-lucide="file-search"></i>
                    <h3>Sin registros</h3>
                    <p>Aún no hay actividad registrada en la bitácora.</p>
                </div>
                <% } else { %>

                <div class="table-wrapper">
                    <table class="table">
                        <thead class="table-head">
                        <tr>
                            <th class="th">Fecha y hora</th>
                            <th class="th">Actor</th>
                            <th class="th">Acción</th>
                            <th class="th">Entidad</th>
                            <th class="th">Detalles</th>
                        </tr>
                        </thead>
                        <tbody class="table-body">

                        <% for (AuditLog log : registros) {
                            String actionClass = "action-default";
                            String actionIcon = "circle";
                            String actionLabel = log.getAction();

                            switch (log.getAction()) {
                                case "CAMBIO_ROL":
                                    actionClass = "action-CAMBIO_ROL";
                                    actionIcon = "refresh-cw";
                                    actionLabel = "Cambio de rol";
                                    break;
                                case "CREAR_USUARIO":
                                    actionClass = "action-CREAR_USUARIO";
                                    actionIcon = "user-plus";
                                    actionLabel = "Crear usuario";
                                    break;
                                case "APROBAR":
                                    actionClass = "action-APROBAR";
                                    actionIcon = "check-circle";
                                    actionLabel = "Aprobar";
                                    break;
                                case "RECHAZAR":
                                    actionClass = "action-RECHAZAR";
                                    actionIcon = "x-circle";
                                    actionLabel = "Rechazar";
                                    break;
                            }

                            String iniActor = "U";
                            if (log.getActorName() != null && !log.getActorName().trim().isEmpty()) {
                                String[] p = log.getActorName().trim().split("\\s+");
                                if (p.length >= 2) iniActor = (p[0].charAt(0) + "" + p[1].charAt(0)).toUpperCase();
                                else if (p[0].length() >= 2) iniActor = p[0].substring(0, 2).toUpperCase();
                            }
                        %>

                        <tr class="table-row">
                            <td class="td-light" style="white-space: nowrap; font-family: 'Courier New', monospace; font-size: 0.8rem;">
                                <%= log.getCreatedAt() %>
                            </td>

                            <td class="td">
                                <div class="actor-cell">
                                    <div class="actor-avatar"><%= iniActor %></div>
                                    <div>
                                        <div class="actor-info-name"><%= log.getActorName() %></div>
                                        <div class="actor-info-role"><%= log.getActorRole() %></div>
                                    </div>
                                </div>
                            </td>

                            <td class="td">
                                <span class="action-badge <%= actionClass %>">
                                    <i data-lucide="<%= actionIcon %>"></i>
                                    <%= actionLabel %>
                                </span>
                            </td>

                            <td class="td">
                                <span class="entity-tag"><%= log.getEntity() %> #<%= log.getEntityId() %></span>
                            </td>

                            <td class="td details-cell">
                                <%= log.getDetails() != null ? log.getDetails() : "—" %>
                            </td>
                        </tr>

                        <% } %>

                        </tbody>
                    </table>
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