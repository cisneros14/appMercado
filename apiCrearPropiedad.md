
# Documentación API Sistema Terra V2 (Completa)

Esta API proporciona una interfaz RESTful completa para la gestión del catálogo inmobiliario del sistema Terra.

**URL Base:** `https://tudominio.com/admin/apis/api_sistema_terra.php`

---

## 🔐 Autenticación y Cabeceras

- **Session:** Utiliza las cookies de sesión del servidor (`session_start()`).
- **CORS:** Soporte para peticiones desde cualquier origen y cabeceras personalizadas.

---

## 🏘️ Endpoints de Propiedades

### 1. Listar Propiedades

**Método:** `GET` | **Acción:** `action=listar`

| Parámetro   | Tipo     | Descripción                               |
| :---------- | :------- | :---------------------------------------- |
| `mine`      | `int`    | `1` para mis propiedades, `0` para todas. |
| `q`         | `string` | Búsqueda por modelo o dirección.          |
| `tipo`      | `int`    | Filtro por ID de tipo de inmueble.        |
| `operacion` | `int`    | `1`=Venta, `2`=Renta.                     |
| `page`      | `int`    | Número de página (10 items/pág).          |

---

### 2. Detalle de Propiedad

**Método:** `GET` | **Acción:** `action=detalle`

| Parámetro | Tipo  | Descripción                     |
| :-------- | :---- | :------------------------------ |
| `id`      | `int` | ID de la propiedad (Requerido). |

**Respuesta:** Retorna el registro de `vivienda` más arrays de `amenidades`, `galeria` y `ambientes`.

---

### 3. Crear / Editar Propiedad

**Método:** `POST` | **Acción:** `action=crear` o `action=editar`

**Campos del Body (JSON o Multipart):**

- `id` (Solo para editar)
- `titulo` (modelo)
- `tipo` (ID)
- `venta_alquiler` (1 o 2)
- `precio` (numérico)
- `habitaciones` (cuartos)
- `banios`
- `niveles`
- `garage`
- `area`
- `area_lote`
- `antiguedad`
- `video` (enlace_video)
- `provincia`, `canton`, `sector` (IDs de catálogo)
- `direccion`, `descripcion`, `observaciones`, `legal`, `financiamiento`, `info`
- `amenidades` (Array de IDs)

---

### 4. Eliminar Propiedad

**Método:** `POST` | **Acción:** `action=eliminar`

- Parámetro: `id` (int). Realiza un borrado lógico (`estado=0`).

---

## 🖼️ Gestión de Medios

### 5. Subir Imagen Principal

**Método:** `POST` | **Acción:** `action=subir_imagen_principal`

- Campos: `id`, `imagen` (archivo).

### 6. Subir Fotos a Galería

**Método:** `POST` | **Acción:** `action=subir_galeria`

- Campos: `id`, `imagenes[]` (múltiples archivos).

### 7. Eliminar Foto de Galería

**Método:** `POST` | **Acción:** `action=eliminar_foto_galeria`

- Campo: `id_foto` (int).

---

## 📋 Catálogos para Formularios

### Catálogo General

**Método:** `GET` | **Acción:** `amenidades` o `tipos`

- Retorna array de objetos `id` y `nombre`.

### Localidades (Jerárquico)

**Método:** `GET` | **Acción:** `localidades`

| Parámetro | Tipo     | Descripción                                                 |
| :-------- | :------- | :---------------------------------------------------------- |
| `tipo`    | `string` | `provincias`, `cantones` o `parroquias`.                    |
| `parent`  | `string` | ID del padre (ej: `id` de provincia para obtener cantones). |

---

**Nota:** Todas las respuestas exitosas devuelven `success: true` y los datos correspondientes en el campo `data`.



<!-- mercadoinmobiliario.ec/admin/apis/api_sistema_terra.php -->
<?php
/**
 * API Sistema Terra V2 - Completa
 * Ubicación: admin/apis/api_sistema_terra.php
 */
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

session_start();
require_once("../config/db.php");
require_once("../config/conexion.php");
require_once("../config/funciones.php");

// Simulación de sesión para pruebas
if (!isset($_SESSION['user_id'])) {
    $_SESSION['user_id'] = 1;
}

$method = $_SERVER['REQUEST_METHOD'];
$action = $_REQUEST['action'] ?? '';

// Helper para respuestas
function jsonResponse($success, $message, $data = null, $code = 200)
{
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}

try {
    switch ($method) {
        case 'GET':
            handleGet($action);
            break;
        case 'POST':
            handlePost($action);
            break;
        default:
            jsonResponse(false, 'Método no soportado', null, 405);
    }
} catch (Exception $e) {
    jsonResponse(false, 'Error interno: ' . $e->getMessage(), null, 500);
}

function handleGet($action)
{
    global $con;

    switch ($action) {
        case 'listar':
            listarPropiedades();
            break;
        case 'detalle':
            detallePropiedad();
            break;
        case 'tipos':
            obtenerCatalogo('tipo_inmueble', 'id_tipo', 'tipo');
            break;
        case 'amenidades':
            obtenerCatalogo('amenidades', 'id_amenidad', 'amenidad');
            break;
        case 'localidades':
            obtenerLocalidades();
            break;
        default:
            jsonResponse(false, 'Acción GET no válida');
    }
}

