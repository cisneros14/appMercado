import 'package:flutter/material.dart';
import '../data/data_sources/local/database_service.dart';
import '../data/data_sources/database_helper.dart';

/// Ejemplo de uso básico de SQLite en la aplicación Triara
/// 
/// Esta clase demuestra cómo inicializar y usar la base de datos
/// SQLite siguiendo la arquitectura definida del proyecto.
class DatabaseUsageExample {
  late final DatabaseHelper _databaseHelper;
  
  /// Inicializa el ejemplo con el helper de base de datos
  DatabaseUsageExample() {
    final databaseService = DatabaseServiceImpl();
    _databaseHelper = DatabaseHelper(databaseService);
  }
  
  /// Ejemplo de inicialización de la base de datos
  Future<void> initializeDatabase() async {
    try {
      await _databaseHelper.initialize();
      debugPrint('✅ Base de datos SQLite inicializada correctamente');
      
      // Verificar integridad
      final bool isHealthy = await _databaseHelper.checkIntegrity();
      debugPrint('✅ Integridad de la base de datos: ${isHealthy ? "OK" : "ERROR"}');
      
      // Mostrar estadísticas iniciales
      final stats = await _databaseHelper.getEstadisticas();
      debugPrint('📊 Estadísticas iniciales: $stats');
      
    } catch (e) {
      debugPrint('❌ Error inicializando base de datos: $e');
    }
  }
  
  /// Ejemplo de inserción de propiedades
  Future<void> insertarPropiedadesEjemplo() async {
    try {
      // Datos de ejemplo para propiedades
      final List<Map<String, dynamic>> propiedadesEjemplo = [
        {
          'id': 'prop_001',
          'titulo': 'Casa moderna en el norte de Quito',
          'descripcion': 'Hermosa casa de 3 habitaciones con jardín privado',
          'precio': 180000.0,
          'tipo': 'casa',
          'estado': 'venta',
          'ciudad': 'Quito',
          'direccion': 'Av. República del Salvador y Portugal',
          'area': 150.5,
          'habitaciones': 3,
          'banos': 2,
          'latitud': -0.1807,
          'longitud': -78.4678,
          'imagenes': '["image1.jpg", "image2.jpg", "image3.jpg"]',
          'fecha_creacion': DateTime.now().millisecondsSinceEpoch,
          'activo': 1,
        },
        {
          'id': 'prop_002',
          'titulo': 'Departamento céntrico en Guayaquil',
          'descripcion': 'Departamento de 2 habitaciones con vista al río',
          'precio': 120000.0,
          'tipo': 'departamento',
          'estado': 'venta',
          'ciudad': 'Guayaquil',
          'direccion': 'Malecón 2000, Centro',
          'area': 85.0,
          'habitaciones': 2,
          'banos': 1,
          'latitud': -2.1894,
          'longitud': -79.8890,
          'imagenes': '["depto1.jpg", "depto2.jpg"]',
          'fecha_creacion': DateTime.now().millisecondsSinceEpoch,
          'activo': 1,
        },
        {
          'id': 'prop_003',
          'titulo': 'Local comercial en renta',
          'descripcion': 'Amplio local comercial en zona comercial',
          'precio': 1500.0,
          'tipo': 'local',
          'estado': 'renta',
          'ciudad': 'Cuenca',
          'direccion': 'Calle Larga y Benigno Malo',
          'area': 200.0,
          'habitaciones': 0,
          'banos': 1,
          'latitud': -2.9001,
          'longitud': -79.0059,
          'imagenes': '["local1.jpg"]',
          'fecha_creacion': DateTime.now().millisecondsSinceEpoch,
          'activo': 1,
        },
      ];
      
      // Insertar propiedades en lote
      final bool success = await _databaseHelper.savePropiedades(propiedadesEjemplo);
      
      if (success) {
        debugPrint('✅ ${propiedadesEjemplo.length} propiedades insertadas correctamente');
      } else {
        debugPrint('❌ Error insertando propiedades');
      }
      
    } catch (e) {
      debugPrint('❌ Error en inserción de propiedades: $e');
    }
  }
  
