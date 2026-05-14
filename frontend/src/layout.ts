type Page =
  | "dashboard"
  | "inventory"
  | "transactions"
  | "history"
  | "analytics"
  | "admin-requests"
  | "admin-users"
  | "admin-items"
  | "superadmin-permissions"
  | "profile";

export function renderLayout(
  title: string,
  content: string,
  active: Page
): string {

  const navItem = (
    href: string,
    label: string,
    key: Page,
    highlight = false
  ) => {
    const isActive = active === key;

    let base =
      "block px-3 py-2 rounded-lg font-medium transition ";

    if (highlight) {
      base += isActive
        ? "bg-blue-600 text-white"
        : "bg-blue-500 text-white hover:bg-blue-600";
    } else {
      base += isActive
        ? "bg-blue-100 text-blue-600"
        : "text-gray-600 hover:bg-gray-100";
    }

    return `<a href="${href}" class="${base}">${label}</a>`;
  };

  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>${title}</title>
  <link href="/src/style.css" rel="stylesheet" />
</head>

<body class="bg-gray-100 font-sans">

<div class="flex h-screen">

  <!-- SIDEBAR -->
  <aside class="w-64 bg-white border-r border-gray-300 flex flex-col">

    <div class="p-4 border-b border-gray-300">
      <h1 class="text-lg font-bold text-gray-700">Quinta Ola</h1>
      <p class="text-xs text-gray-400">Sistema de Inventario</p>
    </div>

    <nav class="flex-1 overflow-y-auto p-4 space-y-6">

      <!-- GENERAL -->
      <div>
        <p class="text-xs font-semibold text-gray-400 uppercase mb-2">General</p>
        ${navItem("/pages/dashboard.html", "Panel Principal", "dashboard")}
        ${navItem("/pages/inventory.html", "Inventario", "inventory")}
        ${navItem("/pages/transactions.html", "Realizar Transacción", "transactions")}
        ${navItem("/pages/history.html", "Historial", "history")}
        ${navItem("/pages/analytics.html", "Análisis", "analytics")}
      </div>

      <!-- ADMIN -->
      <div>
        <p class="text-xs font-semibold text-gray-400 uppercase mb-2">Admin</p>
        ${navItem("/pages/admin-requests.html", "Solicitudes de Transacción", "admin-requests")}
        ${navItem("/pages/admin-items.html", "Administrar Materiales", "admin-items")}
        ${navItem("/pages/admin-users.html", "Administrar Miembros", "admin-users")}
      </div>

      <!-- SUPERADMIN -->
      <div>
        <p class="text-xs font-semibold text-gray-400 uppercase mb-2">SuperAdmin</p>
        ${navItem("/pages/superadmin-permissions.html", "Manage Privileges", "superadmin-permissions")}
      </div>

    </nav>


  </aside>

  <!-- MAIN -->
  <main class="flex-1 overflow-y-auto">
<nav class="h-14 flex items-center justify-between px-4 bg-white border-b border-gray-200">

  <!-- Left: user -->
  <div class="flex items-center gap-2">
    <a href="/pages/profile.html" class="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center text-white font-semibold">
      U
    </a>
    <span class="text-sm font-medium text-gray-800">User Name</span>
  </div>

  <!-- Right: notifications -->
  <button class="text-gray-600 hover:text-gray-900 p-2 rounded-md">
    🔔
  </button>

</nav>
    <div class="bg-none p-6">
      ${content}
    </div>
  </main>

</div>

</body>
</html>
`;
}