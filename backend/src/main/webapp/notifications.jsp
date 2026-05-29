<%--
    ============================================================
     notifications.jsp
    ============================================================
     Vista de notificaciones del usuario logueado.
     Cada notificacion se puede marcar como leida con un POST.

     Recibe del NotificationServlet:
     - "notificaciones" (List<Notification>): las notifs del usuario
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
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>
<body class="page-body">

    <jsp:include page="includes/navbar.jsp"/>

    <main class="page-main-narrow">

        <div class="page-header">
            <div>
                <h1 class="page-title">🔔 Notificaciones</h1>
                <p class="page-subtitle">Mensajes y alertas del sistema</p>
            </div>
        </div>

        <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3">
                ❌ <%= error %>
            </div>
        <% } %>

        <%-- Si no hay notifs, mensaje amable --%>
        <% if (notifs == null || notifs.isEmpty()) { %>
            <div class="panel-form text-center py-16">
                <div class="text-6xl mb-4">📭</div>
                <h3 class="text-lg font-semibold text-gray-700">Sin notificaciones</h3>
                <p class="text-gray-500 mt-2">Aquí aparecerán los mensajes del sistema.</p>
            </div>
        <% } else { %>

            <%-- Lista de notifs como cards --%>
            <div class="space-y-3">
                <% for (Notification n : notifs) { %>

                    <%-- Si esta leida (is_read=true), se ve gris; si no, destacada --%>
                    <% boolean leida = n.isRead();
                       String cardClass = leida
                           ? "bg-gray-50 border border-gray-100"
                           : "bg-white border border-pink-200 shadow-sm";
                    %>

                    <div class="<%= cardClass %> rounded-xl p-4 flex items-start gap-4">

                        <%-- Icono segun tipo de notif --%>
                        <div class="text-2xl flex-shrink-0">
                            <%
                                String tipo = n.getType();
                                String icono = "🔔";
                                if ("request_approved".equals(tipo))      icono = "✅";
                                else if ("request_rejected".equals(tipo)) icono = "❌";
                                else if ("new_request".equals(tipo))      icono = "📨";
                            %>
                            <%= icono %>
                        </div>

                        <%-- Contenido --%>
                        <div class="flex-1">
                            <div class="flex items-center justify-between gap-3">
                                <h4 class="font-bold text-gray-800 <%= leida ? "" : "text-pink-700" %>">
                                    <%= n.getTitle() %>
                                </h4>
                                <% if (!leida) { %>
                                    <span class="bg-pink-500 text-white text-[10px] font-bold px-2 py-0.5 rounded-full uppercase">
                                        Nueva
                                    </span>
                                <% } %>
                            </div>
                            <p class="text-sm text-gray-600 mt-1">
                                <%= n.getMessage() %>
                            </p>
                            <p class="text-xs text-gray-400 mt-2">
                                <%= n.getCreatedAt() != null ? n.getCreatedAt() : "" %>
                            </p>
                        </div>

                        <%-- Boton para marcar como leida (solo si no esta leida) --%>
                        <% if (!leida) { %>
                            <form action="<%= ctx %>/NotificationServlet" method="POST"
                                  style="display:inline;">
                                <input type="hidden" name="action" value="marcar"/>
                                <input type="hidden" name="id" value="<%= n.getId() %>"/>
                                <button type="submit"
                                        class="text-xs text-gray-500 hover:text-pink-600 font-semibold whitespace-nowrap">
                                    Marcar leída
                                </button>
                            </form>
                        <% } %>

                        <%-- Si la notif esta relacionada a una transaccion, link al detalle --%>
                        <% if (n.getRelatedId() > 0) { %>
                            <a href="<%= ctx %>/RequestDetailServlet?id=<%= n.getRelatedId() %>"
                               class="text-xs text-accent hover:underline font-semibold whitespace-nowrap">
                                Ver →
                            </a>
                        <% } %>

                    </div>

                <% } %>
            </div>

        <% } %>

    </main>

    <jsp:include page="includes/footer.jsp"/>

</body>
</html>