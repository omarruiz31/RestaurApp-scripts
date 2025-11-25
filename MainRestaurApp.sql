

CREATE DATABASE restaurapp

CREATE TABLE sucursal(
    sucursal_id SERIAL PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    direccion VARCHAR(60),
    region VARCHAR(40)
);

CREATE TABLE rol(
    rol_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(50)
)
--Enum de emleados
CREATE TYPE estado_empleado AS ENUM ('activo', 'inactivo');

CREATE TABLE empleado(
    empleado_id SERIAL PRIMARY KEY,
    sucursal_id INT NOT NULL,
    rol_id INT NOT NULL,
    nombre VARCHAR(30),
    apellido VARCHAR(30),
    estado estado_empleado NOT NULL DEFAULT 'activo' ,
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
)

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

CREATE TABLE mesa(
    mesa_id SERIAL PRIMARY KEY,
    area_id INT NOT NULL,
    num_mesa INT NOT NULL,
    estado estado_mesa NOT NULL DEFAULT 'libre',
    CONSTRAINT fk_mesa_area
        FOREIGN KEY(area_id)
        REFERENCES areaventa(area_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE reserva(
    reserva_id SERIAL PRIMARY KEY,
    mesa_id INT NOT NULL,
    nombre VARCHAR(30) NOT NULL,
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
    nombre VARCHAR(30),
        CONSTRAINT fk_menu
            FOREIGN KEY (menu_id)
            REFERENCES menu(menu_id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);
