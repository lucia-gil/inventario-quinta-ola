-- ============================================================
-- QUINTA OLA — DATOS DEMO
-- Password de todos los usuarios: demo1234
-- ============================================================

USE inventorydb;

-- ============================================================
-- HASH  DE "demo1234"
-- ============================================================
SET @demo_hash = '$2a$10$XVnKGcN0fEEGnpGU5ateD.jNIjLRb3WkTBX4Uh3d05hgZLXfuUmC.';

-- ============================================================
-- USUARIOS DEMO
-- IDs autogenerados: 1=Lucía, 2=Carmen, 3=María, 4=Pedro, 5=Ana
-- ============================================================

-- VIEWER / SOLICITANTE
INSERT INTO users (email, dni, name, password_hash, role_id) VALUES
    ('solicitante@quintaola.com', '10000001', 'Lucía Solicitante',  @demo_hash, 1);

-- MEMBER / DEPÓSITO
INSERT INTO users (email, dni, name, password_hash, role_id) VALUES
    ('deposito@quintaola.com',    '10000002', 'Carmen del Depósito', @demo_hash, 2);

-- MANAGER / APROBADORA
INSERT INTO users (email, dni, name, password_hash, role_id) VALUES
    ('coordinadora@quintaola.com','10000003', 'María Aprobadora',   @demo_hash, 3);

-- ADMINISTRADOR
INSERT INTO users (email, dni, name, password_hash, role_id) VALUES
    ('admin.demo@quintaola.com',  '10000004', 'Pedro Administrador', @demo_hash, 4);

-- SUPERADMIN
INSERT INTO users (email, dni, name, password_hash, role_id) VALUES
    ('superadmin@quintaola.com',  '10000005', 'Ana SuperAdmin',     @demo_hash, 5);

-- ============================================================
-- TAGS DEMO (created_by = 4 → Pedro Administrador)
-- ============================================================
INSERT INTO tags (name, created_by) VALUES
    ('Construcción',  4),
    ('Acabados',      4),
    ('Líquidos',      4),
    ('Plomería',      4),
    ('Humanitario',   4),
    ('Merchandising', 4),
    ('Lúdico',        4);

-- ============================================================
-- ITEMS DEMO (10 materiales variados)
-- ============================================================
INSERT INTO items (name, description, unit, cached_quantity, min_quantity, status) VALUES
    ('Kit Humanitario Grande',    'Kit completo de ayuda humanitaria', 'kits',      30, 10, 'OK'),
    ('Polera Quinta Ola (M)',     'Merchandising oficial talla M',     'unidades',  15, 20, 'LOW'),
    ('Cemento Portland',          'Bolsa 42.5kg',                       'bolsas',    50, 20, 'OK'),
    ('Pintura Látex Blanca',      'Pintura para paredes interior',      'galones',    8, 15, 'LOW'),
    ('Tubos PVC 2"',              'Tubería de desagüe',                 'unidades',   0, 10, 'UNAVAILABLE'),
    ('Ladrillo King Kong',        'Ladrillo macizo construcción',       'unidades', 200, 50, 'OK'),
    ('Juego Didáctico Memoria',   'Material lúdico para talleres',      'unidades',  12,  5, 'OK'),
    ('Donación Ropa Abrigo',      'Ropa de invierno donada',            'prendas',   45, 10, 'OK'),
    ('Cuerda de Utilería',        'Cuerda 10m para talleres',           'unidades',  20,  5, 'OK'),
    ('Cinta Adhesiva Industrial', 'Cinta para utilería',                'unidades',  35, 10, 'OK');

-- ============================================================
-- RELACIÓN ITEM-TAGS
-- ============================================================
INSERT INTO item_tags (item_id, tag_id) VALUES
    (1, 5),           -- Kit Humanitario → Humanitario
    (2, 6),           -- Polera → Merchandising
    (3, 1),           -- Cemento → Construcción
    (4, 2), (4, 3),   -- Pintura → Acabados + Líquidos
    (5, 4),           -- Tubos PVC → Plomería
    (6, 1),           -- Ladrillo → Construcción
    (7, 7),           -- Juego Didáctico → Lúdico
    (8, 5),           -- Ropa → Humanitario
    (9, 7),           -- Cuerda → Lúdico
    (10, 7);          -- Cinta → Lúdico

-- ============================================================
-- TRANSACTIONS DE EJEMPLO
-- requester_id = 1 (Lucía) | approver_id = 3 (María)
-- ============================================================
INSERT INTO transactions (item_id, requester_id, approver_id, type, quantity, status, notes) VALUES
    (1, 1, 3, 'OUT', 5,  'APPROVED',  'Para taller del sábado'),
    (2, 1, 3, 'OUT', 10, 'PENDING',   'Para evento institucional'),
    (3, 1, 3, 'IN',  20, 'COMPLETED', 'Reposición de stock'),
    (4, 1, 3, 'OUT', 3,  'REJECTED',  'Sin stock suficiente'),
    (7, 1, 3, 'OUT', 4,  'PENDING',   'Para taller de niños');

-- ============================================================
-- NOTIFICACIONES DEMO
-- ============================================================
INSERT INTO notifications (user_id, type, title, message, is_read) VALUES
    (1, 'request_approved',  'Solicitud aprobada',
       'Tu solicitud de Kit Humanitario Grande fue aprobada.', 0),
    (1, 'request_rejected',  'Solicitud rechazada',
       'Tu solicitud de Pintura Látex Blanca fue rechazada por falta de stock.', 0),
    (3, 'new_request',       'Nueva solicitud pendiente',
       'Lucía Solicitante creó una nueva solicitud que requiere tu aprobación.', 0),
    (2, 'ready_for_delivery','Listo para entregar',
       'Hay una solicitud aprobada de Kit Humanitario lista para entrega.', 0);

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
SELECT u.id, u.email, u.name, r.name AS role
FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY u.id;

-- ============================================================
-- CREDENCIALES DEMO (todos con password: demo1234)
-- ============================================================
-- Viewer:      solicitante@quintaola.com
-- Member:      deposito@quintaola.com
-- Manager:     coordinadora@quintaola.com
-- Admin:       admin.demo@quintaola.com
-- SuperAdmin:  superadmin@quintaola.com