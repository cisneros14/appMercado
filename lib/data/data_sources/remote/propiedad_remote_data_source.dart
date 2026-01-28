import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/config/app_config.dart';

/// Data source remoto para consumo del endpoint de propiedades
/// ubicado en `https://mercadoinmobiliario.ec/admin/apis/propiedades.php`.
///
/// Soporta filtros: q, tipo, operacion, provincia, canton, ciudad,
/// precio_desde, precio_hasta, page, per_page.
class PropiedadRemoteDataSource {
  static const String TERRA_API_FILENAME = 'api_sistema_terra.php';
  final Dio _dio;

  PropiedadRemoteDataSource({Dio? dio})
    : _dio = dio ?? AppConfig.createDioClient() {
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
    if (precioDesde != null) params['precio_desde'] = precioDesde;
    if (precioHasta != null) params['precio_hasta'] = precioHasta;
    
    // Enviar explícitamente 0 o 1 para asegurar el scope correcto
    // Si el usuario está logueado, el backend puede filtrar por default si no se especifica.
    params['mine'] = mine ? 1 : 0;

    final response = await _dio.get(
      TERRA_API_FILENAME,
      queryParameters: params,
      options: Options(
        headers: ApiConstants.DEFAULT_HEADERS,
        responseType: ResponseType.plain, // Mantenemos plain para control total
      ),
    );

    return _processResponse(response);
  }

  /// Obtiene el detalle completo de una propiedad, incluyendo galería.
  Future<Map<String, dynamic>> obtenerDetallePropiedad(int id) async {
    final response = await _dio.get(
      TERRA_API_FILENAME,
      queryParameters: {'action': 'detalle', 'id': id},
      options: Options(
        headers: ApiConstants.DEFAULT_HEADERS,
        responseType: ResponseType.plain,
      ),
    );

    return _processResponse(response);
  }

  /// Obtiene la lista de tipos de inmueble desde la API
  Future<List<Map<String, dynamic>>> listarTiposInmueble() async {
    final response = await _dio.get(
      TERRA_API_FILENAME,
      queryParameters: const {'action': 'tipos'},
      options: Options(
        headers: ApiConstants.DEFAULT_HEADERS,
        responseType: ResponseType.plain,
      ),
    );

    final result = await _processResponse(response, isDataList: true);
    if (result is! List) return [];
    return result
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  /// Obtiene la lista de amenidades
  Future<List<Map<String, dynamic>>> listarAmenidades() async {
    final response = await _dio.get(
      TERRA_API_FILENAME,
      queryParameters: const {'action': 'amenidades'},
      options: Options(
        headers: ApiConstants.DEFAULT_HEADERS,
        responseType: ResponseType.plain,
      ),
    );
    final result = await _processResponse(response, isDataList: true);
    if (result is! List) return [];
    return result
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  /// Obtiene localidades (provincias, cantones, parroquias)
  Future<List<Map<String, dynamic>>> listarLocalidades({
    required String tipo,
    String? parent,
  }) async {
    final params = {'action': 'localidades', 'tipo': tipo};
    if (parent != null) params['parent'] = parent;

    final response = await _dio.get(
      TERRA_API_FILENAME, 
      queryParameters: params,
      options: Options(
        headers: ApiConstants.DEFAULT_HEADERS,
        responseType: ResponseType.plain,
      ),
    );
    final result = await _processResponse(response, isDataList: true);
    if (result is! List) return [];
    return result
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }

  /// Crea o edita una propiedad
  Future<Map<String, dynamic>?> guardarPropiedad(Map<String, dynamic> data) async {
    final isEdit = data.containsKey('id') && data['id'] != null;
    final action = isEdit ? 'editar' : 'crear';

    final formData = FormData();
    data.forEach((key, value) {
      if (value is List) {
        for (var item in value) {
          formData.fields.add(MapEntry('${key}[]', item.toString()));
        }
      } else if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    final response = await _dio.post(
      TERRA_API_FILENAME,
      queryParameters: {'action': action},
      data: formData,
      options: Options(responseType: ResponseType.plain),
    );

    return _processResponse(response);
  }

  /// Sube la imagen principal de una propiedad
  Future<Map<String, dynamic>?> subirImagenPrincipal(int id, String filePath) async {
    final formData = FormData.fromMap({
      'id': id,
      'imagen': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      TERRA_API_FILENAME,
      queryParameters: {'action': 'subir_imagen_principal'},
      data: formData,
      options: Options(responseType: ResponseType.plain),
    );

    return _processResponse(response);
  }

  /// Sube múltiples fotos a la galería
  Future<Map<String, dynamic>?> subirGaleria(int id, List<String> filePaths) async {
    final formData = FormData.fromMap({
      'id': id,
    });

    for (var path in filePaths) {
      formData.files.add(
        MapEntry('imagenes[]', await MultipartFile.fromFile(path)),
      );
    }

    final response = await _dio.post(
      TERRA_API_FILENAME,
      queryParameters: {'action': 'subir_galeria'},
      data: formData,
      options: Options(responseType: ResponseType.plain),
    );

    return _processResponse(response);
  }

  /// Helper para procesar respuestas consistentes de la API
  dynamic _processResponse(Response response, {bool isDataList = false}) {
    // Si hay un error (500, 404, etc), intentamos mostrar el cuerpo para diagnosticar
    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! >= 300)) {
      final body = response.data.toString();
      final displayBody = body.length > 200 ? body.substring(0, 200) : body;
      throw Exception('HTTP ${response.statusCode}: $displayBody');
    }

    final data = response.data;
    print('🔍 RAW API RESPONSE: $data');
    final Map<String, dynamic> json;
    
    if (data is Map) {
      json = Map<String, dynamic>.from(data);
    } else if (data is String) {
      // Por si el interceptor no se ejecutó o falló
      final startBrace = data.indexOf('{');
      final startBracket = data.indexOf('[');
      int start = -1;
      if (startBrace != -1 && startBracket != -1) {
        start = startBrace < startBracket ? startBrace : startBracket;
      } else {
        start = startBrace != -1 ? startBrace : startBracket;
      }

      if (start != -1) {
        final sanitized = data.substring(start);
        final decoded = jsonDecode(sanitized);
        if (decoded is List) {
          return decoded; // Caso raro donde la API no sigue el wrapper success/data
        }
        json = decoded is Map ? Map<String, dynamic>.from(decoded) : {};
      } else {
        throw Exception('La respuesta no contiene JSON válido');
      }
    } else {
      throw Exception('Formato de respuesta desconocido: ${data.runtimeType}');
    }
    
    final success = json['success'] == true;
    if (!success) {
      throw Exception(json['message'] ?? 'Error en la petición API');
    }

    return json['data'];
  }
}
