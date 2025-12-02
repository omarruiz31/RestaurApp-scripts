const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// --- CONFIGURACIÓN BD ---
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'restaurapp',
    password: '12345', // <--- IMPORTANTE: TU CONTRASEÑA
    port: 5432,
});

// --- RUTAS DE LECTURA (GET) ---
// (Mismas que antes: Restaurantes, Sucursales, Mesas)
app.get('/api/restaurantes', async (req, res) => {
    const result = await pool.query('SELECT restaurante_id, nombre, rfc FROM restaurante ORDER BY restaurante_id');
    res.json(result.rows);
});

app.get('/api/sucursales/:id', async (req, res) => {
    const result = await pool.query('SELECT sucursal_id, nombre, region FROM sucursal WHERE restaurante_id = $1 ORDER BY nombre', [req.params.id]);
    res.json(result.rows);
});

// Monitor de Mesas (Optimizado)
app.get('/api/mesas/:id', async (req, res) => {
    try {
        const query = `
        WITH cuentas_activas_sucursal AS (
            SELECT c.cuenta_id, c.fecha_hora_inicio, m.mesa_id
            FROM cuenta c
            JOIN cuentamesa cm ON c.cuenta_id = cm.cuenta_id
            JOIN mesa m ON cm.mesa_id = m.mesa_id
            JOIN areaventa av ON m.area_id = av.area_id
            WHERE c.estado = TRUE AND av.sucursal_id = $1
        ),
        total_productos AS (
            SELECT ca.cuenta_id, SUM(dc.cantidad * dc.precio_unitario) as total
            FROM cuentas_activas_sucursal ca
            JOIN comensal com ON ca.cuenta_id = com.cuenta_id
            JOIN detalle_cuenta dc ON com.comensal_id = dc.comensal_id
            GROUP BY ca.cuenta_id
        ),
        total_extras AS (
            SELECT ca.cuenta_id, SUM(dm.cantidad * dm.precio_unitario) as total
            FROM cuentas_activas_sucursal ca
            JOIN comensal com ON ca.cuenta_id = com.cuenta_id
            JOIN detalle_cuenta dc ON com.comensal_id = dc.comensal_id
            JOIN detalle_modificador dm ON dc.detalle_cuenta_id = dm.detalle_cuenta_id
            GROUP BY ca.cuenta_id
        )
        SELECT 
            m.mesa_id,
            m.num_mesa,
            av.nombre AS area,
            CASE WHEN ca.cuenta_id IS NOT NULL THEN 'ocupada' ELSE 'libre' END as estado_mesa,
            ca.cuenta_id,
            to_char(ca.fecha_hora_inicio, 'HH24:MI') as hora,
            (COALESCE(tp.total, 0) + COALESCE(te.total, 0)) as gran_total
        FROM mesa m
        JOIN areaventa av ON m.area_id = av.area_id
        LEFT JOIN cuentas_activas_sucursal ca ON m.mesa_id = ca.mesa_id
        LEFT JOIN total_productos tp ON ca.cuenta_id = tp.cuenta_id
        LEFT JOIN total_extras te ON ca.cuenta_id = te.cuenta_id
        WHERE av.sucursal_id = $1
        ORDER BY av.nombre, m.num_mesa;
        `;
        const result = await pool.query(query, [req.params.id]);
        res.json(result.rows);
    } catch (err) { res.status(500).send(err.message); }
});

// --- RUTAS CRUD CUENTAS (POST, PUT, DELETE) ---

// 1. ABRIR CUENTA (CREATE)
app.post('/api/cuentas/abrir', async (req, res) => {
    const { mesa_id } = req.body;
    const client = await pool.connect();
    
    try {
        await client.query('BEGIN'); // Iniciar transacción
        
        // A. Crear la cuenta
        const resCuenta = await client.query('INSERT INTO cuenta (estado) VALUES (TRUE) RETURNING cuenta_id');
        const nuevaCuentaId = resCuenta.rows[0].cuenta_id;
        
        // B. Vincular a la mesa
        await client.query('INSERT INTO cuentamesa (cuenta_id, mesa_id) VALUES ($1, $2)', [nuevaCuentaId, mesa_id]);
        
        // C. Crear un comensal por defecto (para poder agregar pedidos después)
        await client.query("INSERT INTO comensal (cuenta_id, nombre_etiqueta) VALUES ($1, 'Principal')", [nuevaCuentaId]);

        await client.query('COMMIT'); // Guardar cambios
        res.json({ success: true, message: 'Cuenta abierta' });
    } catch (e) {
        await client.query('ROLLBACK'); // Deshacer si hay error
        res.status(500).json({ error: e.message });
    } finally {
        client.release();
    }
});

