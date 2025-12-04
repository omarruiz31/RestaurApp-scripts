DROP TABLE IF EXISTS historial_preparacion CASCADE;
DROP TABLE IF EXISTS detalle_promocion CASCADE;
DROP TABLE IF EXISTS detalle_modificador CASCADE;
DROP TABLE IF EXISTS detalle_orden CASCADE;
DROP TABLE IF EXISTS detalle_pago CASCADE;
DROP TABLE IF EXISTS sesion CASCADE;
DROP TABLE IF EXISTS pago CASCADE;
DROP TABLE IF EXISTS comensal CASCADE;
DROP TABLE IF EXISTS ordenMesa CASCADE;
DROP TABLE IF EXISTS orden CASCADE;
DROP TABLE IF EXISTS reserva CASCADE;
DROP TABLE IF EXISTS dispositivo CASCADE;
DROP TABLE IF EXISTS area_impresion CASCADE;
DROP TABLE IF EXISTS empleado CASCADE;
DROP TABLE IF EXISTS mesa CASCADE;
DROP TABLE IF EXISTS areaventa CASCADE;
DROP TABLE IF EXISTS producto_componente CASCADE;
DROP TABLE IF EXISTS producto CASCADE;
DROP TABLE IF EXISTS categoria CASCADE;
DROP TABLE IF EXISTS sucursal_menu CASCADE;
DROP TABLE IF EXISTS menu CASCADE;
DROP TABLE IF EXISTS area_cocina CASCADE;
DROP TABLE IF EXISTS promocion CASCADE;
DROP TABLE IF EXISTS descuento CASCADE;
DROP TABLE IF EXISTS metodo_pago CASCADE;
DROP TABLE IF EXISTS modificador CASCADE;
DROP TABLE IF EXISTS rol CASCADE;
DROP TABLE IF EXISTS sucursal CASCADE;
DROP TABLE IF EXISTS restaurante CASCADE;
DROP TYPE IF EXISTS estado_mesa CASCADE;

CREATE TABLE restaurante(
    restaurante_id SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    RFC VARCHAR (120)
);

CREATE TABLE sucursal(
    sucursal_id SERIAL PRIMARY KEY,
    restaurante_id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    direccion VARCHAR(120) NOT NULL,
    region VARCHAR(60),
    telefono VARCHAR(100),

    CONSTRAINT fk_restaurant
    FOREIGN KEY(restaurante_id)
    REFERENCES restaurante(restaurante_id)
    ON UPDATE CASCADE
);

CREATE TABLE rol(
    rol_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(60)
);


