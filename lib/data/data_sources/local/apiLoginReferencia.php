<!-- ubicacion De Esta Api: "https://mercadoinmobiliario.ec/admin/apis/login.php"; -->

<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *"); 
header("Access-Control-Allow-Methods: POST"); 
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

error_reporting(E_ALL);
ini_set('display_errors', 1);

// 🔹 Conexión a la base de datos
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../config/funciones.php';

// Verificar método POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["status" => "error", "message" => "Método no permitido"]);
    exit;
}

// Validar parámetros
if (empty($_POST['user_name']) || empty($_POST['user_password'])) {
    echo json_encode(["status" => "error", "message" => "Faltan parámetros"]);
    exit;
}

$user_name = $con->real_escape_string($_POST['user_name']);
$user_password = $_POST['user_password'];

// Consultar usuario
$sql = "SELECT user_id, firstname, lastname, user_name, user_email, user_password_hash, rol
        FROM users
        WHERE user_name = '$user_name' OR user_email = '$user_name'
        LIMIT 1";

$result = $con->query($sql);

if (!$result) {
    echo json_encode(["status" => "error", "message" => "Error en la consulta: " . $con->error]);
    exit;
}

if ($result->num_rows === 0) {
    echo json_encode(["status" => "error", "message" => "Usuario no encontrado"]);
    exit;
}

$row = $result->fetch_assoc();

// Validar contraseña
if (!password_verify($user_password, $row['user_password_hash'])) {
    echo json_encode(["status" => "error", "message" => "Usuario o contraseña incorrectos"]);
    exit;
}

// Generar token de sesión
$token = base64_encode(uniqid() . time());



// Respuesta exitosa
echo json_encode([
    "status"  => "success",
    "message" => "Login correcto",
    "token"   => $token,
    "user"    => [
        "user_id"    => $row['user_id'],
        "user_name"  => $row['user_name'],
        "firstname"  => $row['firstname'],
        "lastname"   => $row['lastname'],
        "user_email" => $row['user_email'],
        "rol"        => $row['rol']
    ]
]);

