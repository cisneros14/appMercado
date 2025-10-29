import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Configuración global de la aplicación Triara
/// 
/// Centraliza la configuración de servicios, clientes HTTP y otras
/// configuraciones globales de la aplicación.

class AppConfig {
  /// Configuración del cliente HTTP Dio
  static Dio createDioClient() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.API_BASE_URL,
      connectTimeout: Duration(milliseconds: AppConstants.CONNECTION_TIMEOUT),
      receiveTimeout: Duration(milliseconds: AppConstants.RECEIVE_TIMEOUT),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Interceptor para logging en desarrollo
    if (_isDebugMode()) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }
    
    // Interceptor para autenticación
    dio.interceptors.add(AuthInterceptor());
    
    return dio;
  }
  
  /// Verifica si la aplicación está en modo debug
  static bool _isDebugMode() {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}

/// Interceptor para manejo de autenticación
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Agregar token de autenticación si está disponible
    // final token = await TokenStorage.getToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    
    super.onRequest(options, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: Manejar errores de autenticación (401, 403)
    // if (err.response?.statusCode == 401) {
    //   // Redirigir a login
    // }
    
    super.onError(err, handler);
  }
}