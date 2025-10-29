import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/user_model.dart';

/// Data source remoto para manejo de autenticación con API.
///
/// Implementa las llamadas HTTP para autenticación utilizando Dio
/// como cliente HTTP y conectando con la API de login.
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? _createDio();

  /// Crea una instancia de Dio con configuración optimizada
  static Dio _createDio() {
    final dio = Dio();
    
    // Configuración de timeouts
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Headers por defecto
    dio.options.headers = {
      'Accept': 'application/json',
      'User-Agent': 'Triara-App/1.0',
    };

    // Interceptor para logging en debug
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));

    return dio;
  }

  /// Realiza login con credenciales del usuario
  ///
  /// [userName] puede ser nombre de usuario o email
  /// [password] contraseña del usuario
  ///
  /// Retorna [UserModel] con datos del usuario y token
  /// Lanza [DioException] en caso de error de red
  /// Lanza [Exception] para otros errores
  Future<UserModel> login({
    required String userName,
    required String password,
  }) async {
    try {
      // Preparar datos para envío como form data
      final formData = FormData.fromMap({
        'user_name': userName,
        'user_password': password,
      });

      // Realizar petición POST a la API
      final response = await _dio.post(
        ApiConstants.LOGIN_ENDPOINT,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Verificar respuesta exitosa
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Verificar status de la respuesta
        if (responseData['status'] == 'success') {
          // Extraer datos del usuario y token
          final userData = responseData['user'] as Map<String, dynamic>;
          final token = responseData['token'] as String;

          // Debug: imprimir datos recibidos
          print('🔍 Debug - Datos de usuario recibidos:');
          print('userData: $userData');
          print('user_id type: ${userData['user_id'].runtimeType}');

          // Crear modelo de usuario con token
          return UserModel.fromJson({...userData, 'token': token});
        } else {
          // Error en credenciales o servidor
          final message =
              responseData['message'] as String? ?? 'Error de autenticación';
          throw Exception(message);
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores de red
      print('❌ DioException tipo: ${e.type}');
      print('❌ DioException mensaje: ${e.message}');
      print('❌ DioException respuesta: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Tiempo de conexión agotado. Verifique su conectividad');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Tiempo de respuesta agotado del servidor');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Sin conexión a internet. Verifique su conectividad');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Error del servidor: ${e.response?.statusCode}');
      } else {
        throw Exception('Error de red: ${e.message ?? 'Error desconocido'}');
      }
    } catch (e) {
      // Otros errores
      print('❌ Error general: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Verifica la validez de un token con el servidor
  ///
  /// [token] token de autenticación a verificar
  ///
  /// Retorna true si el token es válido
  Future<bool> verifyToken(String token) async {
    try {
      // Aquí implementarías la verificación del token si la API lo soporta
      // Por ahora retornamos true si el token no está vacío
      return token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Realiza logout en el servidor (si es necesario)
  ///
  /// [token] token del usuario a cerrar sesión
  Future<void> logout(String token) async {
    try {
      // Implementar llamada a endpoint de logout si existe
      // Por ahora solo validamos que el token no esté vacío
      if (token.isEmpty) {
        throw Exception('Token inválido');
      }

      // Aquí harías la llamada al endpoint de logout
      // await _dio.post(ApiConstants.LOGOUT_ENDPOINT, ...)
    } catch (e) {
      // El logout remoto es opcional, no lanzamos excepción
      // para permitir logout local
    }
  }
}
