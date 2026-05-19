/**
 * QUINTA OLA — Módulo central de autenticación y roles *
 * USO:
 *   <script src="/src/auth.js"></script>
 *   <script>
 *     Auth.requireLogin();
 *     if (Auth.canApprove()) { ... }
 *   </script>
 */

const Auth = (() => {

  /* ============================================================
     CATÁLOGO ÚNICO DE ROLES
  ============================================================ */
  const ROLES = {
    'role-viewer': {
      readable: 'Solicitante',
      menuType: 'viewer',
      landing:  '/pages/home.html',
    },
    'role-member': {
      readable: 'Encargado de Depósito',
      menuType: 'deposit',
      landing:  '/pages/deposit-view.html',
    },
    'role-manager': {
      readable: 'Aprobador',
      menuType: 'manager',
      landing:  '/pages/dashboard.html',
    },
    'role-admin': {
      readable: 'Administrador',
      menuType: 'admin',
      landing:  '/pages/dashboard.html',
    },
    'role-superadmin': {
      readable: 'SuperAdmin',
      menuType: 'superadmin',
      landing:  '/pages/dashboard.html',
    },
  };

  /* ============================================================
     SESIÓN
  ============================================================ */
  function getUserId()   { return localStorage.getItem('userId'); }
  function getUserName() { return localStorage.getItem('userName') || 'Usuario'; }
  function getUserEmail(){ return localStorage.getItem('userEmail') || ''; }
  function getUserDni()  { return localStorage.getItem('userDni')  || ''; }
  function getRoleId()   { return localStorage.getItem('userRole') || 'role-viewer'; }

  function getRoleInfo()     { return ROLES[getRoleId()] || ROLES['role-viewer']; }
  function getReadableRole() { return getRoleInfo().readable; }
  function getMenuType()     { return getRoleInfo().menuType; }
  function getLandingPage()  { return getRoleInfo().landing; }

  /* ============================================================
     CHECKS POR ROL
  ============================================================ */
  function is(roleId)    { return getRoleId() === roleId; }
  function isViewer()    { return is('role-viewer'); }
  function isMember()    { return is('role-member'); }
  function isManager()   { return is('role-manager'); }
  function isAdmin()     { return is('role-admin'); }
  function isSuperAdmin(){ return is('role-superadmin'); }

  /* ============================================================
     CHECKS POR CAPACIDAD (preferible usar estos en la UI)
  ============================================================ */
  function canApprove() {
    return ['role-manager', 'role-admin', 'role-superadmin'].includes(getRoleId());
  }
  function canDeliver() {
    return ['role-member', 'role-admin', 'role-superadmin'].includes(getRoleId());
  }
  function canManageItems() {
    return ['role-admin', 'role-superadmin'].includes(getRoleId());
  }
  function canManageUsers() {
    return ['role-admin', 'role-superadmin'].includes(getRoleId());
  }
  function canManagePermissions() {
    return isSuperAdmin();
  }
  function canCreateRequest() {
    return ['role-viewer', 'role-manager', 'role-admin'].includes(getRoleId());
  }
  // Las notificaciones las ve todo el mundo MENOS SuperAdmin (lo pide el PDF)
  function canSeeNotifications() {
    return !isSuperAdmin();
  }

  /* ============================================================
     GUARDIAS
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
    if (!allowedRoles.includes(getRoleId())) {
      window.location.href = '/pages/403.html';
      return false;
    }
    return true;
  }

  function requireCapability(capabilityFn) {
    if (!requireLogin()) return false;
    if (!capabilityFn()) {
      window.location.href = '/pages/403.html';
      return false;
    }
    return true;
  }

  /* ============================================================
     APLICAR PERMISOS AL DOM
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
      if (!allowed.includes(getRoleId())) {
        el.style.display = 'none';
      }
    });
    document.querySelectorAll('[data-hidden-for-role]').forEach(el => {
      const hidden = el.getAttribute('data-hidden-for-role').split(',').map(s => s.trim());
      if (hidden.includes(getRoleId())) {
        el.style.display = 'none';
      }
    });
  }

  /* ============================================================
     NOTIFICACIONES — helpers para la campanita
  ============================================================ */
  async function fetchNotifications() {
    if (!canSeeNotifications()) return [];
    try {
      const res = await fetch('/api/notifications', { credentials: 'include' });
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
      await fetch(`/api/notifications/${id}/read`, {
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
    fetch('/api/auth/logout', { method: 'POST', credentials: 'include' })
      .catch(() => {})
      .finally(() => window.location.href = '/pages/show-login.html');
  }

  /* ============================================================
     EXPORT
  ============================================================ */
  const API = {
    ROLES,
    // sesión
    getUserId, getUserName, getUserEmail, getUserDni, getRoleId,
    getRoleInfo, getReadableRole, getMenuType, getLandingPage,
    // checks por rol
    is, isViewer, isMember, isManager, isAdmin, isSuperAdmin,
    // checks por capacidad
    canApprove, canDeliver, canManageItems, canManageUsers,
    canManagePermissions, canCreateRequest, canSeeNotifications,
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