import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
from decimal import Decimal

# --- CONFIGURACIÓN DE LA BASE DE DATOS ---
DB_CONFIG = {
    'dbname': 'restaurapp',    # <--- CAMBIA ESTO
    'user': 'postgres',             # <--- CAMBIA ESTO
    'password': '12345',    # <--- CAMBIA ESTO
    'host': 'localhost',
    'port': '5432'
}

fake = Faker('es_MX') # Generador de datos con localización México

# --- FUNCIONES AUXILIARES ---

def connect():
    """Establece conexión con la BD"""
    return psycopg2.connect(**DB_CONFIG)

def fetch_ids(cursor, table_name, id_column):
    """Obtiene una lista de IDs existentes de una tabla"""
    cursor.execute(f"SELECT {id_column} FROM {table_name};")
    return [row[0] for row in cursor.fetchall()]

def fetch_products_with_prices(cursor):
    """Obtiene diccionario {id: precio} de productos existentes"""
    cursor.execute("SELECT producto_id, precio_unitario FROM producto WHERE es_paquete = FALSE;")
    return {row[0]: row[1] for row in cursor.fetchall()}

# --- GENERADORES DE DATOS ---

def generar_catalogos_faltantes(conn):
    """Rellena tablas pequeñas si están vacías (Roles, Areas, Metodos)"""
    cur = conn.cursor()
    
    # 1. ROLES
    roles = ['Mesero', 'Cajero', 'Gerente', 'Cocinero', 'Hostess']
    cur.execute("SELECT count(*) FROM rol;")
    if cur.fetchone()[0] == 0:
        print("Generando Roles...")
        for rol in roles:
            cur.execute("INSERT INTO rol (nombre, descripcion) VALUES (%s, %s)", (rol, f"Personal de {rol}"))
    
    # 2. AREAS COCINA
    areas_cocina = [('Cocina Caliente', 'General'), ('Barra Bebidas', 'Barra'), ('Plancha', 'Cocina')]
    cur.execute("SELECT count(*) FROM area_cocina;")
    if cur.fetchone()[0] == 0:
        print("Generando Areas de Cocina...")
        for nombre, tipo in areas_cocina:
            cur.execute("INSERT INTO area_cocina (nombre, tipo_area) VALUES (%s, %s)", (nombre, tipo))

    # 3. METODOS DE PAGO
    metodos = [('Efectivo', True), ('Tarjeta Débito', False), ('Tarjeta Crédito', False), ('Transferencia', False)]
    cur.execute("SELECT count(*) FROM metodo_pago;")
    if cur.fetchone()[0] == 0:
        print("Generando Métodos de Pago...")
        for nombre, efectivo in metodos:
            cur.execute("INSERT INTO metodo_pago (nombre, es_efectivo, referencia) VALUES (%s, %s, %s)", (nombre, efectivo, 'General'))

    # 4. AREAS DE IMPRESION
    areas_imp = [('Caja Principal', 'Caja'), ('Cocina General', 'Cocina'), ('Barra', 'Barra')]
    cur.execute("SELECT count(*) FROM area_impresion;")
    if cur.fetchone()[0] == 0:
        print("Generando Areas de Impresión...")
        for nombre, tipo in areas_imp:
            cur.execute("INSERT INTO area_impresion (nombre, ip, tipo_impresora) VALUES (%s, %s, %s)", 
                        (nombre, fake.ipv4_private(), 'Termica 80mm'))

    conn.commit()
    cur.close()

