# Inventario Quinta Ola 📦

Sistema de gestión de inventario para **Quinta Ola** — TEL131 PUCP 2026-1.
Esta aplicación permite controlar, gestionar y optimizar el flujo de materiales desde un solo lugar.

## Estructura del Proyecto

Tras la migración a JSP, el proyecto funciona como un sistema unificado (monolítico):

* **`backend/`** — Lógica del servidor y vistas integradas. Desarrollado con **Java, Maven, Servlets y JSP**. Las vistas y estilos (Tailwind CSS compilado) se encuentran dentro de `src/main/webapp/`.
* **`database/`** — Modelo de la base de datos y scripts de inicialización en MySQL.

## Requisitos Previos

* **Java 17+** (JDK)
* **MySQL 8.0+**
* **Apache Tomcat 10+**
* Un IDE compatible con Java EE (IntelliJ IDEA Ultimate, Eclipse Enterprise o NetBeans)

## Levantar el Proyecto

Dado que las vistas (JSP) ahora están integradas en el backend, solo necesitas levantar un servidor:

1. Clona este repositorio en tu máquina local.
2. Abre la carpeta `backend/` en tu IDE (ej. IntelliJ IDEA, NetBeans o Eclipse).
3. Configura tu servidor **Apache Tomcat (versión 10+)** en el IDE.
4. Ejecuta (Run) el proyecto en el servidor. 
5. El proyecto estará disponible en tu navegador, generalmente en `http://localhost:8080/inventario/`
## Base de Datos y Datos de Prueba

Para inicializar la base de datos con información funcional:

1. Ejecuta primero el script de estructura: `database/inventorydb.sql`
2. Ejecuta después el script de datos iniciales: `database/seed_data.sql`

### 👥 Usuarios de Prueba

Puedes probar los distintos roles del sistema utilizando las siguientes credenciales (la contraseña para todos es `admin123`):

| Rol | Correo / Usuario | Contraseña |
| :--- | :--- | :--- |
| **Viewer** (Solicitante) | `solicitante@quintaola.com` | `demo123` |
| **Member** (Depósito) | `deposito@quintaola.com` | `demo123` |
| **Manager** (Coordinadora)| `coordinadora@quintaola.com` | `demo123` |
| **Admin** | `admin.demo@quintaola.com` | `demo123` |
| **SuperAdmin** | `superadmin@quintaola.com` | `demo123` |
