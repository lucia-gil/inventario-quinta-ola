/**
 * QUINTA OLA — UI Utilities
 * ui.js — Incluye este archivo en TODAS las páginas
 *
 * Genera automáticamente:
 *   - Navbar (con la página activa resaltada)
 *   - Footer
 *   - Stat cards del dashboard
 *   - Filas de tablas
 *   - Badges de estado
 *
 * USO en cada HTML:
 *   <script src="/src/ui.js"></script>
 *   <script>
 *     QO.navbar({ active: 'dashboard', role: 'Administrador', name: 'Alvaro Gómez' });
 *     QO.footer();
 *   </script>
 */

const QO = (() => {

  /* ============================================================
     CONFIGURACIÓN DE RUTAS DE NAVEGACIÓN
     Edita aquí para agregar/quitar páginas del menú
  ============================================================ */
  const NAV_LINKS = [
    { id: 'home',         label: 'Inicio',               href: '/pages/home.html' },
    { id: 'dashboard',    label: 'Dashboard',            href: '/pages/dashboard.html' },
    { id: 'transactions', label: 'Transacciones',        href: '/pages/transactions.html' },
    { id: 'inventory',    label: 'Inventario',           href: '/pages/inventory.html' },
    { id: 'history',      label: 'Historial',            href: '/pages/history.html' },
  ];

  /* Menú extendido para Admin */
  const NAV_LINKS_ADMIN = [
    ...NAV_LINKS,
    { id: 'members', label: 'Miembros', href: '/pages/admin-users.html' },
  ];

  /* Menú extendido para SuperAdmin */
  const NAV_LINKS_SUPERADMIN = [
    ...NAV_LINKS_ADMIN,
    { id: 'permissions', label: 'Permisos (SA)', href: '/pages/superadmin-permissions.html' },
  ];

  /* ============================================================
     NAVBAR
     Parámetros:
       active  : string — id del link activo (ej. 'dashboard')
       name    : string — nombre del usuario
       role    : string — rol del usuario
       menuType: 'default' | 'admin' | 'superadmin'
       logoHref: string  — adónde va el logo al hacer clic
  ============================================================ */
  function navbar({
    active   = '',
    name     = 'Usuario',
    role     = '',
    menuType = 'default',
    logoHref = '/pages/dashboard.html',
  } = {}) {
    const links = menuType === 'superadmin' ? NAV_LINKS_SUPERADMIN
                : menuType === 'admin'      ? NAV_LINKS_ADMIN
                :                            NAV_LINKS;

    const linksHTML = links.map(link => {
      const isActive = link.id === active;
      return isActive
        ? `<a href="${link.href}" class="nav-link-active">
             ${link.label}
             <span class="nav-link-active-line"></span>
           </a>`
        : `<a href="${link.href}" class="nav-link group">
             ${link.label}
             <span class="nav-link-line"></span>
           </a>`;
    }).join('');

    const userInfo = role
      ? `<div class="nav-user-info">
           <p class="nav-user-name">${name}</p>
           <p class="nav-user-role">${role}</p>
         </div>`
      : `<span class="text-sm font-medium text-gray-700">Hola, ${name}</span>`;

    const html = `
      <nav class="navbar">
        <div class="flex items-center">
          <a href="${logoHref}">
            <img src="/img/QuintaOlaLogo.png" alt="Quinta Ola Logo" class="navbar-logo" />
          </a>
        </div>
        <div class="navbar-menu">
          ${linksHTML}
          <div class="nav-divider">
            ${userInfo}
            <a href="/pages/profile.html" class="nav-avatar" id="nav-profile-btn">
              <i data-lucide="user" class="w-5 h-5"></i>
            </a>
          </div>
        </div>
      </nav>`;

    // Insertar al inicio del body
    document.body.insertAdjacentHTML('afterbegin', html);
    // Asegurar padding-top para el contenido
    document.body.classList.add('pt-20');
  }

  /* ============================================================
     NAVBAR PÚBLICA (login, catálogo, home público)
     Para páginas sin sesión iniciada
  ============================================================ */
  function navbarPublic({ active = '' } = {}) {
    const links = [
      { id: 'home',    label: 'Inicio',    href: '/index.html' },
      { id: 'catalog', label: 'Catálogo',  href: '/pages/catalog.html' },
    ];

    const linksHTML = links.map(link => {
      const isActive = link.id === active;
      return isActive
        ? `<a href="${link.href}" class="text-accent font-bold transition">${link.label}</a>`
        : `<a href="${link.href}" class="text-gray-500 hover:text-accent transition font-medium">${link.label}</a>`;
    }).join('');

    const html = `
      <nav class="navbar">
        <div class="flex items-center">
          <a href="/index.html">
            <img src="/img/QuintaOlaLogo.png" alt="Quinta Ola" class="navbar-logo" />
          </a>
        </div>
        <div class="flex gap-6 text-sm items-center">
          ${linksHTML}
          <a href="/pages/cart.html" class="relative text-gray-700 hover:text-accent transition font-medium flex items-center gap-1">
            <i data-lucide="shopping-cart" class="w-5 h-5"></i>
            <span>Carrito</span>
            <span class="absolute -top-2 -right-3 bg-accent text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full cart-count">0</span>
          </a>
          <a href="/pages/show-login.html"
            class="bg-accent text-white px-5 py-2 rounded-lg font-medium hover:bg-pink-600 transition duration-200 shadow-sm flex items-center gap-2">
            <i data-lucide="log-in" class="w-4 h-4"></i> Login
          </a>
        </div>
      </nav>`;

    document.body.insertAdjacentHTML('afterbegin', html);
    document.body.classList.add('pt-20');
  }

  /* ============================================================
     FOOTER INTERNO (páginas con sesión)
  ============================================================ */
  function footer({ type = 'internal' } = {}) {
    const html = `
      <footer class="footer">
        <div class="footer-inner">
          <div class="footer-brand">
            <div class="flex items-center">
              <img src="/img/QuintaOlaLogo.png" alt="Quinta Ola Logo" class="h-14 w-auto object-contain" />
            </div>
            <p class="footer-desc">
              Sistema de gestión de inventarios interno. Facilitando el control y acceso de materiales para todos los proyectos de Quinta Ola.
            </p>
            <div class="flex gap-3 pt-2 text-gray-400">
              <a href="#" class="footer-social-btn-pink"><i data-lucide="instagram" class="w-4 h-4"></i></a>
              <a href="#" class="footer-social-btn-green"><i data-lucide="message-circle" class="w-4 h-4"></i></a>
            </div>
          </div>

          <div class="space-y-4">
            <h4 class="footer-col-title">Menú Principal</h4>
            <ul class="space-y-3">
              <li><a href="/pages/dashboard.html" class="footer-link">Dashboard</a></li>
              <li><a href="/pages/history.html"   class="footer-link">Historial</a></li>
              <li><a href="/pages/show-requestform.html" class="footer-link">Solicitar Material</a></li>
              <li><a href="/pages/inventory.html" class="footer-link">Ver Inventario</a></li>
            </ul>
          </div>

          <div class="space-y-4">
            <h4 class="footer-col-title">Mi Cuenta</h4>
            <ul class="space-y-3">
              <li><a href="/pages/profile.html" class="footer-link">Configurar Perfil</a></li>
              <li><a href="#" class="footer-link">Notificaciones</a></li>
              <li>
                <a href="/index.html" class="hover:text-red-400 transition-colors flex items-center gap-1 mt-6">
                  <i data-lucide="log-out" class="w-4 h-4"></i> Cerrar Sesión
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <p>© 2026 Quinta Ola. Todos los derechos reservados.</p>
          <p>Gestión Interna de Inventarios</p>
        </div>
      </footer>`;

    document.body.insertAdjacentHTML('beforeend', html);
  }

  /* ============================================================
     FOOTER PÚBLICO
  ============================================================ */
  function footerPublic() {
    const html = `
      <footer class="footer">
        <div class="footer-inner">
          <div class="footer-brand">
            <div class="flex items-center">
              <img src="/img/QuintaOlaLogo.png" alt="Quinta Ola Logo" class="h-14 w-auto object-contain" />
            </div>
            <p class="footer-desc">
              Innovando la gestión de inventarios con soluciones modernas, intuitivas y escalables para empresas que miran hacia el futuro.
            </p>
            <div class="flex gap-3 pt-2 text-gray-400">
              <a href="#" class="footer-social-btn-pink"><i data-lucide="instagram" class="w-4 h-4"></i></a>
              <a href="#" class="footer-social-btn-green"><i data-lucide="message-circle" class="w-4 h-4"></i></a>
            </div>
          </div>
          <div class="space-y-4">
            <h4 class="footer-col-title">Plataforma</h4>
            <ul class="space-y-3">
              <li><a href="/index.html"             class="footer-link">Inicio</a></li>
              <li><a href="/pages/catalog.html"     class="footer-link">Catálogo</a></li>
              <li><a href="/pages/show-login.html"  class="footer-link">Iniciar sesión</a></li>
            </ul>
          </div>
          <div class="space-y-4">
            <h4 class="footer-col-title">Soporte</h4>
            <ul class="space-y-3">
              <li><a href="#" class="footer-link">Centro de ayuda</a></li>
              <li><a href="#" class="footer-link">Términos de servicio</a></li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <p>© 2026 Quinta Ola. Todos los derechos reservados.</p>
        </div>
      </footer>`;

    document.body.insertAdjacentHTML('beforeend', html);
  }

  /* ============================================================
     STAT CARD — Genera una tarjeta KPI
     Parámetros:
       containerId : id del div donde renderizar
       cards       : array de { label, value, icon, colorClass }
     colorClass opciones: stat-icon-blue | orange | yellow | green | pink | purple

     Ejemplo:
       QO.renderStatCards('stats-container', [
         { label: 'Total Materiales', value: 5,     icon: 'package',        colorClass: 'stat-icon-blue' },
         { label: 'Bajo Stock',       value: 34,    icon: 'alert-triangle',  colorClass: 'stat-icon-orange' },
         { label: 'Pendientes',       value: 3,     icon: 'clock',           colorClass: 'stat-icon-yellow' },
         { label: 'Aprobadas',        value: 1134,  icon: 'check-circle',    colorClass: 'stat-icon-green' },
       ]);
  ============================================================ */
  function renderStatCards(containerId, cards) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = cards.map(c => `
      <div class="stat-card">
        <div>
          <p class="stat-card-label">${c.label}</p>
          <p class="stat-card-value">${c.value.toLocaleString()}</p>
        </div>
        <div class="stat-card-icon ${c.colorClass}">
          <i data-lucide="${c.icon}" class="w-7 h-7"></i>
        </div>
      </div>`).join('');
    if (window.lucide) lucide.createIcons();
  }

  /* ============================================================
     BADGE DE ESTADO — devuelve HTML string del badge correcto
     Uso en JS al crear filas de tabla dinámicamente
  ============================================================ */
  function statusBadge(status) {
    const map = {
      'Aprobada':  '<span class="status-approved">Aprobada</span>',
      'Aprobado':  '<span class="status-approved">Aprobado</span>',
      'Pendiente': '<span class="status-pending">Pendiente</span>',
      'Rechazada': '<span class="status-rejected">Rechazada</span>',
      'Rechazado': '<span class="status-rejected">Rechazado</span>',
      'Entregada': '<span class="status-delivered">Entregada</span>',
    };
    return map[status] || `<span class="status-badge bg-gray-100 text-gray-600">${status}</span>`;
  }

  function typeBadge(type) {
    return type === 'IN'
      ? `<span class="type-in"><i data-lucide="arrow-down-to-line" class="w-3 h-3 mr-1"></i>IN</span>`
      : `<span class="type-out"><i data-lucide="arrow-up-from-line" class="w-3 h-3 mr-1"></i>OUT</span>`;
  }

  function stockBadge(status) {
    const map = {
      'OK':         '<span class="stock-ok">OK</span>',
      'Stock Bajo': '<span class="stock-low">Stock Bajo</span>',
      'Sin Stock':  '<span class="stock-none">Sin Stock</span>',
    };
    return map[status] || `<span class="stock-ok">${status}</span>`;
  }

  function roleBadge(role) {
    const map = {
      'Admin':   '<span class="role-admin">Admin</span>',
      'Manager': '<span class="role-manager">Manager</span>',
      'Viewer':  '<span class="role-viewer">Viewer</span>',
    };
    return map[role] || `<span class="role-viewer">${role}</span>`;
  }

  /* ============================================================
     USER AVATAR — genera el mini avatar de iniciales con color
     Uso: QO.userAvatar('Juan Pérez')
  ============================================================ */
  function userAvatar(name) {
    const colors = [
      'bg-blue-100 text-blue-600',
      'bg-pink-100 text-pink-600',
      'bg-emerald-100 text-emerald-600',
      'bg-red-100 text-red-600',
      'bg-gray-200 text-gray-600',
      'bg-yellow-100 text-yellow-600',
    ];
    const initials = name.split(' ').map(n => n[0]).slice(0, 2).join('');
    const color = colors[name.charCodeAt(0) % colors.length];
    return `<div class="user-avatar-sm ${color}">${initials}</div>`;
  }

  /* ============================================================
     TABLE ROW — genera una fila de transacción completa
     Uso: QO.renderTransactionRows('tbody-id', dataArray)
     dataArray: [{ id, requester, item, qty, type, date, status }]
  ============================================================ */
  function renderTransactionRows(tbodyId, data) {
    const tbody = document.getElementById(tbodyId);
    if (!tbody) return;
    tbody.innerHTML = data.map(row => `
      <tr class="table-row">
        <td class="td-id">${row.id}</td>
        <td class="td">
          <div class="user-cell">
            ${userAvatar(row.requester)}
            <span class="text-gray-600">${row.requester}</span>
          </div>
        </td>
        <td class="td font-medium text-gray-700">${row.item}</td>
        <td class="td-center text-gray-600">${row.qty}</td>
        <td class="td-center">${typeBadge(row.type)}</td>
        <td class="td-light">${row.date}</td>
        <td class="td-center">${statusBadge(row.status)}</td>
        <td class="td-center">
          <a href="/pages/request-detail.html?id=${row.id}" class="text-gray-400 hover:text-accent transition-colors inline-block" title="Ver detalle">
            <i data-lucide="eye" class="w-5 h-5 mx-auto"></i>
          </a>

        </td>
      </tr>`).join('');
    if (window.lucide) lucide.createIcons();
  }

  /* ============================================================
     INVENTORY ROW — genera filas de tabla de inventario
     dataArray: [{ img, name, tags, stock, unit, min, status }]
  ============================================================ */
  function renderInventoryRows(tbodyId, data) {
    const tbody = document.getElementById(tbodyId);
    if (!tbody) return;
    tbody.innerHTML = data.map(item => `
      <tr class="table-row">
        <td class="td">
          <div class="flex items-center gap-3">
            <img src="${item.img}" alt="${item.name}"
              class="w-10 h-10 rounded-lg object-cover border border-gray-100 shadow-sm"
              onerror="this.src='/img/placeholder.png'">
            <span class="font-semibold text-gray-800">${item.name}</span>
          </div>
        </td>
        <td class="td">
          <div class="flex gap-1 flex-wrap">
            ${item.tags.map(t => `<span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-gray-100 text-gray-600 uppercase">${t}</span>`).join('')}
          </div>
        </td>
        <td class="td-muted">${item.stock} ${item.unit}</td>
        <td class="td-muted">${item.min}</td>
        <td class="td">${stockBadge(item.status)}</td>
      </tr>`).join('');
    if (window.lucide) lucide.createIcons();
  }

  /* ============================================================
     CATALOG CARD — genera tarjeta de catálogo
     Uso: QO.renderCatalogCards('grid-id', dataArray)
  ============================================================ */
  function renderCatalogCards(containerId, data) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = data.map(item => `
      <div class="catalog-card">
        <div class="catalog-card-img">
          <img src="${item.img}" alt="${item.name}"
            onerror="this.src='https://via.placeholder.com/400x300?text=Sin+Imagen'">
        </div>
        <div class="catalog-card-body">
          <div class="flex justify-between items-start mb-2">
            <h3 class="catalog-card-title">${item.name}</h3>
            ${stockBadge(item.status === 'low' ? 'Stock Bajo' : 'OK').replace('stock-ok', 'badge badge-success text-[10px] uppercase').replace('stock-low', 'badge badge-warning text-[10px] uppercase')}
          </div>
          <p class="catalog-card-sku">SKU: ${item.sku}</p>
          <button class="catalog-card-btn" data-id="${item.id}" onclick="QO.addToCart && QO.addToCart(${item.id})">
            <i data-lucide="plus" class="w-4 h-4"></i> Añadir
          </button>
        </div>
      </div>`).join('');
    if (window.lucide) lucide.createIcons();
  }

  /* ============================================================
     PAGINATION — genera paginación
     Uso: QO.renderPagination('pag-id', { current, total, onPage })
  ============================================================ */
  function renderPagination(containerId, { current = 1, total = 1, onPage } = {}) {
    const container = document.getElementById(containerId);
    if (!container) return;

    const pages = Array.from({ length: total }, (_, i) => i + 1);
    container.innerHTML = `
      <div class="pagination">
        <button class="${current === 1 ? 'page-btn-disabled' : 'page-btn'}"
          ${current === 1 ? 'disabled' : ''}
          onclick="${onPage ? `(${onPage})(${current - 1})` : ''}">Anterior</button>
        ${pages.map(p => `
          <button class="${p === current ? 'page-btn-active' : 'page-btn'}"
            onclick="${onPage ? `(${onPage})(${p})` : ''}">${p}</button>
        `).join('')}
        <button class="${current === total ? 'page-btn-disabled' : 'page-btn'}"
          ${current === total ? 'disabled' : ''}
          onclick="${onPage ? `(${onPage})(${current + 1})` : ''}">Siguiente</button>
      </div>`;
  }

  /* ============================================================
     INIT — llama lucide.createIcons() después de insertar HTML
  ============================================================ */
  function init() {
    if (window.lucide) lucide.createIcons();
  }

  /* API pública */
  return {
    navbar,
    navbarPublic,
    footer,
    footerPublic,
    renderStatCards,
    renderTransactionRows,
    renderInventoryRows,
    renderCatalogCards,
    renderPagination,
    statusBadge,
    typeBadge,
    stockBadge,
    roleBadge,
    userAvatar,
    init,
  };
})();

// Auto-inicializar lucide al cargar
document.addEventListener('DOMContentLoaded', () => {
  if (window.lucide) lucide.createIcons();
});
