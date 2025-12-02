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
    'Menú General', 
    '07:00:00', 
    '23:59:00', 
    TRUE
);

-- ==============================================================================
-- 4.1. VINCULAR MENÚ A SUCURSALES (Tabla Intermedia: sucursal_menu)
-- Vinculamos el "Menú General" a AMBAS sucursales (Centro y Universidad)
-- ==============================================================================
INSERT INTO sucursal_menu (sucursal_id, menu_id)
VALUES
-- Vincular a Centro
(
    (SELECT sucursal_id FROM sucursal WHERE nombre='La Bocata Centro' LIMIT 1),
    (SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1)
),
-- Vincular a Universidad
(
    (SELECT sucursal_id FROM sucursal WHERE nombre='La Bocata Universidad' LIMIT 1),
    (SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1)
);

-- 5. INSERTAR CATEGORÍAS
INSERT INTO categoria (menu_id, nombre) VALUES 
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Americanos y Espressos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Latte y Capuccino'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Marrocchino'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Tisanas y Tés'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Bebidas Frías'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Jugos y Jarras'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Malteadas y Batidos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Sodas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Entradas y Quesos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Caldos y Sopas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Para Compartir'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Ensaladas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Desayunos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Sandwich y Cuernitos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Antojitos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Platos Fuertes'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Especialidad Italianos'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Pastas y Pizzas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Pan Dulce y Repostería'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Postres'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Mixología y Licores'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Cervezas'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Temporada y Extras'),
((SELECT menu_id FROM menu WHERE nombre='Menú General' LIMIT 1), 'Paquetes y Combos');

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