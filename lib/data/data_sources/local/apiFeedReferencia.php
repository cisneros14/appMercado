<!-- ubicacion De Esta Api: "https://mercadoinmobiliario.ec/admin/apis/login.php"; -->


<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *"); 
header("Access-Control-Allow-Methods: POST"); 
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../config/funciones.php';

// Parámetros de paginación (opcional)
$offset = intval($_POST['offset'] ?? 0);
$limit  = intval($_POST['limit'] ?? 10);

// Consultar feed
$sql = "
    SELECT f.fecha_hora, f.notificacion, v.id_vivienda, v.modelo, v.precio, v.area, v.img_principal, v.ciudad,
           u.firstname, u.lastname, u.img_url AS user_img
    FROM feed f
    INNER JOIN vivienda v ON v.id_vivienda = f.id_propiedad
    INNER JOIN users u ON v.id_corredor = u.user_id
    ORDER BY f.fecha_hora DESC
    LIMIT $offset, $limit
";

$result = $con->query($sql);

if (!$result) {
    echo json_encode([
        "status" => "error",
        "message" => "Error en la consulta: " . $con->error
    ]);
    exit;
}

$feed = [];

while ($row = $result->fetch_assoc()) {
    $ciudad = get_row("localidad","concat(provincia,' - ',canton)","codigo_parroquia",$row["ciudad"]);
    $localidad = get_row("localidad","parroquia","codigo_parroquia",$row["ciudad"]);

    $feed[] = [
        "fecha_hora"    => $row["fecha_hora"],
        "notificacion"  => $row["notificacion"],
        "id_vivienda"   => $row["id_vivienda"],
        "modelo"        => $row["modelo"],
        "precio"        => $row["precio"],
        "area"          => $row["area"],
        "img_principal" => $row["img_principal"],
        "ciudad"        => $ciudad,
        "localidad"     => $localidad,
        "user" => [
            "firstname" => $row["firstname"],
            "lastname"  => $row["lastname"],
            "img_url"   => $row["user_img"] ?: "img/default-avatar.png"
        ]
    ];
}

// Respuesta JSON
echo json_encode([
    "status" => "success",
    "data"   => $feed,
    "offset" => $offset,
    "limit"  => $limit
]);
