<?php
// ubicacion: https://mercadoinmobiliario.ec/admin/apis/propiedades.php
// api_propiedades.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Manejar preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

session_start();
require_once("../config/db.php");
require_once("../config/conexion.php");
include("../config/funciones.php");
require_once("../../includes/image_helpers.php");

// Para pruebas, simular usuario logeado si no existe
if (!isset($_SESSION['user_id'])) {
    $_SESSION['user_id'] = 1; // ID de prueba
}

function sendResponse($success, $message = '', $data = null, $statusCode = 200) {
    http_response_code($statusCode);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ]);
    exit;
}

// Función para debug - REMOVER EN PRODUCCIÓN
function logError($message) {
    file_put_contents('api_errors.log', date('Y-m-d H:i:s') . ' - ' . $message . PHP_EOL, FILE_APPEND);
}

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch($method) {
        case 'GET':
            handleGetRequest();
            break;
        case 'POST':
            handlePostRequest();
            break;
        default:
            sendResponse(false, 'Método no permitido', null, 405);
    }
} catch (Exception $e) {
    logError('Exception: ' . $e->getMessage());
    sendResponse(false, 'Error interno del servidor: ' . $e->getMessage(), null, 500);
}

function handleGetRequest() {
    global $con;
    
    $params = $_GET;
    $action = $params['action'] ?? '';
    
    if ($action === 'listar') {
        listarPropiedades($params);
    } elseif ($action === 'tipos') {
        listarTiposInmueble();
    } elseif (isset($params['id'])) {
        obtenerPropiedad($params['id']);
    } else {
        sendResponse(false, 'Parámetros insuficientes', null, 400);
    }
}


function handlePostRequest() {
    $input = json_decode(file_get_contents('php://input'), true);
    $action = $input['action'] ?? '';
    
    if ($action === 'eliminar' && isset($input['id'])) {
        eliminarPropiedad($input['id']);
    } else {
        sendResponse(false, 'Acción no válida', null, 400);
    }
}

