/// Clase base para excepciones de la aplicación
/// 
/// Define la estructura común para el manejo de errores
/// en toda la aplicación Triara.
library;

abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message${code != null ? ' ($code)' : ''}';
}

/// Excepción para errores de conexión de red
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Excepción para errores del servidor
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// Excepción para errores de autenticación
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Excepción para errores de validación
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Excepción para recursos no encontrados
class NotFoundException extends AppException {
  const NotFoundException(super.message, [super.code]);
}

/// Excepción para errores de caché
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}