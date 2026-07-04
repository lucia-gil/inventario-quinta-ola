-- ============================================================
-- QUINTA OLA — Script incremental v2
-- Agrega: role-superadmin, columnas para fecha tentativa,
--         tabla de notificaciones, usuarios de prueba por rol
-- ============================================================

USE inventorydb;
SET SQL_SAFE_UPDATES = 0;

-- ============================================================
-- 1. Agregar el rol SuperAdmin si no existe
-- ============================================================
-- INSERT IGNORE INTO roles (id, name, is_system) VALUES
--    ('role-superadmin', 'SuperAdmin', TRUE);

-- ============================================================
-- 2. Columnas nuevas en transactions para fechas tentativas
--    needed_by      = cuándo lo necesita el solicitante
--    estimated_delivery = cuándo estará listo (lo pone el aprobador)
-- ============================================================
ALTER TABLE transactions
    ADD COLUMN IF NOT EXISTS needed_by          DATE NULL AFTER notes,
    ADD COLUMN IF NOT EXISTS estimated_delivery DATE NULL AFTER needed_by;

-- ============================================================
-- 3. Tabla de notificaciones
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    id           CHAR(36)     PRIMARY KEY,
    user_id      CHAR(36)     NOT NULL,
    type         VARCHAR(50)  NOT NULL,    -- 'request_approved', 'request_rejected', 'new_request', 'ready_for_delivery'
    title        VARCHAR(200) NOT NULL,
    message      TEXT,
    related_id   CHAR(36),                  -- ID de la transacción relacionada (opcional)
    is_read      TINYINT(1)   NOT NULL DEFAULT 0,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_notifications_user    ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread  ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at);

-- ============================================================
-- 4. Usuarios de prueba — uno por cada rol
--    Password para TODOS los de prueba: "demo1234"
--    Hash BCrypt correspondiente: $2a$10$wH8QH7n2tHB4QnVnQ3gQGu...
--    (cambia los hashes si tu backend usa otro algoritmo)
-- ============================================================

-- Hash de "demo1234" con BCrypt (lo mismo para todos los de prueba)
SET @demo_hash = '$2a$10$wH8QH7n2tHB4QnVnQ3gQGuYNlCWfFmKaXfYS6vKxkOIxLgZjK3KaG';

-- Solicitante (Viewer)
INSERT IGNORE INTO users (id, email, dni, name, password_hash, role_id, activo)
VALUES ('user-demo-viewer', 'solicitante@quintaola.com', '10000001',
        'Lucía Solicitante', @demo_hash, 'role-viewer', 1);

-- Encargado de Depósito (Member)
INSERT IGNORE INTO users (id, email, dni, name, password_hash, role_id, activo)
VALUES ('user-demo-member', 'deposito@quintaola.com', '10000002',
        'Carmen del Depósito', @demo_hash, 'role-member', 1);

-- Aprobador (Manager) — la coordinadora
INSERT IGNORE INTO users (id, email, dni, name, password_hash, role_id, activo)
VALUES ('user-demo-manager', 'coordinadora@quintaola.com', '10000003',
        'María Aprobadora', @demo_hash, 'role-manager', 1);

-- Administrador
INSERT IGNORE INTO users (id, email, dni, name, password_hash, role_id, activo)
VALUES ('user-demo-admin', 'admin.demo@quintaola.com', '10000004',
        'Pedro Administrador', @demo_hash, 'role-admin', 1);

-- SuperAdmin
INSERT IGNORE INTO users (id, email, dni, name, password_hash, role_id, activo)
VALUES ('user-demo-superadmin', 'superadmin@quintaola.com', '10000005',
        'Ana SuperAdmin', @demo_hash, 'role-superadmin', 1);

-- ============================================================
-- 5. Notificaciones de ejemplo (para que en la demo se vea bonito)
-- ============================================================

-- Para Lucía (viewer): una aprobada y una rechazada
INSERT IGNORE INTO notifications (id, user_id, type, title, message, is_read) VALUES
('notif-demo-1', 'user-demo-viewer', 'request_approved',
 'Solicitud aprobada',
 'Tu solicitud de "Kit Humanitario Básico" fue aprobada. Llegará el viernes.', 0),
('notif-demo-2', 'user-demo-viewer', 'request_rejected',
 'Solicitud rechazada',
 'Tu solicitud de "Cuadernos x100" fue rechazada. Stock insuficiente esta semana.', 0);

-- Para María (manager): hay una nueva solicitud
INSERT IGNORE INTO notifications (id, user_id, type, title, message, is_read) VALUES
('notif-demo-3', 'user-demo-manager', 'new_request',
 'Nueva solicitud pendiente',
 'Lucía Solicitante creó una solicitud de Kit Humanitario para el 25/05.', 0);

-- Para Carmen (depósito): hay algo aprobado listo para entregar
INSERT IGNORE INTO notifications (id, user_id, type, title, message, is_read) VALUES
('notif-demo-4', 'user-demo-member', 'ready_for_delivery',
 'Listo para entregar',
 'Una solicitud aprobada está esperando entrega: Kit Humanitario x2.', 0);

-- ============================================================
-- 6. Verificaciones finales
-- ============================================================
SELECT '=== ROLES ===' AS '';
SELECT id, name FROM roles ORDER BY name;

SELECT '=== USUARIOS POR ROL ===' AS '';
SELECT u.email, u.dni, u.name, r.name AS rol
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.id LIKE 'user-demo-%'
ORDER BY r.name;

SELECT '=== NOTIFICACIONES ===' AS '';
SELECT n.title, u.name AS para, n.is_read
FROM notifications n
JOIN users u ON n.user_id = u.id
ORDER BY n.created_at DESC;

-- ============================================================
-- CREDENCIALES PARA LA DEMO:
--   solicitante@quintaola.com     / demo1234   (Viewer)
--   deposito@quintaola.com        / demo1234   (Member)
--   coordinadora@quintaola.com    / demo1234   (Manager)
--   admin.demo@quintaola.com      / demo1234   (Admin)
--   superadmin@quintaola.com      / demo1234   (SuperAdmin)
-- ============================================================