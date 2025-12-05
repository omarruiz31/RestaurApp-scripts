import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
from decimal import Decimal


SEED_VALUE = 42  
random.seed(SEED_VALUE)
Faker.seed(SEED_VALUE)

# ... resto del código ...

# --- CONFIGURACIÓN ---
DB_CONFIG = {
    'dbname': 'restaurapp', 
    'user': 'postgres', 
    'password': '12345', 
    'host': 'localhost',
    'port': '5432'
}

OUTPUT_FILE = 'historial_roles_final.sql'
FECHA_INICIO = datetime(2023, 1, 1)
FECHA_FIN = datetime(2025, 12, 8)

fake = Faker('es_MX')

class GeneradorHistorico:
    def __init__(self):
        self.conn = None
        self.cur = None
        
        self.ids_sucursales = []
        
        self.empleados_totales = {} 
        self.meseros_por_sucursal = {} 
        self.gerentes_por_sucursal = {}
        self.cajeros_por_sucursal = {}
        
        self.mesas_por_sucursal = {}     
        self.productos_por_sucursal = {} 
        self.paquetes_por_sucursal = {}  
        
        self.metodos_pago = {}           
        self.ids_descuentos = []  
        self.ids_promociones = []
        self.modificadores = {}          
        self.areas_cocina = []
        self.dispositivos_validos_sesion = [] 
        
        self.contadores = {}

    def conectar_y_cargar_contexto(self):
        print("Conectando y analizando estructura de la BD...")
        try:
            self.conn = psycopg2.connect(**DB_CONFIG)
            self.cur = self.conn.cursor()

            print("Ajustando precios en $0.00 en la base de datos real...")
            self.cur.execute("""
                UPDATE producto 
                SET precio_unitario = (random() * (220 - 120) + 120)::NUMERIC(10,2) 
                WHERE precio_unitario = 0.00;
            """)
            self.conn.commit()
            print("Precios corregidos.")

            # 1. Sucursales
            self.cur.execute("SELECT sucursal_id FROM sucursal")
            self.ids_sucursales = [r[0] for r in self.cur.fetchall()]
            if not self.ids_sucursales: raise Exception("No hay sucursales.")

            # 2. Empleados (CLASIFICADOS POR ROL)
            for suc_id in self.ids_sucursales:
                query_emp = f"""
                    SELECT e.empleado_id, r.nombre 
                    FROM empleado e
                    JOIN rol r ON e.rol_id = r.rol_id
                    WHERE e.sucursal_id = {suc_id}
                """
                self.cur.execute(query_emp)
                resultados = self.cur.fetchall()
                
                # Clasificación
                todos = []
                meseros = []
                gerentes = []
                cajeros = []
                
                for emp_id, rol_nombre in resultados:
                    todos.append(emp_id)
                    rol_str = rol_nombre.lower()
                    
                    if 'mesero' in rol_str or 'mesera' in rol_str:
                        meseros.append(emp_id)
                    elif 'gerente' in rol_str:
                        gerentes.append(emp_id)
                    elif 'cajero' in rol_str or 'cajera' in rol_str:
                        cajeros.append(emp_id)
                
                self.empleados_totales[suc_id] = todos
                self.meseros_por_sucursal[suc_id] = meseros
                self.gerentes_por_sucursal[suc_id] = gerentes
                self.cajeros_por_sucursal[suc_id] = cajeros
                
                # Mesas
                self.cur.execute(f"""
                    SELECT m.mesa_id FROM mesa m 
                    JOIN areaventa a ON m.area_id = a.area_id 
                    WHERE a.sucursal_id = {suc_id}
                """)
                mesas = [r[0] for r in self.cur.fetchall()]
                if mesas: self.mesas_por_sucursal[suc_id] = mesas

            # 3. Productos y Paquetes
            for suc_id in self.ids_sucursales:
                q_prod = f"SELECT p.producto_id, p.precio_unitario FROM producto p JOIN categoria c ON p.categoria_id = c.categoria_id JOIN menu m ON c.menu_id = m.menu_id JOIN sucursal_menu sm ON m.menu_id = sm.menu_id WHERE sm.sucursal_id = {suc_id} AND p.es_paquete = FALSE"
                self.cur.execute(q_prod)
                prods = {r[0]: float(r[1]) for r in self.cur.fetchall()}
                if prods: self.productos_por_sucursal[suc_id] = prods

                q_paq = f"SELECT p.producto_id, p.precio_unitario FROM producto p JOIN categoria c ON p.categoria_id = c.categoria_id JOIN menu m ON c.menu_id = m.menu_id JOIN sucursal_menu sm ON m.menu_id = sm.menu_id WHERE sm.sucursal_id = {suc_id} AND p.es_paquete = TRUE"
                self.cur.execute(q_paq)
                paqs = {r[0]: float(r[1]) for r in self.cur.fetchall()}
                if paqs: self.paquetes_por_sucursal[suc_id] = paqs

            # 4. Catálogos
            self.cur.execute("SELECT metodo_id, nombre FROM metodo_pago")
            self.metodos_pago = {r[0]: r[1] for r in self.cur.fetchall()}
            self.cur.execute("SELECT descuento_id FROM descuento WHERE activo = TRUE")
            self.ids_descuentos = [r[0] for r in self.cur.fetchall()]
            self.cur.execute("SELECT promocion_id FROM promocion WHERE esta_activo = TRUE")
            self.ids_promociones = [r[0] for r in self.cur.fetchall()]
            self.cur.execute("SELECT modificador_id, precio FROM modificador")
            self.modificadores = {r[0]: float(r[1]) for r in self.cur.fetchall()}
            self.cur.execute("SELECT area_cocina_id FROM area_cocina")
            self.areas_cocina = [r[0] for r in self.cur.fetchall()]
            self.cur.execute("SELECT dispositivo_id FROM dispositivo WHERE tipo NOT ILIKE '%impresora%'")
            self.dispositivos_validos_sesion = [r[0] for r in self.cur.fetchall()]

            # 5. Contadores
            tablas = ['sesion', 'orden', 'comensal', 'detalle_orden', 'pago', 'detalle_pago', 
                      'reserva', 'historial_preparacion', 'detalle_modificador', 'dispositivo', 
                      'area_impresion']
            for t in tablas:
                pk = f"{t}_id"
                if t == 'detalle_orden': pk = 'detalle_orden_id' 
                if t == 'detalle_modificador': pk = 'detalle_modificador'
                self.cur.execute(f"SELECT COALESCE(MAX({pk}), 0) FROM {t}")
                self.contadores[t] = self.cur.fetchone()[0] + 50 

            print(f"Contexto cargado. Sucursales: {len(self.ids_sucursales)}")

        except Exception as e:
            print(f"Error BD: {e}")
            exit()

    def generar_sql(self):
        print(f"Generando historial con roles ({FECHA_INICIO.date()} - {FECHA_FIN.date()})...")
        
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            # Infraestructura
            f.write("BEGIN;\n")
            f.write("-- GENERANDO INFRAESTRUCTURA BASE --\n")
            
            dispositivos_por_sucursal_map = {} 
            for suc_id in self.ids_sucursales:
                self.contadores['area_impresion'] += 1
                ai_id = self.contadores['area_impresion']
                f.write(f"INSERT INTO area_impresion (area_impresion_id, nombre, ip, tipo_impresora, estado) VALUES ({ai_id}, 'Caja Principal - Suc {suc_id}', '192.168.1.{100+ai_id}', 'Termica', 'activo');\n")
                
                self.contadores['dispositivo'] += 1
                dev_id = self.contadores['dispositivo']
                f.write(f"INSERT INTO dispositivo (dispositivo_id, area_impresion_id, tipo, estado, modelo) VALUES ({dev_id}, {ai_id}, 'Terminal Punto de Venta', 'activo', 'POS System V2');\n")
                
                if suc_id not in dispositivos_por_sucursal_map:
                    dispositivos_por_sucursal_map[suc_id] = []
                dispositivos_por_sucursal_map[suc_id].append(dev_id)
            
            # Auth updates
            f.write("\n-- ACTUALIZANDO EMPLEADOS Y DESCUENTOS --\n")
            all_empleados = []
            for emps in self.empleados_totales.values(): all_empleados.extend(emps)
            
            for emp_id in all_empleados:
                auth = f"AUTH-{fake.bothify(text='####')}"
                f.write(f"UPDATE empleado SET numero_autorizacion = '{auth}' WHERE empleado_id = {emp_id};\n")
            
            for desc_id in self.ids_descuentos:
                nec_auth = 'TRUE' if random.random() < 0.3 else 'FALSE'
                f.write(f"UPDATE descuento SET necesita_autorizacion = {nec_auth} WHERE descuento_id = {desc_id};\n")
            
            f.write("COMMIT;\n\n")

            # --- BUCLE TIEMPO ---
            fecha_actual = FECHA_INICIO
            
            while fecha_actual <= FECHA_FIN:
                if fecha_actual.day == 1: print(f" Procesando: {fecha_actual.strftime('%Y-%m')}")
                
                f.write(f"-- FECHA: {fecha_actual.date()}\n")
                f.write("BEGIN;\n")

                dia_semana = fecha_actual.weekday()
                es_fin_semana = dia_semana >= 4

                for suc_id in self.ids_sucursales:
                    # Listas de personal
                    todos_emps = self.empleados_totales.get(suc_id, [])
                    lista_meseros = self.meseros_por_sucursal.get(suc_id, [])
                    lista_gerentes = self.gerentes_por_sucursal.get(suc_id, [])
                    lista_cajeros = self.cajeros_por_sucursal.get(suc_id, [])
                    
                    mesas = self.mesas_por_sucursal.get(suc_id, [])
                    menu_items = self.productos_por_sucursal.get(suc_id, {})
                    menu_paquetes = self.paquetes_por_sucursal.get(suc_id, {})
                    devs_sucursal = dispositivos_por_sucursal_map.get(suc_id, self.dispositivos_validos_sesion)

                    if not todos_emps or not mesas or not devs_sucursal: continue
                    if not menu_items and not menu_paquetes: continue

                    # 1. Reservas
                    if random.random() < 0.3: 
                        for _ in range(random.randint(1, 3)):
                            self.contadores['reserva'] += 1; rid = self.contadores['reserva']
                            hora = fecha_actual.replace(hour=random.randint(13, 20), minute=random.choice([0,30]))
                            f.write(f"INSERT INTO reserva (reserva_id, mesa_id, nombre, telefono, num_acompañantes, fecha_hora_reserva) VALUES ({rid}, {random.choice(mesas)}, '{fake.first_name()}', '999', {random.randint(2,6)}, '{hora}');\n")

                    # 2. Sesiones
                    for _ in range(random.randint(1, 2)):
                        self.contadores['sesion'] += 1; ses_id = self.contadores['sesion']
                        # La caja la puede abrir cualquiera, pero preferentemente cajeros o gerentes
                        if lista_cajeros and random.random() < 0.7:
                            emp_cajero = random.choice(lista_cajeros)
                        elif lista_gerentes and random.random() < 0.8:
                            emp_cajero = random.choice(lista_gerentes)
                        else:
                            emp_cajero = random.choice(todos_emps)

                        dev = random.choice(devs_sucursal)
                        
                        inicio = fecha_actual.replace(hour=random.randint(7, 11), minute=random.randint(0,59))
                        cierre = inicio + timedelta(hours=random.randint(6, 10))
                        caja = Decimal(random.choice([1000, 1500, 2000]))
                        
                        f.write(f"INSERT INTO sesion (sesion_id, empleado_id, dispositivo_id, fecha_hora_apertura, efectivo_inicial, estado) VALUES ({ses_id}, {emp_cajero}, {dev}, '{inicio}', {caja}, 'cerrada');\n")

                        ventas_efectivo = Decimal(0)
                        
                        # 3. ÓRDENES
                        num_ordenes = random.randint(6, 18) if es_fin_semana else random.randint(3, 10)
                        
                        for _ in range(num_ordenes):
                            self.contadores['orden'] += 1
                            orden_id = self.contadores['orden'] 
                            
                            ts_ini = inicio + timedelta(minutes=random.randint(10, 300))
                            ts_fin = ts_ini + timedelta(minutes=random.randint(30, 90))
                            if ts_fin > cierre: ts_fin = cierre - timedelta(minutes=5)

                            empleado_orden = None
                            rand_val = random.random()

                            if lista_meseros and rand_val < 0.85:
                                empleado_orden = random.choice(lista_meseros)
                            elif lista_cajeros and rand_val < 0.95:
                                empleado_orden = random.choice(lista_cajeros)
                            elif lista_gerentes:
                                empleado_orden = random.choice(lista_gerentes)
                            else:
                                if lista_meseros: empleado_orden = random.choice(lista_meseros)
                                else: empleado_orden = random.choice(todos_emps)

                            # Insert Orden
                            f.write(f"INSERT INTO orden (orden_id, empleado_id, fecha_hora_inicio, fecha_hora_cierre, estado) VALUES ({orden_id}, {empleado_orden}, '{ts_ini}', '{ts_fin}', FALSE);\n")
                            f.write(f"INSERT INTO ordenMesa (orden_id, mesa_id) VALUES ({orden_id}, {random.choice(mesas)});\n")

                            consumos = [] 

                            # 4. Comensales y Detalle
                            for i_com in range(random.randint(1, 5)):
                                self.contadores['comensal'] += 1; cid = self.contadores['comensal']
                                f.write(f"INSERT INTO comensal (comensal_id, orden_id, nombre_etiqueta) VALUES ({cid}, {orden_id}, 'C-{i_com+1}');\n")
                                
                                subtotal = Decimal(0)

                                for _ in range(random.randint(1, 4)):
                                    usar_paquete = (random.random() < 0.15) and bool(menu_paquetes)
                                    if usar_paquete:
                                        pid = random.choice(list(menu_paquetes.keys()))
                                        precio = menu_paquetes[pid]
                                    elif menu_items:
                                        pid = random.choice(list(menu_items.keys()))
                                        precio = menu_items[pid]
                                    else: continue

                                    self.contadores['detalle_orden'] += 1; did = self.contadores['detalle_orden']
                                    f.write(f"INSERT INTO detalle_orden (detalle_orden_id, comensal_id, producto_id, cantidad, precio_unitario) VALUES ({did}, {cid}, {pid}, 1, {precio});\n")
                                    
                                    precio_final = Decimal(precio)
                                    
                                    # Modificadores
                                    if not usar_paquete and self.modificadores and random.random() < 0.2:
                                        mid = random.choice(list(self.modificadores.keys()))
                                        mprec = self.modificadores[mid]
                                        self.contadores['detalle_modificador'] += 1
                                        dmid = self.contadores['detalle_modificador']
                                        f.write(f"INSERT INTO detalle_modificador (detalle_modificador, detalle_orden_id, modificador_id, cantidad, precio_unitario) VALUES ({dmid}, {did}, {mid}, 1, {mprec});\n")
                                        precio_final += Decimal(mprec)
                                    
                                    # Promociones
                                    if self.ids_promociones and random.random() < 0.1:
                                        promid = random.choice(self.ids_promociones)
                                        f.write(f"INSERT INTO detalle_promocion (detalle_orden_id, promocion_id) VALUES ({did}, {promid});\n")

                                    # Historial Cocina
                                    if self.areas_cocina and random.random() < 0.8:
                                        self.contadores['historial_preparacion'] += 1
                                        hid = self.contadores['historial_preparacion']
                                        acoc = random.choice(self.areas_cocina)
                                        ts_prep = ts_ini + timedelta(minutes=random.randint(5, 25))
                                        f.write(f"INSERT INTO historial_preparacion (historial_preparacion_id, detalle_orden_id, area_cocina_id, estado, fecha_hora_preparacion) VALUES ({hid}, {did}, {acoc}, 'terminado', '{ts_prep}');\n")

                                    subtotal += precio_final
                                
                                if subtotal > 0: consumos.append({'id': cid, 'monto': subtotal})

                            # 5. Pagos
                            total_orden = sum(c['monto'] for c in consumos)
                            if total_orden > 0:
                                pagos_list = []
                                if len(consumos) > 1 and random.random() < 0.3:
                                    for c in consumos: pagos_list.append({'m': c['monto'], 'c': c['id']})
                                else:
                                    pagos_list.append({'m': total_orden, 'c': consumos[0]['id']})

                                for pg in pagos_list:
                                    self.contadores['pago'] += 1
                                    pay_id = self.contadores['pago']
                                    met_id = random.choice(list(self.metodos_pago.keys()))
                                    if 'efectivo' in self.metodos_pago[met_id].lower(): ventas_efectivo += pg['m']
                                    
                                    f.write(f"INSERT INTO pago (pago_id, metodo_id, fecha_hora, monto, propina) VALUES ({pay_id}, {met_id}, '{ts_fin}', {pg['m']}, {pg['m']*Decimal(0.1)});\n")
                                    
                                    self.contadores['detalle_pago'] += 1
                                    dpid = self.contadores['detalle_pago']
                                    disc_id = random.choice(self.ids_descuentos) if self.ids_descuentos and random.random() < 0.15 else 'NULL'
                                    
                                    f.write(f"INSERT INTO detalle_pago (detalle_pago_id, orden_id, comensal_id, pago_id, descuento_id) VALUES ({dpid}, {orden_id}, {pg['c']}, {pay_id}, {disc_id});\n")

                        # Cierre Sesión
                        cierre_sis = caja + ventas_efectivo
                        dif = Decimal(random.randint(-50, 50)) if random.random() < 0.2 else 0
                        f.write(f"UPDATE sesion SET fecha_hora_cierre = '{cierre}', efectivo_cierre_sistema = {cierre_sis}, efectivo_cierre_conteo = {cierre_sis + dif}, diferencia = {dif} WHERE sesion_id = {ses_id};\n")

                f.write("COMMIT;\n")
                fecha_actual += timedelta(days=1)

            # Ajuste Secuencias
            f.write("\n-- AJUSTE DE SECUENCIAS --\n")
            mapa = {
                'sesion': 'sesion_id', 'orden': 'orden_id', 'comensal': 'comensal_id', 
                'detalle_orden': 'detalle_orden_id', 'pago': 'pago_id', 'detalle_pago': 'detalle_pago_id', 
                'reserva': 'reserva_id', 'historial_preparacion': 'historial_preparacion_id', 
                'detalle_modificador': 'detalle_modificador', 'dispositivo': 'dispositivo_id',
                'area_impresion': 'area_impresion_id'
            }
            for t, pk in mapa.items():
                f.write(f"SELECT setval(pg_get_serial_sequence('{t}', '{pk}'), {self.contadores[t] + 1});\n")

if __name__ == "__main__":
    app = GeneradorHistorico()
    app.conectar_y_cargar_contexto()
    app.generar_sql()