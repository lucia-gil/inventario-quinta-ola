<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();
    List<Item> items = (List<Item>) request.getAttribute("items");
    String userName = (String) session.getAttribute("userName");
    String error = request.getParameter("error");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Nueva Solicitud | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=25" rel="stylesheet" />
    <!-- Carga de la librería Lucide Icons idéntica a profile.jsp -->
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body class="page-body">

<div class="layout-wrapper">

    <!-- Sidebar (Menú lateral izquierdo) -->
    <jsp:include page="includes/navbar.jsp"/>

    <!-- Contenedor de contenido centralizado que corrige el empuje del footer y sidebar -->
    <div class="main-content">

        <!-- Inclusión de la barra superior que faltaba en la vista original -->
        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main-narrow">

            <!-- Encabezado de Página Estilo Profesional -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">Nueva Solicitud</h1>
                    <p class="page-subtitle">Pide los materiales que necesitas para tu proyecto.</p>
                </div>
                <a href="javascript:history.back()" class="btn-ghost btn-icon">
                    <i data-lucide="arrow-left"></i>
                    Volver
                </a>
            </div>

            <!-- Alertas con Estilos Coherentes -->
            <% if (error != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <!-- Panel del Formulario (Basado en el diseño premium de profile.jsp) -->
            <div class="profile-card">

                <div class="card-header">
                    <div class="card-header-title">
                        <i data-lucide="clipboard-list"></i>
                        <span>Formulario de Pedido</span>
                    </div>
                </div>

                <div class="card-body">
                    <form action="<%= ctx %>/TransactionServlet" method="POST" class="space-y-5" novalidate>

                        <%-- Campo oculto para la acción del Servlet --%>
                        <input type="hidden" name="action" value="crear" />

                        <!-- Banner Informativo del Solicitante -->
                        <div class="verified-card" style="background: var(--purple-bg); border-color: var(--purple-light); margin-top: 0;">
                            <div class="verified-icon" style="background: var(--purple);">
                                <i data-lucide="user"></i>
                            </div>
                            <div>
                                <p class="verified-text-title" style="color: var(--purple-dark);">Solicitante de la Orden</p>
                                <p class="verified-text-sub">
                                    Sesión activa en el sistema como: <strong><%= userName != null ? userName : "Usuario Actual" %></strong>
                                </p>
                            </div>
                        </div>

                        <!-- Selección de Material -->
                            <div class="field-group">
                                <label for="material" class="field-label">Material Requerido *</label>
                                <select id="material" name="itemId" class="field-input" required>
                                    <option value="" disabled selected>Selecciona un material del catálogo...</option>
                                    <% if (items != null) {
                                        for (Item it : items) {
                                            // CORRECCIÓN: Se usa it.isActivo() que devuelve true/false directamente
                                            if (!"UNAVAILABLE".equals(it.getStatus()) && it.isActivo()) {
                                    %>
                                    <option value="<%= it.getId() %>">
                                        <%= it.getName() %> — [Stock Disponible: <%= it.getCachedQuantity() %> <%= it.getUnit() != null ? it.getUnit() : "" %>]
                                    </option>
                                    <%      }
                                    }
                                    } %>
                                </select>
                            </div>

                        <!-- Fila de Doble Columna (Cantidad y Fecha) -->
                        <div class="form-row">
                            <div class="field-group">
                                <label for="cantidad" class="field-label">Cantidad *</label>
                                <input type="number" id="cantidad" name="cantidad" min="1" value="1" class="field-input" required>
                            </div>

                            <div class="field-group">
                                <label for="needed-by" class="field-label">¿Para cuándo lo necesitas? *</label>
                                <input type="date" id="needed-by" name="needed-by" class="field-input" required>
                                <p style="font-size: 11px; color: var(--gray-400); margin-top: 0.4rem; font-weight: 500;">
                                    Esta fecha nos ayuda a priorizar los despachos del almacén.
                                </p>
                            </div>
                        </div>

                        <!-- Propósito / Justificación -->
                        <div class="field-group">
                            <label for="proposito" class="field-label">Propósito / Uso del material *</label>
                            <textarea id="proposito" name="proposito" rows="4" class="field-input" style="resize: vertical;" placeholder="Describe detalladamente para qué actividades necesitas este material..." required></textarea>
                        </div>

                        <!-- Acciones del Formulario -->
                        <div class="flex justify-end gap-3 pt-4" style="border-top: 1px solid var(--gray-100); margin-top: 1.5rem;">
                            <a href="javascript:history.back()" class="btn-ghost">
                                Cancelar
                            </a>
                            <button type="submit" class="btn-save" style="width: auto; margin-top: 0; padding: 0.65rem 1.75rem;">
                                <i data-lucide="send"></i>
                                Enviar Solicitud
                            </button>
                        </div>

                    </form>
                </div>
            </div>

        </main>

        <!-- El Footer ahora se mantendrá siempre al fondo sin colisionar con el Navbar -->
        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

<!-- Inicialización dinámica de Lucide Icons e inyección de fecha mínima -->
<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
        // Evita la selección de días pasados
        const dateInput = document.getElementById('needed-by');
        if(dateInput) {
            dateInput.setAttribute('min', new Date().toISOString().split('T')[0]);
        }
    });
</script>
</body>
</html>