def generar_infraestructura_sucursal(conn, sucursal_id):
    """Crea empleados, áreas de venta, mesas y dispositivos para una sucursal"""
    cur = conn.cursor()
    
    # Obtener IDs necesarios
    roles_ids = fetch_ids(cur, 'rol', 'rol_id')
    area_imp_ids = fetch_ids(cur, 'area_impresion', 'area_impresion_id')
    
    # 1. EMPLEADOS (5 a 10 por sucursal)
    print(f"  -> Contratando empleados para sucursal {sucursal_id}...")
    empleados_ids = []
    for _ in range(random.randint(5, 10)):
        rol_random = random.choice(roles_ids)
        cur.execute("""
            INSERT INTO empleado (sucursal_id, rol_id, nombre, apellido, contraseña, estado)
            VALUES (%s, %s, %s, %s, %s, TRUE) RETURNING empleado_id
        """, (sucursal_id, rol_random, fake.first_name(), fake.last_name(), 'hash_password'))
        empleados_ids.append(cur.fetchone()[0])

    # 2. AREAS DE VENTA Y MESAS
    print(f"  -> Construyendo mesas para sucursal {sucursal_id}...")
    nombres_areas = ['Salón Principal', 'Terraza', 'Privado']
    for nombre_area in nombres_areas:
        # Crear Area
        cur.execute("INSERT INTO areaventa (sucursal_id, nombre) VALUES (%s, %s) RETURNING area_id", 
                    (sucursal_id, nombre_area))
        area_id = cur.fetchone()[0]
        
        # Crear Mesas (3 a 8 por área)
        for i in range(1, random.randint(3, 8)):
            cur.execute("INSERT INTO mesa (area_id, num_mesa, estado) VALUES (%s, %s, 'libre')", (area_id, i))

    # 3. DISPOSITIVOS
    print(f"  -> Instalando dispositivos...")
    modelos = ['iPad', 'Lenovo Tab', 'Posiflex']
    for _ in range(3):
        cur.execute("""
            INSERT INTO dispositivo (area_impresion_id, tipo, estado, modelo)
            VALUES (%s, 'Tablet Comandera', 'activo', %s)
        """, (random.choice(area_imp_ids), random.choice(modelos)))

    conn.commit()
    cur.close()
    return empleados_ids

