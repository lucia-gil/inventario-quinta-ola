/* ============================================================
   QUINTA OLA - auth.js
   ============================================================
   Antes este archivo tenia toda la logica de roles y sesion
   en el navegador (con localStorage). Ya no es asi: ahora
   todo eso vive en el servidor (sesion HTTP + SessionFilter).

   Este archivo se mantiene solo por compatibilidad con vistas
   antiguas que aun lo referencien (a eliminar al cerrar el
   proyecto). NO USAR en JSPs nuevos.

   Lo unico que hacemos aqui es exponer una funcion logout()
   que redirige al AuthServlet con action=logout.
   ============================================================ */

const Auth = {

    // Redirige al AuthServlet para cerrar sesion en el servidor.
    // El servlet invalida la sesion HTTP y manda al login.
    logout: function() {
        window.location.href = '/inventario/AuthServlet?action=logout';
    }
};