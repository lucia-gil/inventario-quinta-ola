-- ============================================================
-- QUINTA OLA — SCRIPT COMPLETO DE USUARIOS DEMO
-- ============================================================

USE inventorydb;

SET SQL_SAFE_UPDATES = 0;

-- ============================================================
-- LIMPIAR USUARIOS DEMO ANTERIORES
-- ============================================================

DELETE FROM notifications
WHERE user_id LIKE 'user-demo-%';

DELETE FROM users
WHERE id LIKE 'user-demo-%';

-- ============================================================
-- ASEGURAR ROLES DEL SISTEMA
-- ============================================================

INSERT IGNORE INTO roles (id, name, is_system) VALUES
('role-viewer',      'Viewer',         TRUE),
('role-member',      'Member',         TRUE),
('role-manager',     'Manager',        TRUE),
('role-admin',       'Administrador',  TRUE),
('role-superadmin',  'SuperAdmin',     TRUE);

-- ============================================================
-- AGREGAR COLUMNAS NUEVAS A TRANSACTIONS
-- ============================================================

ALTER TABLE transactions
ADD COLUMN needed_by DATE NULL AFTER notes;

ALTER TABLE transactions
ADD COLUMN estimated_delivery DATE NULL AFTER needed_by;

-- ============================================================
-- TABLA NOTIFICATIONS
-- ============================================================

CREATE TABLE IF NOT EXISTS notifications (

    id           CHAR(36)     PRIMARY KEY,
    user_id      CHAR(36)     NOT NULL,

    type         VARCHAR(50)  NOT NULL,

    title        VARCHAR(200) NOT NULL,

    message      TEXT,

    related_id   CHAR(36),

    is_read      TINYINT(1)   NOT NULL DEFAULT 0,

    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX idx_notifications_user
ON notifications(user_id);

CREATE INDEX idx_notifications_unread
ON notifications(user_id, is_read);

CREATE INDEX idx_notifications_created
ON notifications(created_at);

-- ============================================================
-- HASH REAL DE "demo1234"
-- ============================================================

SET @demo_hash =
'$2a$10$XVnKGcN0fEEGnpGU5ateD.jNIjLRb3WkTBX4Uh3d05hgZLXfuUmC.';

-- ============================================================
-- USUARIOS DEMO
-- PASSWORD PARA TODOS: demo1234
-- ============================================================

-- VIEWER / SOLICITANTE
INSERT INTO users (
    id,
    email,
    dni,
    name,
    password_hash,
    role_id,
    activo
)
VALUES (
    'user-demo-viewer',
    'solicitante@quintaola.com',
    '10000001',
    'Lucía Solicitante',
    @demo_hash,
    'role-viewer',
    1
);

-- MEMBER / DEPÓSITO
INSERT INTO users (
    id,
    email,
    dni,
    name,
    password_hash,
    role_id,
    activo
)
VALUES (
    'user-demo-member',
    'deposito@quintaola.com',
    '10000002',
    'Carmen del Depósito',
    @demo_hash,
    'role-member',
    1
);

-- MANAGER / APROBADOR
INSERT INTO users (
    id,
    email,
    dni,
    name,
    password_hash,
    role_id,
    activo
)
VALUES (
    'user-demo-manager',
    'coordinadora@quintaola.com',
    '10000003',
    'María Aprobadora',
    @demo_hash,
    'role-manager',
    1
);

-- ADMIN
INSERT INTO users (
    id,
    email,
    dni,
    name,
    password_hash,
    role_id,
    activo
)
VALUES (
    'user-demo-admin',
    'admin.demo@quintaola.com',
    '10000004',
    'Pedro Administrador',
    @demo_hash,
    'role-admin',
    1
);

-- SUPERADMIN
INSERT INTO users (
    id,
    email,
    dni,
    name,
    password_hash,
    role_id,
    activo
)
VALUES (
    'user-demo-superadmin',
    'superadmin@quintaola.com',
    '10000005',
    'Ana SuperAdmin',
    @demo_hash,
    'role-superadmin',
    1
);

-- ============================================================
-- NOTIFICACIONES DEMO
-- ============================================================

INSERT INTO notifications (
    id,
    user_id,
    type,
    title,
    message,
    is_read
)
VALUES
(
    'notif-demo-1',
    'user-demo-viewer',
    'request_approved',
    'Solicitud aprobada',
    'Tu solicitud de Kit Humanitario Básico fue aprobada.',
    0
),

(
    'notif-demo-2',
    'user-demo-viewer',
    'request_rejected',
    'Solicitud rechazada',
    'Tu solicitud de Cuadernos x100 fue rechazada.',
    0
),

(
    'notif-demo-3',
    'user-demo-manager',
    'new_request',
    'Nueva solicitud pendiente',
    'Lucía Solicitante creó una solicitud.',
    0
),

(
    'notif-demo-4',
    'user-demo-member',
    'ready_for_delivery',
    'Listo para entregar',
    'Hay una solicitud aprobada lista para entrega.',
    0
);

-- ============================================================
-- VERIFICAR
-- ============================================================

SELECT
    email,
    role_id,
    activo
FROM users
WHERE id LIKE 'user-demo-%';

-- ============================================================
-- CREDENCIALES
-- ============================================================

-- Viewer:
-- solicitante@quintaola.com
-- demo1234

-- Member:
-- deposito@quintaola.com
-- demo1234

-- Manager:
-- coordinadora@quintaola.com
-- demo1234

-- Admin:
-- admin.demo@quintaola.com
-- demo1234

-- SuperAdmin:
-- superadmin@quintaola.com
-- demo1234