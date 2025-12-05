const API_URL = 'http://localhost:3000/api';
let currentSucursalId = null;
let listaEmpleados = []; // Cache de meseros
let listaProductos = []; // Cache de menú

// --- NAVEGACIÓN ---
function showSection(id) {
    ['view-restaurantes', 'view-sucursales', 'view-mesas'].forEach(v => document.getElementById(v).classList.add('hidden'));
    document.getElementById(id).classList.remove('hidden');
    document.getElementById('btn-volver').classList.toggle('hidden', id === 'view-restaurantes');
}

function goBack() {
    if (!document.getElementById('view-mesas').classList.contains('hidden')) showSection('view-sucursales');
    else showSection('view-restaurantes');
}

// --- CARGA INICIAL ---
async function loadRestaurantes() {
    const res = await fetch(`${API_URL}/restaurantes`);
    const data = await res.json();
    const div = document.getElementById('list-restaurantes');
    div.innerHTML = data.map(r => 
        `<div class="card" onclick="loadSucursales(${r.restaurante_id}, '${r.nombre}')">
            <h3>${r.nombre}</h3><p>${r.rfc || ''}</p>
         </div>`
    ).join('');
    showSection('view-restaurantes');
}

async function loadSucursales(restId, nombre) {
    const res = await fetch(`${API_URL}/sucursales/${restId}`);
    const data = await res.json();
    document.getElementById('title-sucursales').innerText = `Sucursales: ${nombre}`;
    const div = document.getElementById('list-sucursales');
    div.innerHTML = data.map(s => 
        `<div class="card" onclick="enterSucursal(${s.sucursal_id}, '${s.nombre}')">
            <h3>${s.nombre}</h3><p>${s.region}</p>
         </div>`
    ).join('');
    showSection('view-sucursales');
}

// --- ENTRADA A SUCURSAL (CARGA DE DATOS) ---
async function enterSucursal(sucId, nombre) {
    currentSucursalId = sucId;
    document.getElementById('title-mesas').innerText = `Monitor: ${nombre}`;
    
    // Cargar Catálogos en paralelo
    await Promise.all([cargarEmpleados(sucId), cargarMenu(sucId)]);
    
    refreshMesas();
    showSection('view-mesas');
}

async function cargarEmpleados(id) {
    const res = await fetch(`${API_URL}/empleados/${id}`);
    listaEmpleados = await res.json();
}

async function cargarMenu(id) {
    const res = await fetch(`${API_URL}/menu/${id}`);
    listaProductos = await res.json();
}

// --- MONITOR ---
async function refreshMesas() {
    const res = await fetch(`${API_URL}/mesas/${currentSucursalId}`);
    const data = await res.json();
    const div = document.getElementById('grid-mesas');
    
    if (data.length === 0) { div.innerHTML = '<p>No hay mesas configuradas.</p>'; return; }

    div.innerHTML = data.map(m => {
        const isBusy = m.estado_mesa === 'ocupada';
        const cssClass = isBusy ? 'mesa-ocupada' : 'mesa-libre';
        const total = isBusy ? `$${parseFloat(m.gran_total).toFixed(2)}` : 'Libre';
        // Mostramos el nombre del mesero si está ocupada
        const infoExtra = isBusy ? `<small>👤 ${m.mesero || '?'}</small><br><small>🕒 ${m.hora}</small>` : `<small>${m.area}</small>`;

        return `
        <div class="mesa-card ${cssClass}" onclick="abrirModal(${m.mesa_id}, ${m.num_mesa}, ${m.orden_id}, '${m.estado_mesa}', '${m.mesero}')">
            <span class="mesa-num">${m.num_mesa}</span>
            <div class="mesa-info">${infoExtra}</div>
            <span class="mesa-total">${total}</span>
        </div>`;
    }).join('');
}

// --- MODAL ---
let selectedMesa = null;
let selectedOrden = null;

function abrirModal(mesaId, num, ordenId, estado, meseroNombre) {
    selectedMesa = mesaId;
    selectedOrden = ordenId;
    document.getElementById('modal-titulo').innerText = `Mesa ${num}`;
    document.getElementById('modal-overlay').classList.remove('hidden');

    if (estado === 'libre') {
        document.getElementById('acciones-libre').classList.remove('hidden');
        document.getElementById('acciones-ocupada').classList.add('hidden');
        
        // Llenar combo de meseros (Filtrando preferentemente Meseros)
        const sel = document.getElementById('sel-mesero');
        sel.innerHTML = listaEmpleados.map(e => 
            `<option value="${e.empleado_id}">
                ${e.nombre} ${e.apellido} (${e.rol})
             </option>`
        ).join('');
        
    } else {
        document.getElementById('acciones-libre').classList.add('hidden');
        document.getElementById('acciones-ocupada').classList.remove('hidden');
        document.getElementById('info-orden').innerText = `Orden #${ordenId} - Atiende: ${meseroNombre}`;
        
        // Llenar combo productos
        const sel = document.getElementById('sel-productos');
        sel.innerHTML = listaProductos.map(p => 
            `<option value="${p.producto_id}" data-precio="${p.precio_unitario}">
                ${p.nombre} - $${p.precio_unitario}
             </option>`
        ).join('');
    }
}

function cerrarModal() { document.getElementById('modal-overlay').classList.add('hidden'); }

// --- ACCIONES ---
async function accionAbrirCuenta() {
    const empId = document.getElementById('sel-mesero').value;
    const personas = document.getElementById('inp-comensales').value;

    if(!empId) return alert("Debes seleccionar un mesero");

    const res = await fetch(`${API_URL}/ordenes/abrir`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ mesa_id: selectedMesa, num_comensales: personas, empleado_id: empId })
    });
    
    if(res.ok) { cerrarModal(); refreshMesas(); }
    else alert("Error al abrir");
}

async function accionAgregarProducto() {
    const sel = document.getElementById('sel-productos');
    const prodId = sel.value;
    const precio = sel.options[sel.selectedIndex].getAttribute('data-precio');

    const res = await fetch(`${API_URL}/ordenes/pedido`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ orden_id: selectedOrden, producto_id: prodId, precio: precio })
    });

    if(res.ok) { alert("Agregado!"); refreshMesas(); }
}

async function accionCerrarCuenta() {
    if(confirm("¿Cobrar y cerrar mesa?")) {
        await fetch(`${API_URL}/ordenes/cerrar/${selectedOrden}`, { method: 'PUT' });
        cerrarModal(); refreshMesas();
    }
}

async function accionCancelarCuenta() {
    if(confirm("¿Eliminar orden completa?")) {
        await fetch(`${API_URL}/ordenes/cancelar/${selectedOrden}`, { method: 'DELETE' });
        cerrarModal(); refreshMesas();
    }
}

loadRestaurantes();