function handlePost($action)
{
    switch ($action) {
        case 'crear':
            guardarPropiedad(null);
            break;
        case 'editar':
            guardarPropiedad($_POST['id'] ?? $_GET['id'] ?? null);
            break;
        case 'eliminar':
            eliminarPropiedad();
            break;
        case 'subir_imagen_principal':
            subirImagenPrincipal();
            break;
        case 'subir_galeria':
            subirGaleria();
            break;
        case 'eliminar_foto_galeria':
            eliminarFotoGaleria();
            break;
        default:
            jsonResponse(false, 'Acción POST no válida');
    }
}

// --- FUNCIONES DE LÓGICA ---

function listarPropiedades()
{
    global $con;
    $id_corredor = $_SESSION['user_id'];
    $mine = $_GET['mine'] ?? '1';
    $search = mysqli_real_escape_string($con, $_GET['q'] ?? '');

    $where = "WHERE estado = 1";
    if ($mine == '1')
        $where .= " AND id_corredor = $id_corredor";
    if ($search)
        $where .= " AND (modelo LIKE '%$search%' OR direccion LIKE '%$search%')";

    // Filtros adicionales
    if (!empty($_GET['tipo']))
        $where .= " AND tipo = " . intval($_GET['tipo']);
    if (!empty($_GET['operacion']))
        $where .= " AND venta_alquiler = " . intval($_GET['operacion']);

    $page = max(1, intval($_GET['page'] ?? 1));
    $limit = 10;
    $offset = ($page - 1) * $limit;

    $sql = "SELECT * FROM vivienda $where ORDER BY id_vivienda DESC LIMIT $offset, $limit";
    $result = mysqli_query($con, $sql);

    $propiedades = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $row['img_principal'] = $row['img_principal'] ? "../../images/" . $row['img_principal'] : null;
        $propiedades[] = $row;
    }

    jsonResponse(true, 'Listado obtenido', [
        'propiedades' => $propiedades,
        'pagina' => $page
    ]);
}

function detallePropiedad()
{
    global $con;
    $id = intval($_GET['id'] ?? 0);
    if (!$id)
        jsonResponse(false, 'ID requerido');

    $sql = "SELECT * FROM vivienda WHERE id_vivienda = $id LIMIT 1";
    $res = mysqli_query($con, $sql);
    $propiedad = mysqli_fetch_assoc($res);

    if (!$propiedad)
        jsonResponse(false, 'No encontrada');

    // Amenidades
    $sqlAm = "SELECT a.* FROM amenidades a INNER JOIN vivienda_amenidades va ON a.id_amenidad = va.id_amenidad WHERE va.id_vivienda = $id";
    $resAm = mysqli_query($con, $sqlAm);
    $propiedad['amenidades'] = mysqli_fetch_all($resAm, MYSQLI_ASSOC);

    // Galería
    $sqlImg = "SELECT * FROM img_casa WHERE id_casa = $id";
    $resImg = mysqli_query($con, $sqlImg);
    $propiedad['galeria'] = mysqli_fetch_all($resImg, MYSQLI_ASSOC);

    // Ambientes
    $sqlAmb = "SELECT * FROM vivienda_ambiente WHERE id_vivienda = $id";
    $resAmb = mysqli_query($con, $sqlAmb);
    $propiedad['ambientes'] = mysqli_fetch_all($resAmb, MYSQLI_ASSOC);

    jsonResponse(true, 'Detalle obtenido', $propiedad);
}

