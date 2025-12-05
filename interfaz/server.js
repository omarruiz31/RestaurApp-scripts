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
    password: '12345', // <--- TU CONTRASEÑA
    port: 5432,
});

// --- RUTAS GET EXISTENTES (Restaurantes, Sucursales, Mesas, Menú) ---
app.get('/api/restaurantes', async (req, res) => {
    const result = await pool.query('SELECT restaurante_id, nombre, rfc FROM restaurante ORDER BY restaurante_id');
    res.json(result.rows);
});

app.get('/api/sucursales/:id', async (req, res) => {
    const result = await pool.query('SELECT sucursal_id, nombre, region FROM sucursal WHERE restaurante_id = $1 ORDER BY nombre', [req.params.id]);
    res.json(result.rows);
});

// NUEVA RUTA: Obtener Empleados (Para saber quién abre la mesa)
app.get('/api/empleados/:sucursalId', async (req, res) => {
    try {
        const { sucursalId } = req.params;
        // Traemos ID, Nombre y Rol. Filtramos activos.
        const query = `
            SELECT e.empleado_id, e.nombre, e.apellido, r.nombre as rol
            FROM empleado e
            JOIN rol r ON e.rol_id = r.rol_id
            WHERE e.sucursal_id = $1 AND e.estado = TRUE
            ORDER BY r.nombre, e.nombre
        `;
        const result = await pool.query(query, [sucursalId]);
        res.json(result.rows);
    } catch (err) { res.status(500).send(err.message); }
});

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

// Monitor de Mesas (Optimizado para estructura ORDEN)
app.get('/api/mesas/:id', async (req, res) => {
    try {
        const query = `
        WITH ordenes_activas AS (
            SELECT o.orden_id, o.fecha_hora_inicio, om.mesa_id, 
                   e.nombre || ' ' || e.apellido as mesero -- Traemos nombre del mesero
            FROM orden o
            JOIN ordenmesa om ON o.orden_id = om.orden_id
            JOIN mesa m ON om.mesa_id = m.mesa_id
            JOIN areaventa av ON m.area_id = av.area_id
            LEFT JOIN empleado e ON o.empleado_id = e.empleado_id
            WHERE o.estado = TRUE AND av.sucursal_id = $1
        ),
        total_productos AS (
            SELECT ca.orden_id, SUM(d.cantidad * d.precio_unitario) as total
            FROM ordenes_activas ca
            JOIN comensal c ON ca.orden_id = c.orden_id
            JOIN detalle_orden d ON c.comensal_id = d.comensal_id
            GROUP BY ca.orden_id
        )
        SELECT 
            m.mesa_id, m.num_mesa, av.nombre AS area,
            CASE WHEN oa.orden_id IS NOT NULL THEN 'ocupada' ELSE 'libre' END as estado_mesa,
            oa.orden_id,
            oa.mesero, -- Enviamos quién atiende
            to_char(oa.fecha_hora_inicio, 'HH24:MI') as hora,
            COALESCE(tp.total, 0) as gran_total
        FROM mesa m
        JOIN areaventa av ON m.area_id = av.area_id
        LEFT JOIN ordenes_activas oa ON m.mesa_id = oa.mesa_id
        LEFT JOIN total_productos tp ON oa.orden_id = tp.orden_id
        WHERE av.sucursal_id = $1
        ORDER BY av.nombre, m.num_mesa;
        `;
        const result = await pool.query(query, [req.params.id]);
        res.json(result.rows);
    } catch (err) { res.status(500).send(err.message); }
});

// --- RUTAS TRANSACCIONALES ---

// 1. ABRIR ORDEN (Ahora pide EMPLEADO_ID)
app.post('/api/ordenes/abrir', async (req, res) => {
    const { mesa_id, num_comensales, empleado_id } = req.body; 
    const cantidad = num_comensales || 1;

    // Validación básica
    if (!empleado_id) return res.status(400).json({ error: "Se requiere un mesero para abrir la orden" });

    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        // Insertar Orden vinculada al Empleado
        const resOrden = await client.query(
            'INSERT INTO orden (estado, empleado_id) VALUES (TRUE, $1) RETURNING orden_id',
            [empleado_id]
        );
        const nuevaOrdenId = resOrden.rows[0].orden_id;

        await client.query('INSERT INTO ordenmesa (orden_id, mesa_id) VALUES ($1, $2)', [nuevaOrdenId, mesa_id]);

        for (let i = 1; i <= cantidad; i++) {
            await client.query("INSERT INTO comensal (orden_id, nombre_etiqueta) VALUES ($1, $2)", [nuevaOrdenId, `Comensal ${i}`]);
        }

        await client.query('COMMIT');
        res.json({ success: true, message: 'Orden abierta' });
    } catch (e) {
        await client.query('ROLLBACK');
        res.status(500).json({ error: e.message });
    } finally { client.release(); }
});

// 2. AGREGAR PRODUCTO (Igual que antes)
app.post('/api/ordenes/pedido', async (req, res) => {
    const { orden_id, producto_id, precio } = req.body;
    const client = await pool.connect();
    try {
        const resCom = await client.query('SELECT comensal_id FROM comensal WHERE orden_id = $1 LIMIT 1', [orden_id]);
        if (resCom.rows.length === 0) throw new Error("Error datos comensal");
        
        await client.query(
            'INSERT INTO detalle_orden (comensal_id, producto_id, cantidad, precio_unitario) VALUES ($1, $2, 1, $3)',
            [resCom.rows[0].comensal_id, producto_id, precio]
        );
        res.json({ success: true });
    } catch (e) { res.status(500).json({ error: e.message }); } finally { client.release(); }
});

// 3. CERRAR Y 4. CANCELAR (Igual que antes)
app.put('/api/ordenes/cerrar/:id', async (req, res) => {
    try {
        await pool.query("UPDATE orden SET estado = FALSE, fecha_hora_cierre = NOW() WHERE orden_id = $1", [req.params.id]);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/ordenes/cancelar/:id', async (req, res) => {
    try {
        await pool.query("DELETE FROM orden WHERE orden_id = $1", [req.params.id]);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ error: e.message }); }
});

app.listen(3000, () => console.log('Servidor listo en puerto 3000'));