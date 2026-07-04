USE inventorydb;
SET SQL_SAFE_UPDATES = 0;

-- ========================================================
-- NOTA: Primero debes crear las tablas y los ROLES reales, 
-- y LUEGO insertar los usuarios de prueba.
-- ========================================================

-- [Paso 1: Ejecutar la creación de tablas (roles, users, items, etc...)]

-- [Paso 2: Insertar los roles oficiales]
INSERT INTO roles (id, name, is_system) VALUES
    ('role-viewer',      'Viewer',          TRUE),
    ('role-member',      'Member',          TRUE),
    ('role-manager',     'Manager',              TRUE),
    ('role-admin',       'Administrador',        TRUE);

-- [Paso 3: Insertar los Usuarios de prueba usando los IDs de roles reales]
INSERT INTO users (id, email, dni, name, password_hash, role_id, activo) VALUES
('user-admin-1',  'admin@quintaola.com', '12345678', 'Alvaro Gomez',
 '$2a$10$cI75Fn.SIStBgnJfAEny7OSuAvgeHoUTtxTahSUfWrjbzBBz6QHlW', 'role-admin', 1),
('user-lucia-1',  'lucia@quintaola.com', '72345678', 'Lucia Gil',
 '$2a$10$XVnKGcN0fEEGnpGU5ateD.jNIjLRb3WkTBX4Uh3d05hgZLXfuUmC.', 'role-viewer', 1), -- CORREGIDO A role-viewer
('user-carlos-1', 'carlos@quintaola.com','87654321', 'Carlos Ruiz',
 '$2a$10$XVnKGcN0fEEGnpGU5ateD.jNIjLRb3WkTBX4Uh3d05hgZLXfuUmC.', 'role-viewer', 1); -- CORREGIDO A role-viewer
 