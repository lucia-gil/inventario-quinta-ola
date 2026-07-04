USE inventorydb;

-- ============================================================
-- PASSWORD: demo1234
-- ============================================================
SET @demo_hash='$2a$10$zxrp6qqbJSIDwhPFDriat.QA3hm/qYZfK.Zwo8.jdJM1Vtve5MnSq';

-- ============================================================
-- 5 USUARIOS PRINCIPALES
-- ============================================================

INSERT INTO users(email,dni,name,password_hash,role_id,activo) VALUES
('solicitante@quintaola.com','70000001','Lucía Solicitante',@demo_hash,1,1),
('deposito@quintaola.com','70000002','Carlos Depósito',@demo_hash,2,1),
('coordinadora@quintaola.com','70000003','María Coordinadora',@demo_hash,3,1),
('admin.demo@quintaola.com','70000004','Pedro Administrador',@demo_hash,4,1),
('superadmin@quintaola.com','70000005','Ana SuperAdmin',@demo_hash,5,1);

-- ============================================================
-- VIEWERS EXTRA
-- ============================================================

INSERT INTO users(email,dni,name,password_hash,role_id,activo) VALUES
('viewer01@quintaola.com','71000001','Andrea Flores',@demo_hash,1,1),
('viewer02@quintaola.com','71000002','José Ramos',@demo_hash,1,1),
('viewer03@quintaola.com','71000003','Camila Torres',@demo_hash,1,1),
('viewer04@quintaola.com','71000004','Luis Medina',@demo_hash,1,1),
('viewer05@quintaola.com','71000005','Valeria Castro',@demo_hash,1,1),
('viewer06@quintaola.com','71000006','Miguel Rojas',@demo_hash,1,1),
('viewer07@quintaola.com','71000007','Daniela León',@demo_hash,1,1),
('viewer08@quintaola.com','71000008','Fernando Ruiz',@demo_hash,1,1),
('viewer09@quintaola.com','71000009','Paola Salas',@demo_hash,1,1),
('viewer10@quintaola.com','71000010','Kevin Vargas',@demo_hash,1,1);

-- ============================================================
-- MEMBERS
-- ============================================================

INSERT INTO users(email,dni,name,password_hash,role_id,activo) VALUES
('member01@quintaola.com','72000001','Diego Pérez',@demo_hash,2,1),
('member02@quintaola.com','72000002','Melissa Díaz',@demo_hash,2,1),
('member03@quintaola.com','72000003','Juan Silva',@demo_hash,2,1),
('member04@quintaola.com','72000004','Rosa Campos',@demo_hash,2,1),
('member05@quintaola.com','72000005','Renzo Navarro',@demo_hash,2,1),
('member06@quintaola.com','72000006','Claudia Vera',@demo_hash,2,1),
('member07@quintaola.com','72000007','Pedro Salazar',@demo_hash,2,1),
('member08@quintaola.com','72000008','Brenda Núñez',@demo_hash,2,1),
('member09@quintaola.com','72000009','Jorge Soto',@demo_hash,2,1),
('member10@quintaola.com','72000010','Sandra Mena',@demo_hash,2,1);

-- ============================================================
-- MANAGERS
-- ============================================================

INSERT INTO users(email,dni,name,password_hash,role_id,activo) VALUES
('manager01@quintaola.com','73000001','Patricia Guerra',@demo_hash,3,1),
('manager02@quintaola.com','73000002','Cristian Peña',@demo_hash,3,1),
('manager03@quintaola.com','73000003','Tatiana Ortiz',@demo_hash,3,1),
('manager04@quintaola.com','73000004','Marco Hidalgo',@demo_hash,3,1),
('manager05@quintaola.com','73000005','Karen Paredes',@demo_hash,3,1),
('manager06@quintaola.com','73000006','Víctor Ponce',@demo_hash,3,1),
('manager07@quintaola.com','73000007','Silvia Bravo',@demo_hash,3,1),
('manager08@quintaola.com','73000008','Ricardo Lozano',@demo_hash,3,1),
('manager09@quintaola.com','73000009','Mónica Espinoza',@demo_hash,3,1),
('manager10@quintaola.com','73000010','Javier Aguilar',@demo_hash,3,1);

-- ============================================================
-- ADMINISTRADORES
-- ============================================================

INSERT INTO users(email,dni,name,password_hash,role_id,activo) VALUES
('admin01@quintaola.com','74000001','Andrea Núñez',@demo_hash,4,1),
('admin02@quintaola.com','74000002','José Linares',@demo_hash,4,1),
('admin03@quintaola.com','74000003','Carolina Vega',@demo_hash,4,1),
('admin04@quintaola.com','74000004','Luis Cárdenas',@demo_hash,4,1),
('admin05@quintaola.com','74000005','Paola Chávez',@demo_hash,4,1),
('admin06@quintaola.com','74000006','Kevin Montes',@demo_hash,4,1),
('admin07@quintaola.com','74000007','Roxana Alva',@demo_hash,4,1),
('admin08@quintaola.com','74000008','Marco Ríos',@demo_hash,4,1),
('admin09@quintaola.com','74000009','Lucero Pineda',@demo_hash,4,1),
('admin10@quintaola.com','74000010','César Valencia',@demo_hash,4,1);

