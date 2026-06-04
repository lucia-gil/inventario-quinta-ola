<%--
    ════════════════════════════════════════════════════════════════════
     catalog.jsp — Vitrina pública y dinámica de materiales (Corregido)
    ════════════════════════════════════════════════════════════════════
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.quintaola.model.Item" %>
<%
    String ctx = request.getContextPath();
    List<Item> items = (List<Item>) request.getAttribute("items");

    // Capturamos sesión de forma pasiva (sin forzar redirecciones)
    Integer userId = (Integer) session.getAttribute("userId");
    boolean estaLogueado = (userId != null);
%>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Catálogo de Materiales | Quinta Ola</title>
    <link href="<%= ctx %>/css/style.css?v=3" rel="stylesheet" />
    <script src="https://unpkg.com/lucide@latest"></script>
</head>

<body class="bg-background text-textMain font-sans scroll-smooth flex flex-col min-h-screen">

<%-- BARRA DE NAVEGACIÓN PÚBLICA --%>
<nav class="bg-white/90 backdrop-blur-md shadow px-8 py-3 flex justify-between items-center fixed top-0 left-0 w-full z-50">
    <div class="flex items-center">
        <a href="<%= ctx %>/index.jsp" class="transition hover:opacity-90">
            <img src="<%= ctx %>/img/QuintaOlaLogo.png" alt="Quinta Ola" class="h-14 w-auto object-contain" />
        </a>
    </div>

    <div class="flex gap-6 text-sm items-center">
        <a href="<%= ctx %>/CatalogServlet" class="relative text-accent font-medium group">
            Nuestros productos
            <span class="absolute left-0 -bottom-1 w-full h-[2px] bg-accent"></span>
        </a>

        <% if (estaLogueado) { %>
        <a href="<%= ctx %>/DashboardServlet" class="bg-secondary text-white px-5 py-2 rounded-lg font-medium hover:bg-accent transition duration-200 shadow-sm flex items-center gap-2">
            <i data-lucide="layout-dashboard" class="w-4 h-4"></i> Ir al Panel
        </a>
        <% } else { %>
        <a href="<%= ctx %>/AuthServlet?action=formLogin" class="bg-accent text-white px-5 py-2 rounded-lg font-medium hover:bg-secondary transition duration-200 shadow-sm flex items-center gap-2">
            <i data-lucide="log-in" class="w-4 h-4"></i> Inicia sesión
        </a>
        <% } %>
    </div>
</nav>

<%-- CONTENIDO DEL CATÁLOGO --%>
<main class="flex-grow pt-32 pb-16 px-6 max-w-7xl mx-auto w-full">

    <div class="flex flex-col md:flex-row justify-between items-center mb-10 gap-4">
        <div>
            <h1 class="text-3xl font-bold text-secondary">Catálogo de Materiales</h1>
            <p class="text-gray-500 mt-1">Explora en tiempo real los recursos disponibles en los almacenes.</p>
        </div>
        <%-- Buscador estético interactivo mediante JS simple --%>
        <div class="relative w-full md:w-96">
            <i data-lucide="search" class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5"></i>
            <input type="text" id="catalog-search" onkeyup="filtrarCatalogo()" placeholder="Buscar por nombre..." class="w-full pl-10 pr-4 py-2 border border-gray-200 rounded-xl focus:outline-none focus:border-accent focus:ring-1 focus:ring-accent transition-all">
        </div>
    </div>

    <%-- GRILLA DINÁMICA DE PRODUCTOS --%>
    <div id="catalog-grid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">

        <% if (items == null || items.isEmpty()) { %>
        <div class="col-span-full text-center py-16 text-gray-400">
            <i data-lucide="package-x" class="w-12 h-12 mx-auto mb-3 opacity-60"></i>
            <p class="text-lg font-medium">No hay productos registrados en el catálogo actualmente.</p>
        </div>
        <% } else { %>
        <% for (Item item : items) {
            // 🛠️ CORREGIDO: Se cambió item.getStock() por item.getCachedQuantity()
            boolean stockBajo = item.getCachedQuantity() <= item.getMinQuantity();
        %>
        <div class="card-item p-4 border border-gray-100 rounded-2xl shadow-sm bg-white flex flex-col justify-between transition-all hover:shadow-md" data-name="<%= item.getName().toLowerCase() %>">

            <%-- Imagen del producto con fallback estético por si no tiene URL en base de datos --%>
            <div class="w-full h-44 overflow-hidden rounded-xl mb-4 bg-gray-100 relative">
                <img src="<%= (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) ? item.getImageUrl() : "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=500" %>" alt="<%= item.getName() %>" class="w-full h-full object-cover">
                <div class="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent"></div>
            </div>

            <div class="flex-grow">
                <div class="flex items-center justify-between mb-2">
                    <span class="text-[10px] uppercase font-bold tracking-wider text-gray-400">SKU-<%= String.format("%03d", item.getId()) %></span>

                    <% if (stockBajo) { %>
                    <span class="px-2 py-0.5 text-[9px] font-bold rounded-full bg-amber-50 text-amber-600 border border-amber-100">STOCK BAJO</span>
                    <% } else { %>
                    <span class="px-2 py-0.5 text-[9px] font-bold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-100">DISPONIBLE</span>
                    <% } %>
                </div>
                <h3 class="font-semibold text-gray-800 text-base mb-4 item-title"><%= item.getName() %></h3>
            </div>

            <div class="space-y-2 pt-2 border-t border-gray-50">
                <div class="flex justify-between text-xs text-gray-500 mb-2 px-1">
                    <span>Disponibilidad:</span>
                    <%-- 🛠️ CORREGIDO: Se usó getCachedQuantity() para mapear la cantidad real --%>
                    <span class="font-semibold text-gray-700"><%= item.getCachedQuantity() %> <%= item.getUnit() != null ? item.getUnit() : "und" %></span>
                </div>

                <%-- 🛡️ INTERFAZ DE SOLICITUD PROFESIONAL --%>
                <% if (estaLogueado) { %>
                <%-- Usuario autenticado --%>
                <a href="<%= ctx %>/TransactionServlet?action=formCrear" class="block text-center w-full bg-accent text-white hover:bg-secondary text-sm font-semibold py-2.5 rounded-xl transition-all shadow-sm">
                    <i data-lucide="plus" class="w-4 h-4 inline-block -mt-1 mr-1"></i> Solicitar material
                </a>
                <% } else { %>
                <%-- Usuario visitante anónimo --%>
                <a href="<%= ctx %>/AuthServlet?action=formLogin" class="block text-center w-full bg-gray-100 hover:bg-gray-200 text-gray-700 text-sm font-semibold py-2.5 rounded-xl transition-all border border-gray-200">
                    <i data-lucide="lock" class="w-3.5 h-3.5 inline-block -mt-0.5 mr-1 text-gray-400"></i> Iniciar sesión para pedir
                </a>
                <% } %>
            </div>
        </div>
        <% } %> <%-- Closes the for loop --%>
        <% } %> <%-- Closes the else block  --%>

    </div>
</main>

<%-- SCRIPT DE FILTRADO EN TIEMPO REAL --%>
<script>
    function filtrarCatalogo() {
        const query = document.getElementById('catalog-search').value.toLowerCase();
        const cards = document.getElementsByClassName('card-item');

        for (let card of cards) {
            const name = card.getAttribute('data-name');
            if (name.includes(query)) {
                card.style.display = "flex";
            } else {
                card.style.display = "none";
            }
        }
    }

    // Inicializar iconos
    lucide.createIcons();
</script>
</body>
</html>