-- ══════════════════════════════════════════════════════════════
-- 15 usuarios genéricos para probar paginación · Quinta Ola
-- Contraseña de TODOS: Test1234!
-- Roles: 1=Solicitante  2=Enc.Depósito  3=Aprobador
-- ══════════════════════════════════════════════════════════════

INSERT INTO users (email, dni, name, password_hash, role_id, activo) VALUES
  ('carlos.mendoza@quintaola.com',  '12345671', 'Carlos Mendoza',   '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1),
  ('lucia.torres@quintaola.com',    '12345672', 'Lucia Torres',     '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1),
  ('andres.quispe@quintaola.com',   '12345673', 'Andres Quispe',    '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 2, 1),
  ('sofia.ramos@quintaola.com',     '12345674', 'Sofia Ramos',      '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1),
  ('miguel.huanca@quintaola.com',   '12345675', 'Miguel Huanca',    '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 3, 1),
  ('valeria.leon@quintaola.com',    '12345676', 'Valeria Leon',     '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1),
  ('jose.paredes@quintaola.com',    '12345677', 'Jose Paredes',     '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 2, 1),
  ('diana.flores@quintaola.com',    '12345678', 'Diana Flores',     '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1),
  ('roberto.cano@quintaola.com',    '12345679', 'Roberto Cano',     '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 3, 1),
  ('patricia.vega@quintaola.com',   '12345680', 'Patricia Vega',    '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1),
  ('fernando.cruz@quintaola.com',   '12345681', 'Fernando Cruz',    '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 2, 1),
  ('mariela.rojas@quintaola.com',   '12345682', 'Mariela Rojas',    '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1),
  ('christian.diaz@quintaola.com',  '12345683', 'Christian Diaz',   '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1),
  ('natalia.guerra@quintaola.com',  '12345684', 'Natalia Guerra',   '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 3, 1),
  ('jorge.salas@quintaola.com',     '12345685', 'Jorge Salas',      '$2b$10$RWfJn91tDZiPRuK1j6MJpeB3.HLgoNBJnoQ/nF78YKGK3fTONZJGW', 1, 1);

-- ── Verificar inserción ──────────────────────────────────────
SELECT COUNT(*) AS total_usuarios FROM users;
SELECT id, name, role_id, activo FROM users ORDER BY created_at DESC LIMIT 20;