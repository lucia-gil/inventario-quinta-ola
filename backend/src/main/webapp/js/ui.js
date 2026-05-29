/**
 * QUINTA OLA — UI Utilities
 * ui.js — Incluye este archivo en TODAS las páginas
 *
 * Genera automáticamente:
 * - Navbar (con la página activa resaltada y menú según rol)
 * - Footer
 * - Stat cards del dashboard
 * - Filas de tablas
 * - Badges de estado
 *
 * USO en cada HTML/JSP:
 * <script src="/inventario/js/ui.js"></script>
 * <script>
 * QO.navbar({ active: 'dashboard' });   // ← menuType se deduce solo del userRole
 * QO.footer();
 * </script>
 */

const QO = (() => {

    /* ============================================================
       CONFIGURACIÓN DE RUTAS DE NAVEGACIÓN
       Edita aquí para agregar/quitar páginas del menú
    ============================================================ */
    const NAV_LINKS = [
        { id: 'home',         label: 'Inicio',         href: '/inventario/home' },
        { id: 'dashboard',    label: 'Dashboard',      href: '/inventario/dashboard' },
        { id: 'transactions', label: 'Transacciones',  href: '/inventario/transactions' },
        { id: 'inventory',    label: 'Inventario',     href: '/inventario/inventory' },
        { id: 'history',      label: 'Historial',      href: '/inventario/history' },
    ];

    /* Menú extendido para Admin */
    const NAV_LINKS_ADMIN = [
        ...NAV_LINKS,
        { id: 'members', label: 'Miembros', href: '/inventario/admin-users' },
    ];

    /* Menú extendido para SuperAdmin — incluye CRUD de roles y auditoría */
    const NAV_LINKS_SUPERADMIN = [
        ...NAV_LINKS_ADMIN,
        { id: 'roles',       label: 'Roles (SA)',     href: '/inventario/admin-roles' },
        { id: 'permissions', label: 'Permisos (SA)',  href: '/inventario/superadmin-permissions' },
        { id: 'audit',       label: 'Auditoría (SA)', href: '/inventario/auditoria' },
    ];

    /* ============================================================
       DEDUCIR MENÚ AUTOMÁTICAMENTE DESDE EL ROLE ID (INT)
       IDs: 5=SuperAdmin, 4=Administrador, 3=Manager, 2=Member, 1=Viewer
    ============================================================ */
    function getMenuTypeFromRoleId(roleId) {
        const id = parseInt(roleId, 10);

        if (id === 5) return 'superadmin';
        if (id === 4) return 'admin';
        if (id === 3) return 'manager';
        if (id === 2) return 'member';
        if (id === 1) return 'viewer';

        return 'viewer'; // Fallback de seguridad al rol con menos permisos
    }

    /* ============================================================
       NAVBAR
       Parámetros:
         active  : string — id del link activo (ej. 'dashboard')
         name    : string — nombre del usuario (opcional, se lee de localStorage)
         role    : string — rol del usuario (opcional, se lee de localStorage)
         menuType: 'default' | 'admin' | 'superadmin' (opcional, se deduce del rol)
         logoHref: string  — adónde va el logo al hacer clic
    ============================================================ */
    function navbar({
                        active   = '',
                        name     = null,
                        role     = null, // Para mostrar el texto en pantalla
                        roleId   = null, // NUEVO: Para la lógica estricta del menú
                        menuType = null,
                        logoHref = '/inventario/dashboard',
                    } = {}) {

        // Si no se pasa name/role/roleId, los leemos del localStorage
        if (name === null) name = localStorage.getItem('userName') || 'Usuario';
        if (role === null) role = localStorage.getItem('userRole') || '';
        if (roleId === null) roleId = parseInt(localStorage.getItem('roleId'), 10) || 0;

        // Si no se pasa menuType, lo deducimos estrictamente del ID numérico
        if (menuType === null) menuType = getMenuTypeFromRoleId(roleId);

        const links = menuType === 'superadmin' ? NAV_LINKS_SUPERADMIN
            : menuType === 'admin'      ? NAV_LINKS_ADMIN
                :                             NAV_LINKS;

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
            <img src="/inventario/img/QuintaOlaLogo.png" alt="Quinta Ola Logo" class="navbar-logo" />
          </a>
        </div>
        <div class="navbar-menu">
          ${linksHTML}
          <div class="nav-divider">
            ${userInfo}
            <a href="/inventario/profile" class="nav-avatar" id="nav-profile-btn">
              <i data-lucide="user" class="w-5 h-5"></i>
            </a>

            <button onclick="Auth.logout()" class="text-gray-400 hover:text-red-500 transition-colors ml-2 flex items-center justify-center setup-btn" title="Cerrar Sesión">
              <i data-lucide="log-out" class="w-5 h-5"></i>
            </button>

          </div>
        </div>
      </nav>`;

        document.body.insertAdjacentHTML('afterbegin', html);
        document.body.classList.add('pt-20');
    }

    /* ============================================================
       NAVBAR PÚBLICA (login, catálogo, home público)
    ============================================================ */
    function navbarPublic({ active = '' } = {}) {
        const links = [
            { id: 'home',    label: 'Inicio',    href: '/inventario/index.html' },
            { id: 'catalog', label: 'Catálogo',  href: '/inventario/catalog' },
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
          <a href="/inventario/index.html">
            <img src="/inventario/img/QuintaOlaLogo.png" alt="Quinta Ola" class="navbar-logo" />
          </a>
        </div>
        <div class="flex gap-6 text-sm items-center">
          ${linksHTML}
          <a href="/inventario/cart" class="relative text-gray-700 hover:text-accent transition font-medium flex items-center gap-1">
            <i data-lucide="shopping-cart" class="w-5 h-5"></i>
            <span>Carrito</span>
            <span class="absolute -top-2 -right-3 bg-accent text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full cart-count">0</span>
          </a>
          <a href="/inventario/AuthServlet?action=formLogin"
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
              <img src="/inventario/img/QuintaOlaLogo.png" alt="Quinta Ola Logo" class="h-14 w-auto object-contain" />
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
              <li><a href="/inventario/dashboard" class="footer-link">Dashboard</a></li>
              <li><a href="/inventario/history"   class="footer-link">Historial</a></li>
              <li><a href="/inventario/show-requestform" class="footer-link">Solicitar Material</a></li>
              <li><a href="/inventario/inventory" class="footer-link">Ver Inventario</a></li>
            </ul>
          </div>

          <div class="space-y-4">
            <h4 class="footer-col-title">Mi Cuenta</h4>
            <ul class="space-y-3">
              <li><a href="/inventario/profile" class="footer-link">Configurar Perfil</a></li>
              <li><a href="/inventario/notifications" class="footer-link">Notificaciones</a></li>
              <li>
                <a href="#" onclick="Auth.logout(); return false;" class="hover:text-red-400 transition-colors flex items-center gap-1 mt-6">
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
              <img src="/inventario/img/QuintaOlaLogo.png" alt="Quinta Ola Logo" class="h-14 w-auto object-contain" />
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
              <li><a href="/inventario/index.html"             class="footer-link">Inicio</a></li>
              <li><a href="/inventario/catalog"     class="footer-link">Catálogo</a></li>
              <li><a href="/inventario/AuthServlet?action=formLogin"  class="footer-link">Iniciar sesión</a></li>
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
       STAT CARD
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
       BADGES DE ESTADO
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

    /* roleBadge: soporta los nombres nuevos del backend (Administrador, SuperAdmin, Member, Viewer, Manager)
       y mantiene compatibilidad con los viejos (Admin, etc.) */
    function roleBadge(role) {
        if (!role) return '<span class="role-viewer">—</span>';
        const r = String(role).toLowerCase();

        if (r === 'superadmin') {
            return '<span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-purple-50 text-purple-600 border border-purple-100">SuperAdmin</span>';
        }
        if (r === 'administrador' || r === 'admin') {
            return `<span class="role-admin">${role}</span>`;
        }
        if (r === 'manager' || r === 'aprobador') {
            return `<span class="role-manager">${role}</span>`;
        }
        if (r === 'member' || r === 'encargado de depósito') {
            return `<span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-600 border border-emerald-100">${role}</span>`;
        }
        if (r === 'viewer' || r === 'solicitante') {
            return `<span class="role-viewer">${role}</span>`;
        }
        // Rol personalizado creado por SuperAdmin
        return `<span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-bold bg-pink-50 text-pink-600 border border-pink-100">${role}</span>`;
    }

    /* ============================================================
       USER AVATAR
    ============================================================ */
    function userAvatar(name) {
        if (!name) name = '?';
        const colors = [
            'bg-blue-100 text-blue-600',
            'bg-pink-100 text-pink-600',
            'bg-emerald-100 text-emerald-600',
            'bg-red-100 text-red-600',
            'bg-gray-200 text-gray-600',
            'bg-yellow-100 text-yellow-600',
        ];
        const initials = name.split(' ').map(n => n[0]).slice(0, 2).join('').toUpperCase();
        const color = colors[name.charCodeAt(0) % colors.length];
        return `<div class="user-avatar-sm ${color}">${initials}</div>`;
    }

    /* ============================================================
       TRANSACTION ROWS
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
          <a href="/inventario/request-detail?id=${row.id}" class="text-gray-400 hover:text-accent transition-colors inline-block" title="Ver detalle">
            <i data-lucide="eye" class="w-5 h-5 mx-auto"></i>
          </a>
        </td>
      </tr>`).join('');
        if (window.lucide) lucide.createIcons();
    }

    /* ============================================================
       INVENTORY ROW
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
              onerror="this.src='/inventario/img/placeholder.png'">
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
       CATALOG CARD
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
       PAGINATION
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
       INIT
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
        getMenuTypeFromRoleId,
        init,
    };
})();

// Auto-inicializar lucide al cargar
document.addEventListener('DOMContentLoaded', () => {
    if (window.lucide) lucide.createIcons();
});