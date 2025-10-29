import 'package:sqflite/sqflite.dart';
import '../../core/config/database_config.dart';
import 'local/database_service.dart';

/// Helper principal para operaciones de base de datos
///
/// Esta clase proporciona métodos de alto nivel para operaciones
/// comunes de base de datos, abstrayendo la complejidad del DatabaseService.
class DatabaseHelper {
  final DatabaseService _databaseService;

  /// Constructor que recibe el servicio de base de datos
  const DatabaseHelper(this._databaseService);

  // === OPERACIONES GENERALES ===

  /// Inicializa la base de datos
  Future<void> initialize() async {
    await _databaseService.getDatabase();
  }

  /// Cierra la conexión de la base de datos
  Future<void> close() async {
    await _databaseService.closeDatabase();
  }

  /// Limpia todas las tablas (útil para logout o reset)
  Future<void> clearAllData() async {
    await _databaseService.transaction((txn) async {
      await txn.delete(DatabaseConfig.TABLE_FAVORITOS);
      await txn.delete(DatabaseConfig.TABLE_PROPIEDADES);
      await txn.delete(DatabaseConfig.TABLE_USUARIOS);
    });
  }

  // === OPERACIONES DE PROPIEDADES ===

  /// Guarda una propiedad en la base de datos local
  Future<bool> savePropiedad(Map<String, dynamic> propiedadData) async {
    try {
      final int result = await _databaseService.insert(
        DatabaseConfig.TABLE_PROPIEDADES,
        {
          ...propiedadData,
          'fecha_actualizacion': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// Guarda múltiples propiedades en una transacción
  Future<bool> savePropiedades(
    List<Map<String, dynamic>> propiedadesList,
  ) async {
    try {
      await _databaseService.transaction((txn) async {
        final batch = txn.batch();
        for (final propiedad in propiedadesList) {
          batch.insert(
            DatabaseConfig.TABLE_PROPIEDADES,
            {
              ...propiedad,
              'fecha_actualizacion': DateTime.now().millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene todas las propiedades almacenadas localmente
  Future<List<Map<String, dynamic>>> getPropiedades({
    String? tipo,
    String? estado,
    double? precioMin,
    double? precioMax,
    String? ciudad,
    int? limit,
    int? offset,
  }) async {
    String? where;
    List<Object?> whereArgs = [];

    // Construir condiciones WHERE dinámicamente
    List<String> conditions = ['activo = 1'];

    if (tipo != null) {
      conditions.add('tipo = ?');
      whereArgs.add(tipo);
    }

    if (estado != null) {
      conditions.add('estado = ?');
      whereArgs.add(estado);
    }

    if (precioMin != null) {
      conditions.add('precio >= ?');
      whereArgs.add(precioMin);
    }

    if (precioMax != null) {
      conditions.add('precio <= ?');
      whereArgs.add(precioMax);
    }

    if (ciudad != null) {
      conditions.add('ciudad LIKE ?');
      whereArgs.add('%$ciudad%');
    }

    if (conditions.isNotEmpty) {
      where = conditions.join(' AND ');
    }

    return await _databaseService.query(
      DatabaseConfig.TABLE_PROPIEDADES,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'fecha_actualizacion DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Obtiene una propiedad por ID
  Future<Map<String, dynamic>?> getPropiedadById(String id) async {
    final List<Map<String, dynamic>> results = await _databaseService.query(
      DatabaseConfig.TABLE_PROPIEDADES,
      where: 'id = ? AND activo = 1',
      whereArgs: [id],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Actualiza una propiedad
  Future<bool> updatePropiedad(
    String id,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      final int result = await _databaseService.update(
        DatabaseConfig.TABLE_PROPIEDADES,
        {
          ...updatedData,
          'fecha_actualizacion': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// Elimina una propiedad (marca como inactiva)
  Future<bool> deletePropiedad(String id) async {
    try {
      final int result = await _databaseService.update(
        DatabaseConfig.TABLE_PROPIEDADES,
        {
          'activo': 0,
          'fecha_actualizacion': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// Busca propiedades por texto
  Future<List<Map<String, dynamic>>> searchPropiedades(
    String searchTerm,
  ) async {
    return await _databaseService.query(
      DatabaseConfig.TABLE_PROPIEDADES,
      where: '''
        activo = 1 AND (
          titulo LIKE ? OR 
          descripcion LIKE ? OR 
          ciudad LIKE ? OR 
          direccion LIKE ?
        )
      ''',
      whereArgs: [
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
      ],
      orderBy: 'fecha_actualizacion DESC',
    );
  }

  // === OPERACIONES DE USUARIOS ===

  /// Guarda un usuario en la base de datos local
  Future<bool> saveUsuario(Map<String, dynamic> usuarioData) async {
    try {
      final int result = await _databaseService.insert(
        DatabaseConfig.TABLE_USUARIOS,
        usuarioData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene un usuario por ID
  Future<Map<String, dynamic>?> getUsuarioById(String id) async {
    final List<Map<String, dynamic>> results = await _databaseService.query(
      DatabaseConfig.TABLE_USUARIOS,
      where: 'id = ? AND activo = 1',
      whereArgs: [id],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Obtiene un usuario por email
  Future<Map<String, dynamic>?> getUsuarioByEmail(String email) async {
    final List<Map<String, dynamic>> results = await _databaseService.query(
      DatabaseConfig.TABLE_USUARIOS,
      where: 'email = ? AND activo = 1',
      whereArgs: [email],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  // === OPERACIONES DE FAVORITOS ===

  /// Agrega una propiedad a favoritos
  Future<bool> addFavorito(String usuarioId, String propiedadId) async {
    try {
      final int result = await _databaseService.insert(
        DatabaseConfig.TABLE_FAVORITOS,
        {
          'usuario_id': usuarioId,
          'propiedad_id': propiedadId,
          'fecha_agregado': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// Remueve una propiedad de favoritos
  Future<bool> removeFavorito(String usuarioId, String propiedadId) async {
    try {
      final int result = await _databaseService.delete(
        DatabaseConfig.TABLE_FAVORITOS,
        where: 'usuario_id = ? AND propiedad_id = ?',
        whereArgs: [usuarioId, propiedadId],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si una propiedad está en favoritos
  Future<bool> isFavorito(String usuarioId, String propiedadId) async {
    final List<Map<String, dynamic>> results = await _databaseService.query(
      DatabaseConfig.TABLE_FAVORITOS,
      where: 'usuario_id = ? AND propiedad_id = ?',
      whereArgs: [usuarioId, propiedadId],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  /// Obtiene todas las propiedades favoritas de un usuario
  Future<List<Map<String, dynamic>>> getFavoritosByUsuario(
    String usuarioId,
  ) async {
    return await _databaseService.rawQuery(
      '''
      SELECT p.* FROM ${DatabaseConfig.TABLE_PROPIEDADES} p
      INNER JOIN ${DatabaseConfig.TABLE_FAVORITOS} f ON p.id = f.propiedad_id
      WHERE f.usuario_id = ? AND p.activo = 1
      ORDER BY f.fecha_agregado DESC
    ''',
      [usuarioId],
    );
  }

  /// Obtiene el conteo de favoritos de un usuario
  Future<int> getFavoritosCount(String usuarioId) async {
    final List<Map<String, dynamic>> results = await _databaseService.rawQuery(
      '''
      SELECT COUNT(*) as count FROM ${DatabaseConfig.TABLE_FAVORITOS} f
      INNER JOIN ${DatabaseConfig.TABLE_PROPIEDADES} p ON f.propiedad_id = p.id
      WHERE f.usuario_id = ? AND p.activo = 1
    ''',
      [usuarioId],
    );

    return results.first['count'] as int;
  }

  // === OPERACIONES DE ESTADÍSTICAS Y MÉTRICAS ===

  /// Obtiene estadísticas generales de la base de datos local
  Future<Map<String, int>> getEstadisticas() async {
    final propiedadesCount = await _databaseService.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConfig.TABLE_PROPIEDADES} WHERE activo = 1',
    );

    final usuariosCount = await _databaseService.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConfig.TABLE_USUARIOS} WHERE activo = 1',
    );

    final favoritosCount = await _databaseService.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseConfig.TABLE_FAVORITOS}',
    );

    return {
      'propiedades': propiedadesCount.first['count'] as int,
      'usuarios': usuariosCount.first['count'] as int,
      'favoritos': favoritosCount.first['count'] as int,
    };
  }

  /// Obtiene el tamaño de la base de datos en bytes
  Future<int> getDatabaseSize() async {
    try {
      // En una implementación real, aquí calcularías el tamaño del archivo
      return 0; // Placeholder
    } catch (e) {
      return 0;
    }
  }

  // === OPERACIONES DE MANTENIMIENTO ===

  /// Optimiza la base de datos ejecutando VACUUM
  Future<void> optimize() async {
    await _databaseService.execute('VACUUM');
  }

  /// Verifica la integridad de la base de datos
  Future<bool> checkIntegrity() async {
    try {
      final results = await _databaseService.rawQuery('PRAGMA integrity_check');
      return results.first['integrity_check'] == 'ok';
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información sobre las tablas
  Future<List<Map<String, dynamic>>> getTablesInfo() async {
    return await _databaseService.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
  }
}
