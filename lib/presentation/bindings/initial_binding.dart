
import 'package:get/get.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/data_sources/remote/auth_remote_datasource.dart';
import '../../data/data_sources/local/auth_local_datasource.dart';
import '../../core/config/app_config.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core / Singletons
    final dio = AppConfig.createDioClient();

    // 2. Data Sources
    final authRemoteDataSource = AuthRemoteDataSource(dio: dio);
    final authLocalDataSource = AuthLocalDataSource();

    // 3. Repositories
    // We register as implementation to match what controllers ask for, 
    // or we could register as interface and have controllers ask for interface.
    // Given the previous error asked for "AuthRepositoryImpl", we put that.
    Get.put(AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    ), permanent: true);
  }
}
