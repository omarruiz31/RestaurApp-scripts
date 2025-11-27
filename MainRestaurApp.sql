DROP DATABASE IF EXISTS restaurapp;

CREATE DATABASE restaurapp;

CREATE TABLE sucursal(
    sucursal_id SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    direccion VARCHAR(120) NOT NULL,
    region VARCHAR(40)
);

CREATE TABLE rol(
    rol_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(60)
);


CREATE TABLE empleado(
    empleado_id SERIAL PRIMARY KEY,
    sucursal_id INT NOT NULL,
    rol_id INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    contraseña VARCHAR(255) NOT NULL,

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
    nombre VARCHAR(50) NOT NULL,
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
        ON DELETE RESTRICT
);

CREATE TABLE cuenta (
    cuenta_id SERIAL PRIMARY KEY,
    fecha_hora_inicio TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_hora_cierre TIMESTAMP,
    estado BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE cuentaMesa(
    cuenta_id INT NOT NULL,
    mesa_id INT NOT NULL,

    CONSTRAINT pk_cuenta_mesa
        PRIMARY KEY (cuenta_id, mesa_id),

    CONSTRAINT fk_cm_cuenta
        FOREIGN KEY (cuenta_id)
        REFERENCES cuenta(cuenta_id)
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
    cuenta_id INT NOT NULL,
    nombre_etiqueta VARCHAR(40),

    CONSTRAINT fk_cuenta_comensal
        FOREIGN KEY(cuenta_id)
        REFERENCES cuenta(cuenta_id)
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
    sucursal_id INT NOT NULL,
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

CREATE TABLE detalle_cuenta(
    detalle_id SERIAL PRIMARY KEY,
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

--Dispositivo debe estar registrado a cuenta ?? 

CREATE TABLE categoria_modificador(
    categoria_mod_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);


CREATE TABLE modificador(
    modificador_id SERIAL PRIMARY KEY,
    categoria_mod_id INT NOT null,
    nombre VARCHAR(50) NOT NULL,
    precio NUMERIC(10,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT fk_mod_categoria
        FOREIGN KEY(categoria_mod_id)
        REFERENCES categoria_modificador(categoria_mod_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE detalle_modificador(
    detalle_modificador SERIAL  PRIMARY KEY,
    detalle_id INT NOT NULL,
    modificador_id INT,
    cantidad NUMERIC(10,2) NOT NULL DEFAULT 1,
    precio_unitario NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_dm_detalle
        FOREIGN KEY(detalle_id)
        REFERENCES detalle_cuenta(detalle_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_dm_modificador
        FOREIGN KEY(modificador_id)
        REFERENCES modificador(modificador_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
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

    CONSTRAINT fk_metodo
    FOREIGN KEY(metodo_id)
    REFERENCES metodo_pago(metodo_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    
);



CREATE TABLE descuento(
    descuento_id SERIAL PRIMARY KEY,
    nombre_convenio VARCHAR(120) NOT NULL,
    tipo VARCHAR(30),
    porcentaje NUMERIC(10,2),
    monto_fijo NUMERIC(10,2),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE detalle_pago(
    cuenta_id INT ,
    comensal_id INT,
    pago_id INT,
    descuento_id INT,

    CONSTRAINT fk_cuenta
    FOREIGN KEY(cuenta_id)
    REFERENCES cuenta(cuenta_id),

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
    nombre VARCHAR(50) NOT NULL,
    esta_activo BOOLEAN NOT NULL DEFAULT TRUE,
    valor_porcentaje NUMERIC(5,2),
    monto_minimo NUMERIC(10,2),
    fecha_hora_inicio TIMESTAMP,
    fecha_hora_fin TIMESTAMP,
    dias_aplicables VARCHAR(50), 
    tipo_beneficio VARCHAR(50) NOT NULL
);

CREATE TABLE detalle_promocion(

    detalle_id INT NOT NULL,
    promocion_id INT NOT NULL,

    CONSTRAINT pk_detalle_promocion
    PRIMARY KEY(detalle_id,promocion_id),

    CONSTRAINT fk_detalle
    FOREIGN KEY (detalle_id)
    REFERENCES detalle_cuenta(detalle_id),

    CONSTRAINT fk_promocion
    FOREIGN KEY(promocion_id)
    REFERENCES promocion(promocion_id)
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
    tipo VARCHAR(30),
    estado VARCHAR(30),
    modelo VARCHAR(60),

    CONSTRAINT fk_area_impresion 
    FOREIGN KEY(area_impresion_id)
    REFERENCES area_impresion(area_impresion_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
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
    tipo_area VARCHAR(50),
    estado VARCHAR(20) DEFAULT 'activo'
);

CREATE TABLE historial_preparacion(
    historial_preparacion_id SERIAL PRIMARY KEY,
    detalle_id INT NOT NULL,
    area_cocina_id INT NOT NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_hora_preparacion TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_detalle
    FOREIGN KEY(detalle_id)
    REFERENCES detalle_cuenta(detalle_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

    CONSTRAINT fk_historial_area
    FOREIGN KEY(area_cocina_id)
    REFERENCES area_cocina(area_cocina_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
    
);