def simular_operaciones(conn, sucursal_id):
    """Genera flujo operativo: Sesiones, Cuentas, Pedidos, Pagos"""
    cur = conn.cursor()
    
    # Obtener datos de contexto
    empleados = fetch_ids(cur, 'empleado', 'empleado_id') # Filtrar por sucursal idealmente, pero simplificado aquí
    dispositivos = fetch_ids(cur, 'dispositivo', 'dispositivo_id')
    mesas = fetch_ids(cur, 'mesa', 'mesa_id') # Deberían filtrarse por las areas de ESTA sucursal
    productos_dict = fetch_products_with_prices(cur) # {id: precio}
    metodos_pago = fetch_ids(cur, 'metodo_pago', 'metodo_id')
    areas_cocina = fetch_ids(cur, 'area_cocina', 'area_cocina_id')
    
    if not productos_dict:
        print("ADVERTENCIA: No hay productos en la BD. Saltando simulación de ventas.")
        return

    # SIMULAR 5 SESIONES (TURNOS)
    print(f"  -> Simulando operaciones diarias en sucursal {sucursal_id}...")
    
    for _ in range(5): 
        # 1. ABRIR SESIÓN
        empleado_turno = random.choice(empleados)
        dispositivo_turno = random.choice(dispositivos)
        inicio_sesion = fake.date_time_between(start_date='-30d', end_date='now')
        
        cur.execute("""
            INSERT INTO sesion (empleado_id, dispositivo_id, fecha_hora_apertura, efectivo_inicial, estado)
            VALUES (%s, %s, %s, %s, 'cerrada') RETURNING sesion_id
        """, (empleado_turno, dispositivo_turno, inicio_sesion, Decimal(random.randint(500, 2000))))
        sesion_id = cur.fetchone()[0]

        # 2. GENERAR CUENTAS EN ESA SESIÓN (3 a 8 cuentas por turno)
        for _ in range(random.randint(3, 8)):
            mesa_random = random.choice(mesas)
            fecha_cuenta = inicio_sesion + timedelta(minutes=random.randint(10, 300))
            
            # Crear Cuenta
            cur.execute("""
                INSERT INTO cuenta (fecha_hora_inicio, fecha_hora_cierre, estado)
                VALUES (%s, %s, FALSE) RETURNING cuenta_id
            """, (fecha_cuenta, fecha_cuenta + timedelta(hours=1)))
            cuenta_id = cur.fetchone()[0]

            # Asignar Mesa
            cur.execute("INSERT INTO cuentaMesa (cuenta_id, mesa_id) VALUES (%s, %s)", (cuenta_id, mesa_random))

            # Crear Comensales (1 a 4 personas)
            total_cuenta = Decimal(0)
            
            for i in range(1, random.randint(2, 5)):
                nombre_comensal = f"Comensal {i}"
                cur.execute("INSERT INTO comensal (cuenta_id, nombre_etiqueta) VALUES (%s, %s) RETURNING comensal_id",
                            (cuenta_id, nombre_comensal))
                comensal_id = cur.fetchone()[0]

                # Pedir Productos (1 a 3 productos por persona)
                for _ in range(random.randint(1, 3)):
                    prod_id = random.choice(list(productos_dict.keys()))
                    precio = productos_dict[prod_id]
                    cantidad = 1 # Simplificado
                    
                    # Insertar Detalle Cuenta
                    cur.execute("""
                        INSERT INTO detalle_cuenta (comensal_id, producto_id, cantidad, precio_unitario)
                        VALUES (%s, %s, %s, %s) RETURNING detalle_id
                    """, (comensal_id, prod_id, cantidad, precio))
                    detalle_id = cur.fetchone()[0]
                    
                    total_cuenta += (precio * cantidad)

                    # Enviar a Cocina (Historial Preparación)
                    cur.execute("""
                        INSERT INTO historial_preparacion (detalle_id, area_cocina_id, estado, fecha_hora_preparacion)
                        VALUES (%s, %s, 'terminado', %s)
                    """, (detalle_id, random.choice(areas_cocina), fecha_cuenta + timedelta(minutes=15)))

            # 3. PAGAR LA CUENTA
            metodo = random.choice(metodos_pago)
            propina = total_cuenta * Decimal(0.10)
            
            cur.execute("""
                INSERT INTO pago (metodo_id, fecha_hora, monto, propina)
                VALUES (%s, %s, %s, %s) RETURNING pago_id
            """, (metodo, fecha_cuenta + timedelta(hours=1), total_cuenta, propina))
            pago_id = cur.fetchone()[0]

            # Detalle Pago (Relación Cuenta-Pago)
            cur.execute("""
                INSERT INTO detalle_pago (cuenta_id, pago_id) VALUES (%s, %s)
            """, (cuenta_id, pago_id))

    conn.commit()
    cur.close()

# --- EJECUCIÓN PRINCIPAL ---

def main():
    try:
        conn = connect()
        print("Conexión exitosa. Iniciando rellenado de datos...")
        
        # 1. Asegurar catálogos básicos
        generar_catalogos_faltantes(conn)

        # 2. Obtener Sucursales existentes (Insertadas por tu script SQL)
        cur = conn.cursor()
        ids_sucursales = fetch_ids(cur, 'sucursal', 'sucursal_id')
        cur.close()

        if not ids_sucursales:
            print("ERROR: No se encontraron sucursales. Ejecuta tus scripts SQL de inserts primero.")
            return

        print(f"Se encontraron {len(ids_sucursales)} sucursales.")

        # 3. Loop por sucursal para generar su universo
        for suc_id in ids_sucursales:
            print(f"\n--- Procesando Sucursal ID: {suc_id} ---")
            
            # Generar mesas, empleados y dispositivos
            generar_infraestructura_sucursal(conn, suc_id)
            
            # Generar ventas y operaciones
            simular_operaciones(conn, suc_id)

        print("\n¡Proceso finalizado con éxito! Tu base de datos tiene ahora datos transaccionales.")

    except Exception as e:
        print(f"Ocurrió un error: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    main()