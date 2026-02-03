<?php
/**
 * API Registro APP - Completa
 * Ubicación: admin/apis/api_registro_app.php
 * Descripción: API para el registro de usuarios desde la App móvil/externa.
 *              Replica la lógica de admin/registro.php
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Incluir configuraciones y conexión DB
// Ajuste de rutas considerando que estamos en admin/apis/
require_once("../config/db.php");
require_once("../config/conexion.php");

// ==========================================
// CLASE PARA GESTIÓN DE PROVINCIAS
// Copiada de registro.php para mantener consistencia
// ==========================================
class ProvinciasEcuador {
    private $provincias;
    
    public function __construct() {
        $this->provincias = [
            'Azuay' => [
                'Cuenca', 'Girón', 'Gualaceo', 'Nabón', 'Paute', 'Pucará', 
                'San Fernando', 'Santa Isabel', 'Sigsig', 'Oña', 'Chordeleg', 
                'El Pan', 'Sevilla de Oro', 'Guachapala', 'Camilo Ponce Enríquez'
            ],
            'Bolívar' => [
                'Guaranda', 'Chillanes', 'Chimbo', 'Echeandía', 'San Miguel', 
                'Caluma', 'Las Naves'
            ],
            'Cañar' => [
                'Azogues', 'Biblián', 'Cañar', 'La Troncal', 'El Tambo', 
                'Déleg', 'Suscal'
            ],
            'Carchi' => [
                'Tulcán', 'Bolívar', 'Espejo', 'Mira', 'Montúfar', 'San Pedro de Huaca'
            ],
            'Chimborazo' => [
                'Riobamba', 'Alausí', 'Colta', 'Chambo', 'Chunchi', 'Guamote', 
                'Guano', 'Pallatanga', 'Penipe', 'Cumandá'
            ],
            'Cotopaxi' => [
                'Latacunga', 'La Maná', 'Pangua', 'Pujilí', 'Salcedo', 
                'Saquisilí', 'Sigchos'
            ],
            'El Oro' => [
                'Machala', 'Arenillas', 'Atahualpa', 'Balsas', 'Chilla', 
                'El Guabo', 'Huaquillas', 'Marcabelí', 'Pasaje', 'Piñas', 
                'Portovelo', 'Santa Rosa', 'Zaruma', 'Las Lajas'
            ],
            'Esmeraldas' => [
                'Esmeraldas', 'Eloy Alfaro', 'Muisne', 'Quinindé', 'San Lorenzo', 
                'Atacames', 'Ríoverde', 'La Concordia'
            ],
            'Galápagos' => [
                'Puerto Baquerizo Moreno', 'Puerto Ayora', 'Puerto Villamil'
            ],
            'Guayas' => [
                'Guayaquil', 'Alfredo Baquerizo Moreno', 'Balao', 'Balzar', 
                'Colimes', 'Coronel Marcelino Maridueña', 'Daule', 'Durán', 
                'El Empalme', 'El Triunfo', 'Milagro', 'Naranjal', 'Naranjito', 
                'Palestina', 'Pedro Carbo', 'Playas', 'Salitre', 'Samborondón', 
                'Santa Lucía', 'Simón Bolívar', 'Yaguachi'
            ],
            'Imbabura' => [
                'Ibarra', 'Antonio Ante', 'Cotacachi', 'Otavalo', 'Pimampiro', 
                'San Miguel de Urcuquí'
            ],
            'Loja' => [
                'Loja', 'Calvas', 'Catamayo', 'Celica', 'Chaguarpamba', 
                'Espíndola', 'Gonzanamá', 'Macará', 'Paltas', 'Puyango', 
                'Saraguro', 'Sozoranga', 'Zapotillo', 'Pindal', 'Quilanga', 
                'Olmedo'
            ],
            'Los Ríos' => [
                'Babahoyo', 'Baba', 'Montalvo', 'Puebloviejo', 'Quevedo', 
                'Urdaneta', 'Ventanas', 'Vínces', 'Palenque', 'Buena Fé', 
                'Valencia', 'Mocache', 'Quinsaloma'
            ],
            'Manabí' => [
                'Portoviejo', 'Bolívar', 'Chone', 'El Carmen', 'Flavio Alfaro', 
                'Jipijapa', 'Junín', 'Manta', 'Montecristi', 'Paján', 
                'Pichincha', 'Rocafuerte', 'Santa Ana', 'Sucre', 'Tosagua', 
                '24 de Mayo', 'Pedernales', 'Olmedo', 'Puerto López', 
                'Jama', 'Jaramijó', 'San Vicente'
            ],
            'Morona Santiago' => [
                'Macas', 'Gualaquiza', 'Limón Indanza', 'Palora', 'Santiago', 
                'Sucúa', 'Huamboya', 'San Juan Bosco', 'Taisha', 'Logroño', 
                'Pablo Sexto', 'Tiwintza'
            ],
            'Napo' => [
                'Tena', 'Archidona', 'El Chaco', 'Quijos', 'Carlos Julio Arosemena Tola'
            ],
            'Orellana' => [
                'Puerto Francisco de Orellana', 'Aguarico', 'La Joya de los Sachas', 
                'Loreto'
            ],
            'Pastaza' => [
                'Puyo', 'Mera', 'Santa Clara', 'Arajuno'
            ],
            'Pichincha' => [
                'Quito', 'Cayambe', 'Mejía', 'Pedro Moncayo', 'Rumiñahui', 
                'San Miguel de los Bancos', 'Pedro Vicente Maldonado', 'Puerto Quito'
            ],
            'Santa Elena' => [
                'Santa Elena', 'La Libertad', 'Salinas'
            ],
            'Santo Domingo de los Tsáchilas' => [
                'Santo Domingo', 'La Concordia'
            ],
            'Sucumbíos' => [
                'Nueva Loja', 'Cascales', 'Cuyabeno', 'Gonzalo Pizarro', 
                'Putumayo', 'Shushufindi', 'Lago Agrio'
            ],
            'Tungurahua' => [
                'Ambato', 'Baños de Agua Santa', 'Cevallos', 'Mocha', 'Patate', 
                'Quero', 'Pelileo', 'Píllaro', 'Tisaleo'
            ],
            'Zamora Chinchipe' => [
                'Zamora', 'Chinchipe', 'Nangaritza', 'Yacuambi', 'Yantzaza', 
                'El Pangui', 'Centinela del Cóndor', 'Palanda', 'Paquisha'
            ]
        ];
    }
    
    public function obtenerProvincias() {
        return array_keys($this->provincias);
    }
    
    public function obtenerCiudades($provincia) {
        return isset($this->provincias[$provincia]) ? $this->provincias[$provincia] : [];
    }
    
    public function obtenerTodo() {
        return $this->provincias;
    }
    
    public function existeProvincia($provincia) {
        return isset($this->provincias[$provincia]);
    }
}

// Helper para respuestas JSON estándar
function jsonResponse($success, $message, $data = null, $errors = [], $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data,
        'errors' => $errors
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

// Instanciar lógica de provincias
$provObj = new ProvinciasEcuador();

// Enrutamiento de acciones
$action = $_GET['action'] ?? '';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if ($action === 'provincias') {
        // Retorna toda la estructura de provincias y ciudades
        jsonResponse(true, 'Catálogo de provincias y ciudades', $provObj->obtenerTodo());
    } else {
        jsonResponse(false, 'Acción GET no válida. Use ?action=provincias', null, [], 400);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($action === 'registrar') {
        procesarRegistro($con, $provObj);
    } else {
        jsonResponse(false, 'Acción POST no válida. Use ?action=registrar', null, [], 400);
    }
} else {
    jsonResponse(false, 'Método no permitido', null, [], 405);
}

// ==========================================
// FUNCIÓN PRINCIPAL DE REGISTRO
// ==========================================
function procesarRegistro($con, $provObj) {
    $errores = [];

    // 1. Recoger datos
    // Nota: Para multipart/form-data, $_POST se llena automáticamente.
    // Si se enviara JSON raw (sin archivos), habría que usar php://input, 
    // pero como se requiere archivo, asumimos Form Data.
    
    $nombres = trim($_POST['nombres'] ?? '');
    $apellidos = trim($_POST['apellidos'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $celular = trim($_POST['celular'] ?? '');
    $matricula_inmobiliaria = trim($_POST['matricula_inmobiliaria'] ?? '');
    $user_password = $_POST['user_password'] ?? '';
    // Corregir posible campo 'password' vs 'user_password' si la app usa otro nombre
    // pero mantendremos 'user_password' por consistencia con registro.php
    
    $provincia = trim($_POST['provincia'] ?? '');
    $ciudad = trim($_POST['ciudad'] ?? '');
    $acepto_privacidad = $_POST['acepto_privacidad'] ?? '';

    // 2. Validaciones (Replicando registro.php)
    
    // Nombres
    if (empty($nombres) || !preg_match("/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{2,50}$/", $nombres)) {
        $errores[] = "Los nombres deben contener solo letras y tener entre 2 y 50 caracteres.";
    }
    
    // Apellidos
    if (empty($apellidos) || !preg_match("/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{2,50}$/", $apellidos)) {
        $errores[] = "Los apellidos deben contener solo letras y tener entre 2 y 50 caracteres.";
    }
    
    // Email
    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errores[] = "El correo electrónico no es válido.";
    }
    
    // Celular
    if (empty($celular) || !preg_match("/^09[0-9]{8}$/", $celular)) {
        $errores[] = "El celular debe tener formato 09XXXXXXXX (10 dígitos).";
    }
    
    // Matrícula
    if (empty($matricula_inmobiliaria) || !preg_match("/^[A-Z0-9]{6,20}$/", strtoupper($matricula_inmobiliaria))) {
        $errores[] = "La matrícula inmobiliaria debe contener entre 6 y 20 caracteres alfanuméricos.";
    }

    // Provincia y Ciudad
    if (empty($provincia) || strlen($provincia) > 100) {
        $errores[] = "La provincia es obligatoria y debe tener máximo 100 caracteres.";
    }
    if (empty($ciudad) || strlen($ciudad) > 100) {
        $errores[] = "La ciudad es obligatoria y debe tener máximo 100 caracteres.";
    }

    // Validar existencia de provincia en nuestro catálogo (opcional, pero recomendado)
    if (!empty($provincia) && !$provObj->existeProvincia($provincia)) {
        $errores[] = "La provincia seleccionada no es válida.";
    }
    
    // Contraseña
    if (empty($user_password) || strlen($user_password) < 2) {
        $errores[] = "La contraseña debe tener al menos 2 caracteres.";
    }
    
    // Políticas
    // Aceptamos 'on', 'true', '1'
    if ($acepto_privacidad !== 'on' && $acepto_privacidad !== 'true' && $acepto_privacidad !== '1') {
        $errores[] = "Debe aceptar las políticas de privacidad.";
    }

    // Archivo
    if (!isset($_FILES['documento']) || $_FILES['documento']['error'] !== UPLOAD_ERR_OK) {
        // Manejo detallado de error de archivo
        $msg = "El documento es obligatorio.";
        if (isset($_FILES['documento'])) {
            $errCode = $_FILES['documento']['error'];
            if ($errCode !== UPLOAD_ERR_NO_FILE) {
                // Mapear códigos de error comunes
                switch ($errCode) {
                    case UPLOAD_ERR_INI_SIZE: $msg .= " Excede upload_max_filesize."; break;
                    case UPLOAD_ERR_FORM_SIZE: $msg .= " Excede MAX_FILE_SIZE."; break;
                    case UPLOAD_ERR_PARTIAL: $msg .= " Subida parcial."; break;
                    default: $msg .= " Código de error: $errCode.";
                }
            }
        }
        $errores[] = $msg;
    }

    // Retorno temprano si hay errores básicos
    if (!empty($errores)) {
        jsonResponse(false, 'Errores de validación', null, $errores, 422);
    }

    // 3. Procesamiento de Archivo
    $upload_dir = __DIR__ . '/../images/docs/'; // Subir un nivel desde admin/apis/ a admin/images/docs/
    $ruta_doc = null;
    $allowed_types = ['pdf', 'jpg', 'jpeg', 'png', 'gif'];
    $file_extension = strtolower(pathinfo($_FILES['documento']['name'], PATHINFO_EXTENSION));

    if (!is_dir($upload_dir)) {
        if (!mkdir($upload_dir, 0777, true)) {
            jsonResponse(false, 'Error interno: No se pudo crear directorio de subida', null, [], 500);
        }
    }
    if (is_dir($upload_dir) && !is_writable($upload_dir)) {
        chmod($upload_dir, 0777); 
    }

    if (!in_array($file_extension, $allowed_types)) {
        jsonResponse(false, 'Tipo de archivo no permitido. Use PDF o imágenes.', null, [], 422);
    }

    $new_filename = 'doc_' . time() . '_' . uniqid() . '.' . $file_extension;
    $upload_path = $upload_dir . $new_filename;

    if (!move_uploaded_file($_FILES['documento']['tmp_name'], $upload_path)) {
        $err = error_get_last();
        jsonResponse(false, 'Error al mover el archivo subido al servidor.', null, [$err['message'] ?? 'Error desconocido'], 500);
    }

    // Ruta relativa para BD (la misma que usa registro.php)
    $ruta_doc = 'images/docs/' . $new_filename;

    // 4. Inserción en Base de Datos
    $matricula_inmobiliaria = strtoupper($matricula_inmobiliaria);
    $password_hash = password_hash($user_password, PASSWORD_DEFAULT);
    $date_added = date("Y-m-d H:i:s");
    $rol = 2;
    $estado = 0; // Pendiente

    // Campos por defecto
    $telefono_contacto2 = '';
    $empresa = '';
    $img_url = '';
    $pagina_web = '';
    $directiva = 0;
    $cargo = '';
    $facebook = '';
    $instagram = '';
    $cedula_ruc = '';
    $linkedin = '';
    $direccion = '';

    // Query (idéntico a registro.php)
    $query = "INSERT INTO users (firstname, lastname, user_email, telefono_contacto, telefono_contacto2, user_name, user_password_hash, rol, date_added, licencia, empresa, img_url, estado, pagina_web, directiva, cargo, facebook, instagram, cedula_ruc, linkedin, direccion, provincia, ciudad, ruta_doc)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $con->prepare($query);
    if (!$stmt) {
        jsonResponse(false, 'Error de base de datos (Prepare)', null, [$con->error], 500);
    }

    // El sistema usa email como user_name
    $user_name = $email;

    $stmt->bind_param("ssssssssssssssssssssssss", 
        $nombres, 
        $apellidos, 
        $email, 
        $celular, 
        $telefono_contacto2, 
        $user_name, 
        $password_hash, 
        $rol, 
        $date_added, 
        $matricula_inmobiliaria, 
        $empresa, 
        $img_url, 
        $estado, 
        $pagina_web, 
        $directiva, 
        $cargo, 
        $facebook, 
        $instagram, 
        $cedula_ruc, 
        $linkedin, 
        $direccion, 
        $provincia, 
        $ciudad, 
        $ruta_doc
    );

    if ($stmt->execute()) {
        // 5. Envío de Correo
        $email_sent = false;
        try {
            require_once __DIR__ . '/../classes/EmailSender.php';
            $emailSender = new EmailSender();
            $fullName = trim($nombres . ' ' . $apellidos);
            // El método espera: $email, $nombre, $usuario, $password
            $email_sent = $emailSender->enviarCorreoRegistro($email, $fullName, $email, $user_password);
        } catch (Throwable $ex) {
            // No fallamos la request si el correo falla, pero lo notificamos
            error_log("Error enviando correo API: " . $ex->getMessage());
        }

        jsonResponse(true, 'Usuario registrado exitosamente', [
            'id' => $stmt->insert_id,
            'email_sent' => $email_sent,
            'status' => 'pending_approval' // estado 0
        ]);

    } else {
        $error_message = "Error al registrar usuario.";
        if ($stmt->errno == 1062) {
            $error_message = "El correo electrónico ya está registrado.";
        } else {
            $error_message .= " Detalle: " . $stmt->error;
        }
        jsonResponse(false, $error_message, null, [$stmt->error], 409); // 409 Conflict
    }
}
?>
