import '../../domain/repositories/auth_repository.dart';
import '../data_sources/local/auth_local_datasource.dart';
import '../data_sources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementación concreta del repositorio de autenticación.
///
/// Coordina entre el data source remoto (API) y local (SQLite)
/// para proporcionar funcionalidades completas de autenticación.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<UserModel> login({
    required String userName,
    required String password,
  }) async {
    try {
      // 1. Intentar login remoto con la API
      final user = await _remoteDataSource.login(
        userName: userName,
        password: password,
      );

      // 2. Si el login es exitoso, guardar en almacenamiento local
      await _localDataSource.saveUser(user);

      return user;
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por el caso de uso
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // 1. Obtener token actual para logout remoto
      final token = await _localDataSource.getToken();

      // 2. Intentar logout remoto (opcional, no bloquea si falla)
      if (token != null && token.isNotEmpty) {
        try {
          await _remoteDataSource.logout(token);
        } catch (e) {
          // Logout remoto es opcional, continuar con logout local
        }
      }

      // 3. Limpiar datos locales
      await _localDataSource.clearUser();
    } catch (e) {
      // Asegurar que los datos locales se limpien aunque falle el logout remoto
      await _localDataSource.clearUser();
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _localDataSource.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      // Verificar sesión local y validez del token
      final isLocalLoggedIn = await _localDataSource.isLoggedIn();

      if (!isLocalLoggedIn) return false;

      // Verificar si el token sigue siendo válido (por tiempo)
      final isTokenValid = await _localDataSource.isTokenValid();

      if (!isTokenValid) {
        // Token expirado, limpiar sesión
        await _localDataSource.clearUser();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _localDataSource.saveUser(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _localDataSource.clearUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateToken(String token) async {
    try {
      await _localDataSource.updateToken(token);
    } catch (e) {
      rethrow;
    }
  }

  /// Actualiza la última actividad del usuario
  ///
  /// Método adicional para mantener la sesión activa
  Future<void> updateLastActivity() async {
    try {
      await _localDataSource.updateLastActivity();
    } catch (e) {
      // No crítico si falla
    }
  }

  /// Verifica si el token es válido remotamente
  ///
  /// [token] token a verificar
  /// Retorna true si el token es válido
  Future<bool> verifyTokenRemotely(String token) async {
    try {
      return await _remoteDataSource.verifyToken(token);
    } catch (e) {
      return false;
    }
  }
}
