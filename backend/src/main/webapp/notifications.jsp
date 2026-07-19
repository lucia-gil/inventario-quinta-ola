<%--
    ============================================================
     notifications.jsp
    ============================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Notification" %>
<%
    String ctx = request.getContextPath();
    List<Notification> notifs = (List<Notification>) request.getAttribute("notificaciones");
    String error = (String) request.getAttribute("error");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>Notificaciones | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=23" rel="stylesheet" />
</head>
<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main">

            <%-- Encabezado — mismo componente "hero" que Inicio --%>
            <div class="home-hero">
                <div class="home-hero-main">
                    <h1 class="home-hero-title">
                        <span class="home-hero-icon-badge"><i data-lucide="bell-ring"></i></span>
                        Notificaciones
                    </h1>
                    <p class="home-hero-sub">Revisa tus últimos mensajes y alertas del sistema de inventario.</p>
                </div>
            </div>

            <%-- Mensaje de Error --%>
            <% if (error != null) { %>
            <div class="notif-alert-error">
                <i data-lucide="alert-triangle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <%-- Estado Vacío --%>
            <% if (notifs == null || notifs.isEmpty()) { %>
            <div class="notif-empty">
                <div class="notif-empty-icon">
                    <i data-lucide="inbox"></i>
                </div>
                <h3 class="notif-empty-title">Todo al día</h3>
                <p class="notif-empty-desc">No tienes nuevas notificaciones por el momento.</p>
            </div>
            <% } else { %>

            <%-- Lista de Notificaciones --%>
            <div class="notif-list">
                <% for (Notification n : notifs) { %>

                <%
                    boolean leida = (n.getIsRead() == 1);
                    String cardClass = leida ? "notif-card notif-card--read" : "notif-card notif-card--unread";

                    String tipo = n.getType();
                    String iconName = "bell";
                    String iconClass = "notif-icon notif-icon--default";

                    if ("request_approved".equals(tipo)) {
                        iconName = "check-circle";
                        iconClass = "notif-icon notif-icon--approved";
                    } else if ("request_rejected".equals(tipo)) {
                        iconName = "x-circle";
                        iconClass = "notif-icon notif-icon--rejected";
                    } else if ("new_request".equals(tipo)) {
                        iconName = "mail";
                        iconClass = "notif-icon notif-icon--request";
                    }
                %>

                <div class="<%= cardClass %>">

                    <div class="<%= iconClass %>">
                        <i data-lucide="<%= iconName %>"></i>
                    </div>

                    <div class="notif-body">
                        <div class="notif-top-row">
                            <% if (leida) { %>
                            <h4 class="notif-title-read"><%= n.getTitle() %></h4>
                            <% } else { %>
                            <h4 class="notif-title-unread"><%= n.getTitle() %></h4>
                            <span class="notif-badge-new">NUEVA</span>
                            <% } %>
                        </div>

                        <p class="notif-message"><%= n.getMessage() %></p>

                        <div class="notif-footer">
                            <span class="notif-date">
                                <i data-lucide="calendar-clock"></i>
                                <%= n.getCreatedAt() != null ? n.getCreatedAt() : "" %>
                            </span>

                            <div class="notif-actions">
                                <% if (!leida) { %>
                                <form action="<%= ctx %>/NotificationServlet" method="POST">
                                    <input type="hidden" name="action" value="marcar"/>
                                    <input type="hidden" name="id" value="<%= n.getId() %>"/>
                                    <button type="submit" class="btn-ghost btn-icon notif-btn-mark">
                                        <i data-lucide="check-check"></i> Marcar leída
                                    </button>
                                </form>
                                <% } %>

                                <% if (n.getRelatedId() > 0) { %>
                                <a href="<%= ctx %>/RequestDetailServlet?action=detalle&id=<%= n.getRelatedId() %>"
                                   class="btn-page-primary btn-icon notif-btn-detail">
                                    Ver detalle <i data-lucide="arrow-right"></i>
                                </a>
                                <% } %>
                            </div>
                        </div>
                    </div>

                </div>

                <% } %>
            </div>
            <% } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>
    </div>
</div>

<script src="https://unpkg.com/lucide@latest"></script>
<script>
    lucide.createIcons();
</script>
</body>
</html>