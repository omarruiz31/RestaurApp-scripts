import psycopg2
from faker import Faker
import random
from datetime import datetime, timedelta
from decimal import Decimal

# --- CONFIGURACIÓN ---
DB_CONFIG = {
    'dbname': 'restaurapp',  # <--- PON TU NOMBRE DE BD AQUÍ
    'user': 'postgres',           # <--- TU USUARIO
    'password': '12345',  # <--- TU CONTRASEÑA
    'host': 'localhost',
    'port': '5432'
}

OUTPUT_FILE = 'historial_ventas_2023_2025.sql'
FECHA_INICIO = datetime(2023, 1, 1)
FECHA_FIN = datetime(2025, 12, 8)

fake = Faker('es_MX')

# --- CLASE GENERADORA ---

class GeneradorHistorico:
    def __init__(self):
        self.conn = None
        self.cur = None
        self.ids_sucursales = []
        self.empleados_por_sucursal = {} # {sucursal_id: [emp_id, ...]}
        self.mesas_por_sucursal = {}     # {sucursal_id: [mesa_id, ...]}
        self.productos = {}              # {id: precio}
        self.metodos_pago = []
        
        # Contadores para simular SERIAL
        self.contadores = {
            'sesion': 0, 'cuenta': 0, 'comensal': 0, 
            'detalle_cuenta': 0, 'pago': 0, 'detalle_pago': 0
        }

    def conectar_y_cargar_contexto(self):
        """Lee la BD para obtener IDs válidos y el punto de partida de los contadores"""
        print("Conectando a la base de datos para leer contexto...")
        try:
            self.conn = psycopg2.connect(**DB_CONFIG)
            self.cur = self.conn.cursor()

            # 1. Obtener Sucursales
            self.cur.execute("SELECT sucursal_id FROM sucursal")
            self.ids_sucursales = [r[0] for r in self.cur.fetchall()]

            if not self.ids_sucursales:
                raise Exception("No hay sucursales. Corre tus scripts de estructura primero.")

            # 2. Obtener Empleados y Mesas por Sucursal
            for suc_id in self.ids_sucursales:
                # Empleados
                self.cur.execute(f"SELECT empleado_id FROM empleado WHERE sucursal_id = {suc_id}")
                self.empleados_por_sucursal[suc_id] = [r[0] for r in self.cur.fetchall()]
                
                # Mesas
                self.cur.execute(f"""
                    SELECT m.mesa_id FROM mesa m 
                    JOIN areaventa a ON m.area_id = a.area_id 
                    WHERE a.sucursal_id = {suc_id}
                """)
                self.mesas_por_sucursal[suc_id] = [r[0] for r in self.cur.fetchall()]

            # 3. Obtener Productos y Precios
            self.cur.execute("SELECT producto_id, precio_unitario FROM producto WHERE es_paquete = FALSE")
            self.productos = {r[0]: r[1] for r in self.cur.fetchall()}

            # 4. Obtener Métodos de Pago
            self.cur.execute("SELECT metodo_id FROM metodo_pago")
            self.metodos_pago = [r[0] for r in self.cur.fetchall()]

            # 5. Obtener MAX IDs actuales para empezar a contar desde ahí
            tablas = ['sesion', 'cuenta', 'comensal', 'detalle_cuenta', 'pago', 'detalle_pago']
            for tabla in tablas:
                col_id = f"{tabla}_id" if tabla != 'detalle_modificador' else 'detalle_modificador'
                self.cur.execute(f"SELECT COALESCE(MAX({col_id}), 0) FROM {tabla}")
                self.contadores[tabla] = self.cur.fetchone()[0]

            print("Contexto cargado exitosamente.")
            print(f"Iniciando contadores en: {self.contadores}")

        except Exception as e:
            print(f"Error al leer BD: {e}")
            exit()
        finally:
            if self.conn: self.conn.close()

    def generar_sql(self):
        print(f"Generando archivo SQL desde {FECHA_INICIO.date()} hasta {FECHA_FIN.date()}...")
        
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write("-- SCRIPT GENERADO AUTOMATICAMENTE\n")
            f.write("-- Historial de ventas 2023 - 2025\n")
            f.write("BEGIN;\n\n") # Iniciar transacción

            fecha_actual = FECHA_INICIO
            
            while fecha_actual <= FECHA_FIN:
                dia_semana = fecha_actual.weekday() # 0=Lunes, 6=Domingo
                
                # Lógica de volumen: Fin de semana vende más
                if dia_semana >= 4: # Viernes, Sabado, Domingo
                    probabilidad_venta = 1.0 
                    num_cuentas_base = random.randint(15, 30)
                else:
                    probabilidad_venta = 0.8 # A veces no se abre o se vende poco
                    num_cuentas_base = random.randint(5, 12)

                print(f"Procesando fecha: {fecha_actual.date()}", end='\r')

                for suc_id in self.ids_sucursales:
                    empleados = self.empleados_por_sucursal.get(suc_id, [])
                    mesas = self.mesas_por_sucursal.get(suc_id, [])

                    if not empleados or not mesas:
                        continue # Si no hay datos base, saltar

                    # 1. ABRIR SESIÓN (Una por día por sucursal, simulado)
                    self.contadores['sesion'] += 1
                    sesion_id = self.contadores['sesion']
                    emp_sesion = random.choice(empleados)
                    inicio_sesion = fecha_actual.replace(hour=random.randint(8,11), minute=0)
                    
                    # SQL Sesion
                    f.write(f"INSERT INTO sesion (sesion_id, empleado_id, dispositivo_id, fecha_hora_apertura, estado) "
                            f"VALUES ({sesion_id}, {emp_sesion}, 1, '{inicio_sesion}', 'cerrada');\n")

                    # 2. GENERAR CUENTAS
                    for _ in range(num_cuentas_base):
                        # Hora aleatoria dentro del día operativo
                        hora_apertura = inicio_sesion + timedelta(minutes=random.randint(0, 600))
                        hora_cierre = hora_apertura + timedelta(minutes=random.randint(30, 90))
                        
                        self.contadores['cuenta'] += 1
                        cuenta_id = self.contadores['cuenta']
                        
                        # SQL Cuenta
                        f.write(f"INSERT INTO cuenta (cuenta_id, fecha_hora_inicio, fecha_hora_cierre, estado) "
                                f"VALUES ({cuenta_id}, '{hora_apertura}', '{hora_cierre}', FALSE);\n")
                        
                        # SQL CuentaMesa
                        mesa_random = random.choice(mesas)
                        f.write(f"INSERT INTO cuentaMesa (cuenta_id, mesa_id) VALUES ({cuenta_id}, {mesa_random});\n")

                        # 3. COMENSALES Y PEDIDOS
                        total_cuenta = Decimal(0)
                        num_personas = random.randint(1, 5)
                        
                        for p in range(num_personas):
                            self.contadores['comensal'] += 1
                            comensal_id = self.contadores['comensal']
                            
                            # SQL Comensal
                            f.write(f"INSERT INTO comensal (comensal_id, cuenta_id, nombre_etiqueta) "
                                    f"VALUES ({comensal_id}, {cuenta_id}, 'Comensal {p+1}');\n")

                            # Pedidos del comensal
                            for _ in range(random.randint(1, 3)): # 1 a 3 items por persona
                                prod_id = random.choice(list(self.productos.keys()))
                                precio = self.productos[prod_id]
                                cantidad = 1
                                
                                self.contadores['detalle_cuenta'] += 1
                                detalle_id = self.contadores['detalle_cuenta']
                                
                                # SQL Detalle
                                f.write(f"INSERT INTO detalle_cuenta (detalle_id, comensal_id, producto_id, cantidad, precio_unitario) "
                                        f"VALUES ({detalle_id}, {comensal_id}, {prod_id}, {cantidad}, {precio});\n")
                                
                                total_cuenta += (precio * cantidad)

                        # 4. PAGO
                        if self.metodos_pago:
                            self.contadores['pago'] += 1
                            pago_id = self.contadores['pago']
                            metodo = random.choice(self.metodos_pago)
                            propina = round(float(total_cuenta) * 0.10, 2)
                            
                            # SQL Pago
                            f.write(f"INSERT INTO pago (pago_id, metodo_id, fecha_hora, monto, propina) "
                                    f"VALUES ({pago_id}, {metodo}, '{hora_cierre}', {total_cuenta}, {propina});\n")
                            
                            # SQL Detalle Pago (Relación)
                            # Nota: Asumimos que la tabla detalle_pago tiene IDs seriales, pero aquí necesitamos relacionar
                            f.write(f"INSERT INTO detalle_pago (cuenta_id, pago_id) VALUES ({cuenta_id}, {pago_id});\n")

                # Avanzar día
                fecha_actual += timedelta(days=1)
            
            # Ajustar las secuencias de PostgreSQL al final para que no fallen los futuros inserts reales
            f.write("\n-- AJUSTE DE SECUENCIAS (IMPORTANTE)\n")
            tablas_seq = ['sesion', 'cuenta', 'comensal', 'detalle_cuenta', 'pago']
            for t in tablas_seq:
                max_id = self.contadores[t] + 1
                f.write(f"SELECT setval(pg_get_serial_sequence('{t}', '{t}_id'), {max_id});\n")
            
            f.write("\nCOMMIT;\n")
        
        print(f"\n\n¡Listo! Archivo generado: {OUTPUT_FILE}")
        print("Ahora puedes importar este archivo en tu BD usando:")
        print(f"psql -U postgres -d nombre_bd -f {OUTPUT_FILE}")

# --- EJECUCIÓN ---
if __name__ == "__main__":
    app = GeneradorHistorico()
    app.conectar_y_cargar_contexto()
    app.generar_sql()