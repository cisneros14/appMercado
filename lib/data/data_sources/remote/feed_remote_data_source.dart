import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/feed_model.dart';

/// Data source remoto para operaciones del feed
///
/// Maneja la comunicación con la API de feed de propiedades.
/// Utiliza Dio para realizar peticiones HTTP y maneja errores de red.
abstract class FeedRemoteDataSource {
  /// Obtiene la lista del feed con paginación
  ///
  /// [offset] - posición inicial de los elementos
  /// [limit] - cantidad de elementos a obtener
  Future<List<FeedModel>> getFeed({required int offset, required int limit});
}

/// Implementación concreta del data source remoto del feed
class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final Dio _dio;

  FeedRemoteDataSourceImpl({Dio? dio})
    : _dio = dio ?? AppConfig.createDioClient();

  @override
  Future<List<FeedModel>> getFeed({
    required int offset,
    required int limit,
  }) async {
    try {
      // Preparar datos para la petición POST
      final FormData formData = FormData.fromMap({
        'offset': offset.toString(),
        'limit': limit.toString(),
      });

      // Realizar petición a la API
      final Response response = await _dio.post(
        'feed.php',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      // Verificar respuesta exitosa
      if (response.statusCode != 200) {
        throw ServerException(
          'Error del servidor: ${response.statusCode}',
          response.statusCode.toString(),
        );
      }

      // Verificar estructura de respuesta
      final Map<String, dynamic> responseData = response.data;

      if (responseData['status'] != 'success') {
        throw ServerException(
          responseData['message'] ?? 'Error desconocido del servidor',
          response.statusCode.toString(),
        );
      }

      // Extraer y convertir datos del feed
      final List<dynamic> feedData = responseData['data'] ?? [];

      return feedData
          .map((json) => FeedModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Manejar errores específicos de Dio
      throw _handleDioException(e);
    } catch (e) {
      // Manejar otros errores
      throw ServerException('Error inesperado: ${e.toString()}');
    }
  }

  /// Maneja excepciones específicas de Dio y las convierte a excepciones del dominio
  ServerException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ServerException(
          'Tiempo de conexión agotado. Verifica tu conexión a internet.',
        );

      case DioExceptionType.receiveTimeout:
        return ServerException(
          'Tiempo de respuesta agotado. El servidor está tardando demasiado.',
        );

      case DioExceptionType.connectionError:
        return ServerException(
          'Error de conexión. Verifica tu conexión a internet.',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        String message = 'Error del servidor';

        if (statusCode == 404) {
          message = 'Recurso no encontrado';
        } else if (statusCode == 401) {
          message = 'No autorizado. Inicia sesión nuevamente.';
        } else if (statusCode == 403) {
          message = 'Acceso denegado';
        } else if (statusCode == 500) {
          message = 'Error interno del servidor';
        }

        return ServerException(message, statusCode?.toString());

      case DioExceptionType.cancel:
        return ServerException('Petición cancelada');

      default:
        return ServerException(
          'Error de red: ${e.message}',
          e.response?.statusCode?.toString(),
        );
    }
  }
}
