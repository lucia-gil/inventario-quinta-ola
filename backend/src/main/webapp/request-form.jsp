<%--
    ════════════════════════════════════════════════════════════════════
     request-form.jsp — Formulario para crear una nueva solicitud
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();
    List<Item> items = (List<Item>) request.getAttribute("items");
    Integer itemPreseleccionado = (Integer) request.getAttribute("itemPreseleccionado");
    String userName = (String) session.getAttribute("userName");

    // Capturar el error desde el request attribute o parámetro
    String error = (String) request.getAttribute("error");
    if (error == null) {
        error = request.getParameter("error");
    }

    // Capturar los valores previos para la persistencia de datos
    String cantidadPrevia = (String) request.getAttribute("cantidadPrevia");
    if (cantidadPrevia == null) {
        cantidadPrevia = request.getParameter("cantidad");
    }

    String fechaPrevia = (String) request.getAttribute("fechaPrevia");
    if (fechaPrevia == null) {
        fechaPrevia = request.getParameter("neededBy");
    }

    String notasPrevias = (String) request.getAttribute("notasPrevias");
    if (notasPrevias == null) {
        notasPrevias = request.getParameter("notas");
    }

    // Regla: Si el error es por Stock Insuficiente, vaciamos únicamente la cantidad errónea.
    // De lo contrario, mantenemos el valor previo o el valor por defecto "1".
    String cantidadValue = "1";
    if (cantidadPrevia != null) {
        cantidadValue = cantidadPrevia;
    }
    if (error != null && error.contains("Stock insuficiente")) {
        cantidadValue = "";
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Nueva Solicitud | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=11" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Estilos específicos del formulario (Basados en el perfil) ═════ */
        .profile-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            position: relative;
        }

        .card-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--gray-100);
            background: var(--gray-50);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
        }

        .card-header-title {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--purple);
        }

        .card-header-title i {
            width: 18px;
            height: 18px;
            color: var(--pink);
        }

        .card-body {
            padding: 2rem;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }

        @media (max-width: 640px) {
            .form-row { grid-template-columns: 1fr; }
        }

        .field-group {
            margin-bottom: 1.25rem;
        }

        .field-label {
            display: block;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: var(--gray-500);
            margin-bottom: 0.5rem;
        }

        .field-input {
            width: 100%;
            border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm);
            padding: 0.75rem 1rem;
            font-size: 0.9rem;
            color: var(--gray-800);
            background: var(--gray-50);
            transition: all var(--transition);
            outline: none;
            font-family: inherit;
        }

        .field-input:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }

        .verified-card {
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            padding: 1.25rem;
            border-radius: var(--radius-md);
            margin-bottom: 1.75rem;
            background: linear-gradient(135deg, var(--purple-bg) 0%, var(--pink-bg) 100%);
            border: 1px solid rgba(233, 30, 140, 0.2);
        }

        .verified-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 42px;
            height: 42px;
            border-radius: var(--radius-sm);
            flex-shrink: 0;
            background: var(--purple);
            color: var(--white);
        }

        .verified-icon i { width: 20px; height: 20px; }

        .verified-text-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--purple-dark);
            margin-bottom: 0.25rem;
        }

        .verified-text-sub {
            font-size: 0.85rem;
            color: var(--gray-700);
            line-height: 1.5;
        }

        .verified-text-sub strong { color: var(--purple-dark); }

        .btn-save {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white);
            padding: 0.75rem 1.75rem;
            border-radius: var(--radius-full);
            font-size: 0.9rem;
            font-weight: 700;
            border: none;
            cursor: pointer;
            transition: all var(--transition);
            box-shadow: 0 4px 12px rgba(233, 30, 140, 0.2);
        }

        .btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(233, 30, 140, 0.35);
        }

        .btn-save i { width: 18px; height: 18px; }

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

        .alert-error {
            background: var(--red-bg);
            color: var(--red-dark);
            border-color: #FECACA;
        }

        .alert i { width: 18px; height: 18px; flex-shrink: 0; }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 1rem;
            padding-top: 1.5rem;
            border-top: 1px solid var(--gray-100);
            margin-top: 2rem;
        }
    </style>
</head>
<body class="page-body">

