import '../../data/models/user_model.dart';

/// Repositorio abstracto para manejo de autenticación.
///
/// Define los contratos que debe cumplir cualquier implementación
/// de repositorio de autenticación siguiendo los principios de Clean Architecture.
abstract class AuthRepository {
  /// Inicia sesión con las credenciales del usuario
  ///
  /// [userName] puede ser el nombre de usuario o email
  /// [password] contraseña del usuario
  ///
  /// Retorna un [UserModel] si las credenciales son válidas
  /// Lanza una excepción si hay algún error
  Future<UserModel> login({required String userName, required String password});

  /// Cierra la sesión del usuario actual
  ///
  /// Elimina el token y datos de sesión almacenados
  Future<void> logout();

  /// Obtiene el usuario actualmente autenticado
  ///
  /// Retorna [UserModel] si hay una sesión activa, null en caso contrario
  Future<UserModel?> getCurrentUser();

  /// Verifica si hay una sesión activa
  ///
  /// Retorna true si el usuario está autenticado
  Future<bool> isLoggedIn();

  /// Guarda los datos del usuario en almacenamiento local
  ///
  /// [user] datos del usuario a guardar
  Future<void> saveUser(UserModel user);

  /// Elimina los datos del usuario del almacenamiento local
  Future<void> clearUser();

  /// Actualiza el token de autenticación
  ///
  /// [token] nuevo token de autenticación
  Future<void> updateToken(String token);
}
