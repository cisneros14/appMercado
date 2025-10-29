import 'package:sqflite/sqflite.dart';
import '../../../core/config/database_config.dart';
import '../../models/onboarding_slide_model.dart';

/// Data source local para manejar los slides de onboarding en SQLite.
///
/// Proporciona métodos para interactuar con la tabla de slides de onboarding
/// en la base de datos local SQLite.
class OnboardingLocalDatasource {
  static const String _tableName = 'onboarding_slides';

  /// Obtiene la instancia de la base de datos
  Future<Database> get _database async {
    return await DatabaseConfig.database;
  }

  /// Crea la tabla de slides de onboarding si no existe
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        imagen_asset TEXT NOT NULL,
        es_ultimo_slide INTEGER NOT NULL DEFAULT 0,
        color_fondo TEXT NOT NULL,
        orden INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  /// Inserta los slides de onboarding iniciales si la tabla está vacía
  Future<void> insertInitialSlides() async {
    final db = await _database;

    // Verificar si ya existen slides
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    final count = result.first.values.first as int? ?? 0;

    if (count == 0) {
      final slides = OnboardingSlideModel.getSlidesData();

      for (final slide in slides) {
        await db.insert(_tableName, slide.toMap());
      }
    }
  }

  /// Fuerza la actualización de los slides de onboarding con datos nuevos
  ///
  /// Este método elimina todos los slides existentes y los reemplaza
  /// con los datos actuales del modelo. Útil cuando se actualizan textos.
  Future<void> forceUpdateSlides() async {
    final db = await _database;

    // Eliminar todos los slides existentes
    await db.delete(_tableName);

    // Insertar los slides actualizados
    final slides = OnboardingSlideModel.getSlidesData();

    for (final slide in slides) {
      await db.insert(_tableName, slide.toMap());
    }
  }

  /// Obtiene todos los slides de onboarding ordenados por orden
  Future<List<OnboardingSlideModel>> getAllSlides() async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'orden ASC',
    );

    return List.generate(maps.length, (i) {
      return OnboardingSlideModel.fromMap(maps[i]);
    });
  }

  /// Obtiene un slide específico por ID
  Future<OnboardingSlideModel?> getSlideById(int id) async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return OnboardingSlideModel.fromMap(maps.first);
    }
    return null;
  }

  /// Inserta un nuevo slide
  Future<int> insertSlide(OnboardingSlideModel slide) async {
    final db = await _database;

    return await db.insert(_tableName, slide.toMap());
  }

  /// Actualiza un slide existente
  Future<int> updateSlide(OnboardingSlideModel slide) async {
    final db = await _database;

    return await db.update(
      _tableName,
      slide.toMap(),
      where: 'id = ?',
      whereArgs: [slide.id],
    );
  }

  /// Elimina un slide por ID
  Future<int> deleteSlide(int id) async {
    final db = await _database;

    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Elimina todos los slides
  Future<int> deleteAllSlides() async {
    final db = await _database;

    return await db.delete(_tableName);
  }

  /// Obtiene el último slide (con botones de acción)
  Future<OnboardingSlideModel?> getLastSlide() async {
    final db = await _database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'es_ultimo_slide = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return OnboardingSlideModel.fromMap(maps.first);
    }
    return null;
  }

  /// Obtiene el total de slides
  Future<int> getSlidesCount() async {
    final db = await _database;

    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return result.first.values.first as int? ?? 0;
  }
}
