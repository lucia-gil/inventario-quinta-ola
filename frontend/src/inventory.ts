import { renderLayout } from "./layout";

const content = document.getElementById("content").innerHTML

document.getElementById("content").innerHTML = renderLayout(
  "Inventario",
  content,
  "inventory"
);


// type Item = {
//   name: string;
//   category: string;
//   stock: number;
//   minStock: number;
//   unit: string;
// };

// const items: Item[] = [
//   { name: "Cemento", category: "Construcción", stock: 50, minStock: 20, unit: "bolsas" },
//   { name: "Ladrillos", category: "Construcción", stock: 197, minStock: 100, unit: "unidades" },
//   { name: "Pintura Blanca", category: "Acabados", stock: 8, minStock: 15, unit: "galones" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
//   { name: "Tubos PVC", category: "Plomería", stock: 0, minStock: 10, unit: "unidades" },
// ];

// function getStatus(item: Item) {
//   if (item.stock === 0) {
//     return `<span class="px-2 py-1 text-xs rounded bg-red-100 text-red-600">Sin Stock</span>`;
//   }
//   if (item.stock <= item.minStock) {
//     return `<span class="px-2 py-1 text-xs rounded bg-yellow-100 text-yellow-600">Stock Bajo</span>`;
//   }
//   return `<span class="px-2 py-1 text-xs rounded bg-green-100 text-green-600">OK</span>`;
// }

// const tableRows = items.map(item => `
//   <tr class="border-b hover:bg-gray-50">

//     <td class="py-3 px-4 font-medium text-gray-700">
//       ${item.name}
//     </td>

//     <td class="py-3 px-4 text-gray-500">
//       ${item.category}
//     </td>

//     <td class="py-3 px-4">
//       ${item.stock} ${item.unit}
//     </td>

//     <td class="py-3 px-4">
//       ${item.minStock}
//     </td>

//     <td class="py-3 px-4">
//       ${getStatus(item)}
//     </td>

//     <td class="py-3 px-4 flex gap-2">
//       <button class="text-blue-500 hover:underline text-sm">Ver</button>
//       <button class="text-yellow-500 hover:underline text-sm">Editar</button>
//       <button class="text-red-500 hover:underline text-sm">Eliminar</button>
//     </td>

//   </tr>
// `).join("");

// const content = `
//   <div class="flex justify-between items-center mb-4">

//     <div>
//       <h3 class="text-lg font-semibold text-gray-700">Inventario</h3>
//       <p class="text-sm text-gray-400">Gestión de materiales</p>
//     </div>

//     <button class="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600">
//       + Agregar Material
//     </button>

//   </div>

//   <div class="overflow-x-auto">

//     <table class="w-full text-sm">

//       <thead>
//         <tr class="text-left border-b text-gray-500">
//           <th class="py-2 px-4">Nombre</th>
//           <th class="py-2 px-4">Categoría</th>
//           <th class="py-2 px-4">Stock</th>
//           <th class="py-2 px-4">Mínimo</th>
//           <th class="py-2 px-4">Estado</th>
//           <th class="py-2 px-4">Acciones</th>
//         </tr>
//       </thead>

//       <tbody>
//         ${tableRows}
//       </tbody>

//     </table>

//   </div>
// `;

// document.body.innerHTML = renderLayout(
//   "Inventario",
//   content,
//   "inventory"
// );
