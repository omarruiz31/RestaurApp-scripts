/*Entidades independientes
Restaurantex, sucursalx, rol, area_impresion
descuento, promocion, area_cocina, metodo_pago**/

INSERT INTO restaurante (nombre, rfc)
VALUES
  ('La Picadita Jarocha', 'QRC1306209S0');

INSERT INTO sucursal (restaurante_id, nombre, direccion, region, telefono)
VALUES
  --Mina
  (1, 'Soriana Cuauhtemoc', 'Plaza Soriana Col. Cuauhtemoc', 'Minatitlan', '9222239947'),
  (1, 'Centro Mina', 'José Arenas N° 14, Col. Centro', 'Minatitlan', '9222237340'),
  (1, 'Instituto Tecnologico', 'Instituto Tecnológico 1055 Col. Luis Echeverría Álvarez', 'Minatitlan', '9222417821'),
  --Coatza
  (1, 'Centro', 'Av. Hidalgo N° 600, Esq. Allende, Col. Centro', 'Coatazacoalcos', '9212121386'),
  (1, 'Soriana Palmar', 'Av. Las palmas N° 101 Int. Loc. 17, Col. Paraíso', 'Coatazacoalcos', '9212121386'),--CENTRO Y PALMAS TIENE EL MISMO NUM
  (1, 'Soriana Mercado', 'Blvd. Juan Osorio Lopez N. 100 Int. Loc. 2, 3 y 4, Col. Héroes de Nacozari', 'Coatazacoalcos', '9212173716'),
  (1, 'Malecon', 'Malecón 2407, Petroquimica', 'Coatazacoalcos', '9212137072'),
  (1, 'Gaviotas', 'Avenida Jirafas No. 137-A esquina Ceiba Col. Gaviotas', 'Coatazacoalcos', '9216882551');
/*
Auxiliar administrativo
Mesero/a
Encargado de servicio de atención al cliente
Auditor
Auxiliar de RR. HH.
Auxiliar de mantenimiento
Gerente de sucursal
Cocinero
Ayudante de cocina
Cajero*/ 

INSERT INTO rol (nombre, descripcion) 
  VALUES
  ('Auxiliar administrativo', 'Apoyo en tareas administrativas'),
  ('Mesero', 'Atención en mesas'),
  ('Encargado de servicio al cliente', 'Atención al cliente'),
  ('Auditor', 'Revisión de procesos'),
  ('Auxiliar de RRHH', 'Apoyo en recursos humanos'),
  ('Auxiliar de mantenimiento', 'Mantenimiento general'),
  ('Gerente de sucursal', 'Supervisor de la sucursal'),
  ('Cocinero', 'Preparación de alimentos'),
  ('Ayudante de cocina', 'Apoyo en cocina'),
  ('Cajero', 'Cobro y facturación');

  INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, estado, contraseña)
VALUES
    -- Sucursal 1: Soriana Cuauhtémoc (Mina)
    (1, 7, 'María',   'Gómez',      TRUE, 'pass123'),  -- Gerente de sucursal
    (1, 2, 'Luis',    'Cruz',       TRUE, 'pass123'),  -- Mesero
    (1, 2, 'Ana',     'Martínez',   TRUE, 'pass123'),  -- Mesera
    (1, 2, 'Carlos',  'Ramírez',    TRUE, 'pass123'),  -- Mesero
    (1, 8, 'Pedro',   'López',      TRUE, 'pass123'),  -- Cocinero
    (1, 9, 'Daniel',  'Hernández',  TRUE, 'pass123'),  -- Ayudante de cocina
    (1,10, 'Carla',   'Reyes',      TRUE, 'pass123'),  -- Cajera
    (1, 1, 'Jorge',   'Pérez',      TRUE, 'pass123'),  -- Auxiliar administrativo
    (1, 5, 'Laura',   'Hernández',  TRUE, 'pass123'),  -- Auxiliar de RRHH
    (1, 6, 'Miguel',  'Vargas',     TRUE, 'pass123'),  -- Auxiliar de mantenimiento
    (1, 4, 'Sofía',   'Rangel',     TRUE, 'pass123'),  -- Auditor

    -- Sucursal 2: Centro Mina
    (2, 7, 'Ricardo', 'Navarro',    TRUE, 'pass123'),  -- Gerente
    (2, 2, 'Elena',   'Castillo',   TRUE, 'pass123'),  -- Mesera
    (2, 2, 'Diego',   'Santos',     TRUE, 'pass123'),  -- Mesero
    (2, 8, 'Hugo',    'Mendoza',    TRUE, 'pass123'),  -- Cocinero
    (2, 9, 'Brenda',  'Ortiz',      TRUE, 'pass123'),  -- Ayudante
    (2,10, 'Nadia',   'Flores',     TRUE, 'pass123'),  -- Cajera
    (2, 6, 'Óscar',   'Luna',       TRUE, 'pass123'),  -- Mantenimiento

    -- Sucursal 3: Instituto Tecnológico (Mina)
    (3, 7, 'Patricia','Rivera',     TRUE, 'pass123'),  -- Gerente
    (3, 2, 'Iván',    'Torres',     TRUE, 'pass123'),  -- Mesero
    (3, 2, 'Fabiola', 'Juárez',     TRUE, 'pass123'),  -- Mesera
    (3, 8, 'Marco',   'Aguilar',    TRUE, 'pass123'),  -- Cocinero
    (3, 9, 'Cintia',  'Salas',      TRUE, 'pass123'),  -- Ayudante
    (3,10, 'Raúl',    'Pacheco',    TRUE, 'pass123'),  -- Cajero

    -- Sucursal 4: Centro (Coatza) - sucursal central
    (4, 7, 'Alejandro','Domínguez', TRUE, 'pass123'),  -- Gerente
    (4, 2, 'Karla',   'Mora',       TRUE, 'pass123'),  -- Mesera
    (4, 2, 'Sergio',  'Ibarra',     TRUE, 'pass123'),  -- Mesero
    (4, 2, 'Yazmín',  'Salazar',    TRUE, 'pass123'),  -- Mesera
    (4, 8, 'Noé',     'Cortés',     TRUE, 'pass123'),  -- Cocinero
    (4, 9, 'Liliana', 'Rosales',    TRUE, 'pass123'),  -- Ayudante
    (4,10, 'Eric',    'Velázquez',  TRUE, 'pass123'),  -- Cajero
    (4, 1, 'Claudia', 'Mejía',      TRUE, 'pass123'),  -- Auxiliar administrativo
    (4, 5, 'Adriana', 'Pineda',     TRUE, 'pass123'),  -- Auxiliar RRHH
    (4, 6, 'Tomás',   'Galindo',    TRUE, 'pass123'),  -- Mantenimiento

    -- Sucursal 5: Soriana Palmar
    (5, 7, 'Fernando','Zamora',     TRUE, 'pass123'),  -- Gerente
    (5, 2, 'Rocío',   'Campos',     TRUE, 'pass123'),  -- Mesera
    (5, 2, 'Julio',   'Peña',       TRUE, 'pass123'),  -- Mesero
    (5, 8, 'Gabriel', 'Solís',      TRUE, 'pass123'),  -- Cocinero
    (5, 9, 'Paola',   'Delgado',    TRUE, 'pass123'),  -- Ayudante
    (5,10, 'Inés',    'Bernal',     TRUE, 'pass123'),  -- Cajera

    -- Sucursal 6: Soriana Mercado
    (6, 7, 'Héctor',  'Castañeda',  TRUE, 'pass123'),  -- Gerente
    (6, 2, 'Nancy',   'Quiroz',     TRUE, 'pass123'),  -- Mesera
    (6, 2, 'Omar',    'Lagos',      TRUE, 'pass123'),  -- Mesero
    (6, 8, 'Ulises',  'Carrillo',   TRUE, 'pass123'),  -- Cocinero
    (6, 9, 'Rebeca',  'Fierro',     TRUE, 'pass123'),  -- Ayudante
    (6,10, 'Diana',   'Acosta',     TRUE, 'pass123'),  -- Cajera

    -- Sucursal 7: Malecón
    (7, 7, 'Ramón',   'Arriaga',    TRUE, 'pass123'),  -- Gerente
    (7, 2, 'Mónica',  'García',     TRUE, 'pass123'),  -- Mesera
    (7, 2, 'Javier',  'Franco',     TRUE, 'pass123'),  -- Mesero
    (7, 8, 'Israel',  'Nieto',      TRUE, 'pass123'),  -- Cocinero
    (7, 9, 'Paty',    'Corona',     TRUE, 'pass123'),  -- Ayudante
    (7,10, 'Bruno',   'Silva',      TRUE, 'pass123'),  -- Cajero

    -- Sucursal 8: Gaviotas
    (8, 7, 'Esteban', 'Méndez',     TRUE, 'pass123'),  -- Gerente
    (8, 2, 'Luz',     'Arellano',   TRUE, 'pass123'),  -- Mesera
    (8, 2, 'Carlos',  'Mora',       TRUE, 'pass123'),  -- Mesero
    (8, 8, 'Iván',    'Cano',       TRUE, 'pass123'),  -- Cocinero
    (8, 9, 'Marisol', 'León',       TRUE, 'pass123'),  -- Ayudante
    (8,10, 'Pablo',   'Esquivel',   TRUE, 'pass123');  -- Cajero


