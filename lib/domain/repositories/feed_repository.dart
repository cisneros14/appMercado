import '../entities/feed_entity.dart';

/// Repositorio abstracto para operaciones del feed
///
/// Define el contrato para el acceso a datos del feed de propiedades.
/// Sigue el principio de inversión de dependencias de Clean Architecture.
abstract class FeedRepository {
  /// Obtiene la lista del feed con paginación
  ///
  /// [offset] - posición inicial de los elementos
  /// [limit] - cantidad de elementos a obtener
  ///
  /// Retorna una lista de entidades FeedEntity
  /// Puede lanzar excepciones en caso de error
  Future<List<FeedEntity>> getFeed({required int offset, required int limit});
}
