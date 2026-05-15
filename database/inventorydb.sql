-- =========================
-- ROLES
-- =========================

CREATE TABLE roles (
    id           CHAR(36)     PRIMARY KEY,
    name         VARCHAR(100) NOT NULL UNIQUE,
    is_system    BOOLEAN      DEFAULT FALSE,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Roles del sistema
INSERT INTO roles (id, name, is_system) VALUES
    ('role-viewer',      'Viewer',          TRUE),
    ('role-member',      'Member',          TRUE),
    ('role-manager',     'Manager',              TRUE),
    ('role-admin',       'Administrador',        TRUE);

-- =========================
-- USERS
-- =========================

CREATE TABLE users (
    id            CHAR(36)     PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    dni           CHAR(8)      NOT NULL UNIQUE,
    name          VARCHAR(150) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id       CHAR(36),
    activo        TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- =========================
-- ITEMS / TAGS
-- =========================

CREATE TABLE items (
    id               CHAR(36)      PRIMARY KEY,
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

CREATE TABLE tags (
    id         CHAR(36)     PRIMARY KEY,
    name       VARCHAR(100) NOT NULL UNIQUE,
    created_by CHAR(36),

    FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE item_tags (
    item_id CHAR(36),
    tag_id  CHAR(36),

    PRIMARY KEY (item_id, tag_id),

    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id)  REFERENCES tags(id)  ON DELETE CASCADE
);

-- =========================
-- TRANSACTIONS
-- =========================

CREATE TABLE transactions (
    id           CHAR(36)   PRIMARY KEY,
    item_id      CHAR(36)   NOT NULL,
    requester_id CHAR(36)   NOT NULL,
    approver_id  CHAR(36),

    type     ENUM('IN', 'OUT', 'ADJUST') NOT NULL,
    quantity INT                         NOT NULL,

    status ENUM(
        'PENDING',
        'WAITING_CHANGES',
        'APPROVED',
        'REJECTED',
        'COMPLETED'
    ) NOT NULL DEFAULT 'PENDING',

    notes        TEXT,
    created_at   TIMESTAMP  DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    processed_at TIMESTAMP  NULL,

    FOREIGN KEY (item_id)      REFERENCES items(id),
    FOREIGN KEY (requester_id) REFERENCES users(id),
    FOREIGN KEY (approver_id)  REFERENCES users(id)
);

-- =========================
-- INDEXES
-- =========================

CREATE INDEX idx_transactions_item      ON transactions(item_id);
CREATE INDEX idx_transactions_requester ON transactions(requester_id);
CREATE INDEX idx_transactions_status    ON transactions(status);
CREATE INDEX idx_transactions_approver  ON transactions(approver_id);
CREATE INDEX idx_item_tags_tag          ON item_tags(tag_id);
CREATE INDEX idx_users_rol              ON users(role_id);
CREATE INDEX idx_items_activo           ON items(activo);
CREATE INDEX idx_users_activo           ON users(activo);