import 'package:sqflite/sqflite.dart';
import '../../../core/config/database_config.dart';

/// Servicio de base de datos local para operaciones SQLite
///
/// Esta clase maneja la conexión y operaciones básicas con SQLite,
/// siguiendo el patrón Data Source de Clean Architecture.
abstract class DatabaseService {
  /// Obtiene la instancia de la base de datos
  Future<Database> getDatabase();

  /// Cierra la conexión de la base de datos
  Future<void> closeDatabase();

  /// Ejecuta una consulta SQL
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// Inserta un registro
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  });

  /// Actualiza registros
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });

  /// Elimina registros
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  /// Ejecuta SQL raw
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  /// Ejecuta SQL raw sin retorno
  Future<int> rawInsert(String sql, [List<Object?>? arguments]);

  /// Ejecuta SQL raw para update/delete
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]);

  /// Ejecuta SQL raw general
  Future<void> execute(String sql, [List<Object?>? arguments]);

  /// Ejecuta una transacción
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action);

  /// Ejecuta un batch de operaciones
  Future<List<Object?>> batch(void Function(Batch batch) operations);
}

/// Implementación concreta del servicio de base de datos
class DatabaseServiceImpl implements DatabaseService {
  static Database? _database;

  @override
  Future<Database> getDatabase() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final String path = await DatabaseConfig.getDatabasePath();

    return await openDatabase(
      path,
      version: DatabaseConfig.DATABASE_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
      onConfigure: _onConfigure,
    );
  }

  /// Configuración inicial de la base de datos
  Future<void> _onConfigure(Database db) async {
    await DatabaseConfig.configureDatabase(db);
  }

  /// Callback cuando se abre la base de datos
  Future<void> _onOpen(Database db) async {
    // Configuraciones adicionales al abrir
  }

  /// Callback cuando se crea la base de datos por primera vez
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  /// Callback para actualizaciones de esquema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Aquí se manejarán las migraciones futuras
    if (oldVersion < newVersion) {
      // Ejemplo de migración
      // if (oldVersion < 2) {
      //   await _migrateToVersion2(db);
      // }
    }
  }

  /// Crea las tablas iniciales
  Future<void> _createTables(Database db) async {
    // Tabla de propiedades
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.TABLE_PROPIEDADES} (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        precio REAL NOT NULL,
        tipo TEXT NOT NULL,
        estado TEXT NOT NULL,
        ciudad TEXT,
        direccion TEXT,
        area REAL,
        habitaciones INTEGER,
        banos INTEGER,
        latitud REAL,
        longitud REAL,
        imagenes TEXT,
        fecha_creacion INTEGER NOT NULL,
        fecha_actualizacion INTEGER NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla de usuarios (para cache local)
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.TABLE_USUARIOS} (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        telefono TEXT,
        avatar TEXT,
        fecha_registro INTEGER NOT NULL,
        activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Tabla de favoritos
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.TABLE_FAVORITOS} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id TEXT NOT NULL,
        propiedad_id TEXT NOT NULL,
        fecha_agregado INTEGER NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES ${DatabaseConfig.TABLE_USUARIOS} (id) ON DELETE CASCADE,
        FOREIGN KEY (propiedad_id) REFERENCES ${DatabaseConfig.TABLE_PROPIEDADES} (id) ON DELETE CASCADE,
        UNIQUE (usuario_id, propiedad_id)
      )
    ''');

    // Índices para optimizar consultas
    await db.execute('''
      CREATE INDEX idx_propiedades_tipo ON ${DatabaseConfig.TABLE_PROPIEDADES} (tipo)
    ''');

    await db.execute('''
      CREATE INDEX idx_propiedades_estado ON ${DatabaseConfig.TABLE_PROPIEDADES} (estado)
    ''');

    await db.execute('''
      CREATE INDEX idx_propiedades_precio ON ${DatabaseConfig.TABLE_PROPIEDADES} (precio)
    ''');

    await db.execute('''
      CREATE INDEX idx_favoritos_usuario ON ${DatabaseConfig.TABLE_FAVORITOS} (usuario_id)
    ''');
  }

  @override
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await getDatabase();
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await getDatabase();
    return await db.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await getDatabase();
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await getDatabase();
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await getDatabase();
    return await db.rawQuery(sql, arguments);
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    final db = await getDatabase();
    return await db.rawInsert(sql, arguments);
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    final db = await getDatabase();
    return await db.rawUpdate(sql, arguments);
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    final db = await getDatabase();
    await db.execute(sql, arguments);
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await getDatabase();
    return await db.transaction(action);
  }

  @override
  Future<List<Object?>> batch(void Function(Batch batch) operations) async {
    final db = await getDatabase();
    final batch = db.batch();
    operations(batch);
    return await batch.commit();
  }
}
