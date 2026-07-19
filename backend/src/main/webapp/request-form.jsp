<%--
    ════════════════════════════════════════════════════════════════════
     request-form.jsp — Formulario para crear una nueva solicitud
     (rediseño "Ola": pasos numerados + preview en vivo del material)
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
<%!
    // Escapa texto para insertarlo de forma segura dentro de un string JS de una línea.
    private String jsEsc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
    }

    // NUEVO: Escapa caracteres especiales de HTML para prevenir ataques XSS
    private String htmlEsc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Nueva Solicitud | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=23" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* ═════ Tarjeta principal ═════ */
        .profile-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            position: relative;
        }

        /* Encabezado con degradado + franja ondulada de marca */
        .card-header {
            position: relative;
            padding: 1.4rem 1.75rem 1.6rem;
            background: linear-gradient(135deg, var(--purple) 0%, var(--purple-dark) 100%);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            overflow: hidden;
        }
        .card-header::after {
            content: "";
            position: absolute;
            left: 0; right: 0; bottom: 0;
            height: 7px;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='28' height='7' viewBox='0 0 28 7'%3E%3Cpath d='M0 3.5 Q7 0 14 3.5 T28 3.5' fill='none' stroke='%23E91E8C' stroke-width='1.8' stroke-linecap='round'/%3E%3C/svg%3E");
            background-repeat: repeat-x; background-size: 28px 7px; opacity: 0.85;
        }
        .card-header-title {
            display: flex; align-items: center; gap: 0.75rem;
            font-size: 1.05rem; font-weight: 800; color: var(--white);
        }
        .card-header-title-icon {
            display: flex; align-items: center; justify-content: center;
            width: 42px; height: 42px; border-radius: var(--radius-md);
            background: rgba(255,255,255,0.16); flex-shrink: 0;
        }
        .card-header-title-icon i { width: 21px; height: 21px; color: var(--white); }
        .card-header-sub { font-size: 0.78rem; color: rgba(255,255,255,0.75); margin-top: 0.15rem; }

        .card-body { padding: 2.1rem 2rem 2rem; }

        /* ═════ Pasos numerados ═════ */
        .req-step { display: flex; gap: 1.1rem; margin-bottom: 1.9rem; }
        .req-step:last-of-type { margin-bottom: 0; }

        .req-step-num {
            flex-shrink: 0;
            width: 34px; height: 34px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.92rem; font-weight: 800; color: var(--white);
            background: linear-gradient(135deg, var(--purple) 0%, var(--pink) 100%);
            box-shadow: 0 3px 10px rgba(91,31,168,0.28);
            position: relative;
        }
        /* Línea conectora entre pasos */
        .req-step:not(:last-of-type) .req-step-num::after {
            content: "";
            position: absolute;
            top: 38px; left: 50%; transform: translateX(-50%);
            width: 2px; height: calc(100% + 1.9rem - 38px);
            background: linear-gradient(180deg, var(--purple-light) 0%, var(--gray-150) 100%);
        }
        .req-step-body { flex: 1; min-width: 0; }
        .req-step-title {
            font-size: 0.95rem; font-weight: 800; color: var(--gray-800);
            margin-bottom: 0.9rem;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }
        @media (max-width: 640px) { .form-row { grid-template-columns: 1fr; } }

        .field-group { margin-bottom: 1.25rem; }
        .field-label {
            display: block; font-size: 0.75rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.2px;
            color: var(--gray-500); margin-bottom: 0.5rem;
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
            box-sizing: border-box;
        }
        .field-input:focus {
            border-color: var(--purple);
            background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }

        /* ═════ Tarjeta de vista previa del material (en vivo) ═════ */
        .material-preview-card {
            display: flex; align-items: center; gap: 1rem;
            margin-top: 0.85rem;
            padding: 0.9rem 1.1rem;
            border-radius: var(--radius-md);
            background: linear-gradient(135deg, var(--purple-bg) 0%, var(--pink-bg) 100%);
            border: 1px solid #DDD6FE;
            animation: preview-pop 0.28s cubic-bezier(.34,1.56,.64,1) both;
        }
        @keyframes preview-pop {
            from { opacity: 0; transform: translateY(-6px) scale(0.98); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }
        .material-preview-img-wrap {
            width: 56px; height: 56px; border-radius: var(--radius-sm);
            overflow: hidden; flex-shrink: 0; background: var(--white);
            display: flex; align-items: center; justify-content: center;
            box-shadow: var(--shadow-sm);
        }
        .material-preview-img-wrap img { width: 100%; height: 100%; object-fit: cover; }
        .material-preview-img-wrap i { width: 24px; height: 24px; color: var(--purple); opacity: 0.5; }
        .material-preview-name { font-size: 0.9rem; font-weight: 800; color: var(--gray-800); margin-bottom: 0.15rem; }
        .material-preview-meta { display: flex; align-items: center; gap: 0.5rem; flex-wrap: wrap; }
        .material-preview-stock {
            font-size: 0.74rem; font-weight: 700; color: var(--purple);
            display: inline-flex; align-items: center; gap: 0.25rem;
        }
        .material-preview-stock i { width: 12px; height: 12px; }
        .material-preview-tag {
            font-size: 0.66rem; font-weight: 700; color: var(--pink);
            background: rgba(233,30,140,0.1); padding: 0.14rem 0.5rem;
            border-radius: var(--radius-full); text-transform: uppercase; letter-spacing: 0.3px;
        }

        /* ═════ Stepper de cantidad (+/-) ═════ */
        .qty-stepper {
            display: flex; align-items: stretch;
            border: 1.5px solid var(--gray-200); border-radius: var(--radius-sm);
            overflow: hidden; background: var(--gray-50);
            transition: all var(--transition);
        }
        .qty-stepper:focus-within {
            border-color: var(--purple); background: var(--white);
            box-shadow: 0 0 0 3px rgba(91, 31, 168, 0.1);
        }
        .qty-stepper-btn {
            display: flex; align-items: center; justify-content: center;
            width: 42px; flex-shrink: 0; border: none; background: transparent;
            color: var(--purple); cursor: pointer; font-family: inherit;
            transition: background var(--transition);
        }
        .qty-stepper-btn:hover { background: var(--purple-bg); }
        .qty-stepper-btn:active { background: var(--purple-light); color: var(--white); }
        .qty-stepper-btn i { width: 16px; height: 16px; }
        .qty-stepper input {
            flex: 1; min-width: 0; border: none; background: transparent;
            text-align: center; font-size: 0.95rem; font-weight: 700;
            color: var(--gray-800); font-family: inherit; outline: none;
            -moz-appearance: textfield;
        }
        .qty-stepper input::-webkit-outer-spin-button,
        .qty-stepper input::-webkit-inner-spin-button { -webkit-appearance: none; margin: 0; }
        .qty-help { font-size: 0.72rem; color: var(--gray-500); margin-top: 0.4rem; font-weight: 500; }
        .qty-help.qty-help--warn { color: var(--orange-dark); font-weight: 700; }

        /* ═════ Tarjeta de solicitante ═════ */
        .verified-card {
            display: flex; align-items: flex-start; gap: 1rem;
            padding: 1.1rem 1.25rem;
            border-radius: var(--radius-md);
            margin-top: 0.5rem;
            background: var(--gray-50);
            border: 1px solid var(--gray-150);
        }
        .verified-icon {
            display: flex; align-items: center; justify-content: center;
            width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, var(--purple-light) 0%, var(--pink) 100%);
            color: var(--white);
        }
        .verified-icon i { width: 18px; height: 18px; }
        .verified-text-title { font-size: 0.85rem; font-weight: 700; color: var(--gray-800); margin-bottom: 0.15rem; }
        .verified-text-sub { font-size: 0.8rem; color: var(--gray-500); line-height: 1.5; }
        .verified-text-sub strong { color: var(--purple); }

        .btn-save {
            display: inline-flex; align-items: center; justify-content: center; gap: 0.5rem;
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white); padding: 0.75rem 1.75rem;
            border-radius: var(--radius-full); font-size: 0.9rem; font-weight: 700;
            border: none; cursor: pointer; transition: all var(--transition);
            box-shadow: 0 4px 12px rgba(233, 30, 140, 0.2);
        }
        .btn-save:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(233, 30, 140, 0.35); }
        .btn-save i { width: 18px; height: 18px; }

        .alert {
            display: flex; align-items: center; gap: 0.6rem;
            padding: 0.9rem 1.1rem; border-radius: var(--radius-sm);
            font-size: 0.88rem; font-weight: 600; margin-bottom: 1.25rem; border: 1px solid;
        }
        .alert-error { background: var(--red-bg); color: var(--red-dark); border-color: #FECACA; }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }

        .form-actions {
            display: flex; justify-content: flex-end; align-items: center; gap: 1rem;
            padding-top: 1.75rem; border-top: 1px solid var(--gray-100); margin-top: 2.1rem;
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
                <a href="<%= ctx %>/HomeServlet" class="btn-ghost btn-icon"
                   onclick="if (document.referrer && document.referrer.indexOf(window.location.host) !== -1) { history.back(); return false; }">
                    <i data-lucide="arrow-left"></i>
                    Volver
                </a>
            </div>

            <% if (error != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= htmlEsc(error) %></span>
            </div>
            <% } %>

            <div class="profile-card">

                <div class="card-header">
                    <div class="card-header-title">
                        <div class="card-header-title-icon"><i data-lucide="clipboard-list"></i></div>
                        <div>
                            <div>Formulario de Pedido</div>
                            <div class="card-header-sub">Completa los 3 pasos para enviar tu solicitud</div>
                        </div>
                    </div>
                </div>

                <div class="card-body">
                    <form action="<%= ctx %>/TransactionServlet" method="POST" novalidate id="requestForm">

                        <input type="hidden" name="action" value="crear" />
                        <%-- NUEVO: Token CSRF para evitar falsificación de peticiones --%>
                        <input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") != null ? session.getAttribute("csrfToken") : "" %>" />

                        <%-- ═══ PASO 1: Material ═══ --%>
                        <div class="req-step">
                            <div class="req-step-num">1</div>
                            <div class="req-step-body">
                                <div class="req-step-title">¿Qué material necesitas?</div>

                                <div class="field-group" style="margin-bottom: 0;">
                                    <label for="material" class="field-label">Material requerido *</label>
                                    <select id="material" name="itemId" class="field-input" required
                                            onchange="actualizarPreviewMaterial(this.value)">
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

                                    <%-- Vista previa en vivo — se llena vía JS al elegir un material --%>
                                    <div id="materialPreviewCard" class="material-preview-card" style="display:none;">
                                        <div class="material-preview-img-wrap" id="materialPreviewImgWrap">
                                            <i data-lucide="package"></i>
                                        </div>
                                        <div>
                                            <div class="material-preview-name" id="materialPreviewName"></div>
                                            <div class="material-preview-meta">
                                                <span class="material-preview-stock" id="materialPreviewStock">
                                                    <i data-lucide="layers"></i><span></span>
                                                </span>
                                                <span class="material-preview-tag" id="materialPreviewTag" style="display:none;"></span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- ═══ PASO 2: Cantidad y fecha ═══ --%>
                        <div class="req-step">
                            <div class="req-step-num">2</div>
                            <div class="req-step-body">
                                <div class="req-step-title">Detalles del pedido</div>

                                <div class="form-row">
                                    <div class="field-group" style="margin-bottom: 0;">
                                        <label for="cantidad" class="field-label">Cantidad *</label>
                                        <div class="qty-stepper">
                                            <button type="button" class="qty-stepper-btn" onclick="cambiarCantidad(-1)" aria-label="Restar">
                                                <i data-lucide="minus"></i>
                                            </button>
                                            <input type="number" id="cantidad" name="cantidad" min="1" step="1"
                                                   value="<%= htmlEsc(cantidadValue) %>"
                                                   onkeypress="return event.charCode >= 48 && event.charCode <= 57"
                                                   onpaste="return false;"
                                                   oninput="validarCantidadContraStock()" required>
                                            <button type="button" class="qty-stepper-btn" onclick="cambiarCantidad(1)" aria-label="Sumar">
                                                <i data-lucide="plus"></i>
                                            </button>
                                        </div>
                                        <p class="qty-help" id="qtyHelp">Selecciona un material para ver el stock disponible.</p>
                                    </div>

                                    <div class="field-group" style="margin-bottom: 0;">
                                        <label for="needed-by" class="field-label">¿Para cuándo lo necesitas?</label>
                                        <input type="date" id="needed-by" name="neededBy" value="<%= htmlEsc(fechaPrevia != null ? fechaPrevia : "") %>" class="field-input">
                                        <p class="qty-help">Opcional. Esta fecha ayuda a priorizar.</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- ═══ PASO 3: Propósito ═══ --%>
                        <div class="req-step">
                            <div class="req-step-num">3</div>
                            <div class="req-step-body">
                                <div class="req-step-title">Cuéntanos para qué lo necesitas</div>

                                <div class="field-group" style="margin-bottom: 0;">
                                    <label for="proposito" class="field-label">Propósito / Uso del material *</label>
                                    <textarea id="proposito" name="notas" rows="4" class="field-input" style="resize: vertical;"
                                              placeholder="Describe detalladamente para qué necesitas este material..."
                                              required><%= htmlEsc(notasPrevias != null ? notasPrevias : "") %></textarea>
                                </div>

                                <div class="verified-card">
                                    <div class="verified-icon"><i data-lucide="user"></i></div>
                                    <div>
                                        <p class="verified-text-title">Solicitante de la orden</p>
                                        <p class="verified-text-sub">
                                            Sesión activa en el sistema como: <strong><%= htmlEsc(userName != null ? userName : "Usuario Actual") %></strong>
                                        </p>
                                    </div>
                                </div>
                            </div>
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
    // Datos de los materiales disponibles, generados desde el servidor,
    // para actualizar la vista previa sin necesidad de otra petición.
    const MATERIALES = {
        <% if (items != null) {
            boolean primero = true;
            for (Item it : items) {
                if (!"UNAVAILABLE".equals(it.getStatus()) && it.isActivo()) {
                    if (!primero) { %>,<% }
                    primero = false;
                    String img = (it.getImageUrl() != null && !it.getImageUrl().trim().isEmpty()
                                    && !it.getImageUrl().contains("placeholder"))
                            ? (it.getImageUrl().startsWith("http") ? it.getImageUrl() : ctx + it.getImageUrl())
                            : "";
                    String tag = (it.getTags() != null && !it.getTags().isEmpty()) ? it.getTags().get(0) : "";
        %>
        "<%= it.getId() %>": {
        name: "<%= jsEsc(it.getName()) %>",
            stock: <%= it.getCachedQuantity() %>,
        unit: "<%= jsEsc(it.getUnit() != null ? it.getUnit() : "") %>",
            image: "<%= jsEsc(img) %>",
            tag: "<%= jsEsc(tag) %>"
    }
    <%      }
        }
    } %>
    };

    function actualizarPreviewMaterial(itemId) {
        const card = document.getElementById('materialPreviewCard');
        const data = MATERIALES[itemId];

        if (!data) {
            card.style.display = 'none';
            document.getElementById('qtyHelp').textContent = 'Selecciona un material para ver el stock disponible.';
            document.getElementById('qtyHelp').classList.remove('qty-help--warn');
            document.getElementById('cantidad').removeAttribute('max');
            return;
        }

        document.getElementById('materialPreviewName').textContent = data.name;
        document.getElementById('materialPreviewStock').querySelector('span').textContent =
            data.stock + ' ' + data.unit + ' disponibles';

        const tagEl = document.getElementById('materialPreviewTag');
        if (data.tag) {
            tagEl.textContent = data.tag;
            tagEl.style.display = 'inline-block';
        } else {
            tagEl.style.display = 'none';
        }

        const imgWrap = document.getElementById('materialPreviewImgWrap');
        if (data.image) {
            imgWrap.innerHTML = '<img src="' + data.image + '" alt="' + data.name + '"/>';
        } else {
            imgWrap.innerHTML = '<i data-lucide="package"></i>';
            if (typeof lucide !== 'undefined') lucide.createIcons();
        }

        card.style.display = 'flex';

        // Sincronizar el stock disponible con el stepper de cantidad
        document.getElementById('cantidad').setAttribute('max', data.stock);
        validarCantidadContraStock();
    }

    function cambiarCantidad(delta) {
        const input = document.getElementById('cantidad');
        let valor = parseInt(input.value, 10);
        if (isNaN(valor)) valor = 1;
        valor += delta;
        if (valor < 1) valor = 1;
        input.value = valor;
        validarCantidadContraStock();
    }

    function validarCantidadContraStock() {
        const input = document.getElementById('cantidad');
        const help = document.getElementById('qtyHelp');
        const max = input.getAttribute('max');

        if (!max) return;

        const valor = parseInt(input.value, 10);
        const maxNum = parseInt(max, 10);

        if (!isNaN(valor) && valor > maxNum) {
            help.textContent = 'Solo hay ' + maxNum + ' unidades disponibles.';
            help.classList.add('qty-help--warn');
        } else {
            help.textContent = 'Stock disponible: ' + maxNum + ' unidades.';
            help.classList.remove('qty-help--warn');
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') {
            lucide.createIcons();
        }
        const dateInput = document.getElementById('needed-by');
        if (dateInput) {
            dateInput.setAttribute('min', new Date().toISOString().split('T')[0]);
        }

        // Si el material viene preseleccionado (ej. desde el catálogo), mostrar su preview de una
        const materialSelect = document.getElementById('material');
        if (materialSelect && materialSelect.value) {
            actualizarPreviewMaterial(materialSelect.value);
        }
    });
</script>
</body>
</html>