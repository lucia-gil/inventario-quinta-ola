<%--
    ════════════════════════════════════════════════════════════════════
     admin-item.jsp — Formulario crear/editar material (rediseño)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.quintaola.model.Item" %>
<%@ page import="java.util.List" %>
<%
    String ctx = request.getContextPath();

    Integer roleId = (Integer) session.getAttribute("roleId");
    if (roleId == null || (roleId != 2 && roleId != 4 && roleId != 5)) {
        response.sendRedirect(ctx + "/HomeServlet");
        return;
    }

    Item item = (Item) request.getAttribute("item");
    boolean isEditMode = (item != null);

    List<String> tagsDisponibles = (List<String>) request.getAttribute("tagsDisponibles");

    String tagActual = "";
    if (isEditMode && item.getTags() != null && !item.getTags().isEmpty()) {
        tagActual = item.getTags().get(0);
    }

    String pageTitle    = isEditMode ? "Editar Material" : "Añadir Nuevo Material";
    String pageSubtitle = isEditMode
            ? "Modifica los parámetros del material en el inventario"
            : "Registra un nuevo material en el sistema de inventario";
    String btnText   = isEditMode ? "Actualizar Cambios" : "Guardar Material";
    String actionType = isEditMode ? "actualizar" : "crear";

    String errParam     = request.getParameter("error");
    String successParam = request.getParameter("success");

    request.setAttribute("activeMenu", "inventory");
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title><%= pageTitle %> | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=10" rel="stylesheet"/>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        .form-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1px solid var(--gray-100);
            box-shadow: var(--shadow-sm);
            overflow: hidden;
        }
        .form-card-header {
            padding: 1.25rem 1.75rem;
            border-bottom: 1px solid var(--gray-100);
            background: linear-gradient(135deg, var(--purple-bg) 0%, var(--pink-bg) 100%);
        }
        .form-card-header-title {
            display: flex; align-items: center; gap: 0.6rem;
            font-size: 1rem; font-weight: 700; color: var(--purple);
        }
        .form-card-header-title i { width: 18px; height: 18px; }
        .form-card-body { padding: 1.75rem; }

        .form-row {
            display: grid; grid-template-columns: 1fr 1fr;
            gap: 1.5rem; margin-bottom: 1.25rem;
        }
        .form-row-3 {
            display: grid; grid-template-columns: 1fr 1fr 1fr;
            gap: 1.5rem; margin-bottom: 1.25rem;
        }
        @media (max-width: 700px) {
            .form-row, .form-row-3 { grid-template-columns: 1fr; }
        }

        .form-group { margin-bottom: 1.25rem; }

        .form-label-custom {
            display: block; font-size: 0.72rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1.2px;
            color: var(--gray-600); margin-bottom: 0.5rem;
        }
        .form-label-custom .required { color: var(--pink); margin-left: 0.2rem; }

        .form-input, .form-select, .form-textarea {
            width: 100%; border: 1.5px solid var(--gray-200);
            border-radius: var(--radius-sm); padding: 0.7rem 0.95rem;
            font-size: 0.9rem; color: var(--gray-800); background: var(--gray-50);
            transition: all var(--transition); outline: none;
            font-family: inherit; box-sizing: border-box;
        }
        .form-input:focus, .form-select:focus, .form-textarea:focus {
            border-color: var(--purple); background: var(--white);
            box-shadow: 0 0 0 3px rgba(91,31,168,0.1);
        }
        .form-input[readonly] { background: var(--gray-100); cursor: not-allowed; }
        .form-textarea { resize: vertical; min-height: 90px; }
        .form-help { font-size: 0.72rem; color: var(--gray-500); margin-top: 0.35rem; font-style: italic; }

        .input-wrap { position: relative; }
        .input-wrap > i, .input-wrap > svg {
            position: absolute; left: 0.95rem; top: 50%;
            transform: translateY(-50%); color: var(--gray-400);
            width: 16px; height: 16px; pointer-events: none; z-index: 2;
        }
        .input-wrap .form-input { padding-left: 2.65rem; }
        .input-wrap:focus-within > i, .input-wrap:focus-within > svg { color: var(--purple); }

        .tag-chips { display: flex; flex-wrap: wrap; gap: 0.4rem; margin-top: 0.5rem; }
        .tag-chip-suggest {
            display: inline-flex; align-items: center; gap: 0.3rem;
            padding: 0.3rem 0.75rem; font-size: 0.72rem; font-weight: 600;
            color: var(--purple); background: var(--purple-bg);
            border: 1px solid transparent; border-radius: var(--radius-full);
            cursor: pointer; transition: all var(--transition);
        }
        .tag-chip-suggest:hover { background: var(--purple); color: var(--white); }
        .tag-chip-suggest i { width: 12px; height: 12px; }

        .form-divider { border: none; border-top: 1px solid var(--gray-100); margin: 1.5rem 0; }

        .form-actions {
            display: flex; justify-content: flex-end;
            gap: 0.75rem; padding-top: 0.5rem;
        }
        .btn-cancel, .btn-submit {
            display: inline-flex; align-items: center; gap: 0.45rem;
            padding: 0.65rem 1.4rem; border-radius: var(--radius-full);
            font-size: 0.88rem; font-weight: 700; border: none;
            cursor: pointer; transition: all var(--transition); text-decoration: none;
        }
        .btn-cancel {
            background: var(--white); color: var(--gray-700);
            border: 1.5px solid var(--gray-200);
        }
        .btn-cancel:hover { background: var(--gray-100); color: var(--gray-800); }
        .btn-submit {
            background: linear-gradient(135deg, var(--pink) 0%, var(--purple) 100%);
            color: var(--white); box-shadow: 0 4px 12px rgba(233,30,140,0.25);
        }
        .btn-submit:hover { transform: translateY(-1px); box-shadow: 0 6px 18px rgba(233,30,140,0.4); }
        .btn-cancel i, .btn-submit i { width: 14px; height: 14px; }

        .alert {
            display: flex; align-items: center; gap: 0.6rem;
            padding: 0.9rem 1.1rem; border-radius: var(--radius-sm);
            font-size: 0.88rem; font-weight: 600; margin-bottom: 1.25rem; border: 1px solid;
        }
        .alert i { width: 18px; height: 18px; flex-shrink: 0; }
        .alert-error   { background: var(--red-bg);   color: var(--red-dark);   border-color: #FECACA; }
        .alert-success { background: var(--green-bg); color: var(--green-dark); border-color: #BBF7D0; }
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
                    <h1 class="page-title">
                        <i data-lucide="<%= isEditMode ? "edit-3" : "plus-circle" %>"
                           style="display:inline-block;width:24px;height:24px;vertical-align:middle;margin-right:8px;color:var(--purple);"></i>
                        <%= pageTitle %>
                    </h1>
                    <p class="page-subtitle"><%= pageSubtitle %></p>
                </div>
                <a href="<%= ctx %>/InventoryServlet" class="btn-ghost btn-icon">
                    <i data-lucide="arrow-left"></i>
                    Volver al inventario
                </a>
            </div>

            <% if (errParam != null) { %>
            <div class="alert alert-error">
                <i data-lucide="alert-circle"></i>
                <span><%= errParam %></span>
            </div>
            <% } %>

            <% if (successParam != null) { %>
            <div class="alert alert-success">
                <i data-lucide="check-circle"></i>
                <span><%= successParam %></span>
            </div>
            <% } %>

            <%-- ══ Card: Información del material ══ --%>
            <div class="form-card">
                <div class="form-card-header">
                    <div class="form-card-header-title">
                        <i data-lucide="package"></i>
                        Información del material
                    </div>
                </div>
                <div class="form-card-body">
                    <form action="<%= ctx %>/AdminItemServlet" method="POST" id="itemForm">
                        <input type="hidden" name="action" value="<%= actionType %>"/>
                        <% if (isEditMode) { %>
                        <input type="hidden" name="id" value="<%= item.getId() %>"/>
                        <% } %>

                        <div class="form-group">
                            <label class="form-label-custom">Nombre del material <span class="required">*</span></label>
                            <input type="text" name="nombre" class="form-input" required
                                   placeholder="Ej. Kit de Ayuda Humanitaria, Polera Quinta Ola..."
                                   value="<%= isEditMode && item.getName() != null ? item.getName() : "" %>"/>
                        </div>

                        <div class="form-row">
                            <div>
                                <label class="form-label-custom">Etiqueta existente</label>
                                <select name="tags" id="tagSelect" class="form-select">
                                    <option value="">— Seleccionar etiqueta —</option>
                                    <% if (tagsDisponibles != null) {
                                        for (String t : tagsDisponibles) { %>
                                    <option value="<%= t %>" <%= t.equals(tagActual) ? "selected" : "" %>><%= t %></option>
                                    <% } } %>
                                </select>
                                <p class="form-help">Selecciona de las existentes o crea una nueva al lado →</p>
                            </div>
                            <div>
                                <label class="form-label-custom">Crear etiqueta nueva</label>
                                <div class="input-wrap">
                                    <i data-lucide="tag"></i>
                                    <input type="text" name="tagNuevo" id="tagNuevoInput" class="form-input"
                                           placeholder="Ej. Donaciones, Talleres..."/>
                                </div>
                                <p class="form-help">Si escribes aquí, esta etiqueta tomará prioridad.</p>
                            </div>
                        </div>

                        <div class="form-row-3">
                            <div>
                                <label class="form-label-custom">
                                    Stock inicial<% if (!isEditMode) { %> <span class="required">*</span><% } %>
                                </label>
                                <input type="number" name="stock" min="0" class="form-input"
                                       placeholder="0"
                                       value="<%= isEditMode ? item.getCachedQuantity() : "" %>"
                                        <%= isEditMode ? "readonly title='Usa el panel de entrada para modificar el stock'" : "required" %>/>
                                <% if (isEditMode) { %>
                                <p class="form-help">Se actualiza por entregas y aprobaciones.</p>
                                <% } %>
                            </div>
                            <div>
                                <label class="form-label-custom">Unidad <span class="required">*</span></label>
                                <select name="unidad" class="form-select" required>
                                    <option value="" disabled <%= !isEditMode ? "selected" : "" %>>— Seleccionar —</option>
                                    <option value="unidades" <%= isEditMode && "unidades".equals(item.getUnit()) ? "selected" : "" %>>Unidades</option>
                                    <option value="cajas"    <%= isEditMode && "cajas".equals(item.getUnit())    ? "selected" : "" %>>Cajas</option>
                                    <option value="bolsas"   <%= isEditMode && "bolsas".equals(item.getUnit())   ? "selected" : "" %>>Bolsas</option>
                                    <option value="kits"     <%= isEditMode && "kits".equals(item.getUnit())     ? "selected" : "" %>>Kits</option>
                                    <option value="galones"  <%= isEditMode && "galones".equals(item.getUnit())  ? "selected" : "" %>>Galones</option>
                                    <option value="metros"   <%= isEditMode && "metros".equals(item.getUnit())   ? "selected" : "" %>>Metros</option>
                                    <option value="prendas"  <%= isEditMode && "prendas".equals(item.getUnit())  ? "selected" : "" %>>Prendas</option>
                                    <option value="pares"    <%= isEditMode && "pares".equals(item.getUnit())    ? "selected" : "" %>>Pares</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label-custom">Stock mínimo <span class="required">*</span></label>
                                <input type="number" name="minimo" min="0" class="form-input"
                                       placeholder="0" required
                                       value="<%= isEditMode ? item.getMinQuantity() : "" %>"/>
                                <p class="form-help">Alertará cuando se acerque a este nivel.</p>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label-custom">URL de la imagen</label>
                            <div class="input-wrap">
                                <i data-lucide="image"></i>
                                <input type="text" name="imagen" class="form-input"
                                       placeholder="https://ejemplo.com/imagen.jpg o /uploads/foto.jpg"
                                       value="<%= isEditMode && item.getImageUrl() != null ? item.getImageUrl() : "" %>"/>
                            </div>
                            <p class="form-help">Opcional. Si no agregas una, se usará una imagen genérica.</p>
                        </div>

                        <div class="form-group">
                            <label class="form-label-custom">Descripción</label>
                            <textarea name="descripcion" class="form-textarea"
                                      placeholder="Detalles adicionales sobre el material, marca, color, modelo, uso..."><%= isEditMode && item.getDescription() != null ? item.getDescription() : "" %></textarea>
                            <p class="form-help">Opcional. Ayuda a los solicitantes a identificar mejor el material.</p>
                        </div>

                        <hr class="form-divider"/>

                        <div class="form-actions">
                            <a href="<%= ctx %>/InventoryServlet" class="btn-cancel">
                                <i data-lucide="x"></i>Cancelar
                            </a>
                            <button type="submit" class="btn-submit">
                                <i data-lucide="save"></i><%= btnText %>
                            </button>
                        </div>
                    </form>
                </div>
            </div><%-- /form-card --%>

            <%-- ══ Card: Registrar Entrada de Stock (solo modo edición) ══ --%>
            <% if (isEditMode) { %>
            <div class="form-card" style="margin-top:1.5rem;">
                <div class="form-card-header">
                    <div class="form-card-header-title">
                        <i data-lucide="package-plus"></i>
                        Registrar Entrada de Stock
                    </div>
                </div>
                <div class="form-card-body">
                    <p style="font-size:0.83rem;color:var(--gray-500);margin:0 0 1.25rem;">
                        Añade unidades al inventario. La operación quedará registrada en la bitácora.
                        Stock actual: <strong style="color:var(--purple);"><%= item.getCachedQuantity() %> <%= item.getUnit() %></strong>
                    </p>
                    <form action="<%= ctx %>/AdminItemServlet" method="POST">
                        <input type="hidden" name="action"  value="entrada"/>
                        <input type="hidden" name="itemId"  value="<%= item.getId() %>"/>
                        <div class="form-row">
                            <div>
                                <label class="form-label-custom">Cantidad a ingresar <span class="required">*</span></label>
                                <input type="number" name="cantidad" min="1" class="form-input" placeholder="Ej. 10" required/>
                            </div>
                            <div>
                                <label class="form-label-custom">Motivo / Notas</label>
                                <input type="text" name="notas" class="form-input"
                                       placeholder="Ej. Reposición mensual, donación recibida..."/>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-submit">
                                <i data-lucide="plus-circle"></i>Registrar entrada
                            </button>
                        </div>
                    </form>
                </div>
            </div>
            <% } %>

        </main>

        <jsp:include page="includes/footer.jsp"/>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        if (typeof lucide !== 'undefined') lucide.createIcons();

        const tagSelect = document.getElementById('tagSelect');
        const tagNuevo  = document.getElementById('tagNuevoInput');

        if (tagNuevo && tagSelect) {
            tagNuevo.addEventListener('input', function () {
                if (this.value.trim() !== '') tagSelect.value = '';
            });
            tagSelect.addEventListener('change', function () {
                if (this.value !== '') tagNuevo.value = '';
            });
        }
    });
</script>

</body>
</html>
