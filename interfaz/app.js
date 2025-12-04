const API_URL = 'http://localhost:3000/api';
let currentRestaurante = null;
let currentSucursalId = null;

// Variables temporales para el modal
let mesaSeleccionadaId = null;
let ordenSeleccionadaId = null;

// --- NAVEGACIÓN BÁSICA (Igual que antes) ---
function showSection(id) {
    ['view-restaurantes', 'view-sucursales', 'view-mesas'].forEach(v => document.getElementById(v).classList.add('hidden'));
    document.getElementById(id).classList.remove('hidden');
    const btnVolver = document.getElementById('btn-volver');
    if (id === 'view-restaurantes') btnVolver.classList.add('hidden');
    else btnVolver.classList.remove('hidden');
}

function goBack() {
    if (!document.getElementById('view-mesas').classList.contains('hidden')) showSection('view-sucursales');
    else { showSection('view-restaurantes'); currentRestaurante = null; }
}

// --- CARGA DE DATOS ---
async function loadRestaurantes() {
    const res = await fetch(`${API_URL}/restaurantes`);
    const data = await res.json();
    const container = document.getElementById('list-restaurantes');
    container.innerHTML = '';
    data.forEach(r => {
        const div = document.createElement('div');
        div.className = 'card'; div.innerHTML = `<h3>${r.nombre}</h3><p>${r.rfc || ''}</p>`;
        div.onclick = () => loadSucursales(r.restaurante_id, r.nombre);
        container.appendChild(div);
    });
    showSection('view-restaurantes');
}

async function loadSucursales(restId, restNombre) {
    currentRestaurante = restNombre;
    const res = await fetch(`${API_URL}/sucursales/${restId}`);
    const data = await res.json();
    const container = document.getElementById('list-sucursales');
    container.innerHTML = '';
    document.getElementById('title-sucursales').innerText = `Sucursales de ${restNombre}`;
    data.forEach(s => {
        const div = document.createElement('div');
        div.className = 'card'; div.innerHTML = `<h3>${s.nombre}</h3><p>${s.region}</p>`;
        div.onclick = () => loadMesas(s.sucursal_id, s.nombre);
        container.appendChild(div);
    });
    showSection('view-sucursales');
}

async function loadMesas(sucId, sucNombre) {
    currentSucursalId = sucId;
    document.getElementById('title-mesas').innerText = `Monitor: ${sucNombre}`;
    refreshMesas();
    showSection('view-mesas');
}

// --- MONITOR Y ACCIONES ---
async function refreshMesas() {
    if (!currentSucursalId) return;
    const container = document.getElementById('grid-mesas');
    container.innerHTML = '<p>Cargando...</p>';

    const res = await fetch(`${API_URL}/mesas/${currentSucursalId}`);
    const data = await res.json();
    container.innerHTML = '';

    if (data.length === 0) { container.innerHTML = '<p>No hay mesas.</p>'; return; }

    data.forEach(m => {
        const isBusy = m.estado_mesa === 'ocupada';
        const estadoClass = isBusy ? 'mesa-ocupada' : 'mesa-libre';
        const totalDisplay = isBusy ? `$${parseFloat(m.gran_total).toFixed(2)}` : 'Libre';
        const horaDisplay = isBusy ? `${m.hora}` : '--:--';

        const div = document.createElement('div');
        div.className = `mesa-card ${estadoClass}`;
        // Al hacer clic, abrimos el modal pasando datos de la mesa
        div.onclick = () => abrirModalAcciones(m.mesa_id, m.num_mesa, m.orden_id, isBusy);

        div.innerHTML = `
            <span class="mesa-num">Mesa ${m.num_mesa}</span>
            <div class="mesa-info">${m.area}</div>
            <div class="mesa-info">${horaDisplay}</div>
            <span class="mesa-total">${totalDisplay}</span>
        `;
        container.appendChild(div);
    });
}

// --- LÓGICA DEL MODAL CRUD ---
function abrirModalAcciones(mesaId, numMesa, ordenId, isBusy) {
    mesaSeleccionadaId = mesaId;
    ordenSeleccionadaId = ordenId;

    document.getElementById('modal-titulo').innerText = `Mesa ${numMesa}`;
    document.getElementById('modal-overlay').classList.remove('hidden');

    if (isBusy) {
        // Si está ocupada, mostrar opciones de cerrar/cancelar
        document.getElementById('acciones-libre').classList.add('hidden');
        document.getElementById('acciones-ocupada').classList.remove('hidden');
        document.getElementById('modal-desc').innerText = `Orden activa #${ordenId}`;
    } else {
        // Si está libre, mostrar opción de abrir
        document.getElementById('acciones-ocupada').classList.add('hidden');
        document.getElementById('acciones-libre').classList.remove('hidden');
        document.getElementById('modal-desc').innerText = "La mesa está libre.";
    }
}

function cerrarModal() {
    document.getElementById('modal-overlay').classList.add('hidden');
    mesaSeleccionadaId = null;
    ordenSeleccionadaId = null;
}

// 1. ABRIR CUENTA
async function accionAbrirCuenta() {
    if (!mesaSeleccionadaId) return;
    try {
        const res = await fetch(`${API_URL}/ordenes/abrir`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ mesa_id: mesaSeleccionadaId })
        });
        if (res.ok) {
            cerrarModal();
            refreshMesas(); // Recargar monitor
        } else alert('Error al abrir orden');
    } catch (e) { console.error(e); }
}

