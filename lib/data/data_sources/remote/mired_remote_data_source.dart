import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/config/app_config.dart';
import '../local/auth_local_datasource.dart';

/// Remote data source para la funcionalidad "Mi Red".
class MiRedRemoteDataSource {
  final Dio _dio;

  MiRedRemoteDataSource({Dio? dio})
    : _dio = dio ?? AppConfig.createDioClient();

  /// Helper que intenta primero `mired.php` y ante un 404 intenta `apiMiredRef.php`.
  Future<Response> _getWithFallback(
    String endpointName,
    Map<String, dynamic> params,
  ) async {
    final Map<String, dynamic> query = <String, dynamic>{
      'endpoint': endpointName,
    };
    query.addAll(params);
    try {
      final resp = await _dio.get(
        'mired.php',
        queryParameters: query,
        options: Options(headers: ApiConstants.DEFAULT_HEADERS),
      );
      developer.log(
        'MiRedRemoteDataSource._getWithFallback -> url=${resp.requestOptions.uri}',
        name: 'MiRedRemoteDataSource',
      );
      return resp;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      developer.log(
        'MiRedRemoteDataSource._getWithFallback -> error mired.php status=$status',
        name: 'MiRedRemoteDataSource',
      );
      if (status == 404) {
        // Intentar con el nombre alternativo usado en el entorno local
        developer.log(
          'MiRedRemoteDataSource._getWithFallback -> intentando apiMiredRef.php como fallback',
          name: 'MiRedRemoteDataSource',
        );
        final resp2 = await _dio.get(
          'apiMiredRef.php',
          queryParameters: query,
          options: Options(headers: ApiConstants.DEFAULT_HEADERS),
        );
        developer.log(
          'MiRedRemoteDataSource._getWithFallback -> url=${resp2.requestOptions.uri}',
          name: 'MiRedRemoteDataSource',
        );
        return resp2;
      }
      rethrow;
    }
  }

  /// Extrae una lista de la respuesta tolerando diferentes formas.
  /// Busca claves conocidas y, si no encuentra, toma la primera clave cuyo valor sea una lista.
  List<Map<String, dynamic>> _extractListFromResponse(
    dynamic raw,
    List<String> candidates,
  ) {
    try {
      if (raw is List) {
        return List<Map<String, dynamic>>.from(List.from(raw));
      }
      if (raw is Map<String, dynamic>) {
        // Priorizar claves candidatas
        for (final k in candidates) {
          if (raw.containsKey(k) && raw[k] is List) {
            return List<Map<String, dynamic>>.from(List.from(raw[k]));
          }
        }
        // Tomar la primera clave que sea lista
        for (final entry in raw.entries) {
          if (entry.value is List) {
            return List<Map<String, dynamic>>.from(List.from(entry.value));
          }
        }
      }
    } catch (e) {
      developer.log(
        'MiRedRemoteDataSource._extractListFromResponse -> error parse: $e',
        name: 'MiRedRemoteDataSource',
      );
    }
    return <Map<String, dynamic>>[];
  }

  Future<int> _getCurrentUserId() async {
    final authLocal = AuthLocalDataSource();
    final user = await authLocal.getCurrentUser();
    if (user == null) {
      throw Exception('No hay usuario en sesión');
    }
    return user.userId;
  }

  /// Obtiene la lista de contactos del usuario logueado.
  Future<List<Map<String, dynamic>>> getContactos() async {
    final userId = await _getCurrentUserId();
    developer.log(
      'MiRedRemoteDataSource.getContactos -> user_id=$userId',
      name: 'MiRedRemoteDataSource',
    );
    final resp = await _getWithFallback('contactos', {'user_id': userId});

    developer.log(
      'MiRedRemoteDataSource.getContactos -> status=${resp.statusCode}',
      name: 'MiRedRemoteDataSource',
    );
    developer.log(
      'MiRedRemoteDataSource.getContactos -> body=${resp.data}',
      name: 'MiRedRemoteDataSource',
    );

    if (resp.statusCode == 200) {
      final raw = resp.data;
      // Soportar varias formas de respuesta: {'success':true,'contactos':[...]}, {'data': [...]}, o una lista directa
      return _extractListFromResponse(raw, ['contactos', 'data', 'results']);
    }
    throw Exception('Error al obtener contactos (status ${resp.statusCode})');
  }

  /// Busca agentes (excluye contactos existentes). [busqueda] es opcional.
  Future<List<Map<String, dynamic>>> buscarAgentes({String? busqueda}) async {
    final userId = await _getCurrentUserId();
    final params = {'endpoint': 'agentes', 'user_id': userId};
    if (busqueda != null && busqueda.isNotEmpty) params['busqueda'] = busqueda;
    developer.log(
      'MiRedRemoteDataSource.buscarAgentes -> user_id=$userId params=$params',
      name: 'MiRedRemoteDataSource',
    );
    final resp = await _getWithFallback('agentes', {
      'user_id': userId,
      if (busqueda != null) 'busqueda': busqueda,
    });

    developer.log(
      'MiRedRemoteDataSource.buscarAgentes -> status=${resp.statusCode}',
      name: 'MiRedRemoteDataSource',
    );
    developer.log(
      'MiRedRemoteDataSource.buscarAgentes -> body=${resp.data}',
      name: 'MiRedRemoteDataSource',
    );

    if (resp.statusCode == 200) {
      final raw = resp.data;
      return _extractListFromResponse(raw, ['agentes', 'data', 'results']);
    }
    throw Exception('Error al buscar agentes (status ${resp.statusCode})');
  }

  /// Obtiene las invitaciones recibidas para el usuario logueado.
  Future<List<Map<String, dynamic>>> getInvitaciones() async {
    final userId = await _getCurrentUserId();
    developer.log(
      'MiRedRemoteDataSource.getInvitaciones -> user_id=$userId',
      name: 'MiRedRemoteDataSource',
    );
    final resp = await _getWithFallback('invitaciones', {'user_id': userId});

    developer.log(
      'MiRedRemoteDataSource.getInvitaciones -> status=${resp.statusCode}',
      name: 'MiRedRemoteDataSource',
    );
    developer.log(
      'MiRedRemoteDataSource.getInvitaciones -> body=${resp.data}',
      name: 'MiRedRemoteDataSource',
    );

    if (resp.statusCode == 200) {
      final raw = resp.data;
      return _extractListFromResponse(raw, ['invitaciones', 'data', 'results']);
    }
    throw Exception(
      'Error al obtener invitaciones (status ${resp.statusCode})',
    );
  }
}
