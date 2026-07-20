USE inventorydb;

-- ═══════════════════════════════════════════════════
-- TAGS nuevas (si ya tienes algunas con el mismo nombre, no se duplican)
-- ═══════════════════════════════════════════════════
INSERT IGNORE INTO tags (name) VALUES
    ('Merchandising'),
    ('Humanitario'),
    ('Difusión'),
    ('Talleres'),
    ('Oficina'),
    ('Salud Menstrual'),
    ('Eventos');

-- ═══════════════════════════════════════════════════
-- ITEMS — Materiales con sentido para Quinta Ola
-- ═══════════════════════════════════════════════════
INSERT INTO items (name, description, unit, cached_quantity, min_quantity, status, activo) VALUES

-- Merchandising / campañas
('Polera Quinta Ola (S)', 'Polera institucional con logo, talla S', 'unidades', 45, 10, 'OK', 1),
('Polera Quinta Ola (M)', 'Polera institucional con logo, talla M', 'unidades', 60, 10, 'OK', 1),
('Polera Quinta Ola (L)', 'Polera institucional con logo, talla L', 'unidades', 40, 10, 'OK', 1),
('Tote Bag "Libres y sin miedo"', 'Bolsa de tela reutilizable con estampado de campaña', 'unidades', 80, 15, 'OK', 1),
('Stickers Quinta Ola (pack x10)', 'Set de stickers con logo y frases feministas', 'packs', 120, 20, 'OK', 1),
('Pines "Voces Activistas"', 'Pines metálicos de la campaña Voces Activistas', 'unidades', 200, 30, 'OK', 1),
('Pañoletas verdes', 'Pañoletas de tela verde, símbolo de la campaña por derechos', 'unidades', 95, 20, 'OK', 1),
('Banderines institucionales', 'Banderines triangulares con logo para eventos', 'unidades', 30, 10, 'OK', 1),

-- Kits humanitarios / donación
('Kit Humanitario Básico', 'Kit con artículos de primera necesidad para entrega comunitaria', 'kits', 25, 8, 'OK', 1),
('Kit Humanitario Grande', 'Kit ampliado con más insumos para familias', 'kits', 15, 5, 'LOW', 1),
('Mochilas escolares', 'Mochilas para donación en programas educativos', 'unidades', 50, 15, 'OK', 1),
('Cuadernos universitarios', 'Cuadernos de 100 hojas para kits educativos', 'unidades', 300, 50, 'OK', 1),
('Útiles escolares (set completo)', 'Set con lápices, borradores, reglas y colores', 'sets', 70, 20, 'OK', 1),

-- Salud menstrual
('Copas menstruales', 'Copas menstruales de silicona médica, talla única', 'unidades', 60, 15, 'OK', 1),
('Toallas sanitarias reutilizables', 'Toallas de tela lavables para kits de salud menstrual', 'unidades', 150, 30, 'OK', 1),
('Kits de higiene menstrual', 'Kit completo con productos de higiene para adolescentes', 'kits', 40, 10, 'OK', 1),

-- Materiales de talleres / difusión
('Folletos informativos "Derechos de las Mujeres"', 'Material impreso a color para talleres comunitarios', 'unidades', 500, 100, 'OK', 1),
('Cartillas educativas "Voces Activistas"', 'Cartillas ilustradas para talleres con adolescentes', 'unidades', 250, 50, 'OK', 1),
('Banner institucional 2x1m', 'Banner impreso con logo para eventos y ferias', 'unidades', 8, 3, 'OK', 1),
('Roll-up institucional', 'Roll-up publicitario portátil con imagen de marca', 'unidades', 5, 2, 'OK', 1),
('Plumones de pizarra (caja x12)', 'Cajas de plumones para dinámicas de talleres', 'cajas', 35, 10, 'OK', 1),
('Papelógrafos', 'Hojas de papel craft grande para talleres participativos', 'unidades', 180, 40, 'OK', 1),

-- Oficina
('Resma de papel bond A4', 'Papel bond blanco 75g, 500 hojas', 'resmas', 90, 20, 'OK', 1),
('Lapiceros institucionales', 'Lapiceros con logo Quinta Ola', 'unidades', 400, 80, 'OK', 1),
('Carpetas manila', 'Carpetas para archivo de documentos', 'unidades', 220, 50, 'OK', 1),
('Cinta adhesiva (pack x6)', 'Cinta transparente de embalaje', 'packs', 45, 10, 'OK', 1),
('Post-it multicolor', 'Notas adhesivas para dinámicas y organización', 'paquetes', 100, 20, 'OK', 1),

-- Eventos
('Vasos biodegradables (pack x50)', 'Vasos ecológicos para eventos y actividades', 'packs', 60, 15, 'OK', 1),
('Manteles institucionales', 'Manteles con logo para mesas de eventos', 'unidades', 12, 4, 'OK', 1),
('Micrófono inalámbrico', 'Micrófono para charlas y presentaciones', 'unidades', 3, 1, 'LOW', 1),
('Extensiones eléctricas', 'Extensiones de 5 metros para eventos', 'unidades', 10, 3, 'OK', 1);


-- Vincular Merchandising
INSERT IGNORE INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE t.name = 'Merchandising'
  AND i.name IN ('Polera Quinta Ola (S)', 'Polera Quinta Ola (M)', 'Polera Quinta Ola (L)',
                 'Tote Bag "Libres y sin miedo"', 'Stickers Quinta Ola (pack x10)',
                 'Pines "Voces Activistas"', 'Pañoletas verdes', 'Banderines institucionales');

-- Vincular Humanitario
INSERT IGNORE INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE t.name = 'Humanitario'
  AND i.name IN ('Kit Humanitario Básico', 'Kit Humanitario Grande', 'Mochilas escolares',
                 'Cuadernos universitarios', 'Útiles escolares (set completo)');

-- Vincular Salud Menstrual
INSERT IGNORE INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE t.name = 'Salud Menstrual'
  AND i.name IN ('Copas menstruales', 'Toallas sanitarias reutilizables', 'Kits de higiene menstrual');

-- Vincular Talleres/Difusión
INSERT IGNORE INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE t.name = 'Difusión'
  AND i.name IN ('Folletos informativos "Derechos de las Mujeres"', 'Cartillas educativas "Voces Activistas"',
                 'Banner institucional 2x1m', 'Roll-up institucional');

INSERT IGNORE INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE t.name = 'Talleres'
  AND i.name IN ('Plumones de pizarra (caja x12)', 'Papelógrafos', 'Cartillas educativas "Voces Activistas"');

-- Vincular Oficina
INSERT IGNORE INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE t.name = 'Oficina'
  AND i.name IN ('Resma de papel bond A4', 'Lapiceros institucionales', 'Carpetas manila',
                 'Cinta adhesiva (pack x6)', 'Post-it multicolor');

-- Vincular Eventos
INSERT IGNORE INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE t.name = 'Eventos'
  AND i.name IN ('Vasos biodegradables (pack x50)', 'Manteles institucionales',
                 'Micrófono inalámbrico', 'Extensiones eléctricas');