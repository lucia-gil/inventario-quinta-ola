<%--
    ============================================================
     request-detail.jsp
    ============================================================
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.Transaction" %>
<%
    String ctx = request.getContextPath();
    Transaction tx = (Transaction) request.getAttribute("tx");
    String error = (String) request.getAttribute("error");

    // 1. Datos del usuario logueado
    Integer userIdSession = (Integer) session.getAttribute("userId");
    int userId = userIdSession != null ? userIdSession : 0;

    Integer roleIdSession = (Integer) session.getAttribute("roleId");
    int rol = roleIdSession != null ? roleIdSession : 0;

    // 2. REGLA DE NEGOCIO: ¿Puede aprobar?
    boolean puedeAprobar = false;
    if (tx != null && rol >= 3) {
        if (rol >= 4) {
            // Admin (4) y SuperAdmin (5) pueden aprobar cualquier cosa
            puedeAprobar = true;
        } else {
            // Manager (3) puede aprobar, EXCEPTO sus propias solicitudes
            puedeAprobar = (tx.getRequesterId() != userId);
        }
    }

    // Mensajes que vienen como query string despues de un POST
    String success = request.getParameter("success");
    String errParam = request.getParameter("error");
%>
<%!
    /* Metodos auxiliares */
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
        if (s == null) return "status-badge bg-gray-100 text-gray-600";
        switch (s) {
            case "PENDING":   return "status-pending";
            case "APPROVED":  return "status-approved";
            case "REJECTED":  return "status-rejected";
            case "COMPLETED": return "status-delivered";
            default:          return "status-badge bg-gray-100 text-gray-600";
        }
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <title>Detalle de Solicitud | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css" rel="stylesheet" />
</head>
<body class="page-body">

