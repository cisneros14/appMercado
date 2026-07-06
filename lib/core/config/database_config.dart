import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import '../../data/data_sources/local/onboarding_local_datasource.dart';
import '../../data/data_sources/local/auth_local_datasource.dart';

/// Configuración centralizada para la base de datos SQLite
///
/// Esta clase maneja la configuración global de la base de datos,
/// incluyendo nombre, versión y constantes relacionadas.
class DatabaseConfig {
  /// Nombre de la base de datos
  static const String DATABASE_NAME = 'triara.db';

  /// Versión de la base de datos (incrementar para forzar actualizaciones)
  static const int DATABASE_VERSION = 3;

  /// Timeout para operaciones de base de datos (en segundos)
  static const int DATABASE_TIMEOUT = 30;

  /// Nombre de tabla para propiedades
  static const String TABLE_PROPIEDADES = 'propiedades';

  /// Nombre de tabla para usuarios
  static const String TABLE_USUARIOS = 'usuarios';

  /// Nombre de tabla para favoritos
  static const String TABLE_FAVORITOS = 'favoritos';

  /// Nombre de tabla para slides de onboarding
  static const String TABLE_ONBOARDING_SLIDES = 'onboarding_slides';

  /// Configuración de escritura concurrente
  static const bool ENABLE_WRITE_AHEAD_LOGGING = true;

  /// Configuración de foreign keys
  static const bool ENABLE_FOREIGN_KEYS = true;

  /// Configuración de cache de consultas
  static const int QUERY_CACHE_SIZE = 100;

  /// Instancia singleton de la base de datos
  static Database? _database;

  /// Indica si la base de datos fue inicializada
  static bool _isInitialized = false;

  /// Constructor privado para evitar instanciación
  DatabaseConfig._();

  /// Inicializa el databaseFactory para diferentes plataformas
  static void _initializeDatabaseFactory() {
    if (_isInitialized) return;

    // Para web, usar sqflite_common_ffi
    if (kIsWeb) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // Para móviles (Android/iOS) usar sqflite por defecto (no necesita configuración)

    _isInitialized = true;
  }

  /// Getter para obtener la instancia de la base de datos
  static Future<Database> get database async {
    // Inicializar databaseFactory si no se ha hecho
    _initializeDatabaseFactory();

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  static Future<Database> _initDatabase() async {
    final String path = await getDatabasePath();

    return await openDatabase(
      path,
      version: DATABASE_VERSION,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configuración de la base de datos
  static Future<void> _onConfigure(Database db) async {
    await configureDatabase(db);
  }

  /// Creación inicial de tablas
  static Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de slides de onboarding
    await OnboardingLocalDatasource.createTable(db);

    // Crear tabla de sesión de usuario
    await AuthLocalDataSource.createTable(db);

    // Aquí se pueden agregar más tablas en el futuro
    // await createOtherTables(db);
  }

  /// Actualización de la base de datos
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Lógica de migración para futuras versiones
    if (oldVersion < 2) {
      // Migraciones para versión 2: agregar tabla de sesión de usuario
      await AuthLocalDataSource.createTable(db);
    }
  }

  /// Obtiene la ruta completa de la base de datos
  static Future<String> getDatabasePath() async {
    if (kIsWeb) {
      // Para web, usar un path simple
      return DATABASE_NAME;
    } else {
      // Para móviles y desktop, usar el path estándar
      final String databasesPath = await getDatabasesPath();
      return join(databasesPath, DATABASE_NAME);
    }
  }

  /// Elimina la base de datos (útil para desarrollo y testing)
  static Future<void> deleteDatabase() async {
    try {
      final path = await getDatabasePath();
      await databaseFactory.deleteDatabase(path);
      _database = null;
      _isInitialized = false;
      print('✅ Base de datos eliminada exitosamente');
    } catch (e) {
      print('❌ Error al eliminar base de datos: $e');
    }
  }

  /// Configuración adicional para la base de datos
  static Future<void> configureDatabase(Database db) async {
    // Habilitar foreign keys
    if (ENABLE_FOREIGN_KEYS) {
      await db.rawQuery('PRAGMA foreign_keys = ON');
    }

    // Configurar timeout
    await db.rawQuery('PRAGMA busy_timeout = ${DATABASE_TIMEOUT * 1000}');

    // Configurar WAL mode si está habilitado
    if (ENABLE_WRITE_AHEAD_LOGGING) {
      await db.rawQuery('PRAGMA journal_mode = WAL');
    }

    // Configurar cache size
    await db.rawQuery('PRAGMA cache_size = -$QUERY_CACHE_SIZE');
  }

  /// Cierra la base de datos
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Elimina completamente la base de datos (para desarrollo/testing)
  static Future<void> deleteDatabaseFile() async {
    try {
      await closeDatabase();
      final String path = await getDatabasePath();
      await databaseFactory.deleteDatabase(path);
      _database = null;
      print('🗑️ Base de datos eliminada completamente');
    } catch (e) {
      print('❌ Error eliminando base de datos: $e');
    }
  }

  /// Reinicia la base de datos (elimina y recrea)
  static Future<void> resetDatabase() async {
    print('🔄 Reiniciando base de datos...');
    await deleteDatabaseFile();
    // La próxima llamada a database() recreará la BD con la nueva estructura
    await database;
    print('✅ Base de datos reiniciada exitosamente');
  }
}
