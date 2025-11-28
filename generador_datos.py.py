import random
from faker import Faker
from datetime import datetime, timedelta

# --- CONFIGURACIÓN ---
fake = Faker('es_MX')
OUTPUT_FILE = 'populate_full_restaurapp.sql'
DAYS_HISTORY = 730  # 2 años de historia
# Ajusta esto según el volumen deseado (Cuidado: generará millones de líneas si es muy alto)
MIN_ORDERS_DAY = 5
MAX_ORDERS_DAY = 15

# Contadores Globales (Simulación de SERIAL)
ids = {t: 0 for t in [
    'sucursal', 'rol', 'empleado', 'areaventa', 'mesa', 'menu', 'categoria', 
    'producto', 'producto_componente', 'categoria_mod', 'modificador',
    'metodo_pago', 'descuento', 'promocion', 'area_cocina', 'area_impresion',
    'dispositivo', 'sesion', 'reserva', 'cuenta', 'comensal', 'detalle',
    'detalle_mod', 'pago', 'historial'
]}

# Estructuras en memoria para referencias
data_cache = {
    'sucursales': [], 'empleados': [], 'dispositivos': [], 'mesas': [],
    'productos': [], 'paquetes': [], 'modificadores': {}, 'descuentos': [],
    'promociones': [], 'areas_cocina': []
}

def get_header():
    return """
    BEGIN;
    -- Limpieza previa (Orden correcto por FKs)
    TRUNCATE TABLE historial_preparacion, detalle_promocion, detalle_pago, pago, 
    detalle_modificador, detalle_cuenta, comensal, cuentaMesa, reserva, cuenta, 
    sesion, dispositivo, area_impresion, promocion, descuento, metodo_pago, 
    modificador, categoria_modificador, producto_componente, producto, categoria, 
    menu, mesa, areaventa, empleado, rol, sucursal, area_cocina CASCADE;
    \n
    """

def generate_catalogos():
    sql = "-- 1. CATALOGOS GENERALES --\n"
    
    # --- Area Cocina ---
    cocinas = ['Cocina Caliente', 'Barra Fría', 'Bar', 'Plancha']
    for c in cocinas:
        ids['area_cocina'] += 1
        sql += f"INSERT INTO area_cocina (area_cocina_id, nombre, tipo_area) VALUES ({ids['area_cocina']}, '{c}', 'Producción');\n"
        data_cache['areas_cocina'].append(ids['area_cocina'])

    # --- Roles ---
    roles = ['Gerente', 'Cajero', 'Mesero', 'Cocinero', 'Hostess']
    for r in roles:
        ids['rol'] += 1
        sql += f"INSERT INTO rol (rol_id, nombre) VALUES ({ids['rol']}, '{r}');\n"

    # --- Metodos Pago ---
    metodos = [(1,'Efectivo',True), (2,'Tarjeta Crédito',False), (3,'Tarjeta Débito',False), (4,'Transferencia',False)]
    for m in metodos:
        sql += f"INSERT INTO metodo_pago (metodo_id, nombre, es_efectivo) VALUES ({m[0]}, '{m[1]}', {m[2]});\n"

    # --- Descuentos ---
    desc_list = [('Cumpleañero', 'porcentaje', 10, 0), ('Convenio Empresarial', 'porcentaje', 15, 0), ('Cortesía Gerencia', 'monto', 0, 200)]
    for d in desc_list:
        ids['descuento'] += 1
        sql += f"INSERT INTO descuento (descuento_id, nombre_convenio, tipo, porcentaje, monto_fijo) VALUES ({ids['descuento']}, '{d[0]}', '{d[1]}', {d[2]}, {d[3]});\n"
        data_cache['descuentos'].append(ids['descuento'])

    # --- Promociones ---
    promos = [('2x1 Cervezas Jueves', '2x1'), ('Postre Gratis', 'regalo')]
    for p in promos:
        ids['promocion'] += 1
        sql += f"INSERT INTO promocion (promocion_id, nombre, tipo_beneficio, dias_aplicables) VALUES ({ids['promocion']}, '{p[0]}', '{p[1]}', 'Jueves,Viernes');\n"
        data_cache['promociones'].append(ids['promocion'])

    # --- Modificadores (Categoría y Items) ---
    cats_mod = {
        'Término Carne': [('Bien Cocido', 0), ('Medio', 0), ('Tres Cuartos', 0)],
        'Ingredientes Extra': [('Queso Extra', 15), ('Tocino', 20), ('Aguacate', 15)],
        'Bebidas Prep': [('Sin Hielo', 0), ('Poca Azúcar', 0), ('Michelada', 10)]
    }
    
    for cat_name, mods in cats_mod.items():
        ids['categoria_mod'] += 1
        cat_mod_id = ids['categoria_mod']
        sql += f"INSERT INTO categoria_modificador (categoria_mod_id, nombre) VALUES ({cat_mod_id}, '{cat_name}');\n"
        
        mod_ids_list = []
        for mod_name, precio in mods:
            ids['modificador'] += 1
            sql += f"INSERT INTO modificador (modificador_id, categoria_mod_id, nombre, precio) VALUES ({ids['modificador']}, {cat_mod_id}, '{mod_name}', {precio});\n"
            mod_ids_list.append(ids['modificador'])
        
        data_cache['modificadores'][cat_name] = mod_ids_list

    return sql

