import '../../domain/entities/propiedad_entity.dart';
import '../../domain/repositories/propiedad_repository.dart';
import '../data_sources/remote/propiedad_remote_data_source.dart';

/// Implementación del repositorio de propiedades contra el data source remoto.
class PropiedadRepositoryImpl implements PropiedadRepository {
  final PropiedadRemoteDataSource remoteDataSource;

  PropiedadRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PropiedadEntity>> obtenerPropiedades({
    int pagina = 1,
    int limite = 20,
    String? tipoOperacion,
    String? tipoPropiedad,
    double? precioMin,
    double? precioMax,
    String? ciudad,
    int? provinciaId,
    int? cantonId,
    int? ciudadId,
    int? habitacionesMin,
    int? banosMin,
  }) async {
    // Mapear filtros a los esperados por el endpoint PHP
    final operacionId = _mapOperacionToId(tipoOperacion);
    final tipoId = _parseIntOrNull(tipoPropiedad);
    final ciudadIdParsed = ciudadId ?? _parseIntOrNull(ciudad);

    final raw = await remoteDataSource.listarPropiedades(
      q: null, // búsqueda general se manejará desde UI si se usa
      tipo: tipoId,
      operacion: operacionId,
      provincia: provinciaId,
      canton: cantonId,
      ciudad: ciudadIdParsed,
      precioDesde: precioMin,
      precioHasta: precioMax,
      page: pagina,
      perPage: limite,
    );

    var propiedades = (raw['propiedades'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_mapApiItemToEntity)
        .toList();

    // Filtros adicionales del lado cliente (cuando el endpoint no soporta)
    if (habitacionesMin != null) {
      propiedades = propiedades
          .where((p) => p.habitaciones >= habitacionesMin)
          .toList();
    }
    if (banosMin != null) {
      propiedades = propiedades.where((p) => p.banos >= banosMin).toList();
    }

    return propiedades;
  }

  @override
  Future<PropiedadEntity> obtenerPropiedadPorId(String id) {
    // No requerido por la historia actual
    throw UnimplementedError();
  }

  @override
  Future<PropiedadEntity> crearPropiedad(PropiedadEntity propiedad) {
    throw UnimplementedError();
  }

  @override
  Future<PropiedadEntity> actualizarPropiedad(PropiedadEntity propiedad) {
    throw UnimplementedError();
  }

  @override
  Future<void> eliminarPropiedad(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<PropiedadEntity>> buscarPropiedades(String termino) async {
    final raw = await remoteDataSource.listarPropiedades(q: termino);
    final propiedades = (raw['propiedades'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_mapApiItemToEntity)
        .toList();
    return propiedades;
  }

  @override
  Future<List<PropiedadEntity>> obtenerMisPropiedades({
    int pagina = 1,
    int limite = 20,
  }) async {
    final raw = await remoteDataSource.listarPropiedades(
      page: pagina,
      perPage: limite,
      mine: true,
    );

    final propiedades = (raw['propiedades'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_mapApiItemToEntity)
        .toList();

    return propiedades;
  }

  @override
  Future<List<PropiedadEntity>> obtenerPropiedadesFavoritas(String usuarioId) {
    throw UnimplementedError();
  }

  @override
  Future<void> toggleFavorito(String propiedadId, String usuarioId) {
    throw UnimplementedError();
  }

  // Helpers

  int? _mapOperacionToId(String? operacion) {
    if (operacion == null) return null;
    final op = operacion.toLowerCase();
    if (op == 'venta') return 1;
    if (op == 'alquiler' || op == 'renta') return 2;
    return null;
  }

  // _mapTipoToId removido; ahora interpretamos directamente IDs si vienen como string

  PropiedadEntity _mapApiItemToEntity(Map<String, dynamic> json) {
    final ubicacion = (json['ubicacion'] as Map<String, dynamic>?) ?? const {};
    final provincia =
        (ubicacion['provincia'] as Map<String, dynamic>?) ?? const {};
    final sector = (ubicacion['sector'] as Map<String, dynamic>?) ?? const {};
    final tipo = (json['tipo'] as Map<String, dynamic>?) ?? const {};
    final operacion = (json['operacion'] as Map<String, dynamic>?) ?? const {};

    final imagenPrincipal = _normalizeUrl(
      (json['imagen_principal'] as String?) ?? '',
    );
    final corredor = (json['corredor'] as Map<String, dynamic>?) ?? const {};
    final moneda = (json['moneda'] as String?) ?? '\$';
    final urlDetalle = (json['url_detalle'] as String?) ?? '';

    return PropiedadEntity(
      id: '${json['id']}',
      titulo: (json['modelo'] as String?)?.trim().isNotEmpty == true
          ? json['modelo'] as String
          : 'Propiedad',
      descripcion: json['direccion'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0,
      tipoOperacion: (operacion['nombre'] as String?)?.toLowerCase() ?? '',
      tipoPropiedad: (tipo['nombre'] as String?) ?? '',
      area: (json['area'] as num?)?.toDouble() ?? 0,
      habitaciones:
          (json['habitaciones'] as int?) ?? (json['cuartos'] as int?) ?? 0,
      banos: (json['banios'] as int?) ?? 0,
      direccion: json['direccion'] as String? ?? '',
      ciudad: (sector['nombre'] as String?) ?? '',
      provincia: (provincia['nombre'] as String?) ?? '',
      imagenes: [if (imagenPrincipal.isNotEmpty) imagenPrincipal],
      moneda: moneda,
      corredorId: '${corredor['id'] ?? ''}',
      corredorNombre: (corredor['nombre'] as String?) ?? '',
      corredorImagen: (corredor['imagen'] as String?) ?? '',
      corredorImagenPlaceholder:
          (corredor['imagen_placeholder'] as String?) ?? '',
      urlDetalle: urlDetalle,
      fechaPublicacion: DateTime.now(),
      activa: true,
      propietarioId: null,
    );
  }

  String _normalizeUrl(String url) {
    if (url.isEmpty) return url;
    // Si ya es absoluta
    final parsed = Uri.tryParse(url);
    if (parsed != null && parsed.hasScheme) return url;

    // Valores como '/images/...' o '../../images/...'
    String cleaned = url
        .replaceAll('..', '')
        .replaceAll('///', '/')
        .replaceAll('//', '/');
    if (!cleaned.startsWith('/')) cleaned = '/$cleaned';
    return 'https://mercadoinmobiliario.ec$cleaned';
  }

  int? _parseIntOrNull(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }
}
