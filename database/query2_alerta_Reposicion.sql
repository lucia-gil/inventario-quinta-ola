-- ALERTA DE REPOSICION
-- consulta detecta automáticamente los materiales en riesgo de quedarse sin stock. 
-- Usa una subconsulta para calcular el promedio de stock de todos los items activos, 
-- y luego filtra solo los que estén por debajo de ese promedio.
-- En lugar de revisar item por item, el sistema alerta automáticamente cuáles necesitan reposición.
SELECT 
    id, name,
    cached_quantity AS stock_actual,
    min_quantity AS stock_minimo,
    (SELECT AVG(cached_quantity) FROM items WHERE activo = 1) AS promedio_stock,
    status
FROM items
WHERE activo = 1
AND cached_quantity < (
    SELECT AVG(cached_quantity) FROM items WHERE activo = 1
);