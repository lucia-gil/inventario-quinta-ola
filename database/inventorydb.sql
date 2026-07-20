-- ============================================================
-- QUINTA OLA — BD COMPLETA 
-- ============================================================

DROP DATABASE IF EXISTS inventorydb;
CREATE DATABASE inventorydb;
USE inventorydb;

-- ============================================================
-- ROLES (los 5 son fijos, no se borran ni crean nuevos)
-- ============================================================
CREATE TABLE roles (
    id           INT          AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    description  VARCHAR(255),
    is_system    BOOLEAN      DEFAULT FALSE,
    activo       BOOLEAN      DEFAULT TRUE,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (name, description, is_system, activo) VALUES
    ('Viewer',         'Solicitante: crea pedidos de materiales',     TRUE, TRUE),
    ('Member',         'Encargado de depósito: entrega materiales',   TRUE, TRUE),
    ('Manager',        'Aprobador: aprueba o rechaza solicitudes',    TRUE, TRUE),
    ('Administrador',  'Gestión completa de usuarios y materiales',   TRUE, TRUE),
    ('SuperAdmin',     'Control total + auditoría del sistema',       TRUE, TRUE);

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE users (
    id            INT          AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    dni           CHAR(8)      NOT NULL UNIQUE,
    name          VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id       INT          NOT NULL,
    activo        TINYINT(1)   NOT NULL DEFAULT 1,
    avatar_url    VARCHAR(500) DEFAULT NULL,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- ============================================================
-- ITEMS
-- ============================================================
CREATE TABLE items (
    id               INT           AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(255)  NOT NULL,
    description      TEXT,
    image_url        VARCHAR(500),
    unit             VARCHAR(50)   NOT NULL DEFAULT 'unidades',
    cached_quantity  INT           NOT NULL DEFAULT 0,
    min_quantity     INT           NOT NULL DEFAULT 0,
    status           ENUM('OK', 'LOW', 'UNAVAILABLE') NOT NULL DEFAULT 'OK',
    activo           TINYINT(1)    NOT NULL DEFAULT 1,
    created_at       TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TAGS
-- ============================================================
CREATE TABLE tags (
    id         INT          AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    created_by INT,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE item_tags (
    item_id INT,
    tag_id  INT,
    PRIMARY KEY (item_id, tag_id),
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id)  REFERENCES tags(id)  ON DELETE CASCADE
);

-- ============================================================
-- TRANSACTIONS
-- ============================================================
CREATE TABLE transactions (
    id           INT        AUTO_INCREMENT PRIMARY KEY,
    item_id      INT        NOT NULL,
    requester_id INT        NOT NULL,
    approver_id  INT,
    type     ENUM('IN', 'OUT', 'ADJUST') NOT NULL,
    quantity INT                         NOT NULL,
    status ENUM('PENDING', 'WAITING_CHANGES', 'APPROVED', 'REJECTED', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
    notes              TEXT,
    needed_by          DATE       NULL,
    estimated_delivery DATE       NULL,
    created_at         TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    processed_at       TIMESTAMP  NULL,
    delivered_at       TIMESTAMP  NULL,
    FOREIGN KEY (item_id)      REFERENCES items(id),
    FOREIGN KEY (requester_id) REFERENCES users(id),
    FOREIGN KEY (approver_id)  REFERENCES users(id)
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
    id           INT          AUTO_INCREMENT PRIMARY KEY,
    user_id      INT          NOT NULL,
    type         VARCHAR(50)  NOT NULL,
    title        VARCHAR(200) NOT NULL,
    message      TEXT,
    related_id   INT,
    is_read      TINYINT(1)   NOT NULL DEFAULT 0,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
-- PERMISSIONS (catálogo de privilegios disponibles - Sprint 5)
-- ============================================================
CREATE TABLE permissions (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(50)  NOT NULL UNIQUE,
    description VARCHAR(255),
    category    VARCHAR(50)
);

-- ============================================================
-- USER_PERMISSIONS (qué permisos extra tiene cada usuario)
-- ============================================================
CREATE TABLE user_permissions (
    user_id        INT NOT NULL,
    permission_id  INT NOT NULL,
    granted_by     INT NOT NULL,
    granted_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, permission_id),
    FOREIGN KEY (user_id)       REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (granted_by)    REFERENCES users(id)
);

-- ============================================================
-- AUDIT LOG (bitácora inmutable - Sprint 5)
-- ============================================================
CREATE TABLE audit_log (
    id          INT          AUTO_INCREMENT PRIMARY KEY,
    actor_id    INT          NOT NULL,
    action      VARCHAR(50)  NOT NULL,
    entity      VARCHAR(50)  NOT NULL,
    entity_id   INT,
    details     TEXT,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (actor_id) REFERENCES users(id)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_transactions_item       ON transactions(item_id);
CREATE INDEX idx_transactions_requester  ON transactions(requester_id);
CREATE INDEX idx_transactions_status     ON transactions(status);
CREATE INDEX idx_transactions_approver   ON transactions(approver_id);
CREATE INDEX idx_item_tags_tag           ON item_tags(tag_id);
CREATE INDEX idx_users_rol               ON users(role_id);
CREATE INDEX idx_items_activo            ON items(activo);
CREATE INDEX idx_users_activo            ON users(activo);
CREATE INDEX idx_roles_activo            ON roles(activo);
CREATE INDEX idx_notifications_user      ON notifications(user_id);
CREATE INDEX idx_notifications_unread    ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created   ON notifications(created_at);
CREATE INDEX idx_audit_actor             ON audit_log(actor_id);
CREATE INDEX idx_audit_entity            ON audit_log(entity, entity_id);
CREATE INDEX idx_audit_created           ON audit_log(created_at);
CREATE INDEX idx_userperms_user          ON user_permissions(user_id);

-- ============================================================
-- DELIVERY_NOTES — Nota del encargado de depósito al entregar
-- (distinta de "notes", que ya se usa para el propósito original
--  de la solicitud escrito por el solicitante al crearla)
-- ============================================================
ALTER TABLE transactions
    ADD COLUMN delivery_notes TEXT NULL AFTER estimated_delivery;
ALTER TABLE users 
ADD COLUMN require_password_change INT DEFAULT 0;

CREATE TABLE password_reset_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    used INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
