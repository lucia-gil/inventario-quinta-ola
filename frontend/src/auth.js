/**
 * QUINTA OLA — Módulo central de autenticación y roles
 *
 * USO:
 *   <script src="/src/auth.js"></script>
 *   <script>
 *     Auth.requireLogin();
 *     if (Auth.canApprove()) { ... }
 *     if (Auth.isSuperAdmin()) { ... }
 *   </script>
 *
 * IMPORTANTE: este módulo lee localStorage.userRole con el NOMBRE
 * del rol ('Administrador', 'SuperAdmin', etc.), no IDs string viejos.
 * Eso coincide con lo que ahora devuelve el backend tras la migración INT.
 */

const Auth = (() => {

  /* ============================================================
     CATÁLOGO ÚNICO DE ROLES — claves = nombres reales del backend
  ============================================================ */
  const ROLES = {
    'Viewer': {
      readable: 'Solicitante',
      menuType: 'default',
      landing:  '/pages/home.html',
    },
    'Member': {
      readable: 'Encargado de Depósito',
      menuType: 'default',
      landing:  '/pages/deposit-view.html',
    },
    'Manager': {
      readable: 'Aprobador',
      menuType: 'default',
      landing:  '/pages/dashboard.html',
    },
    'Administrador': {
      readable: 'Administrador',
      menuType: 'admin',
      landing:  '/pages/dashboard.html',
    },
    'SuperAdmin': {
      readable: 'SuperAdmin',
      menuType: 'superadmin',
      landing:  '/pages/superadmin-permissions.html',
    },
  };

  /* ============================================================
     SESIÓN
  ============================================================ */
  function getUserId()   { return localStorage.getItem('userId'); }
  function getUserName() { return localStorage.getItem('userName')  || 'Usuario'; }
  function getUserEmail(){ return localStorage.getItem('userEmail') || ''; }
  function getUserDni()  { return localStorage.getItem('userDni')   || ''; }

  // El backend ahora guarda el NOMBRE del rol en userRole, no IDs viejos
  function getRoleName() { return localStorage.getItem('userRole') || 'Viewer'; }
  // El backend ahora guarda el ID numérico en roleId (string en localStorage)
  function getRoleId()   { return parseInt(localStorage.getItem('roleId')) || 1; }

  function getRoleInfo()     { return ROLES[getRoleName()] || ROLES['Viewer']; }
  function getReadableRole() { return getRoleInfo().readable; }
  function getMenuType()     { return getRoleInfo().menuType; }
  function getLandingPage()  { return getRoleInfo().landing; }

  /* ============================================================
     CHECKS POR ROL
  ============================================================ */
  function is(roleName)  { return getRoleName() === roleName; }
  function isViewer()    { return is('Viewer'); }
  function isMember()    { return is('Member'); }
  function isManager()   { return is('Manager'); }
  function isAdmin()     { return is('Administrador'); }
  function isSuperAdmin(){ return is('SuperAdmin'); }

  /* ============================================================
     CHECKS POR CAPACIDAD — preferible usar estos en la UI
  ============================================================ */
  function canApprove() {
    return ['Manager', 'Administrador', 'SuperAdmin'].includes(getRoleName());
  }
  function canDeliver() {
    return ['Member', 'Administrador', 'SuperAdmin'].includes(getRoleName());
  }
  function canManageItems() {
    return ['Administrador', 'SuperAdmin'].includes(getRoleName());
  }
  function canManageUsers() {
    return ['Administrador', 'SuperAdmin'].includes(getRoleName());
  }
  // Solo SuperAdmin puede gestionar permisos, roles y ver auditoría
  function canManagePermissions() { return isSuperAdmin(); }
  function canManageRoles()       { return isSuperAdmin(); }
  function canViewAudit()         { return isSuperAdmin(); }

  function canCreateRequest() {
    return ['Viewer', 'Manager', 'Administrador'].includes(getRoleName());
  }
  // Notificaciones para todos menos SuperAdmin (lo pide el PDF)
  function canSeeNotifications() {
    return !isSuperAdmin();
  }

  /* ============================================================
     GUARDIAS — bloquean acceso a páginas no permitidas
  ============================================================ */
  function requireLogin() {
    if (!getUserId()) {
      window.location.href = '/pages/show-login.html';
      return false;
    }
    return true;
  }

  function requireRole(allowedRoles) {
    if (!requireLogin()) return false;
    if (!allowedRoles.includes(getRoleName())) {
      window.location.href = '/pages/error-404.html';
      return false;
    }
    return true;
  }

  function requireCapability(capabilityFn) {
    if (!requireLogin()) return false;
    if (!capabilityFn()) {
      window.location.href = '/pages/error-404.html';
      return false;
    }
    return true;
  }

  /* ============================================================
     APLICAR PERMISOS AL DOM AUTOMÁTICAMENTE
     Uso en HTML:
       <button data-requires="canApprove">Aprobar</button>
       <a data-requires-role="Administrador,SuperAdmin">Gestión</a>
       <div data-hidden-for-role="Viewer">No para solicitantes</div>
  ============================================================ */
  function applyDOMPermissions() {
    document.querySelectorAll('[data-requires]').forEach(el => {
      const capName = el.getAttribute('data-requires');
      const capFn   = API[capName];
      if (typeof capFn !== 'function' || !capFn()) {
        el.style.display = 'none';
      }
    });
    document.querySelectorAll('[data-requires-role]').forEach(el => {
      const allowed = el.getAttribute('data-requires-role').split(',').map(s => s.trim());
      if (!allowed.includes(getRoleName())) {
        el.style.display = 'none';
      }
    });
    document.querySelectorAll('[data-hidden-for-role]').forEach(el => {
      const hidden = el.getAttribute('data-hidden-for-role').split(',').map(s => s.trim());
      if (hidden.includes(getRoleName())) {
        el.style.display = 'none';
      }
    });
  }

  /* ============================================================
     NOTIFICACIONES — helpers
  ============================================================ */
  async function fetchNotifications() {
    if (!canSeeNotifications()) return [];
    try {
      const res = await fetch('http://localhost:8080/inventario/api/notifications', {
        credentials: 'include',
      });
      if (!res.ok) return [];
      return await res.json();
    } catch {
      return [];
    }
  }

  async function getUnreadCount() {
    const list = await fetchNotifications();
    return list.filter(n => !n.isRead && !n.is_read).length;
  }

  async function markNotificationRead(id) {
    try {
      await fetch(`http://localhost:8080/inventario/api/notifications/${id}/read`, {
        method: 'PUT',
        credentials: 'include',
      });
    } catch {}
  }

  /* ============================================================
     LOGOUT
  ============================================================ */
  function logout() {
    localStorage.clear();
    fetch('http://localhost:8080/inventario/api/auth/logout', {
      method: 'POST',
      credentials: 'include',
    })
      .catch(() => {})
      .finally(() => window.location.href = '/pages/show-login.html');
  }

  /* ============================================================
     EXPORT
  ============================================================ */
  const API = {
    ROLES,
    // sesión
    getUserId, getUserName, getUserEmail, getUserDni,
    getRoleId, getRoleName, getRoleInfo,
    getReadableRole, getMenuType, getLandingPage,
    // checks por rol
    is, isViewer, isMember, isManager, isAdmin, isSuperAdmin,
    // checks por capacidad
    canApprove, canDeliver, canManageItems, canManageUsers,
    canManagePermissions, canManageRoles, canViewAudit,
    canCreateRequest, canSeeNotifications,
    // guardias
    requireLogin, requireRole, requireCapability,
    // DOM
    applyDOMPermissions,
    // notificaciones
    fetchNotifications, getUnreadCount, markNotificationRead,
    // logout
    logout,
  };
  return API;
})();

document.addEventListener('DOMContentLoaded', () => {
  Auth.applyDOMPermissions();
});