function listarPropiedades($filters) {
    global $con;
    
    $corredor = intval($_SESSION['user_id']);
    
    // ¿Listar solo las propiedades del corredor logueado?
    $mine = false;
    if (isset($filters['mine'])) {
        $m = $filters['mine'];
        if ($m === true || $m === 1 || $m === '1' || $m === 'true') $mine = true;
    }

    // Construir WHERE clause de forma segura
    $whereConditions = ["estado = 0"]; // Cambié a 0 para mostrar propiedades activas
    if ($mine) {
        $whereConditions[] = "id_corredor = $corredor";
    } else {
        $whereConditions[] = "id_corredor <> $corredor";
    }
    
    // Aplicar filtros de forma segura
    if (!empty($filters['q'])) {
        $q = mysqli_real_escape_string($con, $filters['q']);
        $whereConditions[] = "(modelo LIKE '%$q%' OR direccion LIKE '%$q%')";
    }
    
    if (!empty($filters['tipo']) && is_numeric($filters['tipo'])) {
        $tipo = intval($filters['tipo']);
        $whereConditions[] = "tipo = $tipo";
    }
    
    if (!empty($filters['operacion']) && is_numeric($filters['operacion'])) {
        $operacion = intval($filters['operacion']);
        if ($operacion == 1) {
            $whereConditions[] = "venta_alquiler = 1";
        } else {
            $whereConditions[] = "venta_alquiler <> 1";
        }
    }
    
    if (!empty($filters['provincia']) && is_numeric($filters['provincia'])) {
        $provincia = intval($filters['provincia']);
        $whereConditions[] = "provincia = $provincia";
    }
    
    if (!empty($filters['canton']) && is_numeric($filters['canton'])) {
        $canton = intval($filters['canton']);
        $whereConditions[] = "canton = $canton";
    }
    
    if (!empty($filters['ciudad']) && is_numeric($filters['ciudad'])) {
        $ciudad = intval($filters['ciudad']);
        $whereConditions[] = "ciudad = $ciudad";
    }
    
    if (!empty($filters['precio_desde']) && is_numeric($filters['precio_desde'])) {
        $desde = floatval($filters['precio_desde']);
        $whereConditions[] = "precio >= $desde";
    }
    
    if (!empty($filters['precio_hasta']) && is_numeric($filters['precio_hasta'])) {
        $hasta = floatval($filters['precio_hasta']);
        $whereConditions[] = "precio <= $hasta";
    }
    
    // Construir la cláusula WHERE completa
    $sWhere = "WHERE " . implode(" AND ", $whereConditions);
    
    // Paginación
    $page = max(1, intval($filters['page'] ?? 1));
    $per_page = intval($filters['per_page'] ?? 10);
    $offset = ($page - 1) * $per_page;
    
    // DEBUG: Log la consulta (remover en producción)
    $debug_sql = "SELECT COUNT(*) as total FROM vivienda $sWhere";
    logError("Count SQL: " . $debug_sql);
    
    // Contar total
    $count_query = mysqli_query($con, "SELECT COUNT(*) as total FROM vivienda $sWhere");
    if (!$count_query) {
        logError("Count query error: " . mysqli_error($con));
        sendResponse(false, 'Error en la consulta count: ' . mysqli_error($con));
    }
    
    $total_row = mysqli_fetch_assoc($count_query);
    $total = $total_row['total'];
    $total_pages = ceil($total / $per_page);
    
    // Consulta principal
    $sql = "SELECT * FROM vivienda $sWhere ORDER BY id_vivienda DESC LIMIT $offset, $per_page";
    logError("Main SQL: " . $sql);
    
    $result = mysqli_query($con, $sql);
    
    if (!$result) {
        logError("Main query error: " . mysqli_error($con));
        sendResponse(false, 'Error en la consulta principal: ' . mysqli_error($con));
    }
    
    $propiedades = [];
    
    while ($row = mysqli_fetch_assoc($result)) {
        $propiedad = procesarPropiedad($row);
        if ($propiedad) {
            $propiedades[] = $propiedad;
        }
    }
    
    $response = [
        'propiedades' => $propiedades,
        'paginacion' => [
            'pagina_actual' => $page,
            'total_paginas' => $total_pages,
            'total_propiedades' => $total,
            'por_pagina' => $per_page
        ]
    ];
    
    sendResponse(true, 'Propiedades obtenidas correctamente', $response);
}

function obtenerPropiedad($id) {
    global $con;
    
    $id = intval($id);
    $sql = "SELECT * FROM vivienda WHERE id_vivienda = $id AND estado = 0";
    
    $result = mysqli_query($con, $sql);
    
    if (!$result) {
        sendResponse(false, 'Error en la consulta: ' . mysqli_error($con));
    }
    
    if (mysqli_num_rows($result) === 0) {
        sendResponse(false, 'Propiedad no encontrada', null, 404);
    }
    
    $row = mysqli_fetch_assoc($result);
    $propiedad = procesarPropiedad($row);
    
    sendResponse(true, 'Propiedad obtenida correctamente', $propiedad);
}

function eliminarPropiedad($id) {
    global $con;
    
    $id = intval($id);
    
    // Verificar si existe
    $check_sql = "SELECT id_vivienda FROM vivienda WHERE id_vivienda = $id";
    $check_result = mysqli_query($con, $check_sql);
    
    if (!$check_result || mysqli_num_rows($check_result) === 0) {
        sendResponse(false, 'La propiedad no existe', null, 404);
    }
    
    // Actualizar estado (eliminación lógica) - Cambié a estado 1 para eliminar
    $update_sql = "UPDATE vivienda SET estado = 1 WHERE id_vivienda = $id";
    
    if (mysqli_query($con, $update_sql)) {
        sendResponse(true, 'Propiedad eliminada correctamente');
    } else {
        sendResponse(false, 'Error al eliminar la propiedad: ' . mysqli_error($con));
    }
}

