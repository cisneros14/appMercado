import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para realizar login de usuario.
///
/// Encapsula la lógica de negocio para autenticar un usuario
/// siguiendo los principios de Clean Architecture.
class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  /// Ejecuta el proceso de login
  ///
  /// [userName] puede ser nombre de usuario o email
  /// [password] contraseña del usuario
  ///
  /// Retorna [UserModel] si el login es exitoso
  /// Lanza excepción si hay algún error
  Future<UserModel> execute({
    required String userName,
    required String password,
  }) async {
    // Validaciones de entrada
    if (userName.trim().isEmpty) {
      throw Exception('El nombre de usuario no puede estar vacío');
    }

    if (password.trim().isEmpty) {
      throw Exception('La contraseña no puede estar vacía');
    }

    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    // Ejecutar login a través del repositorio
    try {
      final user = await _authRepository.login(
        userName: userName.trim(),
        password: password,
      );

      return user;
    } catch (e) {
      // Re-lanzar con mensaje más específico si es necesario
      if (e.toString().contains('Usuario no encontrado')) {
        throw Exception('Usuario no encontrado. Verifique sus credenciales');
      } else if (e.toString().contains('Usuario o contraseña incorrectos')) {
        throw Exception('Credenciales incorrectas. Inténtelo nuevamente');
      } else if (e.toString().contains('Error de conexión')) {
        throw Exception('Sin conexión a internet. Verifique su conectividad');
      } else {
        throw Exception('Error de autenticación: ${e.toString()}');
      }
    }
  }
}

/// Caso de uso para logout de usuario.
///
/// Maneja el cierre de sesión completo del usuario.
class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  /// Ejecuta el proceso de logout
  Future<void> execute() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }
}

/// Caso de uso para obtener el usuario actual.
///
/// Retorna el usuario actualmente autenticado.
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  /// Ejecuta la obtención del usuario actual
  ///
  /// Retorna [UserModel] si hay usuario autenticado, null en caso contrario
  Future<UserModel?> execute() async {
    try {
      return await _authRepository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
}

/// Caso de uso para verificar si hay sesión activa.
///
/// Verifica el estado de autenticación del usuario.
class IsLoggedInUseCase {
  final AuthRepository _authRepository;

  IsLoggedInUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  /// Ejecuta la verificación de sesión activa
  ///
  /// Retorna true si hay sesión activa y válida
  Future<bool> execute() async {
    try {
      return await _authRepository.isLoggedIn();
    } catch (e) {
      return false;
    }
  }
}