INSERT INTO area_impresion (nombre, ip, tipo_impresora, estado)
VALUES
  ('Cocina', '192.168.1.10', 'Térmica 80mm', 'activo'),
  ('Bebidas', '192.168.1.11', 'Térmica 58mm', 'activo'),
  ('Caja', '192.168.1.12', 'Térmica 80mm', 'activo');



INSERT INTO dispositivo (area_impresion_id, tipo, estado, modelo)
VALUES
-- Impresoras principales
(1, 'Impresora térmica', 'activo', 'Epson TM-T20II Cocina'),
(2, 'Impresora térmica', 'activo', 'Star Micronics 58mm Bebidas'),
(3, 'Impresora térmica', 'activo', 'Epson TM-T20II Caja'),

-- Equipos de trabajo
(3, 'Terminal de Caja', 'activo', 'HP ProDesk 400 G5'),
(1, 'Tablet de Mesero', 'activo', 'Samsung Galaxy Tab A'),
(1, 'Tablet de Mesero', 'activo', 'Lenovo Tab M8');

--Método pago
INSERT INTO metodo_pago (nombre, es_efectivo, referencia)
VALUES
('Efectivo', TRUE, 'Pago en moneda nacional'),
('Tarjeta de crédito', FALSE, 'Visa, Mastercard'),
('Tarjeta de débito', FALSE, 'Visa, Mastercard'),
('Transferencia bancaria', FALSE, 'SPEI'),
('Pago con vales', FALSE, 'Vales de despensa / restaurante'),
('Pago mixto', FALSE, 'Combina efectivo y tarjeta');



--Descuentos

-- 1) UNIVERSIDAD VERACRUZANA (UV)
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('UV - 10% en efectivo', 'PORCENTAJE', 10, NULL, 'Universidad Veracruzana', NULL, TRUE),
('UV - 5% con tarjeta',  'PORCENTAJE',  5, NULL, 'Universidad Veracruzana', NULL, TRUE);


-- 2) TARJETAS AFILIADAS (SAMS / CANACO / Caja Popular / Diario del Istmo)
-- 10% monedero pagando en efectivo
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Tarjetas Afiliadas - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL,
 'SAMS / CANACO / Caja Popular / Diario del Istmo', 10, TRUE);

-- 5% monedero pagando con tarjeta
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Tarjetas Afiliadas - 5% monedero (tarjeta)', 'MONEDERO', NULL, NULL,
 'SAMS / CANACO / Caja Popular / Diario del Istmo', 5, TRUE);
