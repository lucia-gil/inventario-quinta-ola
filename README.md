# Inventario Quinta Ola

Sistema de gestión de inventario para Quinta Ola — TEL131 PUCP 2026-1

## Estructura
- `frontend/` — Interfaz web (Vite + Tailwind CSS)
- `backend/`  — Servidor Java (Maven + Tomcat + JDBC)
- `database/` — Modelo y scripts de base de datos MySQL

## Requisitos
- Node.js 18+ (frontend)
- Java 17+ (backend)
- MySQL 8.0+
- Apache Tomcat 10+

## Levantar frontend
cd frontend
npm install
npm run dev

## Levantar backend
Abrir carpeta backend/ en IntelliJ IDEA
Configurar Tomcat y correr

## Datos de prueba
Ejecutar `database/data-prueba.sql` después de `database/inventorydb.sql`

Usuarios de prueba:

- Viewer:
solicitante@quintaola.com
admin123

- Member:
deposito@quintaola.com
admin123

- Manager:
oordinadora@quintaola.com
admin123

- Admin:
admin.demo@quintaola.com
admin123

- SuperAdmin:
superadmin@quintaola.com
admin123
