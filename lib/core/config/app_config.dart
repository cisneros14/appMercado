import 'dart:convert';
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
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 600,
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
    
    // Interceptor para sanitizar HTML/Comentarios en respuestas
    dio.interceptors.add(HtmlCleanerInterceptor());
    
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

/// Interceptor que limpia comentarios HTML o basura antes del JSON real
class HtmlCleanerInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Si la respuesta es un String (ResponseType.plain o interceptada antes de decodificar)
    if (response.data is String) {
      final String rawData = response.data;
      final int startIndex = rawData.indexOf('{');
      final int startListIndex = rawData.indexOf('[');
      
      // Determinar cuál empieza primero (objeto o lista)
      int start = -1;
      if (startIndex != -1 && startListIndex != -1) {
        start = startIndex < startListIndex ? startIndex : startListIndex;
      } else {
        start = startIndex != -1 ? startIndex : startListIndex;
      }
      
      if (start != -1) {
        try {
          final String sanitizedData = rawData.substring(start);
          // Decodificar manualmente para que los repositorios reciban el Map o List esperado
          response.data = jsonDecode(sanitizedData);
          print('🧹 HtmlCleanerInterceptor: Respuesta sanitizada y decodificada');
        } catch (e) {
          print('⚠️ HtmlCleanerInterceptor Error: Fallo al decodificar JSON sanitizado');
        }
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null && err.response!.data is String) {
      final String rawData = err.response!.data;
      final int startBrace = rawData.indexOf('{');
      final int startBracket = rawData.indexOf('[');
      int start = -1;
      if (startBrace != -1 && startBracket != -1) {
        start = startBrace < startBracket ? startBrace : startBracket;
      } else {
        start = startBrace != -1 ? startBrace : startBracket;
      }
      
      if (start != -1) {
        try {
          final String sanitizedData = rawData.substring(start);
          err.response!.data = jsonDecode(sanitizedData);
          print('🧹 HtmlCleanerInterceptor (Error): Respuesta de error sanitizada');
        } catch (e) {
          // Si no se puede parsear, dejamos los datos como están
        }
      }
    }
    super.onError(err, handler);
  }
}