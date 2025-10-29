import '../entities/feed_entity.dart';
import '../repositories/feed_repository.dart';

/// Caso de uso para obtener el feed de propiedades
///
/// Encapsula la lógica de negocio para la obtención del feed,
/// incluyendo validaciones y reglas específicas del dominio.
class GetFeedUseCase {
  final FeedRepository _feedRepository;

  GetFeedUseCase({required FeedRepository feedRepository})
    : _feedRepository = feedRepository;

  /// Ejecuta el caso de uso para obtener el feed
  ///
  /// [offset] - posición inicial (debe ser >= 0)
  /// [limit] - cantidad de elementos (debe ser entre 1 y 50)
  ///
  /// Retorna una lista de entidades FeedEntity
  /// Lanza excepción si los parámetros no son válidos
  Future<List<FeedEntity>> execute({int offset = 0, int limit = 10}) async {
    // Validaciones de negocio
    if (offset < 0) {
      throw ArgumentError('El offset debe ser mayor o igual a 0');
    }

    if (limit <= 0 || limit > 50) {
      throw ArgumentError('El límite debe estar entre 1 y 50');
    }

    // Ejecutar la operación
    return await _feedRepository.getFeed(offset: offset, limit: limit);
  }

  /// Obtiene la primera página del feed (para carga inicial)
  Future<List<FeedEntity>> getInitialFeed({int limit = 10}) async {
    return await execute(offset: 0, limit: limit);
  }

  /// Obtiene más elementos del feed (para paginación/scroll infinito)
  Future<List<FeedEntity>> getMoreFeed({
    required int currentCount,
    int limit = 10,
  }) async {
    return await execute(offset: currentCount, limit: limit);
  }

  /// Refresca el feed (obtiene los elementos más recientes)
  Future<List<FeedEntity>> refreshFeed({int limit = 20}) async {
    return await execute(offset: 0, limit: limit);
  }
}
