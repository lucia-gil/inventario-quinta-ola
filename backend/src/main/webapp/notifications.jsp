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
    <link href="<%= ctx %>/css/style.css?v=14" rel="stylesheet" />
</head>
<body class="page-body" style="background-color: #f9fafb;">

<div class="layout-wrapper" style="display: flex; min-h: 100vh;">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content" style="flex: 1; display: flex; flex-direction: column;">
        <jsp:include page="includes/topbar.jsp"/>

        <%-- Contenedor principal con un ancho máximo óptimo --%>
        <main class="page-main" style="max-w: 1000px; margin: 0 auto; padding: 2rem 1.5rem; width: 100%; flex: 1;">

            <%-- Encabezado con Degradado Real e Inyección de la Ola SVG --%>
            <div style="position: relative; background: linear-gradient(135deg, #5b21b6 0%, #7c3aed 50%, #ec4899 100%); border-radius: 20px; padding: 2.5rem 2rem; margin-bottom: 2rem; overflow: hidden; box-shadow: 0 10px 15px -3px rgba(124, 58, 237, 0.2);">

                <%-- SVG de Olas integrado de forma segura en el fondo --%>
                <svg style="position: absolute; bottom: 0; left: 0; width: 100%; opacity: 0.15; pointer-events: none;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320">
                    <path fill="#ffffff" d="M0,224L48,213.3C96,203,192,181,288,186.7C384,192,480,224,576,218.7C672,213,768,171,864,160C960,149,1056,171,1152,181.3C1248,192,1344,192,1392,192L1440,192L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path>
                </svg>

                <div style="position: relative; z-index: 2;">
                    <h1 style="color: #ffffff; font-size: 1.8rem; font-weight: 800; margin: 0; display: flex; align-items: center; gap: 10px;">
                        <i data-lucide="bell-ring" style="width: 28px; height: 28px;"></i> Notificaciones
                    </h1>
                    <p style="color: #f3e8ff; margin: 0.5rem 0 0 0; font-size: 0.95rem; font-weight: 500;">Revisa tus últimos mensajes y alertas del sistema de inventario</p>
                </div>
            </div>

            <%-- Mensaje de Error --%>
            <% if (error != null) { %>
            <div style="background-color: #fef2f2; border-left: 4px solid #ef4444; color: #b91c1c; border-radius: 0 12px 12px 0; padding: 1rem; display: flex; align-items: center; gap: 12px; margin-bottom: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
                <i data-lucide="alert-triangle" style="width: 20px; height: 20px; flex-shrink: 0;"></i>
                <span style="font-weight: 600; font-size: 0.875rem;"><%= error %></span>
            </div>
            <% } %>

            <%-- Estado Vacío --%>
            <% if (notifs == null || notifs.isEmpty()) { %>
            <div style="background-color: #ffffff; border: 1px solid #e9d5ff; border-radius: 20px; text-align: center; padding: 4rem 2rem; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                <div style="width: 80px; height: 80px; background: linear-gradient(to top right, #f3e8ff, #fce7f3); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #c084fc; margin-bottom: 1.5rem; border: 2px dashed #e9d5ff;">
                    <i data-lucide="inbox" style="width: 36px; height: 36px;"></i>
                </div>
                <h3 style="font-size: 1.25rem; font-weight: 700; color: #1f2937; margin: 0;">Todo al día</h3>
                <p style="color: #6b7280; font-size: 0.875rem; margin: 0.5rem 0 0 0;">No tienes nuevas notificaciones por el momento.</p>
            </div>
            <% } else { %>

            <%-- Lista de Notificaciones --%>
            <div style="display: flex; flex-direction: column; gap: 1rem;">
                <% for (Notification n : notifs) { %>

                <%
                    boolean leida = (n.getIsRead() == 1);

                    // Definición manual de estilos para tarjetas leídas y no leídas
                    String cardStyle = leida
                            ? "background-color: rgba(255, 255, 255, 0.7); border: 1px solid #e5e7eb; opacity: 0.85;"
                            : "background-color: #ffffff; border-left: 4px solid #ec4899; border-top: 1px solid #e9d5ff; border-right: 1px solid #e9d5ff; border-bottom: 1px solid #e9d5ff; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);";

                    String tipo = n.getType();
                    String iconName = "bell";
                    String iconStyle = "color: #7c3aed; background-color: #f3e8ff;";

                    if ("request_approved".equals(tipo)) {
                        iconName = "check-circle";
                        iconStyle = "color: #16a34a; background-color: #dcfce7;";
                    } else if ("request_rejected".equals(tipo)) {
                        iconName = "x-circle";
                        iconStyle = "color: #dc2626; background-color: #fee2e2;";
                    } else if ("new_request".equals(tipo)) {
                        iconName = "mail";
                        iconStyle = "color: #2563eb; background-color: #dbeafe;";
                    }
                %>

                <div style="<%= cardStyle %> border-radius: 16px; padding: 1.5rem; display: flex; align-items: start; gap: 1.25rem; position: relative; transition: all 0.2s ease;">

                    <%-- Icono Redondo --%>
                    <div style="<%= iconStyle %> width: 44px; height: 44px; flex-shrink: 0; border-radius: 12px; display: flex; align-items: center; justify-content: center; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                        <i data-lucide="<%= iconName %>" style="width: 22px; height: 22px;"></i>
                    </div>

                    <%-- Contenido --%>
                    <div style="flex: 1; min-width: 0;">
                        <div style="display: flex; align-items: center; justify-content: space-between; gap: 1rem; margin-bottom: 0.5rem; flex-wrap: wrap;">

                            <% if (leida) { %>
                            <h4 style="font-weight: 700; font-size: 1rem; color: #4b5563; margin: 0;"><%= n.getTitle() %></h4>
                            <% } else { %>
                            <h4 style="font-weight: 800; font-size: 1rem; margin: 0; background: linear-gradient(to right, #4c1d95, #db2777); -webkit-background-clip: text; -webkit-text-fill-color: transparent;"><%= n.getTitle() %></h4>
                            <span style="background: linear-gradient(to right, #ec4899, #8b5cf6); color: #ffffff; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 10px; font-weight: 700; letter-spacing: 0.05em; box-shadow: 0 2px 4px rgba(236,72,153,0.2);">NUEVA</span>
                            <% } %>
                        </div>

                        <p style="font-size: 0.9rem; color: #4b5563; line-height: 1.5; margin: 0 0 1rem 0;">
                            <%= n.getMessage() %>
                        </p>

                        <%-- Acciones Inferiores --%>
                        <div style="display: flex; align-items: center; justify-content: space-between; gap: 1rem; pt-3; border-top: 1px solid #f3f4f6; padding-top: 0.75rem; flex-wrap: wrap;">
                            <span style="font-size: 0.75rem; color: #9ca3af; font-weight: 500; display: flex; align-items: center; gap: 6px;">
                                <i data-lucide="calendar-clock" style="width: 14px; height: 14px;"></i>
                                <%= n.getCreatedAt() != null ? n.getCreatedAt() : "" %>
                            </span>

                            <div style="display: flex; align-items: center; gap: 0.75rem;">
                                <% if (!leida) { %>
                                <form action="<%= ctx %>/NotificationServlet" method="POST" style="margin: 0; display: inline;">
                                    <input type="hidden" name="action" value="marcar"/>
                                    <input type="hidden" name="id" value="<%= n.getId() %>"/>
                                    <button type="submit" style="background-color: #f3f4f6; border: none; color: #4b5563; font-weight: 700; font-size: 0.75rem; padding: 0.5rem 0.75rem; border-radius: 8px; cursor: pointer; display: flex; align-items: center; gap: 6px; transition: all 0.2s;">
                                        <i data-lucide="check-check" style="width: 14px; height: 14px; color: #16a34a;"></i> Marcar leída
                                    </button>
                                </form>
                                <% } %>

                                <% if (n.getRelatedId() > 0) { %>
                                <a href="<%= ctx %>/RequestDetailServlet?action=detalle&id=<%= n.getRelatedId() %>"
                                   style="background-color: #7c3aed; color: #ffffff; text-decoration: none; font-weight: 700; font-size: 0.75rem; padding: 0.5rem 0.75rem; border-radius: 8px; display: flex; align-items: center; gap: 6px; box-shadow: 0 2px 4px rgba(124,58,237,0.2);">
                                    Ver detalle <i data-lucide="arrow-right" style="width: 14px; height: 14px;"></i>
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