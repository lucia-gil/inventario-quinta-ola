-- =========================
-- DATOS DE PRUEBA
-- Ejecutar DESPUÉS de inventorydb.sql
-- =========================

USE inventorydb;
SET SQL_SAFE_UPDATES = 0;

-- Usuarios de prueba
INSERT INTO users (id, email, dni, name, password_hash, role_id, activo) VALUES
('user-admin-1',  'admin@quintaola.com', '12345678', 'Alvaro Gomez',
 '$2a$10$cI75Fn.SIStBgnJfAEny7OSuAvgeHoUTtxTahSUfWrjbzBBz6QHlW', 'role-admin', 1),
('user-lucia-1',  'lucia@quintaola.com', '72345678', 'Lucia Gil',
 '$2a$10$XVnKGcN0fEEGnpGU5ateD.jNIjLRb3WkTBX4Uh3d05hgZLXfuUmC.', 'role-solicitante', 1),
('user-carlos-1', 'carlos@quintaola.com','87654321', 'Carlos Ruiz',
 '$2a$10$XVnKGcN0fEEGnpGU5ateD.jNIjLRb3WkTBX4Uh3d05hgZLXfuUmC.', 'role-solicitante', 1);

-- Items de prueba
INSERT INTO items (id, name, description, image_url, unit, cached_quantity, min_quantity, status, activo) VALUES
('item-1', 'Kit Humanitario Grande',     'Kit de ayuda humanitaria completo',
 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=200',
 'kits', 30, 10, 'OK', 1),
('item-2', 'Kit Lúdico Educativo',       'Juegos y materiales educativos',
 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=200',
 'kits', 15, 5, 'OK', 1),
('item-3', 'Útiles para Talleres',       'Materiales de papelería general',
 'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=200',
 'sets', 25, 10, 'OK', 1),
('item-4', 'Merchandising Institucional','Polos y artículos con logo',
 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200',
 'unidades', 3, 10, 'LOW', 1),
('item-5', 'Polera Quinta Ola',          'Talla M color blanco',
 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200',
 'unidades', 20, 5, 'OK', 1);

SET SQL_SAFE_UPDATES = 1;