-- ITESCO
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('ITESCO - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'ITESCO', 10, TRUE),
('ITESCO - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'ITESCO',  5, TRUE);

-- Al Super / La Mexicana (ajusta el nombre si quieres)
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Al Super Mexicana - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Al Super Mexicana', 10, TRUE),
('Al Super Mexicana - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Al Super Mexicana',  5, TRUE);

-- Etileno XXI
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Etileno XXI - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Etileno XXI', 10, TRUE),
('Etileno XXI - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Etileno XXI',  5, TRUE);

-- CROM
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('CROM - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'CROM', 10, TRUE),
('CROM - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'CROM',  5, TRUE);

-- Grúas Villarreal
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Grúas Villarreal - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Grúas Villarreal', 10, TRUE),
('Grúas Villarreal - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Grúas Villarreal',  5, TRUE);

-- AMA
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('AMA - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'AMA', 10, TRUE),
('AMA - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'AMA',  5, TRUE);

-- Club Deportivo
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Club Deportivo - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Club Deportivo', 10, TRUE),
('Club Deportivo - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Club Deportivo',  5, TRUE);

-- Pro Agroindustria
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Pro Agroindustria - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Pro Agroindustria', 10, TRUE),
('Pro Agroindustria - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Pro Agroindustria',  5, TRUE);

-- Banamex
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Banamex - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Banamex', 10, TRUE),
('Banamex - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Banamex',  5, TRUE);

-- Servifácil
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Servifácil - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Servifácil', 10, TRUE),
('Servifácil - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Servifácil',  5, TRUE);

-- Renault
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Renault - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Renault', 10, TRUE),
('Renault - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Renault',  5, TRUE);

-- Praxair
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Praxair - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Praxair', 10, TRUE),
('Praxair - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Praxair',  5, TRUE);

-- Policía Estatal
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Policía Estatal - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Policía Estatal', 10, TRUE),
('Policía Estatal - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Policía Estatal',  5, TRUE);

-- GPI (grupo poliformas)
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('GPI - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'GPI', 10, TRUE),
('GPI - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'GPI',  5, TRUE);

-- Paquetexpress
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Paquetexpress - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Paquetexpress', 10, TRUE),
('Paquetexpress - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Paquetexpress',  5, TRUE);

-- MG Motors
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('MG Motors - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'MG Motors', 10, TRUE),
('MG Motors - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'MG Motors',  5, TRUE);

-- Consejo de la Judicatura Federal
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('CJF - 10% monedero (efectivo)', 'MONEDERO', NULL, NULL, 'Consejo de la Judicatura Federal', 10, TRUE),
('CJF - 5% monedero (tarjeta)',   'MONEDERO', NULL, NULL, 'Consejo de la Judicatura Federal',  5, TRUE);


-- 3) TARJETA DINERO ELECTRÓNICO (PROGRAMA DE LEALTAD)
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Tarjeta Dinero Electrónico - 10% monedero', 'MONEDERO', NULL, NULL,
 'La Picadita Jarocha', 10, TRUE);


-- 4) CONVENIOS COMERCIALES (beneficio en el otro negocio) tipo = CONVENIO_EXTERNO

-- Animalia - 50% estética canina
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Animalia - 50% estética canina', 'CONVENIO_EXTERNO', 50, NULL, 'Animalia', NULL, TRUE);

-- PASA - 15% en imprenta
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('PASA - 15% imprenta', 'CONVENIO_EXTERNO', 15, NULL, 'PASA', NULL, TRUE);

-- Autoclean - Lavado gratis
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Autoclean - Lavado de auto gratis', 'CONVENIO_EXTERNO', NULL, NULL, 'Autoclean', NULL, TRUE);

-- Holistic Versátil - Membresía + masaje gratis
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Holistic Versátil - Membresía y masaje gratis', 'CONVENIO_EXTERNO', NULL, NULL, 'Holistic Versátil', NULL, TRUE);

-- BambúTea - Nieve mediana gratis
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('BambúTea - Nieve mediana gratis', 'CONVENIO_EXTERNO', NULL, NULL, 'BambúTea', NULL, TRUE);

-- FUTFitness - Inscripción gratis
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('FUTFitness - Inscripción gratis', 'CONVENIO_EXTERNO', NULL, NULL, 'FUTFitness', NULL, TRUE);

-- Kolors - 10% compra digital
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Kolors - 10% compra digital', 'CONVENIO_EXTERNO', 10, NULL, 'Kolors', NULL, TRUE);

-- Sicilia Spa - 35% spa
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Sicilia Spa - 35% servicios de spa', 'CONVENIO_EXTERNO', 35, NULL, 'Sicilia', NULL, TRUE);

-- Salón JG - Cejas HD gratis
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Salón JG - Cejas HD gratis', 'CONVENIO_EXTERNO', NULL, NULL, 'Salón JG', NULL, TRUE);

-- Casa Verde - 20% + producto gratis
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Casa Verde - 20% y producto gratis', 'CONVENIO_EXTERNO', 20, NULL, 'Casa Verde', NULL, TRUE);

-- UNID - 60% inscripción
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('UNID - 60% inscripción', 'CONVENIO_EXTERNO', 60, NULL, 'UNID', NULL, TRUE);
--DQ
INSERT INTO descuento (nombre_convenio, tipo, porcentaje, monto_fijo, empresa, monedero_ahorro, activo)
VALUES
('Dairy Queen - Cono gratis con ticket de $370', 'CONVENIO_EXTERNO', NULL, NULL, 'Dairy Queen', NULL, TRUE);

/*PROMOCIONES SEMANALES LA PICADITA JAROCHA
   Todas tipo 2x1 aplicadas por día. */

-- Lunes de Atascón
INSERT INTO promocion (nombre, esta_activo, valor_porcentaje, monto_minimo, dias_aplicables, tipo_beneficio)
VALUES
('Lunes de Atascón - 2x$123 en memelas y huaraches', TRUE, NULL, NULL, 'Lunes', '2X1');

-- Martes Tradicional
INSERT INTO promocion (nombre, esta_activo, valor_porcentaje, monto_minimo, dias_aplicables, tipo_beneficio)
VALUES
('Martes Tradicional - 2x1 en picadas sencillas', TRUE, NULL, NULL, 'Martes', '2X1');

-- Miércoles de Tamales
INSERT INTO promocion (nombre, esta_activo, valor_porcentaje, monto_minimo, dias_aplicables, tipo_beneficio)
VALUES
('Miércoles de Tamales - 2x1 en tamales rancheros', TRUE, NULL, NULL, 'Miércoles', '2X1');

-- Jueves de Huevos
INSERT INTO promocion (nombre, esta_activo, valor_porcentaje, monto_minimo, dias_aplicables, tipo_beneficio)
VALUES
('Jueves de Huevos - 2x1 1/2 en productos de huevos', TRUE, NULL, NULL, 'Jueves', '2X1');

-- Viernes de Bebidas
INSERT INTO promocion (nombre, esta_activo, valor_porcentaje, monto_minimo, dias_aplicables, tipo_beneficio)
VALUES
('Viernes de Bebidas - 2x1 en todas las aguas frescas', TRUE, NULL, NULL, 'Viernes', '2X1');

INSERT INTO area_cocina (nombre, tipo_area, estado)
VALUES
('Cocina Principal', 'Cocina Caliente', 'activo'),
('Plancha y Comal', 'Cocina de Antojitos', 'activo'),
('Despacho', 'Entrega de Platillos', 'activo');


   -- ÁREAS DE VENTA LA PICADITA JAROCHA

-- 1. Soriana Cuauhtémoc (Mina) - chica, 1 planta
-- Solo atención en mostrador
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
(1, 'Mostrador');

-- 2. Centro Mina - 1 planta con comedor
-- Un solo comedor
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
(2, 'Comedor'),
(2, 'Mostrador');

-- 3. Instituto Tecnológico (Mina) - 2 plantas
-- Comedor en planta baja y alta + mostrador
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
(3, 'Comedor Planta Baja'),
(3, 'Comedor Planta Alta'),
(3, 'Mostrador');

-- 4. Centro Coatzacoalcos - 2 plantas
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
(4, 'Comedor Planta Baja'),
(4, 'Comedor Planta Alta'),
(4, 'Mostrador');

-- 5. Soriana Palmar - chica, 1 planta
-- Local pequeñito, solo mostrador
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
(5, 'Mostrador');

-- 6. Soriana Mercado - chica, 1 planta, pura barra
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
(6, 'Barra / Mostrador');

-- 7. Malecón - 2 plantas
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
(7, 'Comedor Planta Baja'),
(7, 'Comedor Planta Alta'),
(7, 'Mostrador');

-- 8. Gaviotas - 2 plantas
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
(8, 'Comedor Planta Baja'),
(8, 'Comedor Planta Alta'),
(8, 'Mostrador');

-- MESAS POR ÁREA DE VENTA

-- 1. Soriana Cuauhtémoc (Mina)
-- area_id = 1 → Mostrador (6 lugares)
INSERT INTO mesa (area_id, num_mesa) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6);


-- 2. Centro Mina
-- area_id = 2 → Comedor (8 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(2,1),(2,2),(2,3),(2,4),
(2,5),(2,6),(2,7),(2,8);

-- area_id = 3 → Mostrador (4 lugares)
INSERT INTO mesa (area_id, num_mesa) VALUES
(3,1),(3,2),(3,3),(3,4);


-- 3. Instituto Tecnológico (Mina)
-- area_id = 4 → Comedor Planta Baja (8 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(4,1),(4,2),(4,3),(4,4),
(4,5),(4,6),(4,7),(4,8);

-- area_id = 5 → Comedor Planta Alta (6 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(5,1),(5,2),(5,3),(5,4),(5,5),(5,6);

-- area_id = 6 → Mostrador (4 lugares)
INSERT INTO mesa (area_id, num_mesa) VALUES
(6,1),(6,2),(6,3),(6,4);


-- 4. Centro Coatzacoalcos
-- area_id = 7 → Comedor Planta Baja (10 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(7,1),(7,2),(7,3),(7,4),(7,5),
(7,6),(7,7),(7,8),(7,9),(7,10);

-- area_id = 8 → Comedor Planta Alta (8 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(8,1),(8,2),(8,3),(8,4),
(8,5),(8,6),(8,7),(8,8);

-- area_id = 9 → Mostrador (4 lugares)
INSERT INTO mesa (area_id, num_mesa) VALUES
(9,1),(9,2),(9,3),(9,4);


-- 5. Soriana Palmar
-- area_id = 10 → Mostrador (6 lugares)
INSERT INTO mesa (area_id, num_mesa) VALUES
(10,1),(10,2),(10,3),(10,4),(10,5),(10,6);


-- 6. Soriana Mercado
-- area_id = 11 → Barra / Mostrador (8 lugares)
INSERT INTO mesa (area_id, num_mesa) VALUES
(11,1),(11,2),(11,3),(11,4),
(11,5),(11,6),(11,7),(11,8);


-- 7. Malecón
-- area_id = 12 → Comedor Planta Baja (8 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(12,1),(12,2),(12,3),(12,4),
(12,5),(12,6),(12,7),(12,8);

-- area_id = 13 → Comedor Planta Alta (6 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(13,1),(13,2),(13,3),(13,4),(13,5),(13,6);

-- area_id = 14 → Mostrador (4 lugares)
INSERT INTO mesa (area_id, num_mesa) VALUES
(14,1),(14,2),(14,3),(14,4);


-- 8. Gaviotas
-- area_id = 15 → Comedor Planta Baja (8 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(15,1),(15,2),(15,3),(15,4),
(15,5),(15,6),(15,7),(15,8);

-- area_id = 16 → Comedor Planta Alta (6 mesas)
INSERT INTO mesa (area_id, num_mesa) VALUES
(16,1),(16,2),(16,3),(16,4),(16,5),(16,6);

-- area_id = 17 → Mostrador (4 lugares)
INSERT INTO mesa (area_id, num_mesa) VALUES
(17,1),(17,2),(17,3),(17,4);


/* 
   CARGA DE MENÚ - LA PICADITA JAROCHA
   Incluye: Carta completa, Paquetes, Comida Corrida y Modificadores
*/

-- 1. MENÚ PRINCIPAL
INSERT INTO menu (nombre, hora_inicio, hora_fin, fecha_creacion, activo) 
VALUES ('Menú General', '07:00:00', '23:00:00', NOW(), TRUE);

-- 2. CATEGORÍAS (Estructura completa de la carta)
INSERT INTO categoria (menu_id, nombre) VALUES 

(1, 'Picadas'),              -- 1
(1, 'Memelas'),              -- 2
(1, 'Huaraches'),            -- 3
(1, 'Gorditas'),             -- 4
(1, 'Salbutes'),             -- 5
(1, 'Empanadas'),            -- 6
(1, 'Tostadas'),             -- 7
(1, 'Dobladas'),             -- 8
(1, 'Platanitos'),           -- 9
(1, 'Tortas'),               -- 10
(1, 'Huevos'),               -- 11
(1, 'Platillos Regionales'), -- 12
(1, 'Tacos'),                -- 13
(1, 'Caldos'),               -- 14
(1, 'Ensaladas'),            -- 15
(1, 'Cockteles'),            -- 16
(1, 'Postres'),              -- 17
(1, 'Licuados'),             -- 18
(1, 'Aguas Frescas'),        -- 19
(1, 'Calientes'),            -- 20
(1, 'Cervezas'),             -- 21
(1, 'Refrescos'),            -- 22
(1, 'Jugos'),                -- 23
(1, 'Alimentos Variados'),   -- 24
(1, 'Arma tu Doblada'),      -- 25
(1, 'Salsas y Mole Venta'),  -- 26
(1, 'Ordenes de Productos'), -- 27
(1, 'Res'),                  -- 28 
(1, 'Cerdo'),                -- 29  
(1, 'Aves'),                 -- 30 
(1, 'Mariscos'),             -- 31
(1, 'Varios'),               -- 32
(1, 'Paquetes'),             -- 33
(1, 'Comida Corrida'),       -- 34
(1, 'Servicios');            -- 35
/* 
   3. PRODUCTOS POR CATEGORÍA
 */

-- CAT 1: PICADAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(1, 'Salsa roja con chile', 14.00, 'Picada sencilla', FALSE),
(1, 'Salsa roja sin chile', 14.00, 'Picada sencilla', FALSE),
(1, 'Salsa verde', 14.00, 'Picada sencilla', FALSE),
(1, 'Salsa chipotle', 14.00, 'Picada sencilla', FALSE),
(1, 'Salsa ranchera', 14.00, 'Picada sencilla', FALSE),
(1, 'Frijoles', 14.00, 'Picada sencilla', FALSE),
(1, 'Salsa y frijoles', 16.00, 'Picada combinada', FALSE),
(1, 'Mole', 17.00, 'Picada de mole', FALSE),
(1, 'Huevo estrellado', 20.00, 'Picada preparada', FALSE),
(1, 'Chicharrón prensado', 20.00, 'Picada preparada', FALSE),
(1, 'Pollo', 20.00, 'Picada preparada', FALSE),
(1, 'Cochinita', 20.00, 'Picada preparada', FALSE),
(1, 'Longaniza', 20.00, 'Picada preparada', FALSE),
(1, 'Picadillo', 20.00, 'Picada preparada', FALSE),
(1, 'Carne asada', 20.00, 'Picada preparada', FALSE),
(1, 'Cecina', 20.00, 'Picada preparada', FALSE),
(1, 'Chinameca', 20.00, 'Picada preparada', FALSE),
(1, 'Tripa', 20.00, 'Picada preparada', FALSE),
(1, 'Campechana (2 ing.)', 26.00, 'Picada con dos ingredientes', FALSE);

-- CAT 2: MEMELAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(2, 'Chicharrón prensado', 78.00, 'Memela preparada', FALSE),
(2, 'Pollo', 78.00, 'Memela preparada', FALSE),
(2, 'Cochinita', 78.00, 'Memela preparada', FALSE),
(2, 'Longaniza', 78.00, 'Memela preparada', FALSE),
(2, 'Picadillo', 78.00, 'Memela preparada', FALSE),
(2, 'Carne asada', 78.00, 'Memela preparada', FALSE),
(2, 'Cecina', 78.00, 'Memela preparada', FALSE),
(2, 'Chinameca', 78.00, 'Memela preparada', FALSE),
(2, 'Tripa', 78.00, 'Memela preparada', FALSE),
(2, 'Tradicional', 78.00, 'Memela preparada', FALSE),
(2, 'Campechana (2 ing.)', 95.00, 'Memela combinada', FALSE);

-- CAT 3: HUARACHES
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(3, 'Chicharrón prensado', 78.00, 'Huarache preparado', FALSE),
(3, 'Pollo', 78.00, 'Huarache preparado', FALSE),
(3, 'Cochinita', 78.00, 'Huarache preparado', FALSE),
(3, 'Longaniza', 78.00, 'Huarache preparado', FALSE),
(3, 'Picadillo', 78.00, 'Huarache preparado', FALSE),
(3, 'Carne asada', 78.00, 'Huarache preparado', FALSE),
(3, 'Cecina', 78.00, 'Huarache preparado', FALSE),
(3, 'Chinameca', 78.00, 'Huarache preparado', FALSE),
(3, 'Tripa', 78.00, 'Huarache preparado', FALSE),
(3, 'Campechano (2 ing.)', 95.00, 'Huarache combinado', FALSE);

-- CAT 4: GORDITAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(4, 'Negra', 14.00, 'Gordita de frijol', FALSE),
(4, 'Blanca', 14.00, 'Gordita sencilla', FALSE),
(4, 'De dulce', 14.00, 'Gordita dulce', FALSE),
(4, 'Con mole', 16.00, 'Gordita bañada', FALSE),
(4, 'Especial', 23.00, 'Gordita preparada', FALSE),
(4, 'Montada sencilla', 26.50, 'Gordita montada', FALSE),
(4, 'Montada especial', 32.50, 'Gordita montada especial', FALSE);

-- CAT 5: SALBUTES
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(5, 'Pollo', 22.50, 'Salbute preparado', FALSE),
(5, 'Cochinita', 22.50, 'Salbute preparado', FALSE);

-- CAT 6: EMPANADAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(6, 'Queso', 15.00, 'Empanada frita', FALSE),
(6, 'Jamón', 15.00, 'Empanada frita', FALSE),
(6, 'Pollo', 15.00, 'Empanada frita', FALSE),
(6, 'Prensado', 15.00, 'Empanada frita', FALSE),
(6, 'Cochinita', 15.00, 'Empanada frita', FALSE),
(6, 'Picadillo', 15.00, 'Empanada frita', FALSE),
(6, 'Longaniza', 15.00, 'Empanada frita', FALSE),
(6, 'Carne asada', 15.00, 'Empanada frita', FALSE),
(6, 'Tripa', 15.00, 'Empanada frita', FALSE),
(6, 'Campechana (Queso y 1 ing)', 19.00, 'Empanada combinada', FALSE);

-- CAT 7: TOSTADAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(7, 'Pollo', 21.00, 'Tostada preparada', FALSE),
(7, 'Cochinita', 21.00, 'Tostada preparada', FALSE),
(7, 'Picadillo', 21.00, 'Tostada preparada', FALSE);

-- CAT 8: DOBLADAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(8, 'Enfrijoladas con pollo (3 pzs)', 59.00, 'Orden de 3', TRUE),
(8, 'Entomatadas con pollo (3 pzs)', 59.00, 'Orden de 3', TRUE),
(8, 'Enmoladas con pollo (3 pzs)', 64.00, 'Orden de 3', TRUE);

-- CAT 9: PLATANITOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(9, 'Platanitos fritos', 24.50, 'Con crema y queso', FALSE);

-- CAT 10: TORTAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(10, 'Cochinita', 40.00, 'Torta preparada', FALSE),
(10, 'Pollo', 40.00, 'Torta preparada', FALSE),
(10, 'Longaniza', 40.00, 'Torta preparada', FALSE),
(10, 'Chinameca', 40.00, 'Torta preparada', FALSE),
(10, 'Carne asada', 40.00, 'Torta preparada', FALSE),
(10, 'Campechana (2 ing.)', 52.00, 'Torta combinada', FALSE);

-- CAT 11: HUEVOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(11, 'Motuleños', 77.00, 'Huevos preparados', FALSE),
(11, 'Rancheros', 77.00, 'Huevos preparados', FALSE),
(11, 'Divorciados', 77.00, 'Huevos preparados', FALSE),
(11, 'Al gusto (Jamon/Long/Tirados/Salsa/Mexicana)', 65.00, 'Huevos al gusto', FALSE);

-- CAT 12: PLATILLOS REGIONALES
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(12, 'Tamal ranchero', 23.50, 'Pieza de tamal', FALSE),
(12, 'Bomba Veracruzana', 25.00, 'Pieza', FALSE),
(12, 'Chilaquiles con pollo', 69.50, 'Platillo', FALSE),
(12, 'Chilaquiles con pollo y bistec', 89.50, 'Platillo', FALSE),
(12, 'Carne de Chinameca', 84.50, 'Platillo', FALSE),
(12, 'Chilaquiles con pollo y Chinameca', 95.50, 'Platillo', FALSE),
(12, 'Filete a la Tampiqueña', 138.50, 'Platillo especial', FALSE),
(12, 'Chinameca a la Tampiqueña', 138.50, 'Platillo especial', FALSE),
(12, 'Cecina Huasteca', 122.50, 'Platillo', FALSE),
(12, 'Chinameca Huasteca', 122.50, 'Platillo', FALSE),
(12, 'Chiles Rellenos (2 pzs)', 69.50, 'Platillo', FALSE);

-- CAT 13: TACOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(13, 'Carne asada', 15.00, 'Taco individual', FALSE),
(13, 'Cochinita', 15.00, 'Taco individual', FALSE),
(13, 'Tripa', 15.00, 'Taco individual', FALSE),
(13, 'Longaniza', 15.00, 'Taco individual', FALSE),
(13, 'Chinameca', 15.00, 'Taco individual', FALSE),
(13, 'Cecina', 15.00, 'Taco individual', FALSE),
(13, 'Prensado', 15.00, 'Taco individual', FALSE),
(13, 'Campechano (2 ing.)', 19.50, 'Taco combinado', FALSE),
(13, 'Dorados de pollo (3 pzs)', 48.00, 'Orden de tacos dorados', TRUE);

-- CAT 14: CALDOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(14, 'Consomé de Pollo', 56.50, 'Plato de caldo', FALSE),
(14, 'Caldo de Mondongo', 79.00, 'Plato de mondongo', FALSE),
(14, 'Caldo de Pozole', 79.00, 'Plato de pozole', FALSE);

-- CAT 15: ENSALADAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(15, 'Ensalada rusa con pollo', 67.00, 'Plato de ensalada', FALSE),
(15, 'Ensalada rusa con atún', 67.00, 'Plato de ensalada', FALSE);

-- CAT 16: COCKTELES
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(16, 'Cocktel de frutas', 56.50, 'Copa de fruta', FALSE);

-- CAT 17: POSTRES
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(17, 'Pay de Limón', 41.00, 'Rebanada', FALSE),
(17, 'Pay de Queso', 41.00, 'Rebanada', FALSE),
(17, 'Flan Napolitano', 40.00, 'Rebanada', FALSE),
(17, 'Pan de Elote', 35.00, 'Rebanada', FALSE),
(17, 'Pan Dulce', 14.00, 'Pieza', FALSE);

-- CAT 18: LICUADOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(18, 'Licuado de Plátano', 40.00, 'Vaso', FALSE),
(18, 'Licuado de Papaya', 40.00, 'Vaso', FALSE),
(18, 'Licuado de Melón', 40.00, 'Vaso', FALSE),
(18, 'Licuado de Fresa', 40.00, 'Vaso', FALSE),
(18, 'Chocomilk', 40.00, 'Vaso', FALSE);

-- CAT 19: AGUAS FRESCAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(19, 'Agua de Horchata', 22.50, 'Vaso', FALSE),
(19, 'Agua de Jamaica', 22.50, 'Vaso', FALSE),
(19, 'Agua de Naranja', 22.50, 'Vaso', FALSE),
(19, 'Agua del Día (Lunes-Viernes)', 22.50, 'Vaso', FALSE),
(19, 'Jarra de Horchata', 90.00, 'Jarra', FALSE),
(19, 'Jarra de Jamaica', 90.00, 'Jarra', FALSE),
(19, 'Jarra de Naranja', 90.00, 'Jarra', FALSE),
(19, 'Jarra Agua del Día', 90.00, 'Jarra', FALSE);

-- CAT 20: CALIENTES
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(20, 'Café chico', 17.50, 'Taza chica', FALSE),
(20, 'Café grande', 22.50, 'Taza grande', FALSE),
(20, 'Café con leche chico', 23.00, 'Taza chica', FALSE),
(20, 'Café con leche grande', 29.50, 'Taza grande', FALSE),
(20, 'Champurrado chico', 25.50, 'Taza chica', FALSE),
(20, 'Champurrado grande', 32.00, 'Taza grande', FALSE);

-- CAT 21: CERVEZAS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(21, 'Corona media', 35.00, 'Botella', FALSE),
(21, 'Negra modelo / Modelo especial', 38.50, 'Botella', FALSE);

-- CAT 22: REFRESCOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(22, 'Refresco de 600 ml', 30.00, 'Botella', FALSE),
(22, 'Refrescos de lata', 30.00, 'Lata', FALSE),
(22, 'Coca cola light de lata', 30.00, 'Lata', FALSE),
(22, 'Fuze tea de 600 ml', 30.00, 'Botella', FALSE),
(22, 'Agua Ciel', 22.50, 'Botella', FALSE);

-- CAT 23: JUGOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(23, 'Jugo de Naranja', 36.00, 'Vaso', FALSE),
(23, 'Jugo Verde', 40.00, 'Vaso', FALSE),
(23, 'Jugo de Zanahoria', 40.00, 'Vaso', FALSE),
(23, 'Jugo de Toronja', 40.00, 'Vaso', FALSE),
(23, 'Jugo de Naranja c/Zanahoria', 40.00, 'Vaso', FALSE),
(23, 'Jugo de Piña', 40.00, 'Vaso', FALSE),
(23, 'Jugo de Naranja c/Piña', 40.00, 'Vaso', FALSE),
(23, 'Jarra de Jugo de Naranja', 152.00, 'Jarra', FALSE);

-- CAT 24: ALIMENTOS VARIADOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(24, 'Chilaquiles c/Mole, Pollo', 82.00, 'Platillo', FALSE),
(24, 'Chilaquiles c/Mole, Pollo y Bisteck', 93.50, 'Platillo', FALSE),
(24, 'Chilaquiles c/Cochinita', 82.00, 'Platillo', FALSE),
(24, 'Chilaquiles c/Cochinita y Bisteck', 93.50, 'Platillo', FALSE),
(24, 'Chilaquiles c/Pollo y Chinameca', 89.50, 'Platillo', FALSE),
(24, 'Jamón a la Plancha', 10.50, 'Platillo', FALSE),
(24, 'Lata de Atún', 38.00, 'Platillo', FALSE),
(24, 'Postre del día', 16.00, 'Postre', FALSE),
(24, 'Bisteck Asada C/Ensalada', 79.00, 'Platillo', FALSE),
(24, 'Bisteck Asado Natural', 52.50, 'Platillo', FALSE),
(24, 'Cecina C/Chilaquiles C/Pollo', 110.50, 'Platillo', FALSE),
(24, 'Cecina C/Ensalada', 110.50, 'Platillo', FALSE),
(24, 'Cecina Natural', 58.00, 'Platillo', FALSE),
(24, 'Filete a la Parrilla', 108.50, 'Platillo', FALSE);

-- CAT 25: ARMA TU DOBLADA (Piezas individuales)
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(25, 'Enchilada c/Chinameca 1pza', 25.00, 'Pieza individual', FALSE),
(25, 'Enchilada c/Huevo Revuelto 1pza', 18.50, 'Pieza individual', FALSE),
(25, 'Enchilada c/Longaniza 1pza', 25.00, 'Pieza individual', FALSE),
(25, 'Enchilada c/Picadillo 1pza', 25.00, 'Pieza individual', FALSE),
(25, 'Enchilada c/Pollo 1pza', 18.50, 'Pieza individual', FALSE),
(25, 'Enfrijolada c/Chinameca 1pza', 23.50, 'Pieza individual', FALSE),
(25, 'Enfrijolada c/Huevo Revuelto 1pza', 17.50, 'Pieza individual', FALSE),
(25, 'Enfrijolada c/Longaniza 1pza', 23.50, 'Pieza individual', FALSE),
(25, 'Enfrijolada c/Picadillo 1pza', 23.50, 'Pieza individual', FALSE),
(25, 'Enfrijolada c/Pollo 1pza', 17.50, 'Pieza individual', FALSE),
(25, 'Entomatada c/Chinameca 1pza', 23.50, 'Pieza individual', FALSE),
(25, 'Entomatada c/Huevo Revuelto 1pza', 17.50, 'Pieza individual', FALSE),
(25, 'Entomatada c/Longaniza 1pza', 23.50, 'Pieza individual', FALSE),
(25, 'Entomatada c/Picadillo 1pza', 23.50, 'Pieza individual', FALSE),
(25, 'Entomatada c/Pollo 1pza', 17.50, 'Pieza individual', FALSE);

-- CAT 26: SALSAS Y MOLE VENTA
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(26, 'Salsa Chipotle Vaso 1/4 Lt', 27.50, 'Para llevar', FALSE),
(26, 'Salsa Chipotle Vaso 1/2 Lt', 41.00, 'Para llevar', FALSE),
(26, 'Salsa Chipotle Vaso 1 Lt', 69.50, 'Para llevar', FALSE),
(26, 'Salsa Habanero Vaso 1/4 Lt', 86.50, 'Para llevar', FALSE),
(26, 'Salsa Habanero Vaso 1/2 Lt', 132.50, 'Para llevar', FALSE),
(26, 'Salsa Habanero Vaso 1 Lt', 245.00, 'Para llevar', FALSE),
(26, 'Salsa Macha Vaso 1/4 Lt', 86.50, 'Para llevar', FALSE),
(26, 'Salsa Macha Vaso 1/2 Lt', 132.50, 'Para llevar', FALSE),
(26, 'Salsa Macha Vaso 1 Lt', 245.00, 'Para llevar', FALSE),
(26, 'Salsa Verde Vaso 1/4 Lt', 27.50, 'Para llevar', FALSE),
(26, 'Salsa Verde Vaso 1/2 Lt', 41.00, 'Para llevar', FALSE),
(26, 'Salsa Verde Vaso 1 Lt', 69.50, 'Para llevar', FALSE),
(26, 'Mole 1/2 Litro', 42.00, 'Para llevar', FALSE),
(26, 'Mole 1 Litro', 77.50, 'Para llevar', FALSE);

-- CAT 27: ORDENES DE PRODUCTOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(27, 'Orden de Frijoles Aguados', 20.00, 'Guarnición', FALSE),
(27, 'Orden de Crema', 20.00, 'Guarnición', FALSE),
(27, 'Orden de Mole', 20.00, 'Guarnición', FALSE),
(27, 'Orden de Prensado', 20.00, 'Guarnición', FALSE),
(27, 'Orden de Queso', 20.00, 'Guarnición', FALSE),
(27, 'Orden de Salsa de Chicharrón', 20.00, 'Guarnición', FALSE),
(27, 'Orden de Tortillas a mano 3pzs', 10.50, 'Guarnición', FALSE),
(27, 'Orden de Aguacate 5pzs', 25.00, 'Guarnición', FALSE),
(27, 'Orden de Arroz', 21.00, 'Guarnición', FALSE),
(27, 'Orden de Frijol Refrito', 21.00, 'Guarnición', FALSE),
(27, 'Orden de Guacamole', 26.50, 'Guarnición', FALSE),
(27, 'Orden de Sopa', 25.00, 'Guarnición', FALSE),
(27, 'Orden de Ensalada', 21.00, 'Guarnición', FALSE),
(27, 'Orden de Puré de Papa', 21.00, 'Guarnición', FALSE);


-- CAT 28: RES (Se insertan en 0.00 para actualizar)
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(28, 'Bisteces a la Mexicana con frijoles refritos', 0.00, 'Plato fuerte', FALSE),
(28, 'Fajitas de res a la mostaza con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete a la Barbecue con papas', 0.00, 'Plato fuerte', FALSE),
(28, 'Rollito de Carne relleno de verduras con arroz', 0.00, 'Plato fuerte', FALSE),
(28, 'Tortitas de Carne de res deshebrada en chipotle', 0.00, 'Plato fuerte', FALSE),
(28, 'Fajitas de Res adobadas con papas y frijoles', 0.00, 'Plato fuerte', FALSE),
(28, 'Cuete Mechado de verduras con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(28, 'Ropa Vieja de Res con frijoles refritos', 0.00, 'Plato fuerte', FALSE),
(28, 'Barbacoa de Res con frijoles refritos', 0.00, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete a la mostaza con arroz', 0.00, 'Plato fuerte', FALSE),
(28, 'Albondigas Enchipotladas con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete en salsa de toronja', 0.00, 'Plato fuerte', FALSE),
(28, 'Bisteces de Res a la Poblana con frijol', 0.00, 'Plato fuerte', FALSE),
(28, 'Carne deshebrada a la Mexicana con frijol', 0.00, 'Plato fuerte', FALSE),
(28, 'Bisteces de res al albañil con frijoles', 0.00, 'Plato fuerte', FALSE),
(28, 'Birria de Res con frijoles refritos', 0.00, 'Plato fuerte', FALSE),
(28, 'Carne Polaca de res con frijoles refritos', 0.00, 'Plato fuerte', FALSE),
(28, 'Pastel de Carne con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(28, 'Bisteces Rancheros con frijoles refritos', 0.00, 'Plato fuerte', FALSE),
(28, 'Brochetas de Res con ensalada', 0.00, 'Plato fuerte', FALSE),
(28, 'Bisteces Arrieros de Res con frijoles', 0.00, 'Plato fuerte', FALSE),
(28, 'Caldo de Mondongo (Platillo)', 0.00, 'Plato fuerte', FALSE),
(28, 'Fajitas Lázaro de Bisteces con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete en salsa chipotle', 0.00, 'Plato fuerte', FALSE),
(28, 'Bisteces Encebollados de Res con frijoles', 0.00, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete en Salsa de champiñones', 0.00, 'Plato fuerte', FALSE),
(28, 'Milanesa de Res con ensalada y frijoles', 0.00, 'Plato fuerte', FALSE);

-- CAT 29: CERDO
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(29, 'Cerdo Enchilado con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Costillas de Cerdo adobadas con arroz', 0.00, 'Plato fuerte', FALSE),
(29, 'Bisteces Encebollados de Cerdo con ensalada', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo en Salsa de Cacahuate con frijoles', 0.00, 'Plato fuerte', FALSE),
(29, 'Cochinita Pibil con papas y arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Milanesa de Cerdo con ensalada', 0.00, 'Plato fuerte', FALSE),
(29, 'Costillas de Cerdo de Salsa Verde con arroz', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Coca Cola con papas de arroz', 0.00, 'Plato fuerte', FALSE),
(29, 'Costillas de Cerdo en salsa agridulce', 0.00, 'Plato fuerte', FALSE),
(29, 'Puerco en Salsa de Perejil con papas', 0.00, 'Plato fuerte', FALSE),
(29, 'Mole de Cerdo con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo al Pipián con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo en Salsa Pasilla con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Carne de Cerdo en salsa de ciruela pasa', 0.00, 'Plato fuerte', FALSE),
(29, 'Carne de Cerdo Adobada con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Chuletas de Cerdo a la barbecue con ensalada', 0.00, 'Plato fuerte', FALSE),
(29, 'Carne de Cerdo en salsa verde con arroz', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo en Salsa agridulce con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Naranja con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Mestiza con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Cerveza con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Barbecue con papas y arroz', 0.00, 'Plato fuerte', FALSE),
(29, 'Costillas de Cerdo enchipotladas con papas', 0.00, 'Plato fuerte', FALSE),
(29, 'Chuletas de Cerdo a la Plancha con ensalada', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo con calabacitas y granos de elote', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo en Salsa de Tamarindo con arroz', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Hawaiana con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(29, 'Cerdo con Verdolagas con frijoles refritos', 0.00, 'Plato fuerte', FALSE);


-- CAT 30: AVES
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(30, 'Pollos a la Naranja con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo a la barbecue con papitas y arroz', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo a la crema de Queso con arroz', 0.00, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo a la Mantequilla con ensalada', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo a la Hawaiana con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pechugas rellenas de Jamón y Queso', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo en Pipián con arroz blanco y frijoles', 0.00, 'Plato fuerte', FALSE),
(30, 'Mole de Pollo con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Milanesa de Pollo con Ensalada', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo Kentucky con ensalada', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo Adobado con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Barbacoa de Pollo con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo al Orégano con arroz', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo en Salsa de Limón con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo en Salsa de chile morita', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo Entomatado con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo Campirano con papas y arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo con Champiñones con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo Frito con ensalada', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo en Escabeche con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo en Salsa de Perejil con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo Pibil con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pechugas a la Cordón Blue con ensalada', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo en Mole Verde con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo Supremo con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo en Salsa de aguacate', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo a la Vizcaina con frijoles refritos', 0.00, 'Plato fuerte', FALSE),
(30, 'Estofado de Pollo con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo bañado en Salsa Verde con arroz', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo Enchipotlado con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo a la barbecue con ensalada', 0.00, 'Plato fuerte', FALSE),
(30, 'Pollo a la Jardinera con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(30, 'Pechugas adobadas con papas y arroz', 0.00, 'Plato fuerte', FALSE),
(30, 'Tortitas de Pollo Deshebrado en salsa verde', 0.00, 'Plato fuerte', FALSE);

-- CAT 31: MARISCOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(31, 'Filete de Pescado a la Mantequilla', 0.00, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado a la Pimienta con ensalada', 0.00, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado empanizado con ensalada', 0.00, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado a la Veracruzana', 0.00, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado al mojo de ajo', 0.00, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado a la Poblana con arroz', 0.00, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado en salsa de Perejil', 0.00, 'Plato fuerte', FALSE),
(31, 'Pulpos al Ajillo con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(31, 'Pulpos a la Veracruzana con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(31, 'Pulpos Enchipotlados con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(31, 'Pulpos al Mojo de Ajo con arroz blanco', 0.00, 'Plato fuerte', FALSE),
(31, 'Pulpo a la Diabla con arroz blanco', 0.00, 'Plato fuerte', FALSE);


-- CAT 32: VARIOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(32, 'Ensalada de Pollo con tostadas', 0.00, 'Platillo', FALSE),
(32, 'Enchiladas Verdes con Pollo', 0.00, 'Platillo', FALSE),
(32, 'Enfrijoladas de Pollo', 0.00, 'Platillo', FALSE),
(32, 'Crepas de Pollo con ensalada', 0.00, 'Platillo', FALSE),
(32, 'Croquetas de Pollo con ensalada', 0.00, 'Platillo', FALSE),
(32, 'Enchiladas Poblanas con Pollo', 0.00, 'Platillo', FALSE),
(32, 'Spaguetti con trocitos de Pollo a la Poblana', 0.00, 'Platillo', FALSE),
(32, 'Chiles Rellenos de Queso bañados en Tomate', 0.00, 'Platillo', FALSE),
(32, 'Chayote relleno de Picadillo Gratinado', 0.00, 'Platillo', FALSE),
(32, 'Tinga Poblana con frijoles refritos', 0.00, 'Platillo', FALSE),
(32, 'Spaguetti a la Boloñesa con Carne molida', 0.00, 'Platillo', FALSE),
(32, 'Entomatadas con Pollo', 0.00, 'Platillo', FALSE),
(32, 'Calabacitas Granitadas rellenas de carne', 0.00, 'Platillo', FALSE),
(32, 'Calabacitas rellenas de Jamón y Queso', 0.00, 'Platillo', FALSE),
(32, 'Chile Relleno de picadillo bañado en salsa', 0.00, 'Platillo', FALSE),
(32, 'Salpicón Tabasqueño con Tostadas', 0.00, 'Platillo', FALSE),
(32, 'Tacos Árabes con ensalada', 0.00, 'Platillo', FALSE),
(32, 'Spaguetti a la Mantequilla con Jamón y Tocino', 0.00, 'Platillo', FALSE),
(32, 'Chayote Capeado relleno de Jamón y Queso', 0.00, 'Platillo', FALSE),
(32, 'Papas Rellenas de jamón y queso', 0.00, 'Platillo', FALSE),
(32, 'Croquetas de Queso con ensalada', 0.00, 'Platillo', FALSE),
(32, 'Coliflor Lampreado rellena de Queso', 0.00, 'Platillo', FALSE),
(32, 'Acelgas rellenas de Jamón y Queso', 0.00, 'Platillo', FALSE);

-- CAT 33: PAQUETES
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(33, 'Paquete Quemes', 95.00, 'Caldo Mondongo/Pozole + aguas + tostadas', TRUE),
(33, 'Paquete Regional', 100.00, 'Carne Chinameca + aguas + tortillas', TRUE),
(33, 'Paquete Desayunes', 100.00, 'Huevos Div/Ranc/Mot + aguas/cafe + tortillas', TRUE),
(33, 'Paquete Llenes', 105.00, 'Chilaquiles Bistec/Chinameca + aguas', TRUE),
(33, 'Paquete Rico', 90.00, '1 Memela + aguas', TRUE),
(33, 'Paquete Norteño', 150.00, 'Filete Tampiqueña/Chinameca + aguas + tortillas', TRUE),
(33, 'Paquete Guste', 135.00, 'Cecina Huasteca/Chinameca + aguas + tortillas', TRUE),
(33, 'Paquete Piques', 75.00, '3 Picaditas de Carne + aguas', TRUE),
(33, 'Paquete Dobles', 75.00, 'Orden dobladas (Entom/Enfrij/Enmol) + aguas', TRUE),
(33, 'Paquete Alcance', 60.00, '3 Empanadas sencillas + aguas', TRUE),
(33, 'Paquete Nutras', 80.00, '2 Tostadas carne + 1 Platano frito + aguas', TRUE);

-- CAT 34: COMIDA CORRIDA
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(34, 'Comida Corrida del Día', 89.00, 'Sopa, 4 Guisos a escoger, Postre y Agua rellenable', TRUE);

-- CAT 35: SERVICIOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(35, 'Servicio a Domicilio (Compra > $165)', 35.00, 'Costo de envío', FALSE),
(35, 'Servicio a Domicilio (Compra < $165)', 40.00, 'Costo de envío', FALSE);


/*
   4. MODIFICADORES E INGREDIENTES EXTRAS
*/

INSERT INTO modificador (nombre, precio) VALUES 
-- Salsas
('Salsa Roja', 0.00),
('Salsa Verde', 0.00),
('Salsa Macha', 0.00),
('Salsa de Tomate', 0.00),
('Mole', 5.00),

-- Proteínas
('Con Huevo', 10.00),
('Con Pollo Deshebrado', 15.00),
('Con Chinameca', 20.00),
('Con Longaniza', 15.00),
('Con Bistec', 20.00),

-- Extras Generales
('Ingrediente Extra Picada', 5.00),
('Ingrediente Extra Huarache', 15.50),
('Ingrediente Extra Memela', 15.50),
('Ingrediente Extra Empanada', 3.00),
('Extra Huevo Cocido', 15.00),
('Extra Huevo Estrellado', 15.00),
('Extra Aguacate 1pza', 5.00),
('Extra Frijol', 3.50),
('Extra Mole', 4.50),
('Extra Queso', 3.50),
('Extra Lechuga', 3.50),
('Extra Repollo', 3.50),
('Extra Caldo Mondongo', 10.50),
('Extra Caldo Pozole', 10.50),
('Extra Porción Gallina', 68.50),
('Extra Porción Maíz Pozolero', 16.00),
('Extra Porción de Mondongo', 39.00),
('Extra Porción Pozole', 39.00),

-- Opciones Comida Corrida (Precio 0 porque está incluido en el paquete)
('Con Sopa del Día', 0.00),
('Con Arroz', 0.00),
('Con Espagueti', 0.00),
('Guiso: Pollo', 0.00),
('Guiso: Cerdo', 0.00),
('Guiso: Res', 0.00),
('Guiso: Especial', 0.00),
('Agua: Jamaica', 0.00),
('Agua: Horchata', 0.00),
('Agua: Limón/Día', 0.00),
('Postre del Día', 0.00);

--PRODUCTO_COMPONENTE  (Paquetes + Comida Corrida)
   

--Paquete Quemes = 1 Caldo de Pozole + 1 Agua del Día
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Quemes'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Caldo de Pozole' AND categoria_id = 14),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Quemes'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
);

--Paquete Regional = 1 Carne de Chinameca + 1 Agua del Día + 1 Orden de Tortillas
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Regional'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Carne de Chinameca' AND categoria_id = 12),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Regional'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Regional'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Orden de Tortillas a mano 3pzs' AND categoria_id = 27),
  1
);

-- Paquete Desayunes = 1 Motuleños + 1 Café con leche grande + 1 Orden de Tortillas
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Desayunes'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Motuleños' AND categoria_id = 11),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Desayunes'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Café con leche grande' AND categoria_id = 20),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Desayunes'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Orden de Tortillas a mano 3pzs' AND categoria_id = 27),
  1
);

--Paquete Llenes = 1 Chilaquiles c/Pollo y Bisteck + 1 Agua del Día
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Llenes'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Chilaquiles con pollo y bistec' AND categoria_id = 12),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Llenes'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
);

-- Paquete Rico = 1 Memela de carne (usamos Memela Carne asada) + 1 Agua del Día
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Rico'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Carne asada' AND categoria_id = 2),  -- Memela carne asada
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Rico'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
);

-- Paquete Norteño = 1 Filete a la Tampiqueña + 1 Agua del Día + 1 Orden de Tortillas
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Norteño'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Filete a la Tampiqueña' AND categoria_id = 12),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Norteño'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Norteño'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Orden de Tortillas a mano 3pzs' AND categoria_id = 27),
  1
);

-- Paquete Guste = 1 Cecina Huasteca + 1 Agua del Día + 1 Orden de Tortillas
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Guste'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Cecina Huasteca' AND categoria_id = 12),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Guste'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Guste'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Orden de Tortillas a mano 3pzs' AND categoria_id = 27),
  1
);

--Paquete Piques = 3 Picaditas de carne (Picada Carne asada) + 1 Agua del Día
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Piques'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Carne asada' AND categoria_id = 1),  -- Picada carne asada
  3
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Piques'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
);

--Paquete Dobles = 1 Orden de Dobladas (Enfrijoladas) + 1 Agua del Día
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Dobles'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Enfrijoladas con pollo (3 pzs)' AND categoria_id = 8),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Dobles'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
);

--Paquete Alcance = 3 Empanadas sencillas de carne (Empanada Carne asada) + 1 Agua del Día
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Alcance'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Carne asada' AND categoria_id = 6),  -- Empanada carne asada
  3
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Alcance'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
);

-- Paquete Nutras = 2 Tostadas de carne (Tostada Pollo) + 1 Plátano Frito + 1 Agua del Día
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Nutras'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Pollo' AND categoria_id = 7),  -- Tostada de pollo (como tostada de carne)
  2
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Nutras'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Platanitos fritos' AND categoria_id = 9),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Paquete Nutras'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
);

-- Comida Corrida del Día = 1 Agua del Día + 1 Postre del día
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
  (SELECT producto_id FROM producto WHERE nombre = 'Comida Corrida del Día'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Agua del Día (Lunes-Viernes)' AND categoria_id = 19),
  1
),
(
  (SELECT producto_id FROM producto WHERE nombre = 'Comida Corrida del Día'),
  (SELECT producto_id FROM producto 
     WHERE nombre = 'Postre del día' AND categoria_id = 24),
  1
);
