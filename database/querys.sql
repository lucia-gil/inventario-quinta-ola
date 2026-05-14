-- =========================================================
-- BASIC INSERTS
-- =========================================================

-- Create role
INSERT INTO roles (
    id,
    name,
    is_system
)
VALUES (
    'role-admin',
    'Admin',
    TRUE
);

-- Create permission
INSERT INTO permissions (
    id,
    `key`,
    description
)
VALUES (
    'perm-approve',
    'transaction.approve',
    'Can approve transactions'
);

-- Assign permission to role
INSERT INTO role_permissions (
    role_id,
    permission_id
)
VALUES (
    'role-admin',
    'perm-approve'
);

-- Create user
INSERT INTO users (
    id,
    email,
    name,
    password_hash,
    role_id
)
VALUES (
    'user-1',
    'admin@example.com',
    'Admin User',
    'hashed_password',
    'role-admin'
);

-- Create item
INSERT INTO items (
    id,
    name,
    cached_quantity,
    status
)
VALUES (
    'item-1',
    'Laptop',
    10,
    'OK'
);

-- Create tag
INSERT INTO tags (
    id,
    name,
    created_by
)
VALUES (
    'tag-1',
    'Electronics',
    'user-1'
);

-- Link tag to item
INSERT INTO item_tags (
    item_id,
    tag_id
)
VALUES (
    'item-1',
    'tag-1'
);

-- Create transaction
INSERT INTO transactions (
    id,
    item_id,
    requester_id,
    type,
    quantity,
    status
)
VALUES (
    'trx-1',
    'item-1',
    'user-1',
    'OUT',
    2,
    'PENDING'
);

-- =========================================================
-- SELECT QUERIES
-- =========================================================

-- Get all items
SELECT * FROM items;

-- Get single item
SELECT * FROM items
WHERE id = 'item-1';

-- Get item tags
SELECT
    items.name,
    tags.name AS tag_name
FROM item_tags
JOIN items
    ON item_tags.item_id = items.id
JOIN tags
    ON item_tags.tag_id = tags.id;

-- Get all transactions for item
SELECT *
FROM transactions
WHERE item_id = 'item-1';

-- Get pending transactions
SELECT *
FROM transactions
WHERE status = 'PENDING';

-- Get transactions created by user
SELECT *
FROM transactions
WHERE requester_id = 'user-1';

-- Get item stock history
SELECT
    type,
    quantity,
    status,
    created_at
FROM transactions
WHERE item_id = 'item-1'
ORDER BY created_at DESC;

-- =========================================================
-- UPDATE QUERIES
-- =========================================================

-- Approve transaction
UPDATE transactions
SET
    status = 'APPROVED',
    approver_id = 'user-1'
WHERE id = 'trx-1';

-- Complete transaction
UPDATE transactions
SET
    status = 'COMPLETED',
    processed_at = CURRENT_TIMESTAMP
WHERE id = 'trx-1';

-- Update item stock manually
UPDATE items
SET cached_quantity = cached_quantity - 2
WHERE id = 'item-1';

-- Update item status
UPDATE items
SET status = 'LOW'
WHERE id = 'item-1';

-- =========================================================
-- DELETE QUERIES
-- =========================================================

-- Remove tag from item
DELETE FROM item_tags
WHERE item_id = 'item-1'
AND tag_id = 'tag-1';

-- Delete transaction
DELETE FROM transactions
WHERE id = 'trx-1';

-- Delete tag
DELETE FROM tags
WHERE id = 'tag-1';

-- =========================================================
-- PERMISSION LOOKUP
-- =========================================================

-- Get all permissions for a user through role
SELECT
    permissions.`key`
FROM users
JOIN roles
    ON users.role_id = roles.id
JOIN role_permissions
    ON roles.id = role_permissions.role_id
JOIN permissions
    ON role_permissions.permission_id = permissions.id
WHERE users.id = 'user-1';

-- Get user overrides
SELECT
    permissions.`key`,
    user_permission_overrides.effect
FROM user_permission_overrides
JOIN permissions
    ON user_permission_overrides.permission_id = permissions.id
WHERE user_permission_overrides.user_id = 'user-1';

-- =========================================================
-- STOCK REBUILD QUERY
-- =========================================================

SELECT
    item_id,
    SUM(
        CASE
            WHEN type = 'IN'  THEN quantity
            WHEN type = 'OUT' THEN -quantity
            ELSE 0
        END
    ) AS real_stock
FROM transactions
WHERE status = 'COMPLETED'
GROUP BY item_id;