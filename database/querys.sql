-- =========================
-- INSERTS BASE
-- =========================

-- Crear ítem
INSERT INTO items (id, name, description, unit, cached_quantity, min_quantity, status)
VALUES ('item-1', 'Kit Humanitario Grande', 'Kit de ayuda humanitaria completo', 'kits', 30, 10, 'OK');

-- Crear tag
INSERT INTO tags (id, name, created_by)
VALUES ('tag-1', 'Kits Humanitarios', 'user-1');

-- Asignar tag a ítem
INSERT INTO item_tags (item_id, tag_id)
VALUES ('item-1', 'tag-1');

-- Crear transacción
INSERT INTO transactions (id, item_id, requester_id, type, quantity, status, notes)
VALUES ('trx-1', 'item-1', 'user-1', 'OUT', 2, 'PENDING', 'Para taller del sábado');

-- =========================
-- SELECTS
-- =========================

-- Listar ítems activos (para catálogo y formularios)
SELECT * FROM items WHERE activo = 1;

-- Listar todos los ítems incluyendo inactivos (para admin)
SELECT * FROM items;

-- Detalle de un ítem con sus tags
SELECT
    i.id, i.name, i.description, i.unit,
    i.cached_quantity, i.min_quantity, i.status, i.activo,
    GROUP_CONCAT(t.name SEPARATOR ', ') AS tags
FROM items i
LEFT JOIN item_tags it ON i.id = it.item_id
LEFT JOIN tags t       ON it.tag_id = t.id
WHERE i.id = 'item-1'
GROUP BY i.id;

-- Transacciones pendientes (para el aprobador)
SELECT
    t.id, t.type, t.quantity, t.status, t.notes, t.created_at,
    i.name AS item_name,
    u.name AS requester_name
FROM transactions t
JOIN items i ON t.item_id = i.id
JOIN users u ON t.requester_id = u.id
WHERE t.status = 'PENDING'
ORDER BY t.created_at DESC;

-- Historial completo con filtros
SELECT
    t.id, t.type, t.quantity, t.status, t.notes,
    t.created_at, t.processed_at,
    i.name  AS item_name,
    u.name  AS requester_name,
    a.name  AS approver_name
FROM transactions t
JOIN  items i ON t.item_id      = i.id
JOIN  users u ON t.requester_id = u.id
LEFT JOIN users a ON t.approver_id = a.id
ORDER BY t.created_at DESC;

-- Transacciones de un usuario específico
SELECT
    t.id, t.type, t.quantity, t.status, t.created_at,
    i.name AS item_name
FROM transactions t
JOIN items i ON t.item_id = i.id
WHERE t.requester_id = 'user-1'
ORDER BY t.created_at DESC;

-- Solicitudes aprobadas listas para entregar (para encargado de depósito)
SELECT
    t.id, t.quantity, t.notes, t.created_at,
    i.name AS item_name, i.unit,
    u.name AS requester_name,
    a.name AS approver_name
FROM transactions t
JOIN  items i ON t.item_id      = i.id
JOIN  users u ON t.requester_id = u.id
JOIN  users a ON t.approver_id  = a.id
WHERE t.status = 'APPROVED'
ORDER BY t.created_at ASC;

-- =========================
-- UPDATES
-- =========================

-- Aprobar transacción
UPDATE transactions
SET status = 'APPROVED', approver_id = 'user-1'
WHERE id = 'trx-1';

-- Rechazar transacción
UPDATE transactions
SET status = 'REJECTED', approver_id = 'user-1', notes = 'Sin stock suficiente'
WHERE id = 'trx-1';

-- Marcar como entregada (encargado de depósito)
UPDATE transactions
SET status = 'COMPLETED', processed_at = CURRENT_TIMESTAMP
WHERE id = 'trx-1';

-- Descontar stock al completar una salida
UPDATE items
SET
    cached_quantity = cached_quantity - 2,
    status = CASE
        WHEN cached_quantity - 2 <= 0          THEN 'UNAVAILABLE'
        WHEN cached_quantity - 2 <= min_quantity THEN 'LOW'
        ELSE 'OK'
    END
WHERE id = 'item-1';

-- Sumar stock al completar una entrada
UPDATE items
SET
    cached_quantity = cached_quantity + 2,
    status = CASE
        WHEN cached_quantity + 2 <= 0            THEN 'UNAVAILABLE'
        WHEN cached_quantity + 2 <= min_quantity  THEN 'LOW'
        ELSE 'OK'
    END
WHERE id = 'item-1';

-- Deshabilitar ítem (en lugar de DELETE)
UPDATE items SET activo = 0 WHERE id = 'item-1';

-- Rehabilitar ítem
UPDATE items SET activo = 1 WHERE id = 'item-1';

-- Deshabilitar usuario
UPDATE users SET activo = 0 WHERE id = 'user-1';

-- =========================
-- STOCK REBUILD
-- (recalcular cached_quantity desde cero si hay inconsistencias)
-- =========================

UPDATE items i
JOIN (
    SELECT
        item_id,
        SUM(CASE
            WHEN type = 'IN'  THEN  quantity
            WHEN type = 'OUT' THEN -quantity
            ELSE 0
        END) AS real_stock
    FROM transactions
    WHERE status = 'COMPLETED'
    GROUP BY item_id
) calc ON i.id = calc.item_id
SET i.cached_quantity = calc.real_stock;

-- =========================
-- SUBCONSULTAS AVANZADAS
-- =========================

-- 1. Top solicitante: usuario con más solicitudes
SELECT 
    u.name AS usuario,
    u.email,
    COUNT(t.id) AS total_solicitudes
FROM users u
JOIN transactions t ON u.id = t.requester_id
GROUP BY u.id, u.name, u.email
HAVING COUNT(t.id) = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(id) AS cnt 
        FROM transactions 
        GROUP BY requester_id
    ) AS subconsulta
);

-- 2. Alerta de reposición: materiales con stock menor al promedio
SELECT 
    id,
    name,
    cached_quantity AS stock_actual,
    min_quantity AS stock_minimo,
    (SELECT AVG(cached_quantity) FROM items WHERE activo = 1) AS promedio_stock,
    status
FROM items
WHERE activo = 1
AND cached_quantity < (
    SELECT AVG(cached_quantity) FROM items WHERE activo = 1
)
ORDER BY cached_quantity ASC;

-- 3. Historial detallado: solicitudes de materiales por etiqueta
SELECT 
    t.id AS solicitud_id,
    u.name AS solicitante,
    i.name AS material,
    tg.name AS etiqueta,
    t.quantity AS cantidad,
    t.status AS estado,
    t.created_at AS fecha
FROM transactions t
JOIN users u  ON t.requester_id = u.id
JOIN items i  ON t.item_id = i.id
LEFT JOIN item_tags it ON i.id = it.item_id
LEFT JOIN tags tg      ON it.tag_id = tg.id
WHERE i.id IN (
    SELECT item_id FROM item_tags
)
ORDER BY t.created_at DESC;