-- ============================================================
-- SUPER ADMINS
-- ============================================================

INSERT INTO users(email,dni,name,password_hash,role_id,activo) VALUES
('super01@quintaola.com','75000001','Eduardo Mora',@demo_hash,5,1),
('super02@quintaola.com','75000002','Diana Fuentes',@demo_hash,5,1),
('super03@quintaola.com','75000003','Luis Herrera',@demo_hash,5,1),
('super04@quintaola.com','75000004','Marisol Rojas',@demo_hash,5,1),
('super05@quintaola.com','75000005','Jhon Castillo',@demo_hash,5,1),
('super06@quintaola.com','75000006','Rosa Delgado',@demo_hash,5,1),
('super07@quintaola.com','75000007','Javier Soto',@demo_hash,5,1),
('super08@quintaola.com','75000008','Pamela Vargas',@demo_hash,5,1),
('super09@quintaola.com','75000009','Hugo Pacheco',@demo_hash,5,1),
('super10@quintaola.com','75000010','Carla Espino',@demo_hash,5,1);

-- ============================================================
-- TAGS
-- ============================================================

INSERT INTO tags(name,created_by) VALUES
('Construcción',4),
('Herramientas',4),
('Limpieza',4),
('Educación',4),
('Humanitario',4),
('Seguridad',4),
('Oficina',4),
('Electricidad',4),
('Plomería',4),
('Merchandising',4);

-- ============================================================
-- ITEMS
-- ============================================================

SET @img='https://i.pinimg.com/originals/20/b8/88/20b888c0fecfee544c9e2bcbd3e0a157.jpg?nii=t';

INSERT INTO items(name,description,image_url,unit,cached_quantity,min_quantity,status) VALUES
('Cemento Portland','Bolsa de cemento',@img,'bolsas',120,20,'OK'),
('Ladrillo King Kong','Ladrillo de construcción',@img,'unidades',600,100,'OK'),
('Arena Fina','Arena para mezcla',@img,'sacos',80,15,'OK'),
('Pintura Blanca','Pintura látex',@img,'galones',30,10,'LOW'),
('Rodillo de Pintura','Rodillo profesional',@img,'unidades',40,10,'OK'),
('Brocha 4 pulgadas','Brocha industrial',@img,'unidades',35,10,'OK'),
('Martillo','Martillo acero',@img,'unidades',20,5,'OK'),
('Taladro','Taladro eléctrico',@img,'unidades',10,2,'OK'),
('Casco de Seguridad','Casco amarillo',@img,'unidades',50,15,'OK'),
('Guantes de Trabajo','Guantes industriales',@img,'pares',100,20,'OK'),
('Botiquín','Botiquín primeros auxilios',@img,'kits',15,5,'LOW'),
('Kit Humanitario','Kit ayuda humanitaria',@img,'kits',60,10,'OK'),
('Mochila Escolar','Mochila para donación',@img,'unidades',70,20,'OK'),
('Cuaderno A4','Cuaderno universitario',@img,'unidades',200,40,'OK'),
('Lapiceros','Caja lapiceros',@img,'cajas',80,20,'OK'),
('Resmas A4','Papel bond',@img,'paquetes',100,20,'OK'),
('Silla Plástica','Silla blanca',@img,'unidades',40,5,'OK'),
('Mesa Plegable','Mesa portátil',@img,'unidades',15,3,'OK'),
('Extensión Eléctrica','Cable extensión',@img,'unidades',25,5,'OK'),
('Foco LED','Foco ahorro energía',@img,'unidades',90,15,'OK'),
('Tubo PVC','Tubo sanitario',@img,'unidades',60,15,'OK'),
('Llave Inglesa','Herramienta',@img,'unidades',18,5,'OK'),
('Escoba','Escoba industrial',@img,'unidades',30,10,'OK'),
('Detergente','Limpieza general',@img,'botellas',40,10,'OK'),
('Polo Quinta Ola','Merchandising oficial',@img,'unidades',50,10,'OK');

-- ============================================================
-- TAGS DE CADA ITEM
-- ============================================================

INSERT INTO item_tags VALUES
(1,1),
(2,1),
(3,1),
(4,1),
(5,2),
(6,2),
(7,2),
(8,8),
(9,6),
(10,6),
(11,5),
(12,5),
(13,4),
(14,4),
(15,4),
(16,7),
(17,7),
(18,7),
(19,8),
(20,8),
(21,9),
(22,2),
(23,3),
(24,3),
(25,10);

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

SELECT COUNT(*) AS usuarios FROM users;
SELECT COUNT(*) AS materiales FROM items;
SELECT COUNT(*) AS etiquetas FROM tags;