function procesarPropiedad($row) {
    if (!$row) return null;
    
    try {
        $id_vivienda = $row['id_vivienda'];
        
        // Obtener nombres de ubicación con manejo de errores
        $provincia_nombre = get_row('localidad', 'provincia', 'codigo_parroquia', $row['ciudad']) ?? 'Desconocido';
        $canton_nombre = get_row('localidad', 'canton', 'codigo_parroquia', $row['ciudad']) ?? 'Desconocido';
        $sector_nombre = get_row('localidad', 'parroquia', 'codigo_parroquia', $row['ciudad']) ?? 'Desconocido';
        
        // Información del corredor
        $id_corredor = $row['id_corredor'];
        $url_img = get_row('users', 'img_url', 'user_id', $id_corredor) ?? '';
        $nombre_corredor = get_row('users', 'CONCAT(firstname, " ", lastname)', 'user_id', $id_corredor) ?? 'Corredor Desconocido';
        
        // Tipo de propiedad
        $tipo_nombre = get_row('tipo_inmueble', 'tipo', 'id_tipo', $row['tipo']) ?? 'Desconocido';
        
        // Operación
        $operacion = $row['venta_alquiler'];
        $operacion_nombre = ($operacion == 1) ? 'Venta' : 'Alquiler';
        $badge_class = ($operacion == 1) ? 'success' : 'danger';
        
        return [
            'id' => $id_vivienda,
            'modelo' => $row['modelo'] ?? '',
            'direccion' => $row['direccion'] ?? '',
            'imagen_principal' => getPropertyImageUrl($row['img_principal'] ?? ''),
            'imagen_placeholder' => '../../images/front/placeholder.webp',
            'precio' => floatval($row['precio'] ?? 0),
            'moneda' => get_row('perfil', 'moneda', 'id_perfil', 1) ?? '$',
            'habitaciones' => intval($row['cuartos'] ?? 0),
            'banios' => intval($row['banios'] ?? 0),
            'area' => floatval($row['area'] ?? 0),
            'tipo' => [
                'id' => $row['tipo'] ?? 0,
                'nombre' => $tipo_nombre
            ],
            'operacion' => [
                'id' => $operacion,
                'nombre' => $operacion_nombre,
                'badge_class' => $badge_class
            ],
            'ubicacion' => [
                'provincia' => [
                    'id' => $row['provincia'] ?? 0,
                    'nombre' => $provincia_nombre
                ],
                'canton' => [
                    'id' => $row['canton'] ?? 0,
                    'nombre' => $canton_nombre
                ],
                'sector' => [
                    'id' => $row['ciudad'] ?? 0,
                    'nombre' => $sector_nombre
                ],
                'completa' => "$sector_nombre, $canton_nombre, $provincia_nombre"
            ],
            'corredor' => [
                'id' => $id_corredor,
                'nombre' => $nombre_corredor,
                'imagen' => getUserImageUrl($url_img),
                'imagen_placeholder' => '../../admin/img/default.jpg'
            ],
            'url_detalle' => "../../propiedad_ref.php?id=$id_vivienda&id_cor=" . $_SESSION['user_id']
        ];
    } catch (Exception $e) {
        logError('Error procesando propiedad: ' . $e->getMessage());
        return null;
    }
}



function listarTiposInmueble() {
    global $con;

    $sql = "SELECT id_tipo, tipo, img_tipo, id_tokko FROM tipo_inmueble ORDER BY tipo ASC";
    $result = mysqli_query($con, $sql);

    if (!$result) {
        sendResponse(false, 'Error en la consulta de tipos: ' . mysqli_error($con));
    }

    $tipos = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $tipos[] = [
            'id' => intval($row['id_tipo']),
            'nombre' => $row['tipo'],
            'imagen' => $row['img_tipo'],
            'id_tokko' => intval($row['id_tokko'])
        ];
    }

    sendResponse(true, 'Tipos de inmueble obtenidos correctamente', $tipos);
}

?>