-- HISTORIAL POR ETIQUETA
-- consulta muestra el historial completo de solicitudes relacionando materiales con sus etiquetas.
-- Usa una subconsulta para filtrar solo los materiales que tienen etiquetas asignadas, 
-- y luego hace JOINs para traer el nombre del solicitante, el material y la etiqueta.
-- Es útil para generar reportes por categoría de material.
SELECT 
    t.id AS solicitud_id,
    u.name AS solicitante,
    i.name AS material,
    tg.name AS etiqueta,
    t.quantity AS cantidad,
    t.status AS estado,
    t.created_at AS fecha
FROM transactions t
JOIN users u ON t.requester_id = u.id
JOIN items i ON t.item_id = i.id
LEFT JOIN item_tags it ON i.id = it.item_id
LEFT JOIN tags tg ON it.tag_id = tg.id
WHERE i.id IN (SELECT item_id FROM item_tags)
ORDER BY t.created_at DESC;