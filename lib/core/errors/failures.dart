/// Clase base para fallas de la aplicación
/// 
/// Representa errores que pueden ser mostrados al usuario
/// de manera comprensible y amigable.
library;

abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  String toString() => 'Failure: $message${code != null ? ' ($code)' : ''}';
}

/// Falla de conexión de red
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Error de conexión de red']);
}

/// Falla del servidor
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Falla de autenticación
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Error de autenticación']);
}

/// Falla de validación
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}

/// Falla de recurso no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}

/// Falla de caché
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local']);
}