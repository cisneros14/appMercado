import '../../domain/entities/feed_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../data_sources/remote/feed_remote_data_source.dart';

/// Implementación concreta del repositorio de feed
///
/// Coordina la obtención de datos desde fuentes remotas y maneja
/// el mapeo entre modelos de datos y entidades del dominio.
class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _remoteDataSource;

  FeedRepositoryImpl({required FeedRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<FeedEntity>> getFeed({
    required int offset,
    required int limit,
  }) async {
    try {
      // Obtener datos desde la fuente remota
      final feedModels = await _remoteDataSource.getFeed(
        offset: offset,
        limit: limit,
      );

      // Mapear modelos a entidades del dominio
      return feedModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Re-lanzar la excepción para que sea manejada por capas superiores
      rethrow;
    }
  }
}