function guardarPropiedad($id = null)
{
    global $con;
    $data = $_POST;
    if (empty($data)) {
        $data = json_decode(file_get_contents('php://input'), true);
    }

    if (!$data)
        jsonResponse(false, 'Datos vacíos');

    $id_corredor = $_SESSION['user_id'];

    // Mapeo exhaustivo de campos
    $fields = [
        'modelo' => $data['titulo'] ?? '',
        'tipo' => $data['tipo'] ?? 0,
        'venta_alquiler' => $data['venta_alquiler'] ?? 1,
        'precio' => $data['precio'] ?? 0,
        'cuartos' => $data['habitaciones'] ?? 0,
        'banios' => $data['banios'] ?? 0,
        'niveles' => $data['niveles'] ?? 1,
        'garage' => $data['garage'] ?? 0,
        'area' => $data['area'] ?? 0,
        'area_lote' => $data['area_lote'] ?? 0,
        'antiguedad' => $data['antiguedad'] ?? '',
        'enlace_video' => $data['video'] ?? '',
        'provincia' => $data['provincia'] ?? '',
        'ciudad' => $data['canton'] ?? '',
        'sector' => $data['sector'] ?? '',
        'direccion' => $data['direccion'] ?? '',
        'descripcion' => $data['descripcion'] ?? '',
        'observaciones' => $data['observaciones'] ?? '',
        'legal' => $data['legal'] ?? '',
        'financiamiento' => $data['financiamiento'] ?? '',
        'info_doc' => $data['info'] ?? '',
        'pais' => 'ECUADOR',
        'estado' => 1
    ];

    if ($id) {
        $updates = [];
        foreach ($fields as $key => $val) {
            $val_esc = mysqli_real_escape_string($con, $val);
            $updates[] = "`$key` = '$val_esc'";
        }
        $sql = "UPDATE vivienda SET " . implode(", ", $updates) . " WHERE id_vivienda = $id";
        mysqli_query($con, $sql);
    } else {
        $fields['id_corredor'] = $id_corredor;
        $fields['fecha_publicacion'] = date('Y-m-d H:i:s');
        $keys = array_keys($fields);
        $vals = array_map(function ($v) use ($con) {
            return "'" . mysqli_real_escape_string($con, $v) . "'"; }, array_values($fields));
        $sql = "INSERT INTO vivienda (" . implode(",", $keys) . ") VALUES (" . implode(",", $vals) . ")";
        mysqli_query($con, $sql);
        $id = mysqli_insert_id($con);
    }

    // Gestionar Amenidades si se envían (array de IDs)
    if (isset($data['amenidades']) && is_array($data['amenidades'])) {
        mysqli_query($con, "DELETE FROM vivienda_amenidades WHERE id_vivienda = $id");
        foreach ($data['amenidades'] as $id_am) {
            $id_am = intval($id_am);
            mysqli_query($con, "INSERT INTO vivienda_amenidades (id_vivienda, id_amenidad) VALUES ($id, $id_am)");
        }
    }

    jsonResponse(true, ($id ? 'Propiedad actualizada' : 'Propiedad creada'), ['id' => $id]);
}

function eliminarPropiedad()
{
    global $con;
    $id = intval($_POST['id'] ?? 0);
    if (!$id)
        jsonResponse(false, 'ID requerido');

    $sql = "UPDATE vivienda SET estado = 0 WHERE id_vivienda = $id";
    if (mysqli_query($con, $sql))
        jsonResponse(true, 'Eliminada correctamente');
    else
        jsonResponse(false, 'Error al eliminar');
}

function obtenerCatalogo($tabla, $id_col, $name_col)
{
    global $con;
    $sql = "SELECT $id_col as id, $name_col as nombre FROM $tabla ORDER BY $name_col ASC";
    $res = mysqli_query($con, $sql);
    jsonResponse(true, 'Catálogo', mysqli_fetch_all($res, MYSQLI_ASSOC));
}

function obtenerLocalidades()
{
    global $con;
    $tipo = $_GET['tipo'] ?? 'provincias'; // provincias, cantones, parroquias
    $parent = mysqli_real_escape_string($con, $_GET['parent'] ?? '');

    if ($tipo == 'provincias') {
        $sql = "SELECT DISTINCT provincia as nombre, codigo_provincia as id FROM localidad GROUP BY provincia";
    } elseif ($tipo == 'cantones') {
        $sql = "SELECT DISTINCT canton as nombre, codigo_canton as id FROM localidad WHERE codigo_provincia = '$parent' GROUP BY canton";
    } else {
        $sql = "SELECT parroquia as nombre, codigo_parroquia as id FROM localidad WHERE codigo_canton = '$parent'";
    }

    $res = mysqli_query($con, $sql);
    jsonResponse(true, 'Localidades', mysqli_fetch_all($res, MYSQLI_ASSOC));
}

function subirImagenPrincipal()
{
    global $con;
    $id = intval($_POST['id'] ?? 0);
    if (!$id || !isset($_FILES['imagen']))
        jsonResponse(false, 'Datos incompletos');

    $name = time() . "_" . $_FILES['imagen']['name'];
    $path = "../../images/img/" . $name;

    if (move_uploaded_file($_FILES['imagen']['tmp_name'], $path)) {
        mysqli_query($con, "UPDATE vivienda SET img_principal = 'img/$name' WHERE id_vivienda = $id");
        jsonResponse(true, 'Imagen principal actualizada', ['url' => "img/$name"]);
    }
    jsonResponse(false, 'Error al subir');
}

function subirGaleria()
{
    global $con;
    $id = intval($_POST['id'] ?? 0);
    if (!$id || empty($_FILES['imagenes']))
        jsonResponse(false, 'Datos incompletos');

    foreach ($_FILES['imagenes']['tmp_name'] as $k => $tmp) {
        $name = time() . "_" . $k . "_" . $_FILES['imagenes']['name'][$k];
        $path = "../../images/img/" . $name;
        if (move_uploaded_file($tmp, $path)) {
            $url = "img/$name";
            mysqli_query($con, "INSERT INTO img_casa (id_casa, url_imagen) VALUES ($id, '$url')");
        }
    }
    jsonResponse(true, 'Galería actualizada');
}

function eliminarFotoGaleria()
{
    global $con;
    $id_foto = intval($_POST['id_foto'] ?? 0);
    if (!$id_foto)
        jsonResponse(false, 'ID foto requerido');

    mysqli_query($con, "DELETE FROM img_casa WHERE id_img = $id_foto");
    jsonResponse(true, 'Foto eliminada');
}
