/// Constantes para configuración de API.
///
/// Centraliza todas las URLs, endpoints y configuraciones
/// relacionadas con las llamadas a la API externa.
class ApiConstants {
  /// URL base de la API
  static const String BASE_URL = 'https://mercadoinmobiliario.ec/admin/apis/';

  /// Endpoint para login de usuarios
  static const String LOGIN_ENDPOINT = '${BASE_URL}login.php';

  /// Endpoint de Sistema Terra V2
  static const String TERRA_API_ENDPOINT = '${BASE_URL}api_sistema_terra.php';

  /// Endpoint para logout (si existe)
  static const String LOGOUT_ENDPOINT = '${BASE_URL}logout.php';

  /// Endpoint para registro de usuarios (si existe)
  static const String REGISTER_ENDPOINT = '${BASE_URL}register.php';

  /// Endpoint para verificar token (si existe)
  static const String VERIFY_TOKEN_ENDPOINT = '${BASE_URL}verify_token.php';

  /// Timeout para conexiones (en milisegundos)
  static const int CONNECTION_TIMEOUT = 30000; // 30 segundos

  /// Timeout para recibir respuesta (en milisegundos)
  static const int RECEIVE_TIMEOUT = 30000; // 30 segundos

  /// Headers por defecto para las peticiones
  static const Map<String, String> DEFAULT_HEADERS = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  /// Códigos de estado HTTP exitosos
  static const List<int> SUCCESS_CODES = [200, 201];

  /// Mensajes de error por defecto
  static const String DEFAULT_ERROR_MESSAGE = 'Error de conexión';
  static const String TIMEOUT_ERROR_MESSAGE = 'Tiempo de espera agotado';
  static const String NETWORK_ERROR_MESSAGE =
      'Error de red. Verifique su conexión';
  static const String SERVER_ERROR_MESSAGE = 'Error del servidor';
  static const String INVALID_CREDENTIALS_MESSAGE =
      'Usuario o contraseña incorrectos';
}
