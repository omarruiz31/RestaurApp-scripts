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