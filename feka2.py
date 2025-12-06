import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
from decimal import Decimal

# FIJAR LA ALEATORIEDAD 
SEED_VALUE = 42  
random.seed(SEED_VALUE)
Faker.seed(SEED_VALUE)

# --- CONFIGURACIÓN ---
DB_CONFIG = {
    'dbname': 'restaurapp', 
    'user': 'postgres', 
    'password': '12345', # <--- REVISA TU CONTRASEÑA
    'host': 'localhost',
    'port': '5432'
}

OUTPUT_FILE = 'historial_calibrado_6m.sql'
FECHA_INICIO = datetime(2023, 1, 1)
FECHA_FIN = datetime(2025, 12, 8)

fake = Faker('es_MX')
DIAS_SEMANA = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']

# --- REGLAS DE PROMOCIONES POR MARCA ---
PROMOS_PICADITA = [
    "Lunes de Atascón", "Martes Tradicional", "Miércoles de Tamales", 
    "Jueves de Huevos", "Viernes de Bebidas"
]
PROMOS_BOCATA = [
    "Temporada Día de Muertos", "3x2 Cervezas Buen Fin", 
    "2x1 Mocktails", "2x1 Cocteles", "2x1 Mezcal"
]

class GeneradorHistorico:
    def __init__(self):
        self.conn = None
        self.cur = None
        
        self.ids_sucursales = []
        self.sucursal_restaurante_map = {} 
        self.empleados_totales = {}; self.meseros_por_sucursal = {}
        self.gerentes_por_sucursal = {}; self.cajeros_por_sucursal = {}
        self.mesas_por_sucursal = {}; self.productos_por_sucursal = {}
        self.paquetes_por_sucursal = {}; self.metodos_pago = {}
        self.ids_descuentos = []; self.promociones_data = []
        self.modificadores = {}; self.areas_cocina = []
        self.dispositivos_validos_sesion = []
        self.contadores = {}

    def conectar_y_cargar_contexto(self):
        print("Conectando y analizando estructura de la BD...")
        try:
            self.conn = psycopg2.connect(**DB_CONFIG)
            self.cur = self.conn.cursor()

            print("🔧 Ajustando precios en $0.00...")
            self.cur.execute("""
                UPDATE producto 
                SET precio_unitario = (random() * (220 - 120) + 120)::NUMERIC(10,2) 
                WHERE precio_unitario = 0.00;
            """)
            self.conn.commit()

            # Sucursales y Mapeo Restaurante
            self.cur.execute("""
                SELECT s.sucursal_id, r.nombre 
                FROM sucursal s 
                JOIN restaurante r ON s.restaurante_id = r.restaurante_id
            """)
            res = self.cur.fetchall()
            self.ids_sucursales = []
            for row in res:
                sid, rname = row
                self.ids_sucursales.append(sid)
                self.sucursal_restaurante_map[sid] = rname.lower()
            
            if not self.ids_sucursales: raise Exception("No hay sucursales.")

            for suc_id in self.ids_sucursales:
                # Empleados
                self.cur.execute(f"SELECT e.empleado_id, r.nombre FROM empleado e JOIN rol r ON e.rol_id = r.rol_id WHERE e.sucursal_id = {suc_id}")
                res_emp = self.cur.fetchall()
                
                self.empleados_totales[suc_id] = [r[0] for r in res_emp]
                self.meseros_por_sucursal[suc_id] = [r[0] for r in res_emp if 'mesero' in r[1].lower()]
                self.gerentes_por_sucursal[suc_id] = [r[0] for r in res_emp if 'gerente' in r[1].lower()]
                self.cajeros_por_sucursal[suc_id] = [r[0] for r in res_emp if 'cajero' in r[1].lower()]
                
                # Mesas
                self.cur.execute(f"SELECT m.mesa_id FROM mesa m JOIN areaventa a ON m.area_id = a.area_id WHERE a.sucursal_id = {suc_id}")
                self.mesas_por_sucursal[suc_id] = [r[0] for r in self.cur.fetchall()]

                # Productos
                q_p = f"SELECT p.producto_id, p.precio_unitario FROM producto p JOIN categoria c ON p.categoria_id = c.categoria_id JOIN menu m ON c.menu_id = m.menu_id JOIN sucursal_menu sm ON m.menu_id = sm.menu_id WHERE sm.sucursal_id = {suc_id} AND p.es_paquete = FALSE"
                self.cur.execute(q_p); self.productos_por_sucursal[suc_id] = {r[0]: float(r[1]) for r in self.cur.fetchall()}
                q_pq = f"SELECT p.producto_id, p.precio_unitario FROM producto p JOIN categoria c ON p.categoria_id = c.categoria_id JOIN menu m ON c.menu_id = m.menu_id JOIN sucursal_menu sm ON m.menu_id = sm.menu_id WHERE sm.sucursal_id = {suc_id} AND p.es_paquete = TRUE"
                self.cur.execute(q_pq); self.paquetes_por_sucursal[suc_id] = {r[0]: float(r[1]) for r in self.cur.fetchall()}

            # Catálogos
            self.cur.execute("SELECT metodo_id, nombre FROM metodo_pago")
            self.metodos_pago = {r[0]: r[1] for r in self.cur.fetchall()}
            self.cur.execute("SELECT descuento_id FROM descuento WHERE activo = TRUE")
            self.ids_descuentos = [r[0] for r in self.cur.fetchall()]
            
            self.cur.execute("SELECT promocion_id, fecha_hora_inicio, fecha_hora_fin, nombre FROM promocion WHERE esta_activo = TRUE")
            self.promociones_data = [{'id':r[0], 'inicio':r[1], 'fin':r[2], 'nombre':r[3]} for r in self.cur.fetchall()]

            self.cur.execute("SELECT modificador_id, precio FROM modificador"); self.modificadores = {r[0]: float(r[1]) for r in self.cur.fetchall()}
            self.cur.execute("SELECT area_cocina_id FROM area_cocina"); self.areas_cocina = [r[0] for r in self.cur.fetchall()]
            self.cur.execute("SELECT dispositivo_id FROM dispositivo WHERE tipo NOT ILIKE '%impresora%'"); self.dispositivos_validos_sesion = [r[0] for r in self.cur.fetchall()]

            # Contadores
            tablas = ['sesion', 'orden', 'comensal', 'detalle_orden', 'pago', 'detalle_pago', 'reserva', 'historial_preparacion', 'detalle_modificador', 'dispositivo', 'area_impresion']
            for t in tablas:
                pk = f"{t}_id" if t not in ['detalle_orden', 'detalle_modificador'] else t + "_id" if t == 'detalle_orden' else 'detalle_modificador'
                self.cur.execute(f"SELECT COALESCE(MAX({pk}), 0) FROM {t}")
                self.contadores[t] = self.cur.fetchone()[0] + 1000

            print("✅ Contexto cargado.")

        except Exception as e: print(f"❌ Error BD: {e}"); exit()

    def obtener_promociones_validas(self, fecha_orden, sucursal_id):
        validas = []
        dia_nombre = DIAS_SEMANA[fecha_orden.weekday()]
        restaurante = self.sucursal_restaurante_map.get(sucursal_id, "").lower()
        
        for promo in self.promociones_data:
            nombre_promo = promo['nombre']
            
            # Reglas por Marca
            es_picadita = any(k in nombre_promo for k in PROMOS_PICADITA)
            es_bocata   = any(k in nombre_promo for k in PROMOS_BOCATA)
            
            permitida = False
            if 'picadita' in restaurante:
                if es_picadita: permitida = True
            elif 'bocata' in restaurante:
                if es_bocata: permitida = True
            else: # Madison
                if not es_picadita and not es_bocata: permitida = True
            
            if not permitida: continue

            # Reglas por Tiempo
            es_valida_tiempo = False
            if promo['inicio'] and promo['fin']:
                if promo['inicio'] <= fecha_orden <= promo['fin']: es_valida_tiempo = True
            elif not promo['inicio'] and not promo['fin']:
                if promo['nombre'].lower().startswith(dia_nombre.lower()): es_valida_tiempo = True
            
            if es_valida_tiempo: validas.append(promo['id'])
        return validas

    # Verificar disponibilidad de mesa
    def esta_mesa_libre(self, mesa_id, hora_inicio, hora_fin, ocupacion_dia):
        intervalos = ocupacion_dia.get(mesa_id, [])
        for ocupado_ini, ocupado_fin in intervalos:
            if hora_inicio < ocupado_fin and hora_fin > ocupado_ini:
                return False 
        return True 

    def generar_sql(self):
        print(f"Generando historial CALIBRADO 6M ({FECHA_INICIO.date()} - {FECHA_FIN.date()})...")
        
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            # Infraestructura
            f.write("BEGIN;\n")
            dispositivos_por_sucursal_map = {} 
            for suc_id in self.ids_sucursales:
                self.contadores['area_impresion'] += 1; ai_id = self.contadores['area_impresion']
                ip_safe = f"192.168.1.{(ai_id % 250) + 1}"
                f.write(f"INSERT INTO area_impresion (area_impresion_id, nombre, ip, tipo_impresora, estado) VALUES ({ai_id}, 'Caja Principal - Suc {suc_id}', '{ip_safe}', 'Termica', 'activo');\n")
                self.contadores['dispositivo'] += 1; dev_id = self.contadores['dispositivo']
                f.write(f"INSERT INTO dispositivo (dispositivo_id, area_impresion_id, tipo, estado, modelo) VALUES ({dev_id}, {ai_id}, 'Terminal Punto de Venta', 'activo', 'POS System V2');\n")
                if suc_id not in dispositivos_por_sucursal_map: dispositivos_por_sucursal_map[suc_id] = []
                dispositivos_por_sucursal_map[suc_id].append(dev_id)
            
            all_emps = [e for sublist in self.empleados_totales.values() for e in sublist]
            for emp_id in all_emps: f.write(f"UPDATE empleado SET numero_autorizacion = 'AUTH-{fake.bothify(text='####')}' WHERE empleado_id = {emp_id};\n")
            for desc_id in self.ids_descuentos: f.write(f"UPDATE descuento SET necesita_autorizacion = {'TRUE' if random.random() < 0.3 else 'FALSE'} WHERE descuento_id = {desc_id};\n")
            f.write("COMMIT;\n\n")

            fecha_actual = FECHA_INICIO
            while fecha_actual <= FECHA_FIN:
                if fecha_actual.day == 1: print(f" Procesando: {fecha_actual.strftime('%Y-%m')}")
                f.write(f"-- FECHA: {fecha_actual.date()}\n")
                f.write("BEGIN;\n")
                es_fin_semana = fecha_actual.weekday() >= 4

                for suc_id in self.ids_sucursales:
                    todos = self.empleados_totales.get(suc_id, [])
                    mesas = self.mesas_por_sucursal.get(suc_id, [])
                    devs = dispositivos_por_sucursal_map.get(suc_id, self.dispositivos_validos_sesion)
                    menu = self.productos_por_sucursal.get(suc_id, {})
                    paqs = self.paquetes_por_sucursal.get(suc_id, {})
                    if not todos or not mesas or not devs or (not menu and not paqs): continue

                    ocupacion_mesas_hoy = {}

                    # 1. RESERVAS
                    reservas_hoy = [] 
                    if random.random() < 0.3: 
                        for _ in range(random.randint(1, 3)): 
                            for _ in range(5): 
                                mc = random.choice(mesas)
                                hc = fecha_actual.replace(hour=random.randint(13, 20), minute=random.choice([0,30]))
                                fin_reserva = hc + timedelta(hours=2)
                                
                                if self.esta_mesa_libre(mc, hc, fin_reserva, ocupacion_mesas_hoy):
                                    if mc not in ocupacion_mesas_hoy: ocupacion_mesas_hoy[mc] = []
                                    ocupacion_mesas_hoy[mc].append((hc, fin_reserva))

                                    self.contadores['reserva'] += 1; rid = self.contadores['reserva']
                                    f.write(f"INSERT INTO reserva (reserva_id, mesa_id, nombre, telefono, num_acompañantes, fecha_hora_reserva) VALUES ({rid}, {mc}, '{fake.first_name()}', '999', {random.randint(2,6)}, '{hc}');\n")
                                    reservas_hoy.append({'hora': hc, 'mesa_id': mc, 'fin': fin_reserva})
                                    break

                    # 2. SESIONES (1 a 2 sesiones por día)
                    emps_usados = set()
                    num_sesiones = random.randint(1, 2)
                    for i_ses in range(num_sesiones):
                        cands = [e for e in todos if e not in emps_usados]
                        if not cands: break
                        
                        l_caj = [e for e in self.cajeros_por_sucursal.get(suc_id,[]) if e not in emps_usados]
                        l_ger = [e for e in self.gerentes_por_sucursal.get(suc_id,[]) if e not in emps_usados]
                        emp_caj = random.choice(l_caj) if l_caj and random.random()<0.7 else \
                                  random.choice(l_ger) if l_ger and random.random()<0.8 else \
                                  random.choice(cands)
                        emps_usados.add(emp_caj)

                        self.contadores['sesion'] += 1; ses_id = self.contadores['sesion']
                        if i_ses == 0: h_apertura = fecha_actual.replace(hour=8, minute=0)
                        else: h_apertura = fecha_actual.replace(hour=15, minute=0)
                        h_cierre = h_apertura + timedelta(hours=6)
                        caja = Decimal(random.choice([1500, 2000]))
                        
                        f.write(f"INSERT INTO sesion (sesion_id, empleado_id, dispositivo_id, fecha_hora_apertura, efectivo_inicial, estado) VALUES ({ses_id}, {emp_caj}, {random.choice(devs)}, '{h_apertura}', {caja}, 'cerrada');\n")
                        ventas_efectivo = Decimal(0)
                        
                        ordenes_confirmadas = []

                        # A) Reservas
                        pendientes = []
                        for res in reservas_hoy:
                            if h_apertura <= res['hora'] < h_cierre:
                                ts_ini = res['hora'] + timedelta(minutes=random.randint(0, 30))
                                ts_fin = ts_ini + timedelta(minutes=random.randint(45, 90))
                                ordenes_confirmadas.append({'inicio': ts_ini, 'fin': ts_fin, 'mesa': res['mesa_id']})
                            else:
                                pendientes.append(res)
                        reservas_hoy = pendientes

                        # B) Walk-ins (CALIBRADO: 10-20 órdenes)
                        intentos_walkin = random.randint(12, 20) if es_fin_semana else random.randint(5, 10)
                        for _ in range(intentos_walkin):
                            ts_ini = h_apertura + timedelta(minutes=random.randint(10, 350))
                            duracion = timedelta(minutes=random.randint(40, 90))
                            ts_fin = ts_ini + duracion
                            if ts_fin > h_cierre: continue 

                            mesas_random = list(mesas)
                            random.shuffle(mesas_random)
                            
                            for m_cand in mesas_random:
                                if self.esta_mesa_libre(m_cand, ts_ini, ts_fin, ocupacion_mesas_hoy):
                                    if m_cand not in ocupacion_mesas_hoy: ocupacion_mesas_hoy[m_cand] = []
                                    ocupacion_mesas_hoy[m_cand].append((ts_ini, ts_fin))
                                    ordenes_confirmadas.append({'inicio': ts_ini, 'fin': ts_fin, 'mesa': m_cand})
                                    break

                        # 3. CREAR LOS REGISTROS
                        for ord_data in ordenes_confirmadas:
                            ts_ini = ord_data['inicio']
                            ts_fin = ord_data['fin']
                            
                            self.contadores['orden'] += 1; oid = self.contadores['orden']
                            l_mes = self.meseros_por_sucursal.get(suc_id, [])
                            emp_ord = random.choice(l_mes) if l_mes and random.random()<0.90 else random.choice(todos)

                            f.write(f"INSERT INTO orden (orden_id, empleado_id, fecha_hora_inicio, fecha_hora_cierre, estado) VALUES ({oid}, {emp_ord}, '{ts_ini}', '{ts_fin}', FALSE);\n")
                            f.write(f"INSERT INTO ordenMesa (orden_id, mesa_id) VALUES ({oid}, {ord_data['mesa']});\n")

                            consumos = []
                            # 2-4 comensales
                            for i_c in range(random.randint(2, 4)):
                                self.contadores['comensal'] += 1; cid = self.contadores['comensal']
                                f.write(f"INSERT INTO comensal (comensal_id, orden_id, nombre_etiqueta) VALUES ({cid}, {oid}, 'C-{i_c+1}');\n")
                                subtotal = Decimal(0)
                                promos_validas = self.obtener_promociones_validas(ts_ini, suc_id)

                                # 1-3 productos
                                for _ in range(random.randint(1, 3)):
                                    usar_paq = (random.random()<0.15) and bool(paqs)
                                    if usar_paq: pid = random.choice(list(paqs.keys())); pr = paqs[pid]
                                    elif menu: pid = random.choice(list(menu.keys())); pr = menu[pid]
                                    else: continue

                                    self.contadores['detalle_orden'] += 1; did = self.contadores['detalle_orden']
                                    f.write(f"INSERT INTO detalle_orden (detalle_orden_id, comensal_id, producto_id, cantidad, precio_unitario) VALUES ({did}, {cid}, {pid}, 1, {pr});\n")
                                    pr_fin = Decimal(pr)
                                    
                                    if not usar_paq and self.modificadores and random.random() < 0.20:
                                        mid = random.choice(list(self.modificadores.keys())); mpr = self.modificadores[mid]
                                        self.contadores['detalle_modificador'] += 1; dmid = self.contadores['detalle_modificador']
                                        f.write(f"INSERT INTO detalle_modificador (detalle_modificador, detalle_orden_id, modificador_id, cantidad, precio_unitario) VALUES ({dmid}, {did}, {mid}, 1, {mpr});\n")
                                        pr_fin += Decimal(mpr)

                                    if promos_validas and random.random() < 0.15:
                                        prom = random.choice(promos_validas)
                                        f.write(f"INSERT INTO detalle_promocion (detalle_orden_id, promocion_id) VALUES ({did}, {prom});\n")

                                    if self.areas_cocina and random.random() < 0.9:
                                        self.contadores['historial_preparacion'] += 1; hid = self.contadores['historial_preparacion']
                                        ts_prep = ts_ini + timedelta(minutes=random.randint(5, 25))
                                        f.write(f"INSERT INTO historial_preparacion (historial_preparacion_id, detalle_orden_id, area_cocina_id, estado, fecha_hora_preparacion) VALUES ({hid}, {did}, {random.choice(self.areas_cocina)}, 'terminado', '{ts_prep}');\n")
                                    subtotal += pr_fin
                                if subtotal > 0: consumos.append({'id': cid, 'monto': subtotal})
                            
                            tot_ord = sum(c['monto'] for c in consumos)
                            if tot_ord > 0:
                                p_list = []
                                if len(consumos)>1 and random.random()<0.3:
                                    for c in consumos: p_list.append({'m': c['monto'], 'c': c['id']})
                                else: p_list.append({'m': tot_ord, 'c': consumos[0]['id']})

                                for pg in p_list:
                                    self.contadores['pago'] += 1; pid = self.contadores['pago']
                                    met = random.choice(list(self.metodos_pago.keys()))
                                    if 'efectivo' in self.metodos_pago[met].lower(): ventas_efectivo += pg['m']
                                    f.write(f"INSERT INTO pago (pago_id, metodo_id, fecha_hora, monto, propina) VALUES ({pid}, {met}, '{ts_fin}', {pg['m']}, {pg['m']*Decimal(0.15)});\n")
                                    
                                    self.contadores['detalle_pago'] += 1; dpid = self.contadores['detalle_pago']
                                    disc = random.choice(self.ids_descuentos) if self.ids_descuentos and random.random()<0.15 else 'NULL'
                                    f.write(f"INSERT INTO detalle_pago (detalle_pago_id, orden_id, comensal_id, pago_id, descuento_id) VALUES ({dpid}, {oid}, {pg['c']}, {pid}, {disc});\n")

                        cierre_sis = caja + ventas_efectivo
                        dif = Decimal(random.randint(-50, 50)) if random.random() < 0.2 else 0
                        f.write(f"UPDATE sesion SET fecha_hora_cierre = '{h_cierre}', efectivo_cierre_sistema = {cierre_sis}, efectivo_cierre_conteo = {cierre_sis + dif}, diferencia = {dif} WHERE sesion_id = {ses_id};\n")

                f.write("COMMIT;\n")
                fecha_actual += timedelta(days=1)

            f.write("\n-- AJUSTE SECUENCIAS --\n")
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