// 2. CERRAR CUENTA (UPDATE - Cobrar)
app.put('/api/cuentas/cerrar/:id', async (req, res) => {
    const { id } = req.params; // ID Cuenta
    try {
        // Actualizamos estado a FALSE y ponemos fecha de cierre
        await pool.query("UPDATE cuenta SET estado = FALSE, fecha_hora_cierre = NOW() WHERE cuenta_id = $1", [id]);
        
        // NOTA: En un sistema real aquí insertarías en la tabla 'pago', 
        // pero para este ejemplo simplificado solo cerramos la cuenta.
        
        res.json({ success: true, message: 'Cuenta cerrada' });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

// 3. CANCELAR CUENTA (DELETE)
app.delete('/api/cuentas/cancelar/:id', async (req, res) => {
    const { id } = req.params;
    try {
        // Al borrar la cuenta, el ON DELETE CASCADE de tu BD borrará la relación con la mesa
        await pool.query("DELETE FROM cuenta WHERE cuenta_id = $1", [id]);
        res.json({ success: true, message: 'Cuenta eliminada' });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

app.listen(3000, () => console.log('Servidor listo en puerto 3000'));

// ... (MANTENER CÓDIGO ANTERIOR DE CONFIGURACIÓN Y GETS) ...

// --- NUEVA RUTA: OBTENER MENÚ DE LA SUCURSAL ---
app.get('/api/menu/:sucursalId', async (req, res) => {
    try {
        const { sucursalId } = req.params;
        const query = `
            SELECT p.producto_id, p.nombre, p.precio_unitario, c.nombre as categoria
            FROM producto p
            JOIN categoria c ON p.categoria_id = c.categoria_id
            JOIN menu m ON c.menu_id = m.menu_id
            JOIN sucursal_menu sm ON m.menu_id = sm.menu_id
            WHERE sm.sucursal_id = $1 AND p.es_paquete = FALSE
            ORDER BY c.nombre, p.nombre
        `;
        const result = await pool.query(query, [sucursalId]);
        res.json(result.rows);
    } catch (err) { res.status(500).send(err.message); }
});

// --- RUTAS CRUD CUENTAS ACTUALIZADAS ---

// 1. ABRIR CUENTA (Ahora con Comensales)
app.post('/api/cuentas/abrir', async (req, res) => {
    const { mesa_id, num_comensales } = req.body; // Recibimos num_comensales
    const cantidad = num_comensales || 1; // Por defecto 1
    
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        
        // A. Crear Cuenta
        const resCuenta = await client.query('INSERT INTO cuenta (estado) VALUES (TRUE) RETURNING cuenta_id');
        const nuevaCuentaId = resCuenta.rows[0].cuenta_id;
        
        // B. Vincular Mesa
        await client.query('INSERT INTO cuentamesa (cuenta_id, mesa_id) VALUES ($1, $2)', [nuevaCuentaId, mesa_id]);
        
        // C. Crear Comensales (Bucle)
        for(let i = 1; i <= cantidad; i++) {
            await client.query("INSERT INTO comensal (cuenta_id, nombre_etiqueta) VALUES ($1, $2)", [nuevaCuentaId, `Comensal ${i}`]);
        }

        await client.query('COMMIT');
        res.json({ success: true, message: 'Cuenta abierta con comensales' });
    } catch (e) {
        await client.query('ROLLBACK');
        res.status(500).json({ error: e.message });
    } finally { client.release(); }
});

// 2. AGREGAR PRODUCTO (NUEVO)
app.post('/api/cuentas/pedido', async (req, res) => {
    const { cuenta_id, producto_id, precio } = req.body;
    
    // Para simplificar esta interfaz, asignaremos el producto al PRIMER comensal de la cuenta
    // En un sistema avanzado, elegirías a qué comensal asignar.
    
    const client = await pool.connect();
    try {
        // Buscar el ID del primer comensal de esta cuenta
        const resComensal = await client.query('SELECT comensal_id FROM comensal WHERE cuenta_id = $1 ORDER BY comensal_id LIMIT 1', [cuenta_id]);
        
        if(resComensal.rows.length === 0) throw new Error("Cuenta sin comensales");
        const comensal_id = resComensal.rows[0].comensal_id;

        // Insertar detalle
        await client.query(
            'INSERT INTO detalle_cuenta (comensal_id, producto_id, cantidad, precio_unitario) VALUES ($1, $2, 1, $3)',
            [comensal_id, producto_id, precio]
        );

        res.json({ success: true, message: 'Producto agregado' });
    } catch (e) { res.status(500).json({ error: e.message }); } finally { client.release(); }
});

// ... (MANTENER RUTAS DE CERRAR Y CANCELAR IGUALES) ...

app.listen(3000, () => console.log('Servidor actualizado puerto 3000'));