import 'package:get/get.dart';
import '../../data/data_sources/remote/feed_remote_data_source.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../domain/use_cases/get_feed_use_case.dart';
import '../controllers/feed_controller.dart';

/// Configuración de dependencias para el módulo de Feed
///
/// Define la inyección de dependencias siguiendo el patrón de Clean Architecture.
/// Configura todas las dependencias necesarias desde data sources hasta controladores.
class FeedBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 FeedBinding dependencies() - Configurando dependencias...');

    // Data Sources
    Get.lazyPut<FeedRemoteDataSource>(() {
      print('📡 Creando FeedRemoteDataSource...');
      return FeedRemoteDataSourceImpl();
    }, fenix: true);

    // Repositories
    Get.lazyPut<FeedRepository>(() {
      print('🗂️ Creando FeedRepository...');
      return FeedRepositoryImpl(
        remoteDataSource: Get.find<FeedRemoteDataSource>(),
      );
    }, fenix: true);

    // Use Cases
    Get.lazyPut<GetFeedUseCase>(() {
      print('🎯 Creando GetFeedUseCase...');
      return GetFeedUseCase(feedRepository: Get.find<FeedRepository>());
    }, fenix: true);

    // Controllers
    Get.lazyPut<FeedController>(() {
      print('🎮 Creando FeedController...');
      return FeedController(getFeedUseCase: Get.find<GetFeedUseCase>());
    }, fenix: true);

    print('✅ FeedBinding dependencies() - Dependencias configuradas');
  }
}
