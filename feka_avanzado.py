import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
from decimal import Decimal

# --- CONFIGURACIÓN ---
DB_CONFIG = {
    'dbname': 'restaurapp', 
    'user': 'postgres', 
    'password': '12345', # <--- TU CONTRASEÑA
    'host': 'localhost',
    'port': '5432'
}

OUTPUT_FILE = 'historial_global_final.sql'
FECHA_INICIO = datetime(2023, 1, 1)
FECHA_FIN = datetime(2025, 12, 8)

fake = Faker('es_MX')

class GeneradorHistorico:
    def __init__(self):
        self.conn = None
        self.cur = None
        
        # Contexto
        self.ids_sucursales = []
        self.empleados_por_sucursal = {} 
        self.mesas_por_sucursal = {}     
        self.productos_por_sucursal = {} # Platillos normales
        self.paquetes_por_sucursal = {}  # NUEVO: Paquetes
        
        self.metodos_pago = {}           
        self.ids_descuentos = []  
        self.ids_promociones = []
        self.modificadores = {}          
        self.areas_cocina = []
        # No cargamos areas de impresión existentes para usarlas, 
        # sino para saber el ID y crear nuevas para cada sucursal.
        
        self.dispositivos_validos_sesion = [] 
        
        self.contadores = {}

    def conectar_y_cargar_contexto(self):
        print("Conectando y analizando estructura de la BD...")
        try:
            self.conn = psycopg2.connect(**DB_CONFIG)
            self.cur = self.conn.cursor()

            # 1. Sucursales
            self.cur.execute("SELECT sucursal_id FROM sucursal")
            self.ids_sucursales = [r[0] for r in self.cur.fetchall()]
            if not self.ids_sucursales: raise Exception("No hay sucursales.")

            # 2. Empleados y Mesas
            for suc_id in self.ids_sucursales:
                self.cur.execute(f"SELECT empleado_id FROM empleado WHERE sucursal_id = {suc_id}")
                emps = [r[0] for r in self.cur.fetchall()]
                if emps: self.empleados_por_sucursal[suc_id] = emps
                
                self.cur.execute(f"""
                    SELECT m.mesa_id FROM mesa m 
                    JOIN areaventa a ON m.area_id = a.area_id 
                    WHERE a.sucursal_id = {suc_id}
                """)
                mesas = [r[0] for r in self.cur.fetchall()]
                if mesas: self.mesas_por_sucursal[suc_id] = mesas

            # 3. Productos Y PAQUETES por Sucursal
            for suc_id in self.ids_sucursales:
                # A) Productos Normales
                q_prod = f"""
                    SELECT p.producto_id, p.precio_unitario
                    FROM producto p
                    JOIN categoria c ON p.categoria_id = c.categoria_id
                    JOIN menu m ON c.menu_id = m.menu_id
                    JOIN sucursal_menu sm ON m.menu_id = sm.menu_id
                    WHERE sm.sucursal_id = {suc_id} AND p.es_paquete = FALSE
                """
                self.cur.execute(q_prod)
                prods = {r[0]: float(r[1]) for r in self.cur.fetchall()}
                if prods: self.productos_por_sucursal[suc_id] = prods

                # B) PAQUETES (NUEVO)
                q_paq = f"""
                    SELECT p.producto_id, p.precio_unitario
                    FROM producto p
                    JOIN categoria c ON p.categoria_id = c.categoria_id
                    JOIN menu m ON c.menu_id = m.menu_id
                    JOIN sucursal_menu sm ON m.menu_id = sm.menu_id
                    WHERE sm.sucursal_id = {suc_id} AND p.es_paquete = TRUE
                """
                self.cur.execute(q_paq)
                paqs = {r[0]: float(r[1]) for r in self.cur.fetchall()}
                if paqs: self.paquetes_por_sucursal[suc_id] = paqs

            # 4. Catálogos Generales
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

            # Cargar dispositivos existentes (que no sean impresoras) para tener base
            self.cur.execute("SELECT dispositivo_id FROM dispositivo WHERE tipo NOT ILIKE '%impresora%'")
            self.dispositivos_validos_sesion = [r[0] for r in self.cur.fetchall()]

            # 5. Inicializar Contadores
            tablas = ['sesion', 'cuenta', 'comensal', 'detalle_cuenta', 'pago', 'detalle_pago', 
                      'reserva', 'historial_preparacion', 'detalle_modificador', 'dispositivo', 
                      'detalle_promocion', 'area_impresion'] # Agregamos area_impresion
            
            for t in tablas:
                pk = f"{t}_id"
                if t == 'detalle_cuenta': pk = 'detalle_cuenta_id'
                if t == 'detalle_modificador': pk = 'detalle_modificador'
                if t == 'detalle_promocion': continue 
                
                self.cur.execute(f"SELECT COALESCE(MAX({pk}), 0) FROM {t}")
                self.contadores[t] = self.cur.fetchone()[0]

            print(f"Contexto cargado. Sucursales: {len(self.ids_sucursales)}")
            print(f"Paquetes detectados: {sum(len(p) for p in self.paquetes_por_sucursal.values())}")

        except Exception as e:
            print(f"Error BD: {e}")
            exit()

    def generar_sql(self):
        print(f"Generando historial ({FECHA_INICIO.date()} - {FECHA_FIN.date()})...")
        
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write("BEGIN;\n\n")

            # --- NUEVO: GARANTIZAR INFRAESTRUCTURA (AREA IMP + DISPOSITIVO) POR SUCURSAL ---
            f.write("-- GENERANDO INFRAESTRUCTURA BASE POR SUCURSAL --\n")
            
            # Diccionario para saber qué dispositivos pertenecen a qué sucursal (para las sesiones)
            # Como la sesion requiere un dispositivo, asignaremos los nuevos creados a su sucursal.
            dispositivos_por_sucursal_map = {} 

            for suc_id in self.ids_sucursales:
                # 1. Crear Area de Impresión dedicada
                self.contadores['area_impresion'] += 1
                ai_id = self.contadores['area_impresion']
                f.write(f"INSERT INTO area_impresion (area_impresion_id, nombre, ip, tipo_impresora, estado) "
                        f"VALUES ({ai_id}, 'Caja Principal - Suc {suc_id}', '192.168.1.{100+ai_id}', 'Termica', 'activo');\n")
                
                # 2. Crear Dispositivo vinculado a esa área
                self.contadores['dispositivo'] += 1
                dev_id = self.contadores['dispositivo']
                f.write(f"INSERT INTO dispositivo (dispositivo_id, area_impresion_id, tipo, estado, modelo) "
                        f"VALUES ({dev_id}, {ai_id}, 'Terminal Punto de Venta', 'activo', 'POS System V2');\n")
                
                # Guardamos este dispositivo como válido para esta sucursal
                if suc_id not in dispositivos_por_sucursal_map:
                    dispositivos_por_sucursal_map[suc_id] = []
                dispositivos_por_sucursal_map[suc_id].append(dev_id)
                
                # También lo agregamos a la lista global por si acaso
                self.dispositivos_validos_sesion.append(dev_id)

            f.write("\n")

            fecha_actual = FECHA_INICIO
            
            while fecha_actual <= FECHA_FIN:
                dia_semana = fecha_actual.weekday()
                es_fin_semana = dia_semana >= 4
                
                if fecha_actual.day == 1: print(f" Procesando: {fecha_actual.strftime('%Y-%m')}")

                for suc_id in self.ids_sucursales:
                    empleados = self.empleados_por_sucursal.get(suc_id, [])
                    mesas = self.mesas_por_sucursal.get(suc_id, [])
                    
                    # Menús disponibles
                    menu_items = self.productos_por_sucursal.get(suc_id, {})
                    menu_paquetes = self.paquetes_por_sucursal.get(suc_id, {})

                    # Dispositivos de esta sucursal (usamos los que acabamos de crear o los globales)
                    devs_sucursal = dispositivos_por_sucursal_map.get(suc_id, self.dispositivos_validos_sesion)

                    if not empleados or not mesas or not devs_sucursal: continue
                    # Si no hay productos ni paquetes, saltamos
                    if not menu_items and not menu_paquetes: continue

                    # 1. RESERVAS
                    if random.random() < 0.3: 
                        num_reservas = random.randint(1, 3)
                        for _ in range(num_reservas):
                            self.contadores['reserva'] += 1
                            rid = self.contadores['reserva']
                            hora = fecha_actual.replace(hour=random.randint(13, 20), minute=random.choice([0,30]))
                            f.write(f"INSERT INTO reserva (reserva_id, mesa_id, nombre, telefono, num_acompañantes, fecha_hora_reserva) VALUES ({rid}, {random.choice(mesas)}, '{fake.first_name()}', '9999999999', {random.randint(2,6)}, '{hora}');\n")

                    # 2. SESIONES
                    for _ in range(random.randint(1, 2)):
                        self.contadores['sesion'] += 1
                        ses_id = self.contadores['sesion']
                        emp = random.choice(empleados)
                        dev = random.choice(devs_sucursal) # Usamos dispositivo de la sucursal
                        
                        inicio = fecha_actual.replace(hour=random.randint(7, 11), minute=random.randint(0,59))
                        cierre = inicio + timedelta(hours=random.randint(6, 10))
                        caja_inicial = Decimal(random.choice([1000, 1500, 2000]))
                        
                        f.write(f"INSERT INTO sesion (sesion_id, empleado_id, dispositivo_id, fecha_hora_apertura, efectivo_inicial, estado) VALUES ({ses_id}, {emp}, {dev}, '{inicio}', {caja_inicial}, 'cerrada');\n")

                        ventas_efectivo_sesion = Decimal(0)
                        
                        # 3. CUENTAS
                        num_cuentas = random.randint(6, 18) if es_fin_semana else random.randint(3, 10)
                        
                        for _ in range(num_cuentas):
                            self.contadores['cuenta'] += 1
                            cta_id = self.contadores['cuenta']
                            
                            ts_ini = inicio + timedelta(minutes=random.randint(10, 300))
                            ts_fin = ts_ini + timedelta(minutes=random.randint(30, 90))
                            if ts_fin > cierre: ts_fin = cierre - timedelta(minutes=5)

                            f.write(f"INSERT INTO cuenta (cuenta_id, fecha_hora_inicio, fecha_hora_cierre, estado) VALUES ({cta_id}, '{ts_ini}', '{ts_fin}', FALSE);\n")
                            f.write(f"INSERT INTO cuentaMesa (cuenta_id, mesa_id) VALUES ({cta_id}, {random.choice(mesas)});\n")

                            consumos_comensales = [] 

                            # 4. COMENSALES Y DETALLES (PRODUCTOS O PAQUETES)
                            for i_com in range(random.randint(1, 5)):
                                self.contadores['comensal'] += 1
                                com_id = self.contadores['comensal']
                                f.write(f"INSERT INTO comensal (comensal_id, cuenta_id, nombre_etiqueta) VALUES ({com_id}, {cta_id}, 'C-{i_com+1}');\n")
                                
                                subtotal_comensal = Decimal(0)

                                for _ in range(random.randint(1, 4)):
                                    # DECISIÓN: ¿PAQUETE O PRODUCTO INDIVIDUAL?
                                    # 15% Probabilidad de paquete si existen paquetes en el menú
                                    usar_paquete = (random.random() < 0.15) and bool(menu_paquetes)
                                    
                                    if usar_paquete:
                                        prod_id = random.choice(list(menu_paquetes.keys()))
                                        precio_base = menu_paquetes[prod_id]
                                    elif menu_items:
                                        prod_id = random.choice(list(menu_items.keys()))
                                        precio_base = menu_items[prod_id]
                                    else:
                                        continue # No hay nada que vender

                                    precio_final_item = Decimal(precio_base)

                                    self.contadores['detalle_cuenta'] += 1
                                    det_id = self.contadores['detalle_cuenta']
                                    
                                    f.write(f"INSERT INTO detalle_cuenta (detalle_cuenta_id, comensal_id, producto_id, cantidad, precio_unitario) VALUES ({det_id}, {com_id}, {prod_id}, 1, {precio_base});\n")

                                    # MODIFICADORES (Solo si no es paquete, usualmente)
                                    if not usar_paquete and self.modificadores and random.random() < 0.2:
                                        mod_id = random.choice(list(self.modificadores.keys()))
                                        precio_mod = self.modificadores[mod_id]
                                        self.contadores['detalle_modificador'] += 1
                                        dm_id = self.contadores['detalle_modificador']
                                        f.write(f"INSERT INTO detalle_modificador (detalle_modificador, detalle_cuenta_id, modificador_id, cantidad, precio_unitario) VALUES ({dm_id}, {det_id}, {mod_id}, 1, {precio_mod});\n")
                                        precio_final_item += Decimal(precio_mod)

                                    # PROMOCIONES
                                    if self.ids_promociones and random.random() < 0.1:
                                        promo_id = random.choice(self.ids_promociones)
                                        f.write(f"INSERT INTO detalle_promocion (detalle_cuenta_id, promocion_id) VALUES ({det_id}, {promo_id});\n")

                                    # HISTORIAL COCINA
                                    if self.areas_cocina and random.random() < 0.8:
                                        self.contadores['historial_preparacion'] += 1
                                        hist_id = self.contadores['historial_preparacion']
                                        area_coc = random.choice(self.areas_cocina)
                                        ts_prep = ts_ini + timedelta(minutes=random.randint(2, 15))
                                        f.write(f"INSERT INTO historial_preparacion (historial_preparacion_id, detalle_cuenta_id, area_cocina_id, estado, fecha_hora_preparacion) VALUES ({hist_id}, {det_id}, {area_coc}, 'terminado', '{ts_prep}');\n")

                                    subtotal_comensal += precio_final_item
                                
                                if subtotal_comensal > 0:
                                    consumos_comensales.append({'id': com_id, 'monto': subtotal_comensal})

                            # 5. PAGOS (Usando métodos dinámicos)
                            total_cuenta = sum(c['monto'] for c in consumos_comensales)
                            
                            if total_cuenta > 0:
                                pagos_a_realizar = []
                                if len(consumos_comensales) > 1 and random.random() < 0.3:
                                    for c in consumos_comensales:
                                        pagos_a_realizar.append({'monto': c['monto'], 'comensal_id': c['id']})
                                else:
                                    pagos_a_realizar.append({'monto': total_cuenta, 'comensal_id': consumos_comensales[0]['id']})

                                for p_data in pagos_a_realizar:
                                    self.contadores['pago'] += 1
                                    pid = self.contadores['pago']
                                    
                                    # Elegir método de pago dinámicamente de lo que haya en la BD
                                    mid = random.choice(list(self.metodos_pago.keys()))
                                    nombre_met = self.metodos_pago[mid]
                                    
                                    # Detección flexible de efectivo
                                    if 'efectivo' in nombre_met.lower():
                                        ventas_efectivo_sesion += p_data['monto']
                                    
                                    propina = round(p_data['monto'] * Decimal(0.10), 2)
                                    f.write(f"INSERT INTO pago (pago_id, metodo_id, fecha_hora, monto, propina) VALUES ({pid}, {mid}, '{ts_fin}', {p_data['monto']}, {propina});\n")
                                    
                                    # Detalle Pago
                                    self.contadores['detalle_pago'] += 1
                                    dpid = self.contadores['detalle_pago']
                                    did = 'NULL'
                                    if self.ids_descuentos and random.random() < 0.15:
                                        did = random.choice(self.ids_descuentos)
                                    
                                    cid_sql = p_data['comensal_id']
                                    f.write(f"INSERT INTO detalle_pago (detalle_pago_id, cuenta_id, comensal_id, pago_id, descuento_id) VALUES ({dpid}, {cta_id}, {cid_sql}, {pid}, {did});\n")

                        # 6. CIERRE SESIÓN
                        efectivo_sistema = caja_inicial + ventas_efectivo_sesion
                        diferencia = Decimal(0)
                        if random.random() < 0.2: diferencia = Decimal(random.randint(-50, 50))
                        efectivo_real = efectivo_sistema + diferencia
                        
                        f.write(f"UPDATE sesion SET fecha_hora_cierre = '{cierre}', efectivo_cierre_sistema = {efectivo_sistema}, efectivo_cierre_conteo = {efectivo_real}, diferencia = {diferencia}, estado = 'cerrada' WHERE sesion_id = {ses_id};\n")

                fecha_actual += timedelta(days=1)

            # AJUSTE DE SECUENCIAS
            f.write("\n-- AJUSTE DE SECUENCIAS --\n")
            mapa = {
                'sesion': 'sesion_id', 'cuenta': 'cuenta_id', 'comensal': 'comensal_id', 
                'detalle_cuenta': 'detalle_cuenta_id', 'pago': 'pago_id', 'detalle_pago': 'detalle_pago_id', 
                'reserva': 'reserva_id', 'historial_preparacion': 'historial_preparacion_id', 
                'detalle_modificador': 'detalle_modificador', 'dispositivo': 'dispositivo_id',
                'area_impresion': 'area_impresion_id'
            }
            for t, pk in mapa.items():
                f.write(f"SELECT setval(pg_get_serial_sequence('{t}', '{pk}'), {self.contadores[t] + 1});\n")
            
            f.write("COMMIT;\n")

if __name__ == "__main__":
    app = GeneradorHistorico()
    app.conectar_y_cargar_contexto()
    app.generar_sql()