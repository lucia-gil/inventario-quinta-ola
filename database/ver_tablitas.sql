USE inventorydb;

-- Ver los 5 roles
SELECT * FROM roles;

-- Ver los 5 usuarios con su rol asociado
SELECT u.id, u.email, u.name, r.name AS rol
FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY u.id;

-- Ver los 10 items
SELECT id, name, cached_quantity, status FROM items;

-- Ver los 7 tags
SELECT * FROM tags;

-- Ver las 5 transacciones
SELECT t.id, i.name AS item, u.name AS solicitante, t.type, t.quantity, t.status
FROM transactions t
JOIN items i ON t.item_id = i.id
JOIN users u ON t.requester_id = u.id;

-- Ver las 4 notificaciones
SELECT n.id, u.name AS para, n.title, n.is_read
FROM notifications n
JOIN users u ON n.user_id = u.id;