  /// Ejemplo de consultas de propiedades
  Future<void> consultarPropiedadesEjemplo() async {
    try {
      debugPrint('🔍 === EJEMPLOS DE CONSULTAS ===');
      
      // 1. Obtener todas las propiedades
      final todasPropiedades = await _databaseHelper.getPropiedades();
      debugPrint('📋 Total de propiedades: ${todasPropiedades.length}');
      
      // 2. Filtrar por tipo
      final casas = await _databaseHelper.getPropiedades(tipo: 'casa');
      debugPrint('🏠 Casas encontradas: ${casas.length}');
      
      // 3. Filtrar por rango de precio
      final propiedadesCaras = await _databaseHelper.getPropiedades(
        precioMin: 100000.0,
        precioMax: 200000.0,
      );
      debugPrint('💰 Propiedades entre \$100k-\$200k: ${propiedadesCaras.length}');
      
      // 4. Filtrar por ciudad
      final propiedadesQuito = await _databaseHelper.getPropiedades(ciudad: 'Quito');
      debugPrint('🏙️ Propiedades en Quito: ${propiedadesQuito.length}');
      
      // 5. Búsqueda por texto
      final resultadosBusqueda = await _databaseHelper.searchPropiedades('moderna');
      debugPrint('🔎 Búsqueda "moderna": ${resultadosBusqueda.length} resultados');
      
      // 6. Obtener propiedad específica
      final propiedadEspecifica = await _databaseHelper.getPropiedadById('prop_001');
      if (propiedadEspecifica != null) {
        debugPrint('📍 Propiedad encontrada: ${propiedadEspecifica['titulo']}');
      }
      
    } catch (e) {
      debugPrint('❌ Error en consultas: $e');
    }
  }
  
  /// Ejemplo de gestión de usuarios y favoritos
  Future<void> gestionUsuariosYFavoritosEjemplo() async {
    try {
      debugPrint('👤 === GESTIÓN DE USUARIOS Y FAVORITOS ===');
      
      // Crear usuario de ejemplo
      final Map<String, dynamic> usuarioEjemplo = {
        'id': 'user_001',
        'nombre': 'Juan Pérez',
        'email': 'juan.perez@email.com',
        'telefono': '+593987654321',
        'avatar': 'avatar_juan.jpg',
        'fecha_registro': DateTime.now().millisecondsSinceEpoch,
        'activo': 1,
      };
      
      // Guardar usuario
      final bool usuarioGuardado = await _databaseHelper.saveUsuario(usuarioEjemplo);
      debugPrint('✅ Usuario guardado: $usuarioGuardado');
      
      // Agregar favoritos
      await _databaseHelper.addFavorito('user_001', 'prop_001');
      await _databaseHelper.addFavorito('user_001', 'prop_002');
      debugPrint('⭐ Favoritos agregados');
      
      // Verificar si es favorito
      final bool esFavorito = await _databaseHelper.isFavorito('user_001', 'prop_001');
      debugPrint('❤️ ¿Es favorito prop_001?: $esFavorito');
      
      // Obtener favoritos del usuario
      final favoritos = await _databaseHelper.getFavoritosByUsuario('user_001');
      debugPrint('📌 Favoritos del usuario: ${favoritos.length}');
      
      // Conteo de favoritos
      final conteoFavoritos = await _databaseHelper.getFavoritosCount('user_001');
      debugPrint('📊 Total de favoritos: $conteoFavoritos');
      
    } catch (e) {
      debugPrint('❌ Error en gestión de usuarios: $e');
    }
  }
  
  /// Ejemplo de operaciones de mantenimiento
  Future<void> mantenimientoBDEjemplo() async {
    try {
      debugPrint('🔧 === MANTENIMIENTO DE BASE DE DATOS ===');
      
      // Obtener estadísticas finales
      final stats = await _databaseHelper.getEstadisticas();
      debugPrint('📊 Estadísticas: $stats');
      
      // Información de tablas
      final tablas = await _databaseHelper.getTablesInfo();
      debugPrint('📋 Tablas en la base de datos:');
      for (final tabla in tablas) {
        debugPrint('  - ${tabla['name']}');
      }
      
      // Optimizar base de datos
      await _databaseHelper.optimize();
      debugPrint('⚡ Base de datos optimizada');
      
      // Verificar integridad final
      final bool integridadOK = await _databaseHelper.checkIntegrity();
      debugPrint('✔️ Integridad final: ${integridadOK ? "OK" : "ERROR"}');
      
    } catch (e) {
      debugPrint('❌ Error en mantenimiento: $e');
    }
  }
  
  /// Ejecuta todos los ejemplos en secuencia
  Future<void> ejecutarTodosLosEjemplos() async {
    debugPrint('🚀 === INICIANDO EJEMPLOS DE USO DE SQLITE ===');
    
    await initializeDatabase();
    await insertarPropiedadesEjemplo();
    await consultarPropiedadesEjemplo();
    await gestionUsuariosYFavoritosEjemplo();
    await mantenimientoBDEjemplo();
    
    debugPrint('✨ === EJEMPLOS COMPLETADOS ===');
  }
  
  /// Limpia todos los datos de prueba
  Future<void> limpiarDatosPrueba() async {
    try {
      await _databaseHelper.clearAllData();
      debugPrint('🧹 Datos de prueba limpiados');
    } catch (e) {
      debugPrint('❌ Error limpiando datos: $e');
    }
  }
  
  /// Cierra la conexión de la base de datos
  Future<void> cerrarBaseDatos() async {
    try {
      await _databaseHelper.close();
      debugPrint('🔒 Conexión de base de datos cerrada');
    } catch (e) {
      debugPrint('❌ Error cerrando base de datos: $e');
    }
  }
}