// 2. CERRAR CUENTA (COBRAR)
async function accionCerrarCuenta() {
    if (!ordenSeleccionadaId) return;
    if (!confirm("¿Confirmar cobro y cierre de orden?")) return;
    try {
        const res = await fetch(`${API_URL}/ordenes/cerrar/${ordenSeleccionadaId}`, { method: 'PUT' });
        if (res.ok) {
            cerrarModal();
            refreshMesas();
        } else alert('Error al cerrar');
    } catch (e) { console.error(e); }
}

// 3. CANCELAR CUENTA (BORRAR)
async function accionCancelarCuenta() {
    if (!ordenSeleccionadaId) return;
    if (!confirm("¿SEGURO? Esto eliminará la orden y sus pedidos de la base de datos.")) return;
    try {
        const res = await fetch(`${API_URL}/ordenes/cancelar/${ordenSeleccionadaId}`, { method: 'DELETE' });
        if (res.ok) {
            cerrarModal();
            refreshMesas();
        } else alert('Error al cancelar');
    } catch (e) { console.error(e); }
}

// ... (Variables y Navegación igual que antes) ...

let listaProductosCache = []; // Para no pedir el menú a cada rato

// --- CARGA DE DATOS ---
// ... (loadRestaurantes y loadSucursales igual que antes) ...

async function loadMesas(sucId, sucNombre) {
    currentSucursalId = sucId;
    document.getElementById('title-mesas').innerText = `Monitor: ${sucNombre}`;

    // AL ENTRAR A LA SUCURSAL, CARGAMOS SU MENÚ
    cargarMenuSucursal(sucId);

    refreshMesas();
    showSection('view-mesas');
}

// Nueva función para traer el menú
async function cargarMenuSucursal(sucId) {
    try {
        const res = await fetch(`${API_URL}/menu/${sucId}`);
        listaProductosCache = await res.json();
    } catch (e) { console.error("Error cargando menú", e); }
}

// ... (refreshMesas igual que antes) ...

// --- LÓGICA DEL MODAL CRUD ---
function abrirModalAcciones(mesaId, numMesa, cuentaId, isBusy) {
    mesaSeleccionadaId = mesaId;
    cuentaSeleccionadaId = cuentaId;

    document.getElementById('modal-titulo').innerText = `Mesa ${numMesa}`;
    document.getElementById('modal-overlay').classList.remove('hidden');

    if (isBusy) {
        document.getElementById('acciones-libre').classList.add('hidden');
        document.getElementById('acciones-ocupada').classList.remove('hidden');
        document.getElementById('modal-desc').innerText = `Cuenta activa #${cuentaId}`;

        // Llenar el Select de Productos
        llenarSelectProductos();
    } else {
        document.getElementById('acciones-ocupada').classList.add('hidden');
        document.getElementById('acciones-libre').classList.remove('hidden');
        document.getElementById('modal-desc').innerText = "La mesa está libre.";
        document.getElementById('inp-comensales').value = 2; // Reset valor
    }
}

function llenarSelectProductos() {
    const select = document.getElementById('sel-productos');
    select.innerHTML = '';

    if (listaProductosCache.length === 0) {
        const op = document.createElement('option');
        op.text = "No hay menú disponible";
        select.add(op);
        return;
    }

    // Ordenar por categoría visualmente (opcional)
    listaProductosCache.forEach(prod => {
        const option = document.createElement('option');
        option.value = prod.producto_id;
        // Guardamos el precio en un atributo data para usarlo al enviar
        option.setAttribute('data-precio', prod.precio_unitario);
        option.text = `${prod.nombre} - $${prod.precio_unitario}`;
        select.appendChild(option);
    });
}

// 1. ABRIR CUENTA (Con Comensales)
async function accionAbrirCuenta() {
    if (!mesaSeleccionadaId) return;
    const num = document.getElementById('inp-comensales').value;

    try {
        const res = await fetch(`${API_URL}/cuentas/abrir`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                mesa_id: mesaSeleccionadaId,
                num_comensales: parseInt(num)
            })
        });
        if (res.ok) {
            cerrarModal();
            refreshMesas();
        } else alert('Error al abrir cuenta');
    } catch (e) { console.error(e); }
}

// 2. AGREGAR PRODUCTO (NUEVO)
async function accionAgregarProducto() {
    if (!cuentaSeleccionadaId) return;

    const select = document.getElementById('sel-productos');
    const productoId = select.value;
    // Obtener precio del atributo data
    const precio = select.options[select.selectedIndex].getAttribute('data-precio');

    try {
        const res = await fetch(`${API_URL}/cuentas/pedido`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                cuenta_id: cuentaSeleccionadaId,
                producto_id: productoId,
                precio: precio
            })
        });
        if (res.ok) {
            alert("Producto añadido");
            // No cerramos el modal para permitir añadir más cosas rápido
            // Pero actualizamos el monitor de fondo para ver subir el total
            refreshMesas();
        } else alert('Error al agregar producto');
    } catch (e) { console.error(e); }
}

// ... (accionCerrarCuenta y accionCancelarCuenta IGUAL que antes) ...

loadRestaurantes();