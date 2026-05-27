-- ============================================================
-- QUINTA OLA — ESQUEMA DE BASE DE DATOS
-- IDs en INT AUTO_INCREMENT
-- ============================================================

DROP DATABASE IF EXISTS inventorydb;
CREATE DATABASE inventorydb;
USE inventorydb;

-- ============================================================
-- ROLES
-- ============================================================
CREATE TABLE roles (
    id           INT          AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    description  VARCHAR(255),
    is_system    BOOLEAN      DEFAULT FALSE,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Roles del sistema (IDs autogenerados: 1=Viewer, 2=Member, 3=Manager, 4=Admin, 5=SuperAdmin)
INSERT INTO roles (name, description, is_system) VALUES
    ('Viewer',         'Solo lectura del catáuserslogo',              TRUE),
    ('Member',         'Solicitante: crea solicitudes',          TRUE),
    ('Manager',        'Aprobador: aprueba o rechaza',           TRUE),
    ('Administrador',  'Administra usuarios y materiales',       TRUE),
    ('SuperAdmin',     'Control total + auditoría',              TRUE);

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

    status ENUM(
        'PENDING',
        'WAITING_CHANGES',
        'APPROVED',
        'REJECTED',
        'COMPLETED'
    ) NOT NULL DEFAULT 'PENDING',

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
CREATE INDEX idx_notifications_user      ON notifications(user_id);
CREATE INDEX idx_notifications_unread    ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created   ON notifications(created_at);