/// Clase base para fallas de la aplicación
/// 
/// Representa errores que pueden ser mostrados al usuario
/// de manera comprensible y amigable.

abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  String toString() => 'Failure: $message${code != null ? ' ($code)' : ''}';
}

/// Falla de conexión de red
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Error de conexión de red']) : super(message);
}

/// Falla del servidor
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error del servidor']) : super(message);
}

/// Falla de autenticación
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Error de autenticación']) : super(message);
}

/// Falla de validación
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Datos inválidos']) : super(message);
}

/// Falla de recurso no encontrado
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Recurso no encontrado']) : super(message);
}

/// Falla de caché
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error de almacenamiento local']) : super(message);
}