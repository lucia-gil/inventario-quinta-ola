/**
 * QUINTA OLA — UI Utilities v2
 * Cambios respecto a v1:
 *   - Catálogo del viewer apunta a inventory.html (es interno)
 *   - Campanita de notificaciones en navbar para todos menos SuperAdmin
 *   - statusBadge y stockBadge aceptan español e inglés
 *   - Bug del link al detalle arreglado (usa fullId si existe)
 */

const QO = (() => {

  /* ============================================================
     MENÚS POR ROL
  ============================================================ */
  const NAV_LINKS_VIEWER = [
    { id: 'home',          label: 'Inicio',           href: '/pages/home.html' },
    { id: 'inventory',     label: 'Catálogo',         href: '/pages/inventory.html' }, // catálogo INTERNO = inventario
    { id: 'transactions',  label: 'Mis Solicitudes',  href: '/pages/transactions.html' },
    { id: 'history',       label: 'Historial',        href: '/pages/history.html' },
  ];

  const NAV_LINKS_MANAGER = [
    { id: 'dashboard',     label: 'Panel Principal',  href: '/pages/dashboard.html' },
    { id: 'transactions',  label: 'Por Aprobar',      href: '/pages/transactions.html' },
    { id: 'inventory',     label: 'Inventario',       href: '/pages/inventory.html' },
    { id: 'history',       label: 'Historial',        href: '/pages/history.html' },
  ];

  const NAV_LINKS_DEPOSIT = [
    { id: 'deposit',       label: 'Por Entregar',     href: '/pages/deposit-view.html' },
    { id: 'inventory',     label: 'Inventario',       href: '/pages/inventory.html' },
    { id: 'transactions',  label: 'Transacciones',    href: '/pages/transactions.html' },
    { id: 'history',       label: 'Historial',        href: '/pages/history.html' },
  ];

  const NAV_LINKS_ADMIN = [
    { id: 'dashboard',     label: 'Panel Principal',  href: '/pages/dashboard.html' },
    { id: 'transactions',  label: 'Solicitudes',      href: '/pages/transactions.html' },
    { id: 'inventory',     label: 'Inventario',       href: '/pages/inventory.html' },
    { id: 'history',       label: 'Historial',        href: '/pages/history.html' },
    { id: 'analytics',     label: 'Análisis',         href: '/pages/analytics.html' },
    { id: 'members',       label: 'Miembros',         href: '/pages/admin-users.html' },
  ];

  const NAV_LINKS_SUPERADMIN = [
    ...NAV_LINKS_ADMIN,
    { id: 'permissions',   label: 'Permisos',         href: '/pages/superadmin-permissions.html' },
    { id: 'auditoria',     label: 'Auditoría',        href: '/pages/auditoria.html' },
  ];

  /* ============================================================
     NAVBAR
  ============================================================ */
  function navbar({
    active   = '',
    name     = 'Usuario',
    role     = '',
    menuType = 'viewer',
    logoHref = null,
  } = {}) {

    const linksByType = {
      viewer:     NAV_LINKS_VIEWER,
      manager:    NAV_LINKS_MANAGER,
      deposit:    NAV_LINKS_DEPOSIT,
      admin:      NAV_LINKS_ADMIN,
      superadmin: NAV_LINKS_SUPERADMIN,
      default:    NAV_LINKS_VIEWER,
    };
    const links = linksByType[menuType] || NAV_LINKS_VIEWER;

    if (!logoHref) logoHref = links[0]?.href || '/index.html';

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

    // CAMPANITA — solo si NO es SuperAdmin (el PDF lo pide explícitamente)
    const showBell = (typeof Auth !== 'undefined' && Auth.canSeeNotifications && Auth.canSeeNotifications());
    const bellHTML = showBell
      ? `<div class="relative" id="notif-bell-wrap">
           <button id="notif-bell" class="nav-avatar relative" title="Notificaciones">
             <i data-lucide="bell" class="w-5 h-5"></i>
             <span id="notif-badge" class="hidden absolute -top-1 -right-1 bg-red-500 text-white text-[10px] font-bold rounded-full min-w-[18px] h-[18px] flex items-center justify-center px-1">0</span>
           </button>
           <div id="notif-dropdown" class="hidden absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-lg border border-gray-100 z-50 max-h-96 overflow-y-auto">
             <div class="p-3 border-b border-gray-100 flex justify-between items-center">
               <h4 class="font-bold text-gray-800 text-sm">Notificaciones</h4>
               <a href="/pages/notifications.html" class="text-xs text-accent hover:underline">Ver todas</a>
             </div>
             <div id="notif-list" class="divide-y divide-gray-50">
               <p class="text-center text-xs text-gray-400 py-6">Cargando...</p>
             </div>
           </div>
         </div>`
      : '';

    const logoutBtn = (typeof Auth !== 'undefined' && Auth.logout)
      ? `<button onclick="Auth.logout()" class="nav-avatar" title="Cerrar sesión">
           <i data-lucide="log-out" class="w-5 h-5"></i>
         </button>`
      : '';

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
            ${bellHTML}
            <a href="/pages/profile.html" class="nav-avatar" id="nav-profile-btn" title="Mi perfil">
              <i data-lucide="user" class="w-5 h-5"></i>
            </a>
            ${logoutBtn}
          </div>
        </div>
      </nav>`;

    document.body.insertAdjacentHTML('afterbegin', html);
    document.body.classList.add('pt-20');

    // Inicializar campanita después de inyectar
    if (showBell) {
      initNotificationBell();
    }
  }

  /* ============================================================
     CAMPANITA — carga el contador y maneja el dropdown
  ============================================================ */
  async function initNotificationBell() {
    const bell     = document.getElementById('notif-bell');
    const dropdown = document.getElementById('notif-dropdown');
    const badge    = document.getElementById('notif-badge');
    const list     = document.getElementById('notif-list');

    if (!bell || !dropdown) return;

    // Toggle del dropdown
    bell.addEventListener('click', (e) => {
      e.stopPropagation();
      dropdown.classList.toggle('hidden');
    });
    // Cerrar al hacer click afuera
    document.addEventListener('click', (e) => {
      if (!document.getElementById('notif-bell-wrap')?.contains(e.target)) {
        dropdown.classList.add('hidden');
      }
    });

    // Cargar notificaciones
    try {
      const notifs = await Auth.fetchNotifications();
      const unread = notifs.filter(n => !n.isRead && !n.is_read);

      // Badge
      if (unread.length > 0) {
        badge.textContent = unread.length > 9 ? '9+' : unread.length;
        badge.classList.remove('hidden');
      }

      // Lista (máximo 5 en el dropdown)
      if (notifs.length === 0) {
        list.innerHTML = `<p class="text-center text-xs text-gray-400 py-6">Sin notificaciones</p>`;
      } else {
        list.innerHTML = notifs.slice(0, 5).map(n => {
          const isUnread = !n.isRead && !n.is_read;
          const icon = {
            'request_approved':   'check-circle',
            'request_rejected':   'x-circle',
            'new_request':        'inbox',
            'ready_for_delivery': 'package',
          }[n.type] || 'bell';
          const color = {
            'request_approved':   'text-green-600 bg-green-50',
            'request_rejected':   'text-red-600 bg-red-50',
            'new_request':        'text-blue-600 bg-blue-50',
            'ready_for_delivery': 'text-amber-600 bg-amber-50',
          }[n.type] || 'text-gray-600 bg-gray-50';

          return `
            <div class="flex gap-3 p-3 hover:bg-gray-50 ${isUnread ? 'bg-blue-50/30' : ''}">
              <div class="w-8 h-8 rounded-full ${color} flex items-center justify-center flex-shrink-0">
                <i data-lucide="${icon}" class="w-4 h-4"></i>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-xs font-bold text-gray-800 truncate">${n.title}</p>
                <p class="text-[11px] text-gray-500 leading-snug">${n.message || ''}</p>
                <p class="text-[10px] text-gray-400 mt-1">${n.createdAt || n.created_at || ''}</p>
              </div>
              ${isUnread ? '<span class="w-2 h-2 rounded-full bg-blue-500 flex-shrink-0 mt-1"></span>' : ''}
            </div>`;
        }).join('');
      }
      if (window.lucide) lucide.createIcons();
    } catch (err) {
      console.warn('No se pudieron cargar notificaciones:', err);
      list.innerHTML = `<p class="text-center text-xs text-gray-400 py-6">No disponibles</p>`;
    }
  }

  /* ============================================================
     NAVBAR PÚBLICA (sin sesión)
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
     FOOTER INTERNO
  ============================================================ */
  function footer() {
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
          </div>
          <div class="space-y-4">
            <h4 class="footer-col-title">Mi Cuenta</h4>
            <ul class="space-y-3">
              <li><a href="/pages/profile.html" class="footer-link">Mi Perfil</a></li>
              <li><a href="/pages/notifications.html" class="footer-link" data-requires="canSeeNotifications">Notificaciones</a></li>
              <li>
                <a href="#" onclick="Auth && Auth.logout && Auth.logout(); return false;" class="hover:text-red-400 transition-colors flex items-center gap-1 mt-6">
                  <i data-lucide="log-out" class="w-4 h-4"></i> Cerrar Sesión
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <p>© 2026 Quinta Ola. Todos los derechos reservados.</p>
        </div>
      </footer>`;
    document.body.insertAdjacentHTML('beforeend', html);
  }

  function footerPublic() {
    const html = `
      <footer class="footer">
        <div class="footer-inner">
          <div class="footer-brand">
            <img src="/img/QuintaOlaLogo.png" alt="Quinta Ola Logo" class="h-14 w-auto object-contain" />
          </div>
        </div>
        <div class="footer-bottom">
          <p>© 2026 Quinta Ola. Todos los derechos reservados.</p>
        </div>
      </footer>`;
    document.body.insertAdjacentHTML('beforeend', html);
  }

  /* ============================================================
     STAT CARD
  ============================================================ */
  function renderStatCards(containerId, cards) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = cards.map(c => `
      <div class="stat-card">
        <div>
          <p class="stat-card-label">${c.label}</p>
          <p class="stat-card-value">${(c.value || 0).toLocaleString()}</p>
        </div>
        <div class="stat-card-icon ${c.colorClass}">
          <i data-lucide="${c.icon}" class="w-7 h-7"></i>
        </div>
      </div>`).join('');
    if (window.lucide) lucide.createIcons();
  }

  /* ============================================================
     BADGES — aceptan español e inglés
  ============================================================ */
  function statusBadge(status) {
    const map = {
      'Aprobada':  '<span class="status-approved">Aprobada</span>',
      'Aprobado':  '<span class="status-approved">Aprobado</span>',
      'Pendiente': '<span class="status-pending">Pendiente</span>',
      'Rechazada': '<span class="status-rejected">Rechazada</span>',
      'Rechazado': '<span class="status-rejected">Rechazado</span>',
      'Entregada': '<span class="status-delivered">Entregada</span>',
      'Completada':'<span class="status-delivered">Entregada</span>',
      'PENDING':   '<span class="status-pending">Pendiente</span>',
      'APPROVED':  '<span class="status-approved">Aprobada</span>',
      'REJECTED':  '<span class="status-rejected">Rechazada</span>',
      'COMPLETED': '<span class="status-delivered">Entregada</span>',
      'WAITING_CHANGES': '<span class="status-pending">Esperando cambios</span>',
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
      'OK':          '<span class="stock-ok">OK</span>',
      'Stock Bajo':  '<span class="stock-low">Stock Bajo</span>',
      'Sin Stock':   '<span class="stock-none">Sin Stock</span>',
      'LOW':         '<span class="stock-low">Stock Bajo</span>',
      'UNAVAILABLE': '<span class="stock-none">Sin Stock</span>',
    };
    return map[status] || `<span class="stock-ok">${status}</span>`;
  }

  function roleBadge(role) {
    const map = {
      'Admin':         '<span class="role-admin">Admin</span>',
      'Administrador': '<span class="role-admin">Administrador</span>',
      'Manager':       '<span class="role-manager">Aprobador</span>',
      'Viewer':        '<span class="role-viewer">Solicitante</span>',
      'Member':        '<span class="role-viewer">Depósito</span>',
      'SuperAdmin':    '<span class="role-admin">SuperAdmin</span>',
    };
    return map[role] || `<span class="role-viewer">${role}</span>`;
  }

  function userAvatar(name) {
    if (!name) name = 'Usuario';
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
     TABLAS — usa fullId si existe (para el link al detalle)
  ============================================================ */
  function renderTransactionRows(tbodyId, data) {
    const tbody = document.getElementById(tbodyId);
    if (!tbody) return;
    tbody.innerHTML = data.map(row => {
      const linkId = row.fullId || row.id;
      return `
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
          <a href="/pages/request-detail.html?id=${linkId}" class="text-gray-400 hover:text-accent transition-colors inline-block" title="Ver detalle">
            <i data-lucide="eye" class="w-5 h-5 mx-auto"></i>
          </a>
        </td>
      </tr>`;
    }).join('');
    if (window.lucide) lucide.createIcons();
  }

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
            ${(item.tags || []).map(t => `<span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-gray-100 text-gray-600 uppercase">${t}</span>`).join('')}
          </div>
        </td>
        <td class="td-muted">${item.stock} ${item.unit || ''}</td>
        <td class="td-muted">${item.min}</td>
        <td class="td">${stockBadge(item.status)}</td>
      </tr>`).join('');
    if (window.lucide) lucide.createIcons();
  }

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

  function init() {
    if (window.lucide) lucide.createIcons();
  }

  return {
    navbar, navbarPublic, footer, footerPublic,
    renderStatCards, renderTransactionRows, renderInventoryRows,
    renderCatalogCards, renderPagination,
    statusBadge, typeBadge, stockBadge, roleBadge, userAvatar, init,
  };
})();

document.addEventListener('DOMContentLoaded', () => {
  if (window.lucide) lucide.createIcons();
});