CREATE TABLE empleado(
    empleado_id SERIAL PRIMARY KEY,
    sucursal_id INT NOT NULL,
    rol_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    contraseña VARCHAR(255) NOT NULL,
    numero_autorizacion VARCHAR(100) DEFAULT NULL, -- campo nuevo 
    

    CONSTRAINT fk_rol
        FOREIGN KEY(rol_id)
        REFERENCES rol(rol_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    
    CONSTRAINT fk_empleado_sucursal
        FOREIGN KEY(sucursal_id)
        REFERENCES sucursal(sucursal_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE areaventa(
    area_id SERIAL PRIMARY KEY,
    sucursal_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT fk_sucursal_area
        FOREIGN KEY (sucursal_id)
        REFERENCES sucursal(sucursal_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


--Crear el enum
CREATE TYPE estado_mesa AS ENUM ('libre', 'ocupada', 'reservada');

--OPCION 2 

CREATE TABLE mesa(
    mesa_id SERIAL PRIMARY KEY,
    area_id INT NOT NULL,
    num_mesa INT NOT NULL,
    estado estado_mesa NOT NULL DEFAULT 'libre',

    CONSTRAINT fk_area
        FOREIGN KEY (area_id)
        REFERENCES areaventa(area_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_mesa_por_area --restriccion nueva 
    UNIQUE (area_id, num_mesa)
);

CREATE TABLE orden (
    orden_id SERIAL PRIMARY KEY,
    fecha_hora_inicio TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_hora_cierre TIMESTAMP,
    estado BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE ordenMesa(
    orden_id INT NOT NULL,
    mesa_id INT NOT NULL,

    CONSTRAINT pk_orden_mesa
        PRIMARY KEY (orden_id, mesa_id),

    CONSTRAINT fk_cm_orden
        FOREIGN KEY (orden_id)
        REFERENCES orden(orden_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    
    CONSTRAINT fk_cm_mesa
        FOREIGN KEY (mesa_id)
        REFERENCES mesa(mesa_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE comensal(
    comensal_id SERIAL PRIMARY KEY,
    orden_id INT NOT NULL,
    nombre_etiqueta VARCHAR(40),

    CONSTRAINT fk_orden_comensal
        FOREIGN KEY(orden_id)
        REFERENCES orden(orden_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE reserva(
    reserva_id SERIAL PRIMARY KEY,
    mesa_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(12),
    num_acompañantes INT NOT NULL,
    fecha_hora_reserva TIMESTAMP NOT NULL,
    CONSTRAINT fk_mesa_reserva
        FOREIGN KEY (mesa_id)
        REFERENCES mesa(mesa_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);




CREATE TABLE menu(
    menu_id SERIAL PRIMARY KEY,
    sucursal_id INT ,
    nombre VARCHAR(100) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT NOW(),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_sucursal
        FOREIGN KEY (sucursal_id)
        REFERENCES sucursal(sucursal_id)
        ON UPDATE CASCADE ON DELETE RESTRICT

);

CREATE TABLE sucursal_menu(
    sucursal_id INT,
    menu_id INT,

    CONSTRAINT pk_sucursal_menu
        PRIMARY KEY (sucursal_id, menu_id),

    CONSTRAINT fk_sucursal
        FOREIGN KEY(sucursal_id)
        REFERENCES sucursal(sucursal_id),
    
    CONSTRAINT fk_menu
    FOREIGN KEY(menu_id)
    REFERENCES menu(menu_id)
);

CREATE TABLE categoria(
    categoria_id SERIAL PRIMARY KEY,
    menu_id INT NOT NULL,
    nombre VARCHAR(100),
        CONSTRAINT fk_menu
            FOREIGN KEY (menu_id)
            REFERENCES menu(menu_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);

CREATE TABLE producto(
    producto_id SERIAL PRIMARY KEY,
    categoria_id INT ,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_unitario NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    es_paquete BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_categoria_producto
        FOREIGN KEY (categoria_id)
        REFERENCES categoria(categoria_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE producto_componente (
    id_componente SERIAL PRIMARY KEY,
    id_producto_padre INT NOT NULL, 
    id_producto_hijo INT NOT NULL,  
    cantidad NUMERIC(10,2) DEFAULT 1,
    
    CONSTRAINT fk_comp_padre
        FOREIGN KEY (id_producto_padre)
        REFERENCES producto(producto_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_comp_hijo
        FOREIGN KEY (id_producto_hijo)
        REFERENCES producto(producto_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

);


CREATE TABLE modificador(
    modificador_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio NUMERIC(10,2) NOT NULL DEFAULT 0.00
);

CREATE TABLE metodo_pago(
    metodo_id SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    es_efectivo BOOLEAN,
    referencia VARCHAR(200)
);

CREATE TABLE pago(
    pago_id SERIAL PRIMARY KEY,
    metodo_id INT NOT NULL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    monto NUMERIC(10,2),
    propina NUMERIC(10,2),

    CONSTRAINT fk_metodo
    FOREIGN KEY(metodo_id)
    REFERENCES metodo_pago(metodo_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    
);


CREATE TABLE descuento(
    descuento_id SERIAL PRIMARY KEY,
    nombre_convenio VARCHAR(120) NOT NULL,
    tipo VARCHAR(100),
    porcentaje NUMERIC(10,2),
    monto_fijo NUMERIC(10,2),
    empresa VARCHAR(120),
    monedero_ahorro  NUMERIC(10,2),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    necesita_autorizacion BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE detalle_pago(
    detalle_pago_id SERIAL PRIMARY KEY,
    orden_id INT ,
    comensal_id INT,
    pago_id INT,
    descuento_id INT,

    CONSTRAINT fk_orden
    FOREIGN KEY(orden_id)
    REFERENCES orden(orden_id),

    CONSTRAINT fk_comensal
    FOREIGN KEY(comensal_id)
    REFERENCES comensal(comensal_id),

    CONSTRAINT fk_pago
    FOREIGN KEY(pago_id)
    REFERENCES pago(pago_id),

    CONSTRAINT fk_descuento
    FOREIGN KEY(descuento_id)
    REFERENCES descuento(descuento_id)
);  

CREATE TABLE promocion(
    promocion_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    esta_activo BOOLEAN NOT NULL DEFAULT TRUE,
    valor_porcentaje NUMERIC(5,2),
    monto_minimo NUMERIC(10,2),
    fecha_hora_inicio TIMESTAMP,
    fecha_hora_fin TIMESTAMP,
    dias_aplicables VARCHAR(120), 
    tipo_beneficio VARCHAR(100) NOT NULL
);


CREATE TABLE area_impresion (
    area_impresion_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    ip INET,
    tipo_impresora VARCHAR(60),
    estado VARCHAR(20) NOT NULL DEFAULT 'activo'
);

CREATE TABLE dispositivo(
    dispositivo_id SERIAL PRIMARY KEY,
    area_impresion_id INT NOT NULL,
    fecha_registro TIMESTAMP NOT NULL DEFAULT NOW(),
    tipo VARCHAR(100),
    estado VARCHAR(100),
    modelo VARCHAR(60),

    CONSTRAINT fk_area_impresion 
    FOREIGN KEY(area_impresion_id)
    REFERENCES area_impresion(area_impresion_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE detalle_orden(
    detalle_orden_id SERIAL PRIMARY KEY,
    comensal_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad  NUMERIC(10,2),
    precio_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_detalle_comensal
        FOREIGN KEY (comensal_id)
        REFERENCES comensal(comensal_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY(producto_id)
        REFERENCES producto(producto_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
    
);

CREATE TABLE detalle_modificador(
    detalle_modificador SERIAL  PRIMARY KEY,
    detalle_orden_id INT NOT NULL,
    modificador_id INT,
    cantidad NUMERIC(10,2) NOT NULL DEFAULT 1,
    precio_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_dm_detalle
        FOREIGN KEY(detalle_orden_id)
        REFERENCES detalle_orden(detalle_orden_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_dm_modificador
        FOREIGN KEY(modificador_id)
        REFERENCES modificador(modificador_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE detalle_promocion(

    detalle_orden_id INT NOT NULL,
    promocion_id INT NOT NULL,

    CONSTRAINT pk_detalle_promocion
    PRIMARY KEY(detalle_orden_id,promocion_id),

    CONSTRAINT fk_detalle
    FOREIGN KEY (detalle_orden_id)
    REFERENCES detalle_orden(detalle_orden_id),

    CONSTRAINT fk_promocion
    FOREIGN KEY(promocion_id)
    REFERENCES promocion(promocion_id)
);

CREATE TABLE sesion(
    sesion_id SERIAL PRIMARY KEY,
    empleado_id INT NOT NULL,
    dispositivo_id INT NOT NULL,
    fecha_hora_apertura TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_hora_cierre TIMESTAMP,
    efectivo_inicial NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    efectivo_cierre_conteo NUMERIC(10,2),
    efectivo_cierre_sistema NUMERIC(10,2),
    diferencia NUMERIC(10,2),
    estado VARCHAR(20) NOT NULL DEFAULT 'abierta',

    CONSTRAINT fk_sesion_empleado
        FOREIGN KEY (empleado_id)
        REFERENCES empleado(empleado_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_sesion_dispositivo
        FOREIGN KEY (dispositivo_id)
        REFERENCES dispositivo(dispositivo_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

);

CREATE TABLE area_cocina (
    area_cocina_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_area VARCHAR(100),
    estado VARCHAR(30) DEFAULT 'activo'
);

CREATE TABLE historial_preparacion(
    historial_preparacion_id SERIAL PRIMARY KEY,
    detalle_orden_id INT NOT NULL,
    area_cocina_id INT NOT NULL,
    estado VARCHAR(100) NOT NULL,
    fecha_hora_preparacion TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_detalle
    FOREIGN KEY(detalle_orden_id)
    REFERENCES detalle_orden(detalle_orden_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

    CONSTRAINT fk_historial_area
    FOREIGN KEY(area_cocina_id)
    REFERENCES area_cocina(area_cocina_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    
);

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

  INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, estado, contraseña, numero_autorizacion)
VALUES
    -- Sucursal 1: Soriana Cuauhtémoc (Mina)
    (1, 7, 'María',   'Gómez',      TRUE, 'pass123', 'AUTH-S1-001'),  -- Gerente de sucursal
    (1, 2, 'Luis',    'Cruz',       TRUE, 'pass123', NULL),           -- Mesero
    (1, 2, 'Ana',     'Martínez',   TRUE, 'pass123', NULL),           -- Mesera
    (1, 2, 'Carlos',  'Ramírez',    TRUE, 'pass123', NULL),           -- Mesero
    (1, 8, 'Pedro',   'López',      TRUE, 'pass123', NULL),           -- Cocinero
    (1, 9, 'Daniel',  'Hernández',  TRUE, 'pass123', NULL),           -- Ayudante de cocina
    (1,10, 'Carla',   'Reyes',      TRUE, 'pass123', NULL),           -- Cajera
    (1, 1, 'Jorge',   'Pérez',      TRUE, 'pass123', NULL),           -- Auxiliar administrativo
    (1, 5, 'Laura',   'Hernández',  TRUE, 'pass123', NULL),           -- Auxiliar de RRHH
    (1, 6, 'Miguel',  'Vargas',     TRUE, 'pass123', NULL),           -- Auxiliar de mantenimiento
    (1, 4, 'Sofía',   'Rangel',     TRUE, 'pass123', NULL),           -- Auditor

    -- Sucursal 2: Centro Mina
    (2, 7, 'Ricardo', 'Navarro',    TRUE, 'pass123', 'AUTH-S2-001'),  -- Gerente
    (2, 2, 'Elena',   'Castillo',   TRUE, 'pass123', NULL),           -- Mesera
    (2, 2, 'Diego',   'Santos',     TRUE, 'pass123', NULL),           -- Mesero
    (2, 8, 'Hugo',    'Mendoza',    TRUE, 'pass123', NULL),           -- Cocinero
    (2, 9, 'Brenda',  'Ortiz',      TRUE, 'pass123', NULL),           -- Ayudante
    (2,10, 'Nadia',   'Flores',     TRUE, 'pass123', NULL),           -- Cajera
    (2, 6, 'Óscar',   'Luna',       TRUE, 'pass123', NULL),           -- Mantenimiento

    -- Sucursal 3: Instituto Tecnológico (Mina)
    (3, 7, 'Patricia','Rivera',     TRUE, 'pass123', 'AUTH-S3-001'),  -- Gerente
    (3, 2, 'Iván',    'Torres',     TRUE, 'pass123', NULL),           -- Mesero
    (3, 2, 'Fabiola', 'Juárez',     TRUE, 'pass123', NULL),           -- Mesera
    (3, 8, 'Marco',   'Aguilar',    TRUE, 'pass123', NULL),           -- Cocinero
    (3, 9, 'Cintia',  'Salas',      TRUE, 'pass123', NULL),           -- Ayudante
    (3,10, 'Raúl',    'Pacheco',    TRUE, 'pass123', NULL),           -- Cajero

    -- Sucursal 4: Centro (Coatza) - sucursal central
    (4, 7, 'Alejandro','Domínguez', TRUE, 'pass123', 'AUTH-S4-001'),  -- Gerente
    (4, 2, 'Karla',   'Mora',       TRUE, 'pass123', NULL),           -- Mesera
    (4, 2, 'Sergio',  'Ibarra',     TRUE, 'pass123', NULL),           -- Mesero
    (4, 2, 'Yazmín',  'Salazar',    TRUE, 'pass123', NULL),           -- Mesera
    (4, 8, 'Noé',     'Cortés',     TRUE, 'pass123', NULL),           -- Cocinero
    (4, 9, 'Liliana', 'Rosales',    TRUE, 'pass123', NULL),           -- Ayudante
    (4,10, 'Eric',    'Velázquez',  TRUE, 'pass123', NULL),           -- Cajero
    (4, 1, 'Claudia', 'Mejía',      TRUE, 'pass123', NULL),           -- Auxiliar administrativo
    (4, 5, 'Adriana', 'Pineda',     TRUE, 'pass123', NULL),           -- Auxiliar RRHH
    (4, 6, 'Tomás',   'Galindo',    TRUE, 'pass123', NULL),           -- Mantenimiento

    -- Sucursal 5: Soriana Palmar
    (5, 7, 'Fernando','Zamora',     TRUE, 'pass123', 'AUTH-S5-001'),  -- Gerente
    (5, 2, 'Rocío',   'Campos',     TRUE, 'pass123', NULL),           -- Mesera
    (5, 2, 'Julio',   'Peña',       TRUE, 'pass123', NULL),           -- Mesero
    (5, 8, 'Gabriel', 'Solís',      TRUE, 'pass123', NULL),           -- Cocinero
    (5, 9, 'Paola',   'Delgado',    TRUE, 'pass123', NULL),           -- Ayudante
    (5,10, 'Inés',    'Bernal',     TRUE, 'pass123', NULL),           -- Cajera

    -- Sucursal 6: Soriana Mercado
    (6, 7, 'Héctor',  'Castañeda',  TRUE, 'pass123', 'AUTH-S6-001'),  -- Gerente
    (6, 2, 'Nancy',   'Quiroz',     TRUE, 'pass123', NULL),           -- Mesera
    (6, 2, 'Omar',    'Lagos',      TRUE, 'pass123', NULL),           -- Mesero
    (6, 8, 'Ulises',  'Carrillo',   TRUE, 'pass123', NULL),           -- Cocinero
    (6, 9, 'Rebeca',  'Fierro',     TRUE, 'pass123', NULL),           -- Ayudante
    (6,10, 'Diana',   'Acosta',     TRUE, 'pass123', NULL),           -- Cajera

    -- Sucursal 7: Malecón
    (7, 7, 'Ramón',   'Arriaga',    TRUE, 'pass123', 'AUTH-S7-001'),  -- Gerente
    (7, 2, 'Mónica',  'García',     TRUE, 'pass123', NULL),           -- Mesera
    (7, 2, 'Javier',  'Franco',     TRUE, 'pass123', NULL),           -- Mesero
    (7, 8, 'Israel',  'Nieto',      TRUE, 'pass123', NULL),           -- Cocinero
    (7, 9, 'Paty',    'Corona',     TRUE, 'pass123', NULL),           -- Ayudante
    (7,10, 'Bruno',   'Silva',      TRUE, 'pass123', NULL),           -- Cajero

    -- Sucursal 8: Gaviotas
    (8, 7, 'Esteban', 'Méndez',     TRUE, 'pass123', 'AUTH-S8-001'),  -- Gerente
    (8, 2, 'Luz',     'Arellano',   TRUE, 'pass123', NULL),           -- Mesera
    (8, 2, 'Carlos',  'Mora',       TRUE, 'pass123', NULL),           -- Mesero
    (8, 8, 'Iván',    'Cano',       TRUE, 'pass123', NULL),           -- Cocinero
    (8, 9, 'Marisol', 'León',       TRUE, 'pass123', NULL),           -- Ayudante
    (8,10, 'Pablo',   'Esquivel',   TRUE, 'pass123', NULL);           -- Cajero


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
('Tarjeta de débito', FALSE, 'Visa, Mastercard');



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

-- Vincular el menú a la sucursal
INSERT INTO sucursal_menu (sucursal_id, menu_id) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1);


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
(28, 'Bisteces a la Mexicana con frijoles refritos', 194.26, 'Plato fuerte', FALSE),
(28, 'Fajitas de res a la mostaza con arroz blanco', 138.11, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete a la Barbecue con papas', 123.48, 'Plato fuerte', FALSE),
(28, 'Rollito de Carne relleno de verduras con arroz', 212.46, 'Plato fuerte', FALSE),
(28, 'Tortitas de Carne de res deshebrada en chipotle', 143.21, 'Plato fuerte', FALSE),
(28, 'Fajitas de Res adobadas con papas y frijoles', 137.72, 'Plato fuerte', FALSE),
(28, 'Cuete Mechado de verduras con arroz blanco', 212.59, 'Plato fuerte', FALSE),
(28, 'Ropa Vieja de Res con frijoles refritos', 173.46, 'Plato fuerte', FALSE),
(28, 'Barbacoa de Res con frijoles refritos', 186.28, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete a la mostaza con arroz', 143.65, 'Plato fuerte', FALSE),
(28, 'Albondigas Enchipotladas con arroz blanco', 179.44, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete en salsa de toronja', 188.38, 'Plato fuerte', FALSE),
(28, 'Bisteces de Res a la Poblana con frijol', 186.91, 'Plato fuerte', FALSE),
(28, 'Carne deshebrada a la Mexicana con frijol', 217.89, 'Plato fuerte', FALSE),
(28, 'Bisteces de res al albañil con frijoles', 197.20, 'Plato fuerte', FALSE),
(28, 'Birria de Res con frijoles refritos', 135.25, 'Plato fuerte', FALSE),
(28, 'Carne Polaca de res con frijoles refritos', 124.36, 'Plato fuerte', FALSE),
(28, 'Pastel de Carne con arroz blanco', 125.39, 'Plato fuerte', FALSE),
(28, 'Bisteces Rancheros con frijoles refritos', 177.56, 'Plato fuerte', FALSE),
(28, 'Brochetas de Res con ensalada', 158.54, 'Plato fuerte', FALSE),
(28, 'Bisteces Arrieros de Res con frijoles', 167.57, 'Plato fuerte', FALSE),
(28, 'Caldo de Mondongo (Platillo)', 209.87, 'Plato fuerte', FALSE),
(28, 'Fajitas Lázaro de Bisteces con arroz blanco', 172.55, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete en salsa chipotle', 193.14, 'Plato fuerte', FALSE),
(28, 'Bisteces Encebollados de Res con frijoles', 219.01, 'Plato fuerte', FALSE),
(28, 'Medallones de Cuete en Salsa de champiñones', 203.65, 'Plato fuerte', FALSE),
(28, 'Milanesa de Res con ensalada y frijoles', 146.25, 'Plato fuerte', FALSE);

-- CAT 29: CERDO
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(29, 'Cerdo Enchilado con arroz blanco', 169.49, 'Plato fuerte', FALSE),
(29, 'Costillas de Cerdo adobadas con arroz', 213.78, 'Plato fuerte', FALSE),
(29, 'Bisteces Encebollados de Cerdo con ensalada', 139.77, 'Plato fuerte', FALSE),
(29, 'Cerdo en Salsa de Cacahuate con frijoles', 185.28, 'Plato fuerte', FALSE),
(29, 'Cochinita Pibil con papas y arroz blanco', 205.30, 'Plato fuerte', FALSE),
(29, 'Milanesa de Cerdo con ensalada', 198.81, 'Plato fuerte', FALSE),
(29, 'Costillas de Cerdo de Salsa Verde con arroz', 122.89, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Coca Cola con papas de arroz', 163.55, 'Plato fuerte', FALSE),
(29, 'Costillas de Cerdo en salsa agridulce', 153.69, 'Plato fuerte', FALSE),
(29, 'Puerco en Salsa de Perejil con papas', 217.06, 'Plato fuerte', FALSE),
(29, 'Mole de Cerdo con arroz blanco', 127.84, 'Plato fuerte', FALSE),
(29, 'Cerdo al Pipián con arroz blanco', 207.80, 'Plato fuerte', FALSE),
(29, 'Cerdo en Salsa Pasilla con arroz blanco', 175.08, 'Plato fuerte', FALSE),
(29, 'Carne de Cerdo en salsa de ciruela pasa', 157.48, 'Plato fuerte', FALSE),
(29, 'Carne de Cerdo Adobada con arroz blanco', 192.41, 'Plato fuerte', FALSE),
(29, 'Chuletas de Cerdo a la barbecue con ensalada', 182.60, 'Plato fuerte', FALSE),
(29, 'Carne de Cerdo en salsa verde con arroz', 143.07, 'Plato fuerte', FALSE),
(29, 'Cerdo en Salsa agridulce con arroz blanco', 174.64, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Naranja con arroz blanco', 122.33, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Mestiza con arroz blanco', 170.43, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Cerveza con arroz blanco', 167.58, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Barbecue con papas y arroz', 208.60, 'Plato fuerte', FALSE),
(29, 'Costillas de Cerdo enchipotladas con papas', 178.81, 'Plato fuerte', FALSE),
(29, 'Chuletas de Cerdo a la Plancha con ensalada', 179.83, 'Plato fuerte', FALSE),
(29, 'Cerdo con calabacitas y granos de elote', 171.07, 'Plato fuerte', FALSE),
(29, 'Cerdo en Salsa de Tamarindo con arroz', 135.97, 'Plato fuerte', FALSE),
(29, 'Cerdo a la Hawaiana con arroz blanco', 219.57, 'Plato fuerte', FALSE),
(29, 'Cerdo con Verdolagas con frijoles refritos', 210.01, 'Plato fuerte', FALSE);


INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(30, 'Pollos a la Naranja con arroz blanco', 214.17, 'Plato fuerte', FALSE),
(30, 'Pollo a la barbecue con papitas y arroz', 209.47, 'Plato fuerte', FALSE),
(30, 'Pollo a la crema de Queso con arroz', 135.81, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo a la Mantequilla con ensalada', 176.17, 'Plato fuerte', FALSE),
(30, 'Pollo a la Hawaiana con arroz blanco', 130.67, 'Plato fuerte', FALSE),
(30, 'Pechugas rellenas de Jamón y Queso', 120.78, 'Plato fuerte', FALSE),
(30, 'Pollo en Pipián con arroz blanco y frijoles', 151.37, 'Plato fuerte', FALSE),
(30, 'Mole de Pollo con arroz blanco', 169.05, 'Plato fuerte', FALSE),
(30, 'Milanesa de Pollo con Ensalada', 125.37, 'Plato fuerte', FALSE),
(30, 'Pollo Kentucky con ensalada', 171.91, 'Plato fuerte', FALSE),
(30, 'Pollo Adobado con arroz blanco', 142.48, 'Plato fuerte', FALSE),
(30, 'Barbacoa de Pollo con arroz blanco', 216.33, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo al Orégano con arroz', 141.79, 'Plato fuerte', FALSE),
(30, 'Pollo en Salsa de Limón con arroz blanco', 142.69, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo en Salsa de chile morita', 137.21, 'Plato fuerte', FALSE),
(30, 'Pollo Entomatado con arroz blanco', 131.20, 'Plato fuerte', FALSE),
(30, 'Pollo Campirano con papas y arroz blanco', 164.17, 'Plato fuerte', FALSE),
(30, 'Pollo con Champiñones con arroz blanco', 172.86, 'Plato fuerte', FALSE),
(30, 'Pollo Frito con ensalada', 190.78, 'Plato fuerte', FALSE),
(30, 'Pollo en Escabeche con arroz blanco', 148.49, 'Plato fuerte', FALSE),
(30, 'Pollo en Salsa de Perejil con arroz blanco', 128.09, 'Plato fuerte', FALSE),
(30, 'Pollo Pibil con arroz blanco', 179.13, 'Plato fuerte', FALSE),
(30, 'Pechugas a la Cordón Blue con ensalada', 133.45, 'Plato fuerte', FALSE),
(30, 'Pollo en Mole Verde con arroz blanco', 217.16, 'Plato fuerte', FALSE),
(30, 'Pollo Supremo con arroz blanco', 199.92, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo en Salsa de aguacate', 165.94, 'Plato fuerte', FALSE),
(30, 'Pollo a la Vizcaina con frijoles refritos', 176.14, 'Plato fuerte', FALSE),
(30, 'Estofado de Pollo con arroz blanco', 135.16, 'Plato fuerte', FALSE),
(30, 'Pollo bañado en Salsa Verde con arroz', 204.21, 'Plato fuerte', FALSE),
(30, 'Pollo Enchipotlado con arroz blanco', 206.41, 'Plato fuerte', FALSE),
(30, 'Filete de Pollo a la barbecue con ensalada', 153.73, 'Plato fuerte', FALSE),
(30, 'Pollo a la Jardinera con arroz blanco', 157.30, 'Plato fuerte', FALSE),
(30, 'Pechugas adobadas con papas y arroz', 138.94, 'Plato fuerte', FALSE),
(30, 'Tortitas de Pollo Deshebrado en salsa verde', 158.13, 'Plato fuerte', FALSE);

-- CAT 31: MARISCOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(31, 'Filete de Pescado a la Mantequilla', 190.88, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado a la Pimienta con ensalada', 195.31, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado empanizado con ensalada', 183.61, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado a la Veracruzana', 210.77, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado al mojo de ajo', 138.72, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado a la Poblana con arroz', 197.04, 'Plato fuerte', FALSE),
(31, 'Filete de Pescado en salsa de Perejil', 208.08, 'Plato fuerte', FALSE),
(31, 'Pulpos al Ajillo con arroz blanco', 143.38, 'Plato fuerte', FALSE),
(31, 'Pulpos a la Veracruzana con arroz blanco', 206.31, 'Plato fuerte', FALSE),
(31, 'Pulpos Enchipotlados con arroz blanco', 156.62, 'Plato fuerte', FALSE),
(31, 'Pulpos al Mojo de Ajo con arroz blanco', 166.23, 'Plato fuerte', FALSE),
(31, 'Pulpo a la Diabla con arroz blanco', 205.87, 'Plato fuerte', FALSE);


INSERT INTO producto (categoria_id, nombre, precio_unitario, descripcion, es_paquete) VALUES
(32, 'Ensalada de Pollo con tostadas', 183.21, 'Platillo', FALSE),
(32, 'Enchiladas Verdes con Pollo', 171.66, 'Platillo', FALSE),
(32, 'Enfrijoladas de Pollo', 170.46, 'Platillo', FALSE),
(32, 'Crepas de Pollo con ensalada', 151.14, 'Platillo', FALSE),
(32, 'Croquetas de Pollo con ensalada', 188.32, 'Platillo', FALSE),
(32, 'Enchiladas Poblanas con Pollo', 129.96, 'Platillo', FALSE),
(32, 'Spaguetti con trocitos de Pollo a la Poblana', 151.27, 'Platillo', FALSE),
(32, 'Chiles Rellenos de Queso bañados en Tomate', 122.78, 'Platillo', FALSE),
(32, 'Chayote relleno de Picadillo Gratinado', 129.35, 'Platillo', FALSE),
(32, 'Tinga Poblana con frijoles refritos', 161.67, 'Platillo', FALSE),
(32, 'Spaguetti a la Boloñesa con Carne molida', 193.34, 'Platillo', FALSE),
(32, 'Entomatadas con Pollo', 154.68, 'Platillo', FALSE),
(32, 'Calabacitas Granitadas rellenas de carne', 210.59, 'Platillo', FALSE),
(32, 'Calabacitas rellenas de Jamón y Queso', 184.64, 'Platillo', FALSE),
(32, 'Chile Relleno de picadillo bañado en salsa', 173.23, 'Platillo', FALSE),
(32, 'Salpicón Tabasqueño con Tostadas', 176.77, 'Platillo', FALSE),
(32, 'Tacos Árabes con ensalada', 132.62, 'Platillo', FALSE),
(32, 'Spaguetti a la Mantequilla con Jamón y Tocino', 124.77, 'Platillo', FALSE),
(32, 'Chayote Capeado relleno de Jamón y Queso', 129.90, 'Platillo', FALSE),
(32, 'Papas Rellenas de jamón y queso', 188.61, 'Platillo', FALSE),
(32, 'Croquetas de Queso con ensalada', 121.50, 'Platillo', FALSE),
(32, 'Coliflor Lampreado rellena de Queso', 177.70, 'Platillo', FALSE),
(32, 'Acelgas rellenas de Jamón y Queso', 178.21, 'Platillo', FALSE);

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

/* =========================================================
   ADAPTACIÓN DE DATOS: MADISON GRILL -> MainRestaurApp
   ========================================================= */

-- 1. INSERTAR RESTAURANTE (Empresa Principal)
INSERT INTO restaurante (nombre, RFC) 
VALUES ('Madison Grill', 'MAD101010GRL');

-- 2. INSERTAR SUCURSALES
-- Se insertan todas las sucursales mencionadas, vinculadas al restaurante creado.
INSERT INTO sucursal (restaurante_id, nombre, direccion, region, telefono)
VALUES
((SELECT restaurante_id FROM restaurante WHERE nombre='Madison Grill' LIMIT 1), 'Madison Grill Coatzacoalcos', 'Av. Universidad #105, Coatzacoalcos, Veracruz', 'Sur de Veracruz', '9211234567'),
((SELECT restaurante_id FROM restaurante WHERE nombre='Madison Grill' LIMIT 1), 'Madison Grill Córdoba', 'Plaza Shangri-La, Córdoba, Veracruz', 'Centro de Veracruz', '2711234567'),
((SELECT restaurante_id FROM restaurante WHERE nombre='Madison Grill' LIMIT 1), 'Madison Grill Poliforum', 'Av. Lázaro Cárdenas, Frente al Velódromo, Xalapa, Veracruz', 'Xalapa', '2287654321'),
((SELECT restaurante_id FROM restaurante WHERE nombre='Madison Grill' LIMIT 1), 'Madison Grill Puebla', 'Zona Angelópolis, Puebla, Puebla', 'Puebla', '2221234567'),
((SELECT restaurante_id FROM restaurante WHERE nombre='Madison Grill' LIMIT 1), 'Madison Grill Xalapa', 'Av. Araucarias, Plaza Las Américas, Xalapa, Veracruz', 'Xalapa', '2281112222');

-- 3. INSERTAR MENÚ
-- Vinculado a la sucursal de Coatzacoalcos (según tu script original)
INSERT INTO menu (sucursal_id, nombre, hora_inicio, hora_fin)
VALUES (
    (SELECT sucursal_id FROM sucursal WHERE nombre='Madison Grill Coatzacoalcos' LIMIT 1),
    'Menú Principal Coatzacoalcos', 
    '12:00', 
    '23:59'
);

-- 4. INSERTAR CATEGORÍAS
-- Usamos una variable temporal implícita buscando el ID del menú
INSERT INTO categoria (menu_id, nombre) VALUES
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Entradas'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Sopas, Pastas & Ensaladas'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Taquería'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Ribs & Boneless'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Madison Kids'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Hamburguesas'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Cortes'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Paquetes y Sides'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Postres'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Madison Drinks'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Madison Coctelería'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Carajillos'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Cervezas'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Vinos'),
((SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos' LIMIT 1), 'Destilados');

-- 5. INSERTAR PRODUCTOS
-- 5.1 ENTRADAS
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Tiradito de papada de cerdo 300 gr', 'Acompañado de salsa chiltepín.', 195.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Molcajete de chicharrón de Rib Eye 200 gr', 'Chicharrón de Rib Eye con nopales, aguacate y cebolla al grill.', 430.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Queso fundido 200 gr', 'Queso fundido tradicional.', 145.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Queso fundido con chistorra 320 gr', 'Queso fundido con chistorra artesanal.', 160.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Tuétanos con arrachera 650 gr', 'Tuétano a la parrilla con arrachera flameada con mezcal.', 360.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Mollejas de res 400 gr', 'Mollejas fritas sobre cebolla tatemada.', 295.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Chicharrón de la Ramos 200 gr', 'Chicharrón tradicional en salsa verde.', 210.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Mochomos 280 gr', 'Filete de cerdo deshebrado con frijoles meneados.', 150.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Yakimeshi de la Ramos 90 gr', 'Arroz frito con camarón, chicharrón Ramos, aguacate y pasta Tampico.', 145.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Carpaccio de salmón 150 gr', 'Salmón con Parmigiano Reggiano, vinagreta y chile serrano.', 190.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Aguachile verde 150 gr', 'Camarón con salsa de chile serrano.', 155.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Aguachile negro 150 gr', 'Camarón con salsa de chile habanero.', 165.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Tostada de atún 80 gr', 'Atún fresco con mochomos, salsa ponzu y aguacate.', 95.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Guacamole tatemado 200 gr', 'Preparado en la mesa con chiles tatemados.', 115.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Coliflor 500 gr', 'Coliflor al grill con salsa chemita y Parmigiano Reggiano.', 120.00),
((SELECT categoria_id FROM categoria WHERE nombre='Entradas' AND menu_id=(SELECT menu_id FROM menu WHERE nombre='Menú Principal Coatzacoalcos') LIMIT 1), 'Papas trufadas 300 gr', 'Papas perfumadas con trufa y queso Parmigiano Reggiano.', 130.00);

-- 5.2 SOPAS Y PASTAS
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Sopas, Pastas & Ensaladas' LIMIT 1), 'Chicken chipotle 350 gr', 'Pasta fetuccini con pollo, chipotle y parmesano.', 170.00),
((SELECT categoria_id FROM categoria WHERE nombre='Sopas, Pastas & Ensaladas' LIMIT 1), 'Pasta Obregón 180 gr', 'Fetuccini con machaca, tomate deshidratado y Parmigiano Reggiano.', 160.00),
((SELECT categoria_id FROM categoria WHERE nombre='Sopas, Pastas & Ensaladas' LIMIT 1), 'Sopa de cecina 90 gr', 'Caldo rojo con cecina, aguacate, queso y tortilla.', 115.00),
((SELECT categoria_id FROM categoria WHERE nombre='Sopas, Pastas & Ensaladas' LIMIT 1), 'Carne en su jugo 200 gr', 'Fondo de res con diezmillo, tocino y frijoles.', 160.00),
((SELECT categoria_id FROM categoria WHERE nombre='Sopas, Pastas & Ensaladas' LIMIT 1), 'Ramen sonorense 200 gr', 'Ramen con barbacoa de res.', 155.00),
((SELECT categoria_id FROM categoria WHERE nombre='Sopas, Pastas & Ensaladas' LIMIT 1), 'Ensalada del chef 530 gr', 'Lechuga rizada, frutas, aguacate y queso de cabra.', 120.00),
((SELECT categoria_id FROM categoria WHERE nombre='Sopas, Pastas & Ensaladas' LIMIT 1), 'Ensalada dulce 530 gr', 'Lechuga con fresa, blueberry, tocino y aderezo de frambuesa.', 145.00),
((SELECT categoria_id FROM categoria WHERE nombre='Sopas, Pastas & Ensaladas' LIMIT 1), 'Ensalada César 250 gr', 'Ensalada César con pollo al grill y parmesano.', 195.00);

-- 5.3 TAQUERÍA
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Taquería' LIMIT 1), 'Tacos de barbacoa de brisket (3 pzas)', 'Brisket estilo Jalisco con cilantro y cebolla.', 175.00),
((SELECT categoria_id FROM categoria WHERE nombre='Taquería' LIMIT 1), 'Tacos de carnitas estilo Sonora (3 pzas)', 'Papada de cerdo con salsa chiltepín.', 165.00),
((SELECT categoria_id FROM categoria WHERE nombre='Taquería' LIMIT 1), 'Taco capitán (1 pza)', 'Camarón cocido con aderezo habanero y arroz frito.', 85.00),
((SELECT categoria_id FROM categoria WHERE nombre='Taquería' LIMIT 1), 'Taco de camarón (1 pza)', 'Camarón frito con panko, aguacate y habanero.', 85.00),
((SELECT categoria_id FROM categoria WHERE nombre='Taquería' LIMIT 1), 'Taco de pulpo (1 pza)', 'Pulpo zarandeado con pico de gallo y aguacate.', 130.00),
((SELECT categoria_id FROM categoria WHERE nombre='Taquería' LIMIT 1), 'Cachetada de Rib Eye (1 pza)', 'Torerita de rib eye con queso mozzarella y aguacate.', 110.00),
((SELECT categoria_id FROM categoria WHERE nombre='Taquería' LIMIT 1), 'Giro de trompo de Picanha (1 pza)', 'Pan árabe con picanha, verduras y papas.', 120.00),
((SELECT categoria_id FROM categoria WHERE nombre='Taquería' LIMIT 1), 'Taco de salmón estilo Baja (1 pza)', 'Salmón tempura con pico de gallo y aderezo.', 58.00);

-- 5.4 RIBS & BONELESS
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Ribs & Boneless' LIMIT 1), 'Baby back rib 650 gr', 'Costilla horneada con salsa a elegir.', 295.00),
((SELECT categoria_id FROM categoria WHERE nombre='Ribs & Boneless' LIMIT 1), 'Boneless de pollo 200 gr', 'Boneless bañados en salsa a elegir.', 130.00),
((SELECT categoria_id FROM categoria WHERE nombre='Ribs & Boneless' LIMIT 1), 'Perfect match 830 gr', 'Baby back rib y boneless con elote.', 379.00);

-- 5.5 MADISON KIDS
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Madison Kids' LIMIT 1), 'Slider de pollo (2 pzas, 100 gr)', 'Pollo crujiente con mayo y pepinillos. Con papas a la francesa.', 130.00),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Kids' LIMIT 1), 'Slider de res (2 pzas, 100 gr)', 'Carne smash Sonora con pepinillos. Con papas a la francesa.', 150.00),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Kids' LIMIT 1), 'Boneless de pollo (100 gr)', 'Pechuga de pollo al tempura con papas a la francesa.', 95.00);

-- 5.6 HAMBURGUESAS
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Buffalo Chicken Fried 130 gr', 'Pechuga crujiente con salsa búfalo, col y aderezo ranch.', 185.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Mozzarella Crunch 120 gr', 'Carne smash Sonora con mozzarella frita y aderezo fresh pickle.', 170.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Grilled Cheese Burger 240 gr', 'Doble carne smash Sonora, queso americano y aderezo de quesos.', 210.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Sonora Bacon 120 gr', 'Carne smash Sonora con doble tocino, aros de cebolla y aderezo tamarindo morita.', 175.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Mamba Burger 240 gr', 'Doble carne smash Sonora, queso americano y cebolla caramelizada.', 210.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Madison 120 gr', 'Carne smash Sonora con lechuga, betabel, piña asada, huevo estrellado y queso manchego.', 210.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Albardada 310 gr', 'Carne rellena de provolone, envuelta en tocino y bañada en BBQ.', 280.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Clásica de pollo 130 gr', 'Pechuga crujiente con tocino, pepinillos y salsa búfalo.', 160.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Beyond Burger 110 gr', 'Carne plant-based con champiñones, lechuga y cebolla morada.', 230.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Cheese Burger 120 gr', 'Carne smash Sonora con doble queso americano y pepinillos.', 140.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Slider de pollo 50 gr', 'Pollo crujiente con mayo y pepinillos.', 50.00),
((SELECT categoria_id FROM categoria WHERE nombre='Hamburguesas' LIMIT 1), 'Slider de res 50 gr', 'Carne smash Sonora con queso americano.', 60.00);

-- 5.7 CORTES
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Porterhouse 800 gr', 'Acompañado de papas a la francesa.', 1290.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Kansas City 500 gr', 'New York con hueso.', 750.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Cabrería 400 gr', 'Filete de res con hueso.', 495.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Centro de filete 200 gr', 'Acompañado de mantequilla de trufa.', 420.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Centro de filete 400 gr', 'Acompañado de mantequilla de trufa.', 680.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Filete Chemita 200 gr', 'Filete con papas y salsa agridulce.', 410.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Picanha 500 gr', 'Picanha al grill.', 650.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Vacío 300 gr', 'Corte argentino.', 480.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'New York 400 gr', 'Con chicharrón, guacamole y papas.', 550.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Black New York 400 gr', 'Con rub negro. Acompañado de puré de ajo.', 580.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Tomahawk', 'Precio por gramo. Con trufa y guacamole.', 1.55),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Medallones de Sirloin 500 gr', 'Sirloin premium.', 590.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Rib Eye 350 gr', 'Con mantequilla de trufa, chicharrón y guacamole.', 580.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Rib Eye 500 gr', 'Con mantequilla de trufa, chicharrón y guacamole.', 750.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Arrachera 330 gr', 'Arrachera al grill.', 395.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Filete a la pimienta 200 gr', 'Con salsa cremosa de pimienta.', 410.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Pechuga con adobo 350 gr', 'Bañada en adobo. Con puré.', 210.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Camarones zarandeados 250 gr', 'Con ensalada verde, arroz, tortillas y queso.', 395.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Pulpo a las brazas 200 gr', 'Pulpo al grill con ensalada y guarnición.', 490.00),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Salmón agridulce 300 gr', 'Salmón con papas adobadas.', 395.00);


-- 5.8 PAQUETES Y SIDES (PRODUCTOS PADRE Y EXTRAS)
-- Insertamos los paquetes y los items que faltaban del script original (Chorizos, etc)
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario, es_paquete) VALUES
-- Paquetes
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Brisket 1 kg (2-3 prs.)', 'Horneado 12 horas. Incluye guarnición predeterminada.', 680.00, TRUE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Madison Black (4-5 prs.)', 'Cabrería 200g, Kansas City 500g, Tomahawk 700g, New York 400g, Chorizo argentino 300g.', 2350.00, TRUE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Madison (4-5 prs.)', 'Arrachera 300g, Top Sirloin 300g, New York 300g, Rib Eye 300g, Chorizo español 300g.', 1470.00, TRUE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Olvidado (4-5 prs.)', 'Vacío 300g, Picanha 250g, Centro de filete 200g, Medallones Sirloin 500g, Chistorra 300g.', 1650.00, TRUE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Arrachera (3-4 prs.) 1 kg', 'Arrachera importada 1kg.', 990.00, TRUE),
-- Sides y Extras
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Frijoles meneados 210 gr', 'Frijoles puercos con queso.', 60.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Mac and Cheese 150 gr', 'Pasta con queso.', 110.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Guacamole Ramos 280 gr', 'Con chicharrón de La Ramos.', 105.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Elote amarillo (2 pzas.)', 'Elote tatemado.', 60.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Verduras al grill 250 gr', 'Verduras al carbón.', 60.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Puré de papa 200 gr', 'Con gravy.', 60.00, FALSE),
-- Items adicionales requeridos para los paquetes (que no estaban en cortes ni sides)
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Chorizo argentino 300 gr.', 'Chorizo argentino asado.', 0.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Chorizo español 300 gr.', 'Chorizo estilo español.', 0.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Cortes' LIMIT 1), 'Top Sirloin 300 gr', 'Corte de res, 300 g', 0.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Picanha 250 gr', 'Corte brasileño porción 250 g', 0.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Sides' LIMIT 1), 'Chistorra 300 gr', 'Chistorra 300 g incluida en paquete Olvidado', 0.00, FALSE);


-- 5.9 POSTRES, BEBIDAS Y LICORES (Resto de categorías)
INSERT INTO producto (categoria_id, nombre, descripcion, precio_unitario, es_paquete) VALUES
-- Postres
((SELECT categoria_id FROM categoria WHERE nombre='Postres' LIMIT 1), 'Pay de plátano 290 gr', 'Pay helado con plátano.', 145.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Postres' LIMIT 1), 'Cheesecake de coyota 290 gr', 'Cheesecake con base de coyota.', 165.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Postres' LIMIT 1), 'Flan de cajeta 280 gr', 'Flan tradicional.', 145.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Postres' LIMIT 1), 'Volcán de chocolate 240 gr', 'Bizcocho tibio relleno.', 140.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Postres' LIMIT 1), 'Cheesecake de Lotus', 'Tarta de queso con Lotus.', 240.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Postres' LIMIT 1), 'Cheesecake de pistache 190 gr', 'Mousse frío de pistache.', 165.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Postres' LIMIT 1), 'Oreo Frita 390 gr', 'Oreo al tempura.', 165.00, FALSE),

-- Drinks
((SELECT categoria_id FROM categoria WHERE nombre='Madison Drinks' LIMIT 1), 'Pop soda 350 ml', NULL, 58.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Drinks' LIMIT 1), 'Palomina 350 ml', NULL, 58.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Drinks' LIMIT 1), 'Familia Coca-Cola 355 ml', NULL, 45.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Drinks' LIMIT 1), 'Agua Ciel 600 ml', NULL, 31.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Drinks' LIMIT 1), 'Americano 250 ml', NULL, 40.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Drinks' LIMIT 1), 'Capuccino 330 ml', NULL, 48.00, FALSE),

-- Coctelería
((SELECT categoria_id FROM categoria WHERE nombre='Madison Coctelería' LIMIT 1), 'Necio', 'Ron blanco y manzana.', 139.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Coctelería' LIMIT 1), 'Mojito bichí', 'Ron blanco y yerbabuena.', 139.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Coctelería' LIMIT 1), 'Margarita clásica', 'Tequila y limón.', 150.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Madison Coctelería' LIMIT 1), 'Clericot', 'Vino tinto y frutas.', 139.00, FALSE),

-- Carajillos
((SELECT categoria_id FROM categoria WHERE nombre='Carajillos' LIMIT 1), 'Magnum', 'Con mini Magnum.', 145.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Carajillos' LIMIT 1), 'Mazapán', 'Con mazapán.', 130.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Carajillos' LIMIT 1), 'Clásico', 'Licor 43 y café.', 135.00, FALSE),

-- Cervezas
((SELECT categoria_id FROM categoria WHERE nombre='Cervezas' LIMIT 1), 'Agualegre 355 ml', NULL, 75.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Cervezas' LIMIT 1), 'Superior 355 ml', NULL, 49.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Cervezas' LIMIT 1), 'Heineken 355 ml', NULL, 59.00, FALSE),

-- Vinos
((SELECT categoria_id FROM categoria WHERE nombre='Vinos' LIMIT 1), 'Chateau Domecq Blend 750 ml', NULL, 870.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Vinos' LIMIT 1), 'Casa Madero 3V Blend 750 ml', NULL, 950.00, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Vinos' LIMIT 1), 'Don Leo Cabernet Sauvignon 750 ml', NULL, 980.00, FALSE),

-- Destilados
((SELECT categoria_id FROM categoria WHERE nombre='Destilados' LIMIT 1), 'Don Julio 70', 'Tequila Cristalino', 1800.00, FALSE);


-- 6. INSERTAR COMPONENTES DE PAQUETES (Lógica reconstruida por Nombres)

-- Paquete: Brisket 1 kg (Incluye side predeterminado: Puré de papa)
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
 (SELECT producto_id FROM producto WHERE nombre='Brisket 1 kg (2-3 prs.)' LIMIT 1),
 (SELECT producto_id FROM producto WHERE nombre='Puré de papa 200 gr' LIMIT 1),
 1
);

-- Paquete: Madison Black (Cabrería, Kansas, Tomahawk, NY, Chorizo Argentino)
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
((SELECT producto_id FROM producto WHERE nombre='Madison Black (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Cabrería 400 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Madison Black (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Kansas City 500 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Madison Black (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Tomahawk' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Madison Black (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='New York 400 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Madison Black (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Chorizo argentino 300 gr.' LIMIT 1), 1);

-- Paquete: Madison (Arrachera, Top Sirloin, NY, Rib Eye, Chorizo Español)
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
((SELECT producto_id FROM producto WHERE nombre='Madison (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Arrachera 330 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Madison (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Top Sirloin 300 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Madison (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='New York 400 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Madison (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Rib Eye 350 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Madison (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Chorizo español 300 gr.' LIMIT 1), 1);

-- Paquete: Olvidado (Vacío, Picanha, Centro Filete, Medallones, Chistorra)
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
((SELECT producto_id FROM producto WHERE nombre='Olvidado (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Vacío 300 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Olvidado (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Picanha 250 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Olvidado (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Centro de filete 200 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Olvidado (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Medallones de Sirloin 500 gr' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Olvidado (4-5 prs.)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Chistorra 300 gr' LIMIT 1), 1);

-- Paquete: Arrachera 1kg (Incluye: 3 Arracheras individuales)
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
(
 (SELECT producto_id FROM producto WHERE nombre='Arrachera (3-4 prs.) 1 kg' LIMIT 1),
 (SELECT producto_id FROM producto WHERE nombre='Arrachera 330 gr' LIMIT 1),
 3
);

/* =========================================================
   INFRAESTRUCTURA OPERATIVA: MADISON GRILL
   Roles, Empleados, Áreas, Mesas y Vinculación de Menú
   ========================================================= */

/* =========================================================
   INFRAESTRUCTURA OPERATIVA: MADISON GRILL
   Roles, Empleados con Nombres Reales, Áreas, Mesas
   ========================================================= */

-- 1. INSERTAR ROLES (Si no existen)
INSERT INTO rol (nombre, descripcion)
SELECT 'Gerente', 'Gerente de Sucursal' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'Gerente');
INSERT INTO rol (nombre, descripcion)
SELECT 'Mesero', 'Atención a comensales' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'Mesero');
INSERT INTO rol (nombre, descripcion)
SELECT 'Cajero', 'Cobro y facturación' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'Cajero');
INSERT INTO rol (nombre, descripcion)
SELECT 'Cocinero', 'Preparación de alimentos' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'Cocinero');

-- 2. INSERTAR ÁREAS DE VENTA
INSERT INTO areaventa (sucursal_id, nombre)
SELECT sucursal_id, 'Salón Principal' FROM sucursal WHERE nombre LIKE 'Madison Grill%';

INSERT INTO areaventa (sucursal_id, nombre)
SELECT sucursal_id, 'Terraza' FROM sucursal WHERE nombre LIKE 'Madison Grill%';

-- 3. INSERTAR MESAS
-- A. Mesas Salón Principal (1-10)
INSERT INTO mesa (area_id, num_mesa, estado)
SELECT av.area_id, s.num, 'libre'
FROM areaventa av
JOIN sucursal suc ON av.sucursal_id = suc.sucursal_id
CROSS JOIN generate_series(1, 10) AS s(num)
WHERE suc.nombre LIKE 'Madison Grill%' AND av.nombre = 'Salón Principal';

-- B. Mesas Terraza (11-15)
INSERT INTO mesa (area_id, num_mesa, estado)
SELECT av.area_id, s.num, 'libre'
FROM areaventa av
JOIN sucursal suc ON av.sucursal_id = suc.sucursal_id
CROSS JOIN generate_series(11, 15) AS s(num)
WHERE suc.nombre LIKE 'Madison Grill%' AND av.nombre = 'Terraza';

-- =========================================================
-- 4. INSERTAR EMPLEADOS CON NOMBRES REALES
-- =========================================================

-- A. GERENTES (1 por sucursal)
INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, numero_autorizacion, estado)
SELECT 
    s.sucursal_id,
    (SELECT rol_id FROM rol WHERE nombre = 'Gerente' LIMIT 1),
    (ARRAY['Carlos', 'Roberto', 'Ana', 'Laura', 'Miguel', 'Sofia', 'Jorge', 'Patricia'])[floor(random()*8 + 1)],
    (ARRAY['Hernández', 'García', 'Martínez', 'López', 'González', 'Pérez', 'Rodríguez', 'Sánchez'])[floor(random()*8 + 1)],
    'admin123',
    CONCAT('AUTH-', LPAD(((floor(random()*900000)::int) + 100000)::text, 6, '0')),
    TRUE
FROM sucursal s
WHERE s.nombre LIKE 'Madison Grill%';

-- B. MESEROS (3 por sucursal)
INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, numero_autorizacion, estado)
SELECT 
    s.sucursal_id,
    (SELECT rol_id FROM rol WHERE nombre = 'Mesero' LIMIT 1),
    (ARRAY['Juan', 'Pedro', 'Maria', 'Luisa', 'Diego', 'Carmen', 'Raul', 'Elena', 'Fernando', 'Lucia', 'Ricardo', 'Teresa'])[floor(random()*12 + 1)],
    (ARRAY['Ramirez', 'Torres', 'Flores', 'Rivera', 'Gomez', 'Diaz', 'Cruz', 'Morales', 'Ortiz', 'Gutierrez', 'Chavez', 'Ramos'])[floor(random()*12 + 1)],
    'mesero123',
    NULL,
    TRUE
FROM sucursal s
CROSS JOIN generate_series(1, 3) AS serie
WHERE s.nombre LIKE 'Madison Grill%';

-- C. COCINEROS (2 por sucursal)
INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, numero_autorizacion, estado)
SELECT 
    s.sucursal_id,
    (SELECT rol_id FROM rol WHERE nombre = 'Cocinero' LIMIT 1),
    (ARRAY['Jose', 'Antonio', 'Francisco', 'Manuel', 'Javier', 'David', 'Daniel', 'Alejandro'])[floor(random()*8 + 1)],
    (ARRAY['Castillo', 'Jimenez', 'Moreno', 'Romero', 'Alvarez', 'Molina', 'Ruiz', 'Delgado'])[floor(random()*8 + 1)],
    'cocina123',
    NULL,
    TRUE
FROM sucursal s
CROSS JOIN generate_series(1, 2) AS serie
WHERE s.nombre LIKE 'Madison Grill%';

-- D. CAJEROS (1 por sucursal)
INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, numero_autorizacion, estado)
SELECT 
    s.sucursal_id,
    (SELECT rol_id FROM rol WHERE nombre = 'Cajero' LIMIT 1),
    (ARRAY['Gabriela', 'Veronica', 'Silvia', 'Monica', 'Adriana', 'Rosa', 'Isabel', 'Pilar'])[floor(random()*8 + 1)],
    (ARRAY['Vega', 'Campos', 'Mendez', 'Guzman', 'Vargas', 'Reyes', 'Aguilar', 'Rojas'])[floor(random()*8 + 1)],
    'caja123',
    NULL,
    TRUE
FROM sucursal s
WHERE s.nombre LIKE 'Madison Grill%';


-- 5. RELACIÓN SUCURSAL - MENÚ
INSERT INTO sucursal_menu (sucursal_id, menu_id)
SELECT s.sucursal_id, m.menu_id
FROM sucursal s
CROSS JOIN menu m
WHERE s.nombre LIKE 'Madison Grill%' 
AND m.nombre = 'Menú Principal Coatzacoalcos'
AND NOT EXISTS (
    SELECT 1 FROM sucursal_menu sm 
    WHERE sm.sucursal_id = s.sucursal_id AND sm.menu_id = m.menu_id
);

/* =========================================================
   CARGA DE DATOS v3: LA BOCATA (Con Tabla Intermedia)
   Cambio: Menú desvinculado de tabla Menu y vinculado por sucursal_menu
   ========================================================= */

-- 1. INSERTAR RESTAURANTE
INSERT INTO restaurante (nombre, RFC) 
VALUES ('La Bocata', 'BOC230515XYZ');

-- 2. INSERTAR SUCURSALES
INSERT INTO sucursal (restaurante_id, nombre, direccion, region, telefono)
VALUES
(
    (SELECT restaurante_id FROM restaurante WHERE nombre='La Bocata' LIMIT 1), 
    'La Bocata Centro', 
    'Calle Bravo y Torres', 
    'Centro',
    '2288112233'
),
(
    (SELECT restaurante_id FROM restaurante WHERE nombre='La Bocata' LIMIT 1), 
    'La Bocata Universidad', 
    'Av. Universidad Veracruzana 122', 
    'Zona Universitaria',
    '2288445566'
);

-- 3. INSERTAR ÁREAS DE VENTA
INSERT INTO areaventa (sucursal_id, nombre)
VALUES
    ((SELECT sucursal_id FROM sucursal WHERE nombre='La Bocata Centro' LIMIT 1), 'Salón Principal'),
    ((SELECT sucursal_id FROM sucursal WHERE nombre='La Bocata Universidad' LIMIT 1), 'Salón Principal');

-- 4. INSERTAR MENÚ (Sin sucursal_id)
INSERT INTO menu (nombre, hora_inicio, hora_fin, activo) 
VALUES (
    'Menú General Bocata', 
    '07:00:00', 
    '23:59:00', 
    TRUE
);

-- ==============================================================================
-- 4.1. VINCULAR MENÚ A SUCURSALES (Tabla Intermedia: sucursal_menu)
-- Vinculamos el "Menú General Bocata" a AMBAS sucursales (Centro y Universidad)
-- ==============================================================================
INSERT INTO sucursal_menu (sucursal_id, menu_id)
VALUES
-- Vincular a Centro
(
    (SELECT sucursal_id FROM sucursal WHERE nombre='La Bocata Centro' LIMIT 1),
    (SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1)
),
-- Vincular a Universidad
(
    (SELECT sucursal_id FROM sucursal WHERE nombre='La Bocata Universidad' LIMIT 1),
    (SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1)
);

-- 5. INSERTAR CATEGORÍAS
INSERT INTO categoria (menu_id, nombre) VALUES 
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Americanos y Espressos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Latte y Capuccino'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Marrocchino'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Tisanas y Tés'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Bebidas Frías'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Jugos y Jarras'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Malteadas y Batidos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Sodas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Entradas y Quesos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Caldos y Sopas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Para Compartir'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Ensaladas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Desayunos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Sandwich y Cuernitos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Antojitos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Platos Fuertes'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Especialidad Italianos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Pastas y Pizzas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Pan Dulce y Repostería'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Postres'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Mixología y Licores'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Cervezas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Temporada y Extras'),
((SELECT menu_id FROM menu WHERE nombre='Menú General Bocata' LIMIT 1), 'Paquetes y Combos');

-- 6. INSERTAR PRODUCTOS
-- CAFÉ Y TÉ
INSERT INTO producto (categoria_id, nombre, precio_unitario, es_paquete) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Americanos y Espressos' LIMIT 1), 'Americano Chico', 40, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Americanos y Espressos' LIMIT 1), 'Americano Grande', 43, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Americanos y Espressos' LIMIT 1), 'Espresso', 40, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Latte y Capuccino' LIMIT 1), 'Latte / Capuccino', 55, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Latte y Capuccino' LIMIT 1), 'Chocolate Caliente', 60, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Latte y Capuccino' LIMIT 1), 'Chai Latte', 79, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Tisanas y Tés' LIMIT 1), 'Té Caliente', 39, FALSE);

-- BEBIDAS FRÍAS Y JUGOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, es_paquete) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Bebidas Frías' LIMIT 1), 'Frappuccino Clásico', 77, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Bebidas Frías' LIMIT 1), 'Café Frío', 70, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Jugos y Jarras' LIMIT 1), 'Jugo de Naranja', 63, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Jugos y Jarras' LIMIT 1), 'Limonada Natural', 40, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Jugos y Jarras' LIMIT 1), 'Jarra Clericot', 250, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Jugos y Jarras' LIMIT 1), 'Jarra Sangría', 250, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Jugos y Jarras' LIMIT 1), 'Jarra Tinto de Verano', 250, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Sodas' LIMIT 1), 'Refresco', 40, FALSE);

-- ALIMENTOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, es_paquete) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Caldos y Sopas' LIMIT 1), 'Sopa Azteca', 72, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Para Compartir' LIMIT 1), 'Parrillada Bocata', 1011, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Ensaladas' LIMIT 1), 'Ensalada César con Pollo', 170, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Desayunos' LIMIT 1), 'Hotcakes', 79, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Antojitos' LIMIT 1), 'Chilaquiles Clásicos', 119, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Platos Fuertes' LIMIT 1), 'Cecina Normal', 266, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Especialidad Italianos' LIMIT 1), 'Bocata Jamón Serrano', 181, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Pastas y Pizzas' LIMIT 1), 'Pasta Alfredo', 144, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Pastas y Pizzas' LIMIT 1), 'Focaccia Margarita', 144, FALSE);

-- ANTOJITOS Y PAN
INSERT INTO producto (categoria_id, nombre, precio_unitario, es_paquete) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Antojitos' LIMIT 1), 'Tamal Bollito', 30, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Antojitos' LIMIT 1), 'Tamal Chanchamito', 30, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Antojitos' LIMIT 1), 'Tamal de Masa Colada', 35, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Pan Dulce y Repostería' LIMIT 1), 'Mini Pan Dulce (Pieza)', 15, FALSE);

-- POSTRES
INSERT INTO producto (categoria_id, nombre, precio_unitario, es_paquete) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Postres' LIMIT 1), 'Postre Individual (Varios)', 75, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Pan Dulce y Repostería' LIMIT 1), 'Concha', 20, FALSE);

-- BAR / LICORES
INSERT INTO producto (categoria_id, nombre, precio_unitario, es_paquete) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Mixología y Licores' LIMIT 1), 'Wine Mixer (Copa)', 90, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Mixología y Licores' LIMIT 1), 'Daiquiri', 90, FALSE), 
((SELECT categoria_id FROM categoria WHERE nombre='Mixología y Licores' LIMIT 1), 'Mezcalina', 85, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Mixología y Licores' LIMIT 1), 'Margarita', 90, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Mixología y Licores' LIMIT 1), 'Mojito', 90, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Mixología y Licores' LIMIT 1), 'Long Island Iced Tea', 125, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Mixología y Licores' LIMIT 1), 'Ginebra Mix', 109, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Mixología y Licores' LIMIT 1), 'Mocktail (Sin Alcohol)', 70, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Cervezas' LIMIT 1), 'Cerveza Nacional', 45, FALSE);

-- EXTRAS INTERNOS
INSERT INTO producto (categoria_id, nombre, precio_unitario, es_paquete) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Temporada y Extras' LIMIT 1), 'Hamburguesa Pan de Muerto (Solo)', 150, FALSE), 
((SELECT categoria_id FROM categoria WHERE nombre='Temporada y Extras' LIMIT 1), 'Pan de Muerto', 70, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Temporada y Extras' LIMIT 1), 'Papas Fritas (Guarnición)', 40, FALSE),
((SELECT categoria_id FROM categoria WHERE nombre='Temporada y Extras' LIMIT 1), 'Rajas (Guarnición)', 20, FALSE);

-- 7. INSERTAR PAQUETES
INSERT INTO producto (categoria_id, nombre, precio_unitario, es_paquete) VALUES
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Combos' LIMIT 1), 'Paq. Tamal 1 (Bollito)', 85, TRUE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Combos' LIMIT 1), 'Paq. Tamal 2 (Bollito)', 101, TRUE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Combos' LIMIT 1), 'Paq. Parrillada & Clericot', 1200, TRUE),
((SELECT categoria_id FROM categoria WHERE nombre='Paquetes y Combos' LIMIT 1), 'Paq. Postre & Café', 100, TRUE),
((SELECT categoria_id FROM categoria WHERE nombre='Temporada y Extras' LIMIT 1), 'Hamburmuerta', 190, TRUE);

-- 8. INSERTAR COMPONENTES DE PAQUETES
-- Paq. Tamal 1
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
((SELECT producto_id FROM producto WHERE nombre='Paq. Tamal 1 (Bollito)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Tamal Bollito' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Paq. Tamal 1 (Bollito)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Americano Grande' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Paq. Tamal 1 (Bollito)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Mini Pan Dulce (Pieza)' LIMIT 1), 1);

-- Paq. Tamal 2
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
((SELECT producto_id FROM producto WHERE nombre='Paq. Tamal 2 (Bollito)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Tamal Bollito' LIMIT 1), 2),
((SELECT producto_id FROM producto WHERE nombre='Paq. Tamal 2 (Bollito)' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Americano Grande' LIMIT 1), 1);

-- Paq. Parrillada
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
((SELECT producto_id FROM producto WHERE nombre='Paq. Parrillada & Clericot' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Parrillada Bocata' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Paq. Parrillada & Clericot' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Jarra Clericot' LIMIT 1), 1);

-- Paq. Postre
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
((SELECT producto_id FROM producto WHERE nombre='Paq. Postre & Café' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Postre Individual (Varios)' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Paq. Postre & Café' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Latte / Capuccino' LIMIT 1), 1);

-- Paq. Hamburmuerta
INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES
((SELECT producto_id FROM producto WHERE nombre='Hamburmuerta' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Hamburguesa Pan de Muerto (Solo)' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Hamburmuerta' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Papas Fritas (Guarnición)' LIMIT 1), 1),
((SELECT producto_id FROM producto WHERE nombre='Hamburmuerta' LIMIT 1), (SELECT producto_id FROM producto WHERE nombre='Rajas (Guarnición)' LIMIT 1), 1);

-- 9. INSERTAR PROMOCIONES
INSERT INTO promocion (nombre, dias_aplicables, tipo_beneficio, monto_minimo, fecha_hora_inicio, fecha_hora_fin, valor_porcentaje)
VALUES 
('Temporada Día de Muertos: Hamburmuerta', 'Todos', 'PRECIO_FIJO_PAQUETE', 190, '2025-10-20 00:00:00', '2025-11-05 23:59:00', NULL),
('3x2 Cervezas Buen Fin', 'Todos', '3X2', NULL, '2025-11-11 00:00:00', '2025-11-18 23:59:00', NULL),
('2x1 Mocktails Sin Alcohol', 'Todos', '2X1', NULL, '2025-05-31 00:00:00', '2025-06-01 23:59:00', NULL),
('2x1 Cocteles Seleccionados', 'Miércoles,Jueves,Domingo', '2X1', NULL, NULL, NULL, NULL),
('2x1 Mezcal en sucursales', 'Todos', '2X1', NULL, NULL, NULL, NULL),
('2x$110 Margaritas y Mojitos', NULL, 'PRECIO_FIJO_CANTIDAD', 110, '2025-04-01 00:00:00', '2025-04-30 23:59:00', NULL),
('2x$497 Jarras Tinto/Sangría', NULL, 'PRECIO_FIJO_CANTIDAD', 497, '2025-04-01 00:00:00', '2025-04-30 23:59:00', NULL),
('3x1 Tequilas', NULL, '3X1', 0, '2025-04-01 00:00:00', '2025-04-30 23:59:00', NULL);

/* =========================================================
   INFRAESTRUCTURA OPERATIVA: LA BOCATA
   (Roles, Áreas, Mesas, Empleados Reales, Menú)
   ========================================================= */

-- 1. ASEGURAR ROLES (Si no existen)
INSERT INTO rol (nombre, descripcion)
SELECT 'Gerente', 'Gerente de Sucursal' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'Gerente');
INSERT INTO rol (nombre, descripcion)
SELECT 'Mesero', 'Atención a comensales' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'Mesero');
INSERT INTO rol (nombre, descripcion)
SELECT 'Cajero', 'Cobro y facturación' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'Cajero');
INSERT INTO rol (nombre, descripcion)
SELECT 'Cocinero', 'Preparación de alimentos' WHERE NOT EXISTS (SELECT 1 FROM rol WHERE nombre = 'Cocinero');


-- 2. INSERTAR ÁREAS DE VENTA
-- Creamos Salón y Terraza para las sucursales de La Bocata
INSERT INTO areaventa (sucursal_id, nombre)
SELECT sucursal_id, 'Salón Principal'
FROM sucursal 
WHERE nombre LIKE 'La Bocata%'
AND NOT EXISTS (SELECT 1 FROM areaventa WHERE areaventa.sucursal_id = sucursal.sucursal_id AND nombre = 'Salón Principal');

INSERT INTO areaventa (sucursal_id, nombre)
SELECT sucursal_id, 'Terraza'
FROM sucursal 
WHERE nombre LIKE 'La Bocata%'
AND NOT EXISTS (SELECT 1 FROM areaventa WHERE areaventa.sucursal_id = sucursal.sucursal_id AND nombre = 'Terraza');


-- 3. INSERTAR MESAS
-- A. Mesas Salón Principal (1-10)
INSERT INTO mesa (area_id, num_mesa, estado)
SELECT av.area_id, s.num, 'libre'
FROM areaventa av
JOIN sucursal suc ON av.sucursal_id = suc.sucursal_id
CROSS JOIN generate_series(1, 10) AS s(num)
WHERE suc.nombre LIKE 'La Bocata%' AND av.nombre = 'Salón Principal'
AND NOT EXISTS (SELECT 1 FROM mesa m WHERE m.area_id = av.area_id AND m.num_mesa = s.num);

-- B. Mesas Terraza (11-15)
INSERT INTO mesa (area_id, num_mesa, estado)
SELECT av.area_id, s.num, 'libre'
FROM areaventa av
JOIN sucursal suc ON av.sucursal_id = suc.sucursal_id
CROSS JOIN generate_series(11, 15) AS s(num)
WHERE suc.nombre LIKE 'La Bocata%' AND av.nombre = 'Terraza'
AND NOT EXISTS (SELECT 1 FROM mesa m WHERE m.area_id = av.area_id AND m.num_mesa = s.num);


-- =========================================================
-- 4. INSERTAR EMPLEADOS CON NOMBRES REALES
-- =========================================================

-- A. GERENTES (1 por sucursal)
INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, numero_autorizacion, estado)
SELECT 
    s.sucursal_id,
    (SELECT rol_id FROM rol WHERE nombre = 'Gerente' LIMIT 1),
    (ARRAY['Luis', 'Carmen', 'Roberto', 'Fernanda', 'Javier', 'Adriana'])[floor(random()*6 + 1)],
    (ARRAY['Mendez', 'Vega', 'Castillo', 'Solis', 'Fuentes', 'Ortiz'])[floor(random()*6 + 1)],
    'adminbocata',
    CONCAT('AUTH-', LPAD(((floor(random()*900000)::int) + 100000)::text, 6, '0')),
    TRUE
FROM sucursal s
WHERE s.nombre LIKE 'La Bocata%'
AND NOT EXISTS (
    SELECT 1 FROM empleado e 
    WHERE e.sucursal_id = s.sucursal_id 
    AND e.rol_id = (SELECT rol_id FROM rol WHERE nombre = 'Gerente' LIMIT 1)
);

-- B. MESEROS (3 por sucursal)
INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, numero_autorizacion, estado)
SELECT 
    s.sucursal_id,
    (SELECT rol_id FROM rol WHERE nombre = 'Mesero' LIMIT 1),
    (ARRAY['Hugo', 'Paco', 'Luis', 'Ana', 'Maria', 'Sofia', 'Lucia', 'Diego', 'Carlos', 'Elena'])[floor(random()*10 + 1)],
    (ARRAY['Lopez', 'Perez', 'Garcia', 'Sanchez', 'Romero', 'Diaz', 'Torres', 'Ruiz', 'Alvarez', 'Vargas'])[floor(random()*10 + 1)],
    'meserobocata',
    NULL,
    TRUE
FROM sucursal s
CROSS JOIN generate_series(1, 3) AS serie
WHERE s.nombre LIKE 'La Bocata%';

-- C. COCINEROS (2 por sucursal)
INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, numero_autorizacion, estado)
SELECT 
    s.sucursal_id,
    (SELECT rol_id FROM rol WHERE nombre = 'Cocinero' LIMIT 1),
    (ARRAY['Miguel', 'Angel', 'Jose', 'Ramon', 'David', 'Daniel'])[floor(random()*6 + 1)],
    (ARRAY['Gutierrez', 'Chavez', 'Ramos', 'Flores', 'Acosta', 'Silva'])[floor(random()*6 + 1)],
    'cocinabocata',
    NULL,
    TRUE
FROM sucursal s
CROSS JOIN generate_series(1, 2) AS serie
WHERE s.nombre LIKE 'La Bocata%';

-- D. CAJEROS (1 por sucursal)
INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, numero_autorizacion, estado)
SELECT 
    s.sucursal_id,
    (SELECT rol_id FROM rol WHERE nombre = 'Cajero' LIMIT 1),
    (ARRAY['Patricia', 'Laura', 'Diana', 'Monica', 'Rosa'])[floor(random()*5 + 1)],
    (ARRAY['Morales', 'Rivera', 'Reyes', 'Jimenez', 'Molina'])[floor(random()*5 + 1)],
    'cajabocata',
    NULL,
    TRUE
FROM sucursal s
WHERE s.nombre LIKE 'La Bocata%'
AND NOT EXISTS (
    SELECT 1 FROM empleado e 
    WHERE e.sucursal_id = s.sucursal_id 
    AND e.rol_id = (SELECT rol_id FROM rol WHERE nombre = 'Cajero' LIMIT 1)
);


-- 5. RELACIÓN SUCURSAL - MENÚ
-- Vinculamos el 'Menú General Bocata' a las sucursales de La Bocata
INSERT INTO sucursal_menu (sucursal_id, menu_id)
SELECT s.sucursal_id, m.menu_id
FROM sucursal s
CROSS JOIN menu m
WHERE s.nombre LIKE 'La Bocata%' 
AND m.nombre = 'Menú General Bocata'
AND NOT EXISTS (
    SELECT 1 FROM sucursal_menu sm 
    WHERE sm.sucursal_id = s.sucursal_id AND sm.menu_id = m.menu_id
);