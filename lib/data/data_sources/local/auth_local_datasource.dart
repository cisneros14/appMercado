import 'package:sqflite/sqflite.dart';
import '../../../core/config/database_config.dart';
import '../../models/user_model.dart';

/// Data source local para manejo de datos de usuario en SQLite.
///
/// Proporciona métodos para almacenar, recuperar y gestionar
/// información del usuario autenticado en la base de datos local.
class AuthLocalDataSource {
  static const String _tableName = 'user_session';

  /// Obtiene la instancia de la base de datos
  Future<Database> get _database async {
    return await DatabaseConfig.database;
  }

  /// Crea la tabla de sesión de usuario si no existe
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        user_id INTEGER NOT NULL,
        user_name TEXT NOT NULL,
        firstname TEXT NOT NULL,
        lastname TEXT NOT NULL,
        user_email TEXT NOT NULL,
        rol TEXT NOT NULL,
        token TEXT,
        login_date TEXT DEFAULT CURRENT_TIMESTAMP,
        last_activity TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  /// Guarda los datos del usuario en la sesión local
  ///
  /// [user] modelo del usuario a guardar
  /// Solo puede haber una sesión activa a la vez
  Future<void> saveUser(UserModel user) async {
    final db = await _database;

    // Primero eliminar cualquier sesión existente
    await db.delete(_tableName);

    // Insertar nueva sesión
    await db.insert(_tableName, {
      'id': 1, // Solo una sesión activa
      'user_id': user.userId,
      'user_name': user.userName,
      'firstname': user.firstName,
      'lastname': user.lastName,
      'user_email': user.userEmail,
      'rol': user.rol,
      'token': user.token,
      'login_date': DateTime.now().toIso8601String(),
      'last_activity': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Obtiene el usuario actualmente en sesión
  ///
  /// Retorna [UserModel] si hay sesión activa, null en caso contrario
  Future<UserModel?> getCurrentUser() async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return UserModel.fromMap({
        'user_id': map['user_id'],
        'user_name': map['user_name'],
        'firstname': map['firstname'],
        'lastname': map['lastname'],
        'user_email': map['user_email'],
        'rol': map['rol'],
        'token': map['token'],
      });
    }
    return null;
  }

  /// Verifica si hay una sesión activa
  ///
  /// Retorna true si existe un usuario en sesión
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null && user.token != null && user.token!.isNotEmpty;
  }

  /// Actualiza el token del usuario en sesión
  ///
  /// [token] nuevo token de autenticación
  Future<void> updateToken(String token) async {
    final db = await _database;

    await db.update(
      _tableName,
      {'token': token, 'last_activity': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  /// Actualiza la última actividad del usuario
  Future<void> updateLastActivity() async {
    final db = await _database;

    await db.update(
      _tableName,
      {'last_activity': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  /// Elimina la sesión del usuario (logout)
  Future<void> clearUser() async {
    final db = await _database;
    await db.delete(_tableName);
  }

  /// Obtiene el token del usuario en sesión
  ///
  /// Retorna el token si hay sesión activa, null en caso contrario
  Future<String?> getToken() async {
    final user = await getCurrentUser();
    return user?.token;
  }

  /// Verifica si el token sigue siendo válido (basado en tiempo)
  ///
  /// [maxHours] máximo de horas de inactividad permitidas
  /// Retorna true si la sesión sigue siendo válida
  Future<bool> isTokenValid({int maxHours = 24}) async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['last_activity'],
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isEmpty) return false;

    final lastActivityStr = maps.first['last_activity'] as String?;
    if (lastActivityStr == null) return false;

    final lastActivity = DateTime.parse(lastActivityStr);
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    return difference.inHours < maxHours;
  }
}
