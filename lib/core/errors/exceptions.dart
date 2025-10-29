/// Clase base para excepciones de la aplicación
/// 
/// Define la estructura común para el manejo de errores
/// en toda la aplicación Triara.

abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

/// Excepción para errores de conexión de red
class NetworkException extends AppException {
  const NetworkException(String message, [String? code]) : super(message, code);
}

/// Excepción para errores del servidor
class ServerException extends AppException {
  const ServerException(String message, [String? code]) : super(message, code);
}

/// Excepción para errores de autenticación
class AuthException extends AppException {
  const AuthException(String message, [String? code]) : super(message, code);
}

/// Excepción para errores de validación
class ValidationException extends AppException {
  const ValidationException(String message, [String? code]) : super(message, code);
}

/// Excepción para recursos no encontrados
class NotFoundException extends AppException {
  const NotFoundException(String message, [String? code]) : super(message, code);
}

/// Excepción para errores de caché
class CacheException extends AppException {
  const CacheException(String message, [String? code]) : super(message, code);
}