import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

/// Data source remoto para consumo del endpoint de propiedades
/// ubicado en `https://mercadoinmobiliario.ec/admin/apis/propiedades.php`.
///
/// Soporta filtros: q, tipo, operacion, provincia, canton, ciudad,
/// precio_desde, precio_hasta, page, per_page.
class PropiedadRemoteDataSource {
  final Dio _dio;

  PropiedadRemoteDataSource({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.BASE_URL)) {
    // Asegurar baseUrl si se inyecta un Dio externo sin configurarla
    if (_dio.options.baseUrl.isEmpty) {
      _dio.options.baseUrl = ApiConstants.BASE_URL;
    }
  }

  /// Llama al endpoint de listado con filtros.
  Future<Map<String, dynamic>> listarPropiedades({
    String? q,
    int? tipo,
    int? operacion,
    int? provincia,
    int? canton,
    int? ciudad,
    double? precioDesde,
    double? precioHasta,
    int page = 1,
    int perPage = 20,
    bool mine = false,
  }) async {
    final params = <String, dynamic>{
      'action': 'listar',
      'page': page,
      'per_page': perPage,
    };

    if (q != null && q.isNotEmpty) params['q'] = q;
    if (tipo != null) params['tipo'] = tipo;
    if (operacion != null) params['operacion'] = operacion;
    if (provincia != null) params['provincia'] = provincia;
    if (canton != null) params['canton'] = canton;
    if (ciudad != null) params['ciudad'] = ciudad;
    if (precioDesde != null) params['precio_desde'] = precioDesde;
    if (precioHasta != null) params['precio_hasta'] = precioHasta;
    if (mine) params['mine'] = 1;

    final response = await _dio.get(
      'propiedades.php',
      queryParameters: params,
      options: Options(
        headers: ApiConstants.DEFAULT_HEADERS,
        responseType: ResponseType.json,
      ),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    final data = response.data as Map<String, dynamic>;
    final success = data['success'] == true;
    if (!success) {
      throw Exception(data['message'] ?? 'Error al obtener propiedades');
    }

    final result = data['data'] as Map<String, dynamic>;
    return result; // contiene 'propiedades' y 'paginacion'
  }

  /// Obtiene la lista de tipos de inmueble desde la API
  /// Endpoint: propiedades.php?action=tipos
  Future<List<Map<String, dynamic>>> listarTiposInmueble() async {
    final response = await _dio.get(
      'propiedades.php',
      queryParameters: const {'action': 'tipos'},
      options: Options(
        headers: ApiConstants.DEFAULT_HEADERS,
        responseType: ResponseType.json,
      ),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }

    final data = response.data as Map<String, dynamic>;
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Error al obtener tipos de inmueble');
    }

    final List<dynamic> tipos = data['data'] as List<dynamic>;
    return tipos.whereType<Map<String, dynamic>>().toList();
  }
}