def generate_estructura_restaurante():
    sql = "-- 2. ESTRUCTURA (Sucursales, Empleados, Dispositivos, Menú) --\n"
    nombres_suc = ['Centro', 'Plaza Real']
    
    # Categorías de productos
    menu_structure = {
        'Bebidas': {'items': [('Coca Cola', 35), ('Cerveza Indio', 55)], 'mods': 'Bebidas Prep'},
        'Hamburguesas': {'items': [('Clásica', 120), ('BBQ', 140)], 'mods': 'Término Carne'}, # Mods obligatorios
        'Extras': {'items': [('Papas Fritas', 50)], 'mods': 'Ingredientes Extra'}
    }

    for suc_nom in nombres_suc:
        ids['sucursal'] += 1
        suc_id = ids['sucursal']
        sql += f"INSERT INTO sucursal (sucursal_id, nombre, direccion) VALUES ({suc_id}, '{suc_nom}', '{fake.address()}');\n"
        
        # Area Impresion
        ids['area_impresion'] += 1
        ai_id = ids['area_impresion']
        sql += f"INSERT INTO area_impresion (area_impresion_id, nombre, tipo_impresora) VALUES ({ai_id}, 'Barra {suc_nom}', 'Térmica');\n"

        # Dispositivos (Cajas/Tablets)
        for d in range(2):
            ids['dispositivo'] += 1
            disp_id = ids['dispositivo']
            sql += f"INSERT INTO dispositivo (dispositivo_id, area_impresion_id, tipo, modelo) VALUES ({disp_id}, {ai_id}, 'Tablet', 'iPad');\n"
            data_cache['dispositivos'].append({'id': disp_id, 'sucursal': suc_id})

        # Empleados
        for _ in range(4):
            ids['empleado'] += 1
            emp_id = ids['empleado']
            rol = random.randint(1, 4)
            sql += f"INSERT INTO empleado (empleado_id, sucursal_id, rol_id, nombre, apellido, contraseña) VALUES ({emp_id}, {suc_id}, {rol}, '{fake.first_name()}', '{fake.last_name()}', '1234');\n"
            data_cache['empleados'].append({'id': emp_id, 'sucursal': suc_id, 'rol': rol})

        # Areas y Mesas
        ids['areaventa'] += 1
        area_id = ids['areaventa']
        sql += f"INSERT INTO areaventa (area_id, sucursal_id, nombre) VALUES ({area_id}, {suc_id}, 'Salón');\n"
        for nm in range(1, 6):
            ids['mesa'] += 1
            sql += f"INSERT INTO mesa (mesa_id, area_id, num_mesa) VALUES ({ids['mesa']}, {area_id}, {nm});\n"
            data_cache['mesas'].append({'id': ids['mesa'], 'sucursal': suc_id})

        # Menú
        ids['menu'] += 1
        menu_id = ids['menu']
        sql += f"INSERT INTO menu (menu_id, sucursal_id, nombre, hora_inicio, hora_fin) VALUES ({menu_id}, {suc_id}, 'Menu General', '08:00', '22:00');\n"

        # Productos
        for cat_nom, data in menu_structure.items():
            ids['categoria'] += 1
            cat_id = ids['categoria']
            sql += f"INSERT INTO categoria (categoria_id, menu_id, nombre) VALUES ({cat_id}, {menu_id}, '{cat_nom}');\n"
            
            for prod_nom, precio in data['items']:
                ids['producto'] += 1
                prod_id = ids['producto']
                sql += f"INSERT INTO producto (producto_id, categoria_id, nombre, precio_unitario) VALUES ({prod_id}, {cat_id}, '{prod_nom}', {precio});\n"
                
                # Guardar referencia para generar pedidos
                # mod_cat: categoría de modificadores aplicable (si tiene)
                data_cache['productos'].append({'id': prod_id, 'precio': precio, 'mod_cat': data.get('mods'), 'es_paquete': False})

    # --- PAQUETES (Producto Componente) ---
    # Creamos un "Paquete Comida" que incluye Hamburguesa y Refresco
    # Necesitamos IDs de productos base. Tomamos el último y penúltimo generados como ejemplo simple.
    base_prod_1 = ids['producto'] - 1 # Asumimos Hamburguesa
    base_prod_2 = ids['producto'] - 3 # Asumimos Refresco
    
    if base_prod_1 > 0 and base_prod_2 > 0:
        ids['producto'] += 1
        paquete_id = ids['producto']
        # Insertar el producto padre (El paquete en sí)
        # Asumimos categoria 1 del ultimo menu para simplificar
        cat_dummy = ids['categoria'] 
        sql += f"INSERT INTO producto (producto_id, categoria_id, nombre, precio_unitario, es_paquete) VALUES ({paquete_id}, {cat_dummy}, 'Paquete Ahorro', 150.00, TRUE);\n"
        
        # Relacionar componentes
        sql += f"INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES ({paquete_id}, {base_prod_1}, 1);\n"
        sql += f"INSERT INTO producto_componente (id_producto_padre, id_producto_hijo, cantidad) VALUES ({paquete_id}, {base_prod_2}, 1);\n"
        
        data_cache['productos'].append({'id': paquete_id, 'precio': 150, 'mod_cat': None, 'es_paquete': True})

    return sql

