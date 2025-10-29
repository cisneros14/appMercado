<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once("../config/db.php");
require_once("../config/conexion.php");

$method = $_SERVER['REQUEST_METHOD'];
$endpoint = isset($_GET['endpoint']) ? $_GET['endpoint'] : '';

// Obtener user_id de parámetros GET
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

if ($user_id <= 0) {
    http_response_code(401);
    echo json_encode(['error' => 'user_id requerido']);
    exit;
}

switch($endpoint) {
    case 'contactos':
        handleContactos($user_id, $con);
        break;
    case 'agentes':
        handleAgentes($user_id, $con);
        break;
    case 'invitaciones':
        handleInvitaciones($user_id, $con);
        break;
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint no encontrado']);
        break;
}

function handleContactos($user_id, $con) {
    // Mejorar la consulta para devolver solo contactos válidos usando JOIN.
    // Esto evita retornar elementos con user_id nulo cuando el usuario referido no existe.
    $sql = "SELECT u.user_id AS id,
                   CONCAT(u.firstname, ' ', u.lastname) AS nombre,
                   u.telefono_contacto AS telefono,
                   u.direccion AS ciudad,
                   u.user_email AS email,
                   COALESCE(u.img_url, 'img/default.jpg') AS imagen,
                   m.fecha AS fecha_conexion,
                   COALESCE(ROUND(AVG(c.puntuacion),1), 0) AS promedio,
                   COUNT(c.puntuacion) AS total_calif
            FROM mired m
            JOIN users u ON (
                (m.id_comprador = $user_id AND u.user_id = m.id_vendedor)
                OR
                (m.id_vendedor = $user_id AND u.user_id = m.id_comprador)
            )
            LEFT JOIN calificaciones c ON c.calificado_id = u.user_id
            WHERE m.estado = 1
            GROUP BY u.user_id, u.firstname, u.lastname, u.telefono_contacto, u.direccion, u.user_email, u.img_url, m.fecha
            ORDER BY m.fecha DESC";

    $result = mysqli_query($con, $sql);
    $contactos = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $contactos[] = [
            'id' => $row['id'],
            'nombre' => $row['nombre'],
            'telefono' => $row['telefono'],
            'ciudad' => $row['ciudad'],
            'email' => $row['email'],
            'imagen' => $row['imagen'],
            'fecha_conexion' => $row['fecha_conexion'],
            'calificacion' => [
                'promedio' => $row['promedio'],
                'total' => $row['total_calif']
            ]
        ];
    }

    echo json_encode(['success' => true, 'contactos' => $contactos]);
}

function handleAgentes($user_id, $con) {
    // Obtener IDs de contactos existentes
    $contactos = [];
    $sql_red = "SELECT * FROM mired WHERE (id_comprador = $user_id OR id_vendedor = $user_id) AND estado = 1";
    $query_red = mysqli_query($con, $sql_red);
    
    while ($red = mysqli_fetch_array($query_red)) {
        $contactos[] = ($red['id_comprador'] == $user_id) ? $red['id_vendedor'] : $red['id_comprador'];
    }
    
    $excluir_ids = array_merge([$user_id], $contactos);
    $excluir_string = implode(',', $excluir_ids);
    
    $busqueda = isset($_GET['busqueda']) ? mysqli_real_escape_string($con, $_GET['busqueda']) : '';
    $where = "WHERE user_id NOT IN ($excluir_string)";
    
    if (!empty($busqueda)) {
        $where .= " AND (firstname LIKE '%$busqueda%' OR lastname LIKE '%$busqueda%' OR direccion LIKE '%$busqueda%')";
    }
    
    $sql_agentes = "SELECT * FROM users $where ORDER BY firstname, lastname";
    $query_agentes = mysqli_query($con, $sql_agentes);
    
    $agentes = [];
    
    while ($agente = mysqli_fetch_array($query_agentes)) {
        $id_agente = $agente['user_id'];
        
        $sql_check = "SELECT estado FROM mired WHERE id_comprador = $user_id AND id_vendedor = $id_agente AND estado = 0";
        $res_check = mysqli_query($con, $sql_check);
        $ya_invitado = mysqli_num_rows($res_check) > 0;
        
        $sql_calif = "SELECT AVG(puntuacion) as promedio, COUNT(*) as total FROM calificaciones WHERE calificado_id = $id_agente";
        $res_calif = mysqli_query($con, $sql_calif);
        $calif = mysqli_fetch_array($res_calif);
        
        $agentes[] = [
            'id' => $agente['user_id'],
            'nombre' => $agente['firstname'] . ' ' . $agente['lastname'],
            'telefono' => $agente['telefono_contacto'],
            'ciudad' => $agente['direccion'],
            'email' => $agente['user_email'],
            'imagen' => !empty($agente['img_url']) ? $agente['img_url'] : 'img/default.jpg',
            'calificacion' => [
                'promedio' => round($calif['promedio'], 1),
                'total' => $calif['total']
            ],
            'ya_invitado' => $ya_invitado
        ];
    }
    
    echo json_encode(['success' => true, 'agentes' => $agentes]);
}

function handleInvitaciones($user_id, $con) {
    $sql_invitaciones = "SELECT mired.*, users.firstname, users.lastname, users.img_url, users.telefono_contacto 
                         FROM mired 
                         JOIN users ON mired.id_comprador = users.user_id 
                         WHERE mired.id_vendedor = $user_id AND mired.estado = 0";
    $query_invitaciones = mysqli_query($con, $sql_invitaciones);
    
    $invitaciones = [];
    
    while ($inv = mysqli_fetch_array($query_invitaciones)) {
        $invitaciones[] = [
            'id_mired' => $inv['id'],
            'id_remitente' => $inv['id_comprador'],
            'nombre' => $inv['firstname'] . ' ' . $inv['lastname'],
            'telefono' => $inv['telefono_contacto'],
            'imagen' => !empty($inv['img_url']) ? $inv['img_url'] : 'img/default.jpg',
            'fecha_invitacion' => $inv['fecha']
        ];
    }
    
    echo json_encode(['success' => true, 'invitaciones' => $invitaciones]);
}
?>