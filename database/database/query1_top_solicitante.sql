-- Subconsulta 1 — Top solicitante:
-- identifica al usuario que más solicitudes ha realizado en el 
-- sistema, usa una sunconsulta anidada, primero cuenta las solictudes por usuario
-- luego obtiene el máximo de esos conteos, 
-- y y finalmente filtra solo al usuario que tenga ese máximo

USE inventorydb;
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