def generate_historia_operativa():
    sql = "-- 3. HISTORIA OPERATIVA (Sesiones, Ventas, Reservas) --\n"
    start_date = datetime.now() - timedelta(days=DAYS_HISTORY)
    
    # Iterar día por día
    current_date = start_date
    while current_date <= datetime.now():
        str_date = current_date.strftime('%Y-%m-%d')
        # print(f"Generando datos para: {str_date}") # Descomentar para debug local
        
        # 1. Abrir Sesiones (1 por sucursal/dispositivo random)
        # Seleccionamos un par de empleados para abrir turno hoy
        sesiones_del_dia = []
        for emp in random.sample(data_cache['empleados'], k=min(2, len(data_cache['empleados']))):
            # Buscar dispositivo de su sucursal
            disp = next((d for d in data_cache['dispositivos'] if d['sucursal'] == emp['sucursal']), None)
            if disp:
                ids['sesion'] += 1
                sesion_id = ids['sesion']
                inicio = f"{str_date} 08:00:00"
                fin = f"{str_date} 23:00:00"
                sql += f"INSERT INTO sesion (sesion_id, empleado_id, dispositivo_id, fecha_hora_apertura, fecha_hora_cierre, estado) VALUES ({sesion_id}, {emp['id']}, {disp['id']}, '{inicio}', '{fin}', 'cerrada');\n"
                sesiones_del_dia.append({'id': sesion_id, 'sucursal': emp['sucursal']})

        # 2. Reservas (Algunas futuras, algunas pasadas)
        if random.random() > 0.7: # 30% prob de reserva
            ids['reserva'] += 1
            mesa_res = random.choice(data_cache['mesas'])
            hora_res = f"{str_date} 20:00:00"
            sql += f"INSERT INTO reserva (reserva_id, mesa_id, nombre, num_acompañantes, fecha_hora_reserva) VALUES ({ids['reserva']}, {mesa_res['id']}, '{fake.name()}', 2, '{hora_res}');\n"

        # 3. Cuentas (Ventas)
        num_orders = random.randint(MIN_ORDERS_DAY, MAX_ORDERS_DAY)
        for _ in range(num_orders):
            if not sesiones_del_dia: break
            
            # Datos básicos cuenta
            ids['cuenta'] += 1
            cuenta_id = ids['cuenta']
            sesion = random.choice(sesiones_del_dia)
            mesa = random.choice([m for m in data_cache['mesas'] if m['sucursal'] == sesion['sucursal']])
            
            hora_inicio = f"{str_date} {random.randint(13,21)}:{random.randint(10,59)}:00"
            
            sql += f"INSERT INTO cuenta (cuenta_id, fecha_hora_inicio, estado) VALUES ({cuenta_id}, '{hora_inicio}', FALSE);\n"
            sql += f"INSERT INTO cuentaMesa (cuenta_id, mesa_id) VALUES ({cuenta_id}, {mesa['id']});\n"

            # Comensales y Detalles
            num_comensales = random.randint(1, 4)
            total_cuenta = 0
            comensales_info = []

            for i in range(num_comensales):
                ids['comensal'] += 1
                com_id = ids['comensal']
                comensales_info.append(com_id)
                sql += f"INSERT INTO comensal (comensal_id, cuenta_id, nombre_etiqueta) VALUES ({com_id}, {cuenta_id}, 'Comensal {i+1}');\n"

                # Productos por comensal
                for _ in range(random.randint(1, 3)):
                    prod = random.choice(data_cache['productos'])
                    ids['detalle'] += 1
                    det_id = ids['detalle']
                    
                    sql += f"INSERT INTO detalle_cuenta (detalle_id, comensal_id, producto_id, cantidad, precio_unitario) VALUES ({det_id}, {com_id}, {prod['id']}, 1, {prod['precio']});\n"
                    total_cuenta += prod['precio']

                    # Modificadores (Si el producto tiene categoría de modificadores asociada)
                    if prod['mod_cat'] and prod['mod_cat'] in data_cache['modificadores']:
                        mods_disponibles = data_cache['modificadores'][prod['mod_cat']]
                        mod_elegido = random.choice(mods_disponibles) # Elegir ID modificador
                        # Obtener precio (esto es simplificado, en script real buscariamos precio)
                        precio_mod = 0 # Asumimos 0 para simplificar query Python, o podrias guardar precios en cache
                        sql += f"INSERT INTO detalle_modificador (detalle_id, modificador_id, precio_unitario) VALUES ({det_id}, {mod_elegido}, {precio_mod});\n"

                    # Promocion (Detalle Promocion)
                    if random.random() > 0.9 and data_cache['promociones']:
                        promo_id = random.choice(data_cache['promociones'])
                        sql += f"INSERT INTO detalle_promocion (detalle_id, promocion_id) VALUES ({det_id}, {promo_id});\n"

                    # Historial Preparacion (Cocina)
                    area_cocina = random.choice(data_cache['areas_cocina'])
                    sql += f"INSERT INTO historial_preparacion (detalle_id, area_cocina_id, estado, fecha_hora_preparacion) VALUES ({det_id}, {area_cocina}, 'Terminado', '{hora_inicio}');\n"

            # Pagos (Cierre de Cuenta)
            # Aplicar Descuento Global?
            desc_id_sql = "NULL"
            if random.random() > 0.9 and data_cache['descuentos']:
                desc_id = random.choice(data_cache['descuentos'])
                desc_id_sql = str(desc_id)
                total_cuenta = total_cuenta * 0.9 # Aplicar simulacion de descuento al monto
            
            # Registrar Pago
            ids['pago'] += 1
            pago_id = ids['pago']
            metodo = random.randint(1, 4)
            hora_cierre = f"{str_date} 23:30:00"
            
            sql += f"UPDATE cuenta SET fecha_hora_cierre = '{hora_cierre}', estado = FALSE WHERE cuenta_id = {cuenta_id};\n"
            sql += f"INSERT INTO pago (pago_id, metodo_id, fecha_hora, monto) VALUES ({pago_id}, {metodo}, '{hora_cierre}', {total_cuenta});\n"
            
            # Relacion Pago-Comensal (Asumimos pago único para simplificar este bucle masivo, o dividido al primer comensal)
            sql += f"INSERT INTO detalle_pago (cuenta_id, comensal_id, pago_id, descuento_id) VALUES ({cuenta_id}, {comensales_info[0]}, {pago_id}, {desc_id_sql});\n"

        current_date += timedelta(days=1)
    
    return sql

# --- EJECUCIÓN ---
def main():
    try:
        print("Generando script SQL masivo...")
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(get_header())
            f.write(generate_catalogos())
            f.write(generate_estructura_restaurante())
            f.write(generate_historia_operativa())
            f.write("COMMIT;")
        print(f"¡Listo! Archivo generado: {OUTPUT_FILE}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == '__main__':
    main()