<div class="layout-wrapper">

    <jsp:include page="includes/navbar.jsp"/>

    <div class="main-content">

        <jsp:include page="includes/topbar.jsp"/>

        <main class="page-main-narrow">

            <div class="page-header">
                <div>
                    <h1 class="page-title">Nueva Solicitud</h1>
                    <p class="page-subtitle">Pide los materiales que necesitas para tu proyecto.</p>
                </div>
                <a href="<%= ctx %>/HomeServlet" class="btn-ghost btn-icon">
                    <i data-lucide="arrow-left"></i>
                    Volver
                </a>
            </div>

            <% if (error != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <div class="profile-card">

                <div class="card-header">
                    <div class="card-header-title">
                        <i data-lucide="clipboard-list"></i>
                        <span>Formulario de Pedido</span>
                    </div>
                </div>

                <div class="card-body">
                    <form action="<%= ctx %>/TransactionServlet" method="POST" novalidate>

                        <input type="hidden" name="action" value="crear" />

                        <div class="verified-card">
                            <div class="verified-icon">
                                <i data-lucide="user"></i>
                            </div>
                            <div>
                                <p class="verified-text-title">Solicitante de la Orden</p>
                                <p class="verified-text-sub">
                                    Sesión activa en el sistema como: <strong><%= userName != null ? userName : "Usuario Actual" %></strong>
                                </p>
                            </div>
                        </div>

                        <div class="field-group">
                            <label for="material" class="field-label">Material Requerido *</label>
                            <select id="material" name="itemId" class="field-input" required>
                                <option value="" disabled <%= itemPreseleccionado == null ? "selected" : "" %>>
                                    Selecciona un material del catálogo...
                                </option>
                                <% if (items != null) {
                                    for (Item it : items) {
                                        if (!"UNAVAILABLE".equals(it.getStatus()) && it.isActivo()) {
                                %>
                                <option value="<%= it.getId() %>" <%= (itemPreseleccionado != null && itemPreseleccionado == it.getId()) ? "selected" : "" %>>
                                    <%= it.getName() %> — [Stock Disponible: <%= it.getCachedQuantity() %> <%= it.getUnit() != null ? it.getUnit() : "" %>]
                                </option>
                                <%      }
                                }
                                } %>
                            </select>
                        </div>

                        <div class="form-row">
                            <div class="field-group" style="margin-bottom: 0;">
                                <label for="cantidad" class="field-label">Cantidad *</label>
                                <input type="number" id="cantidad" name="cantidad" min="1" step="1" value="<%= cantidadValue %>" class="field-input" onkeypress="return event.charCode >= 48 && event.charCode <= 57" onpaste="return false;" required>
                            </div>

                            <div class="field-group" style="margin-bottom: 0;">
                                <label for="needed-by" class="field-label">¿Para cuándo lo necesitas?</label>
                                <input type="date" id="needed-by" name="neededBy" value="<%= fechaPrevia != null ? fechaPrevia : "" %>" class="field-input">
                                <p style="font-size: 11px; color: var(--gray-400); margin-top: 0.4rem; font-weight: 500;">
                                    Opcional. Esta fecha ayuda a priorizar.
                                </p>
                            </div>
                        </div>

                        <div class="field-group" style="margin-top: 1.25rem;">
                            <label for="proposito" class="field-label">Propósito / Uso del material *</label>
                            <textarea id="proposito" name="notas" rows="4" class="field-input" style="resize: vertical;" placeholder="Describe detalladamente para qué necesitas este material..." required><%= notasPrevias != null ? notasPrevias : "" %></textarea>
                        </div>

                        <div class="form-actions">
                            <a href="<%= ctx %>/HomeServlet" class="btn-ghost" style="border: 1px solid var(--gray-300); color: var(--gray-600);">
                                Cancelar
                            </a>
                            <button type="submit" class="btn-save">
                                <i data-lucide="send"></i>
                                Enviar Solicitud
                            </button>
                        </div>

                    </form>
                </div>
            </div>

        </main>

        <jsp:include page="includes/footer.jsp"/>

    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
        const dateInput = document.getElementById('needed-by');
        if(dateInput) {
            dateInput.setAttribute('min', new Date().toISOString().split('T')[0]);
        }
    });
</script>
</body>
</html>