<%-- 🛡️ ENVOLTURA PARA EVITAR EL SOLAPAMIENTO DEL SIDEBAR --%>
<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <main class="page-main-narrow">

            <%-- Header con boton volver --%>
            <div class="page-header">
                <div>
                    <h1 class="page-title">Detalle de Solicitud</h1>
                    <% if (tx != null) { %>
                    <p class="page-subtitle">
                        TXN-<%= String.format("%04d", tx.getId()) %>
                    </p>
                    <% } %>
                </div>
                <a href="<%= ctx %>/HistoryServlet" class="btn-ghost">
                    ← Volver al historial
                </a>
            </div>

            <%-- Mensajes de feedback --%>
            <% if (success != null) { %>
            <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3 mb-4">
                ✅ <%= success %>
            </div>
            <% } %>
            <% if (errParam != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 mb-4">
                ❌ <%= errParam %>
            </div>
            <% } %>
            <% if (error != null) { %>
            <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 mb-4">
                ❌ <%= error %>
            </div>
            <% } %>

            <%-- Si la transaccion existe, mostramos sus datos --%>
            <% if (tx != null) { %>

            <%-- Panel principal con los datos --%>
            <div class="panel-form">

                <%-- Estado destacado arriba --%>
                <div class="flex justify-between items-center mb-6 pb-4 border-b border-gray-100">
                    <div>
                        <p class="form-label-tiny">Estado actual</p>
                        <span class="<%= claseBadgeStatus(tx.getStatus()) %> text-base mt-1">
                                    <%= traducirStatus(tx.getStatus()) %>
                                </span>
                    </div>
                    <div class="text-right">
                        <p class="form-label-tiny">Fecha de solicitud</p>
                        <p class="text-sm font-semibold text-gray-700 mt-1">
                            <%= tx.getCreatedAt() != null ? tx.getCreatedAt() : "—" %>
                        </p>
                    </div>
                </div>

                <%-- Grid con info del solicitante e item --%>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">

                    <div>
                        <p class="form-label-tiny">👤 Solicitante</p>
                        <p class="text-sm font-semibold text-gray-800 mt-1">
                            <%= tx.getRequesterName() != null ? tx.getRequesterName() : "—" %>
                        </p>
                    </div>

                    <div>
                        <p class="form-label-tiny">📦 Material solicitado</p>
                        <p class="text-sm font-semibold text-gray-800 mt-1">
                            <%= tx.getItemName() != null ? tx.getItemName() : "—" %>
                        </p>
                    </div>

                    <div>
                        <p class="form-label-tiny">🔢 Cantidad</p>
                        <p class="text-sm font-semibold text-gray-800 mt-1">
                            <%= tx.getQuantity() %>
                            <%= tx.getItemUnit() != null ? tx.getItemUnit() : "" %>
                        </p>
                    </div>

                    <div>
                        <p class="form-label-tiny">🔄 Tipo de movimiento</p>
                        <p class="text-sm font-semibold text-gray-800 mt-1">
                            <%= "IN".equals(tx.getType()) ? "Ingreso (IN)" : "Salida (OUT)" %>
                        </p>
                    </div>

                </div>

                <%-- Si hay aprobador asignado, mostramos --%>
                <% if (tx.getApproverName() != null && !tx.getApproverName().isEmpty()) { %>
                <div class="bg-gray-50 rounded-xl p-4 mb-6">
                    <p class="form-label-tiny">Aprobado/Rechazado por</p>
                    <p class="text-sm font-semibold text-gray-700 mt-1">
                        <%= tx.getApproverName() %>
                    </p>
                </div>
                <% } %>

                <%-- Notas / Proposito --%>
                <div class="mb-6">
                    <p class="form-label-tiny">📝 Notas / Propósito</p>
                    <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 mt-1">
                        <p class="text-sm text-gray-700 leading-relaxed">
                            <%= tx.getNotes() != null && !tx.getNotes().isEmpty()
                                    ? tx.getNotes()
                                    : "Sin notas adicionales." %>
                        </p>
                    </div>
                </div>

                <%-- BOTONES DE APROBAR / RECHAZAR --%>
                <%-- Solo se muestran si la solicitud esta pendiente Y el usuario tiene permisos validos --%>
                <% if ("PENDING".equals(tx.getStatus()) && puedeAprobar) { %>

                <hr class="border-gray-100 my-6"/>

                <h3 class="font-bold text-gray-800 mb-4">¿Qué quieres hacer con esta solicitud?</h3>

                <div class="flex gap-3">

                    <%-- Form para APROBAR --%>
                    <form action="<%= ctx %>/TransactionServlet" method="POST"
                          onsubmit="return confirm('¿Confirmas que apruebas esta solicitud?');"
                          style="display:inline;">
                        <input type="hidden" name="action" value="aprobar"/>
                        <input type="hidden" name="id" value="<%= tx.getId() %>"/>
                        <input type="hidden" name="notas" value="Aprobada desde detalle"/>
                        <button type="submit"
                                class="bg-green-500 hover:bg-green-600 text-white px-6 py-2.5 rounded-xl font-semibold shadow-sm flex items-center gap-2">
                            ✅ Aprobar Solicitud
                        </button>
                    </form>

                    <%-- Form para RECHAZAR --%>
                    <button onclick="rechazarSolicitud(<%= tx.getId() %>)"
                            class="bg-red-500 hover:bg-red-600 text-white px-6 py-2.5 rounded-xl font-semibold shadow-sm flex items-center gap-2">
                        ❌ Rechazar Solicitud
                    </button>

                </div>

                <% } %>

            </div>

            <% } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div> <%-- fin main-content --%>
</div> <%-- fin layout-wrapper --%>

<%-- Form oculto para rechazar --%>
<form id="rejectForm" action="<%= ctx %>/TransactionServlet" method="POST" style="display:none;">
    <input type="hidden" name="action" value="rechazar"/>
    <input type="hidden" name="id" id="rejectTxId"/>
    <input type="hidden" name="notas" id="rejectNotas"/>
</form>

<script>
    function rechazarSolicitud(id) {
        const motivo = prompt('Por favor indica el motivo del rechazo:');
        if (motivo === null) return;
        if (motivo.trim() === '') {
            alert('El motivo es obligatorio para rechazar.');
            return;
        }
        document.getElementById('rejectTxId').value = id;
        document.getElementById('rejectNotas').value = motivo;
        document.getElementById('rejectForm').submit();
    }
</script>

</body>
</html>