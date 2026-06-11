-- lista las items para la distibucion tags en el inventario
SELECT t.name, COUNT(i.id) cantidad FROM tags t 
LEFT JOIN item_tags it ON t.id = it.tag_id
LEFT JOIN items i ON it.item_id = i.id
GROUP BY t.id;

-- lista las unidades para la distibucion tags en el inventario
SELECT t.name, SUM(i.cached_quantity) cantidad FROM tags t 
LEFT JOIN item_tags it ON t.id = it.tag_id
LEFT JOIN items i ON it.item_id = i.id
GROUP BY t.id;

-- lista los items para los dias de la semana actual, entrada vs salida
WITH RECURSIVE current_week_days AS (
    -- 1. Start with Monday of the current week
    SELECT 
        DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) AS week_date,
        1 AS day_num
    UNION ALL
    -- 2. Increment by 1 day until we hit Sunday (7 days total)
    SELECT 
        DATE_ADD(week_date, INTERVAL 1 DAY),
        day_num + 1
    FROM current_week_days
    WHERE day_num < 7
)
-- 3. Left join the virtual days calendar to your transactions table
SELECT 
    DAYNAME(cwd.week_date) AS day_of_week,
    COALESCE(COUNT(CASE WHEN t.type = 'IN' THEN 1 END), 0) AS `in`,
    COALESCE(COUNT(CASE WHEN t.type = 'OUT' THEN 1 END), 0) AS `out`
FROM current_week_days cwd
LEFT JOIN transactions t 
    ON DATE(t.created_at) = cwd.week_date
GROUP BY 
    cwd.day_num, 
    cwd.week_date
ORDER BY 
    cwd.day_num;
    
-- lista los items para los dias de la semana actual, cuenta de los estados
WITH RECURSIVE current_week_days AS (
    -- 1. Start with Monday of the current week
    SELECT 
        DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY) AS week_date,
        1 AS day_num
    UNION ALL
    -- 2. Increment by 1 day until we hit Sunday (7 days total)
    SELECT 
        DATE_ADD(week_date, INTERVAL 1 DAY),
        day_num + 1
    FROM current_week_days
    WHERE day_num < 7
)
-- 3. Left join the virtual days calendar to your transactions table
SELECT 
    DAYNAME(cwd.week_date) AS day_of_week,
    COALESCE(COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END), 0) AS `completadas`,
    COALESCE(COUNT(CASE WHEN status = 'PENDING' THEN 1 END), 0) AS `pendientes`,
    COALESCE(COUNT(CASE WHEN status = 'REJECTED' THEN 1 END), 0) AS `rechazadas`
FROM current_week_days cwd
LEFT JOIN transactions t 
    ON DATE(t.created_at) = cwd.week_date
GROUP BY 
    cwd.day_num, 
    cwd.week_date
ORDER BY 
    cwd.day_num;