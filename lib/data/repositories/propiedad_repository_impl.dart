import 'package:collection/collection.dart';
import '../../domain/entities/propiedad_entity.dart';
import '../../domain/repositories/propiedad_repository.dart';
import '../data_sources/remote/propiedad_remote_data_source.dart';
import '../../core/utils/image_utils.dart';

/// Implementación del repositorio de propiedades contra el data source remoto.
class PropiedadRepositoryImpl implements PropiedadRepository {
  final PropiedadRemoteDataSource remoteDataSource;

  PropiedadRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PropiedadEntity>> obtenerPropiedades({
    int pagina = 1,
    int limite = 20,
    String? searchTerm,
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
      q: searchTerm, // Búsqueda en servidor
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

    final dynamic rawPropiedades = raw['propiedades'];
    final List rawList = rawPropiedades is List ? rawPropiedades : [];

    var propiedades = rawList
        .whereType<Map>()
        .map((m) => _mapApiItemToEntity(Map<String, dynamic>.from(m)))
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
  Future<PropiedadEntity> obtenerPropiedadPorId(String id) async {
    var raw = await remoteDataSource.obtenerDetallePropiedad(int.parse(id));
    
    // RESOLUCIÓN DE NOMBRES (Catalogos)
    // El backend devuelve IDs en campos como 'ciudad', 'provincia', 'tipo'.
    // Intentamos resolverlos consultando los catálogos.
    try {
      // 1. Identificar qué necesitamos resolver
      final tipoId = raw['tipo']?.toString();
      final provinciaId = raw['provincia']?.toString();
      final cantonId = raw['ciudad']?.toString() ?? raw['canton']?.toString(); // A veces viene como ciudad o canton
      
      print('🕵️ RESOLVER UBICACIÓN: tipoId=$tipoId, provId=$provinciaId, cantonId=$cantonId');
      
      // 2. Cargar catálogos necesarios en paralelo
      final futures = <Future<List<Map<String, dynamic>>>>[];
      // Siempre cargamos tipos
      futures.add(obtenerTiposInmueble());
      // Siempre cargamos provincias
      futures.add(obtenerLocalidades(tipo: 'provincias'));
      
      final results = await Future.wait(futures);
      final tipos = results[0];
      final provincias = results[1];
      
      // 3. Resolver TIPO
      if (tipoId != null) {
        final tMatch = tipos.firstWhereOrNull((t) => t['id'].toString() == tipoId);
        if (tMatch != null && tMatch['nombre'] != null) {
          raw['tipo'] = {'nombre': tMatch['nombre']}; // Estructura que _mapApiItemToEntity entiende
        }
      }
      
      // 4. Resolver UBICACIÓN
      String nombreProvincia = '';
      String nombreCanton = '';
      
      // Aseguramos que provinciaId sea string limpio
      final provIdStr = provinciaId?.trim();

      if (provIdStr != null && provIdStr.isNotEmpty) {
        final pMatch = provincias.firstWhereOrNull((p) => p['id'].toString() == provIdStr);
        if (pMatch != null) {
          nombreProvincia = pMatch['nombre'] ?? '';
          print('🎯 Match Provincia: $nombreProvincia (ID: $provIdStr)');
          raw['provincia_nombre'] = nombreProvincia;
          
          // Resolver cantón solo si tenemos provincia válida y ID de cantón
          final cantIdStr = cantonId?.trim();
          
          if (cantIdStr != null && cantIdStr.isNotEmpty) {
              try {
                // Importante: pasar el parent tal cual viene (ID '22')
                final cantones = await obtenerLocalidades(tipo: 'cantones', parent: provIdStr);
                print('📦 Cantones cargados para $provIdStr: ${cantones.length}');
                
                final cMatch = cantones.firstWhereOrNull(
                  (c) => c['id'].toString() == cantIdStr
                );
                
                if (cMatch != null) {
                  nombreCanton = cMatch['nombre'] ?? '';
                  print('🎯 Match Cantón: $nombreCanton (ID: $cantIdStr)');
                  raw['ciudad_nombre'] = nombreCanton;
                } else {
                   print('⚠️ No match found for Canton ID $cantIdStr in list.');
                }
              } catch (e) {
                print('❌ Error loading cantones: $e');
              }
          }
        } else {
             print('⚠️ No match found for Provincia ID $provIdStr in list.');
        }
      }
      
    } catch (e) {
      print('⚠️ Error resolviendo catálogos en detalle: $e');
    }

    return _mapApiItemToEntity(raw);
  }

  @override
  Future<PropiedadEntity> crearPropiedad(PropiedadEntity propiedad) async {
    // Para creación completa se recomienda usar un Map directo o extender la entidad.
    // Por ahora implementamos la llamada básica.
    final data = {
      'titulo': propiedad.titulo,
      'descripcion': propiedad.descripcion,
      'precio': propiedad.precio,
      'venta_alquiler': _mapOperacionToId(propiedad.tipoOperacion),
      'tipo': _parseIntOrNull(propiedad.tipoPropiedad),
      'habitaciones': propiedad.habitaciones,
      'banios': propiedad.banos,
      'area': propiedad.area,
      'direccion': propiedad.direccion,
    };

    final res = await remoteDataSource.guardarPropiedad(data);
    if (res == null) throw Exception('La API no devolvió datos al crear la propiedad');
    return _mapApiItemToEntity(res);
  }

  /// Método extendido para el módulo de subida (no está en el contrato base pero es útil internamente)
  Future<PropiedadEntity> subirPropiedadCompleta({
    required Map<String, dynamic> datos,
    String? pathImagenPrincipal,
    List<String>? pathsGaleria,
  }) async {
    // 1. Crear o Editar propiedad
    final res = await remoteDataSource.guardarPropiedad(datos);
    if (res == null) throw Exception('La API no devolvió datos al guardar la propiedad');
    
    // Si es edición, el ID ya lo tenemos. Si es creación, lo tomamos de la respuesta.
    final idStr = datos['id']?.toString() ?? res['id']?.toString() ?? '0';
    final id = int.tryParse(idStr) ?? 0;

    if (id == 0) throw Exception('Error al obtener ID de la propiedad');

    // 2. Subir imagen principal si existe
    if (pathImagenPrincipal != null) {
      await remoteDataSource.subirImagenPrincipal(id, pathImagenPrincipal);
    }

    // 3. Subir galería si existe
    if (pathsGaleria != null && pathsGaleria.isNotEmpty) {
      await remoteDataSource.subirGaleria(id, pathsGaleria);
    }

    // 4. Retornar una entidad mínima con lo que tenemos (o podrías hacer un fetch del detalle)
    return PropiedadEntity(
      id: id.toString(),
      titulo: datos['titulo'] ?? 'Propiedad',
      descripcion: datos['descripcion'] ?? '',
      precio: (datos['precio'] as num?)?.toDouble() ?? 0,
      tipoOperacion: datos['venta_alquiler'] == 2 ? 'renta' : 'venta',
      tipoPropiedad: datos['tipo']?.toString() ?? '',
      area: (datos['area'] as num?)?.toDouble() ?? 0,
      habitaciones: (datos['habitaciones'] as int?) ?? 0,
      banos: (datos['banios'] as int?) ?? 0,
      areaLote: (datos['area_lote'] as num?)?.toDouble() ?? 0,
      niveles: (datos['niveles'] as int?) ?? 0,
      garage: (datos['garage'] as int?) ?? 0,
      antiguedad: datos['antiguedad']?.toString() ?? '',
      video: datos['video']?.toString() ?? '',
      amenidades: (datos['amenidades'] as List?)?.map((e) => e.toString()).toList() ?? [],
      direccion: datos['direccion'] ?? '',
      ciudad: '',
      provincia: '',
      imagenes: [if (pathImagenPrincipal != null) 'file://$pathImagenPrincipal'],
      fechaPublicacion: DateTime.now(),
      activa: true,
    );
  }

  @override
  Future<PropiedadEntity> actualizarPropiedad(PropiedadEntity propiedad) async {
    final data = {
      'id': propiedad.id,
      'titulo': propiedad.titulo,
      'descripcion': propiedad.descripcion,
      'precio': propiedad.precio,
      'venta_alquiler': _mapOperacionToId(propiedad.tipoOperacion),
      'tipo': propiedad.tipoPropiedad,
      'habitaciones': propiedad.habitaciones,
      'banios': propiedad.banos,
      'area': propiedad.area,
      'direccion': propiedad.direccion,
    };
    final res = await remoteDataSource.guardarPropiedad(data);
    if (res == null) throw Exception('La API no devolvió datos al actualizar la propiedad');
    return _mapApiItemToEntity(res);
  }

  @override
  Future<void> eliminarPropiedad(String id) async {
    // Se debería agregar 'eliminarPropiedad' al RemoteDataSource también si no está
    // Por ahora usamos la lógica del endpoint
    // await remoteDataSource.eliminarPropiedad(int.parse(id));
  }

  @override
  Future<List<Map<String, dynamic>>> obtenerTiposInmueble() =>
      remoteDataSource.listarTiposInmueble();

  @override
  Future<List<Map<String, dynamic>>> obtenerAmenidades() =>
      remoteDataSource.listarAmenidades();

  @override
  Future<List<Map<String, dynamic>>> obtenerLocalidades({
    required String tipo,
    String? parent,
  }) => remoteDataSource.listarLocalidades(tipo: tipo, parent: parent);

  @override
  Future<List<PropiedadEntity>> buscarPropiedades(String termino) async {
    final raw = await remoteDataSource.listarPropiedades(q: termino);
    final dynamic rawPropiedades = raw['propiedades'];
    final List rawList = rawPropiedades is List ? rawPropiedades : [];

    final propiedades = rawList
        .whereType<Map>()
        .map((m) => _mapApiItemToEntity(Map<String, dynamic>.from(m)))
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

    final dynamic rawPropiedades = raw['propiedades'];
    final List rawList = rawPropiedades is List ? rawPropiedades : [];

    final propiedades = rawList
        .whereType<Map>()
        .map((m) => _mapApiItemToEntity(Map<String, dynamic>.from(m)))
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
    // Procesamiento Ultra-Robusto de Ubicación
    String nombreProvincia = '';
    String nombreCiudad = '';

    final rawUbicacion = json['ubicacion'];
    if (rawUbicacion is Map) {
      final prov = rawUbicacion['provincia'];
      if (prov is Map) {
        nombreProvincia = prov['nombre']?.toString() ?? '';
      } else {
        nombreProvincia = json['provincia_nombre']?.toString() ?? json['provincia']?.toString() ?? '';
      }

      final sect = rawUbicacion['sector'] ?? rawUbicacion['ciudad'] ?? rawUbicacion['canton'];
      if (sect is Map) {
        nombreCiudad = sect['id']?.toString() ?? sect['nombre']?.toString() ?? '';
      } else {
        nombreCiudad = json['ciudad']?.toString() ?? json['canton']?.toString() ?? json['sector']?.toString() ?? '';
      }
    } else {
      // Formato plano (Listar de api_sistema_terra o propiedades recién creadas)
      print('🔍 _mapApiItemToEntity RAW location: prov=${json['provincia']} city=${json['ciudad']} canton=${json['canton']} prov_nombre=${json['provincia_nombre']} city_nombre=${json['ciudad_nombre']}');

      // PRIORIDAD: Nombre inyectado > Nombre explícito > ID/Valor orginal
      nombreProvincia = json['provincia_nombre']?.toString() ?? 
                       json['provincia']?.toString() ?? '';
                       
      nombreCiudad = json['ciudad_nombre']?.toString() ?? 
                     json['ciudad']?.toString() ?? 
                     json['canton']?.toString() ?? 
                     json['sector']?.toString() ?? '';
                     
      print('✅ _mapApiItemToEntity RESOLVED: $nombreProvincia - $nombreCiudad');
    }

    // Procesamiento de Tipo e Inmueble (tolerante a IDs y Mapas)
    String nombreTipo = '';
    final rawTipo = json['tipo'];
    if (rawTipo is Map) {
      nombreTipo = rawTipo['nombre']?.toString() ?? '';
    } else {
      final tId = rawTipo?.toString();
      // Mapear plurales para coincidir con catálogo: 1->Casas, 2->Departamentos
      nombreTipo = tId == '1' ? 'Casas' : (tId == '2' ? 'Departamentos' : (tId?.isNotEmpty == true ? tId! : 'Propiedad'));
    }

    // Procesamiento de Operación
    String nombreOperacion = '';
    final rawOp = json['operacion'];
    if (rawOp is Map) {
      nombreOperacion = rawOp['nombre']?.toString() ?? '';
    } else {
      final vAlq = json['venta_alquiler']?.toString();
      nombreOperacion = vAlq == '2' ? 'renta' : 'venta';
    }

    final imgPrincipal = (json['img_principal']?.toString()) ?? (json['imagen_principal']?.toString()) ?? '';
    
    // Extraer galería si existe
    final List<String> imagenes = [];
    if (imgPrincipal.isNotEmpty) imagenes.add(imgPrincipal);
    
    final rawGaleria = json['galeria'];
    if (rawGaleria is List) {
      for (var item in rawGaleria) {
        if (item is Map) {
          final url = item['url_imagen']?.toString() ?? '';
          if (url.isNotEmpty) {
            imagenes.add(url);
          }
        }
      }
    }
    
    final rawCorredor = json['corredor'];
    final corredorMap = (rawCorredor is Map) ? Map<String, dynamic>.from(rawCorredor) : <String, dynamic>{};
    
    // Extraer amenidades
    // Extraer amenidades (Manejo robusto de array vacío o null)
    final List<String> amenidades = [];
    final rawAmenities = json['amenidades'];
    
    // Si es una lista, iteramos
    if (rawAmenities is List) {
      for (var item in rawAmenities) {
        if (item is Map) {
          // Priorizar el nombre para visualización directa
          final nombre = item['nombre']?.toString();
          if (nombre != null && nombre.isNotEmpty) {
            amenidades.add(nombre);
          } else {
             // Fallback al ID si no hay nombre
             final id = item['id']?.toString() ?? item['id_amenidad']?.toString();
             if (id != null && id.isNotEmpty) amenidades.add(id);
          }
        } else if (item != null) {
          // Si viene como string directo "1" o "Piscina"
          amenidades.add(item.toString());
        }
      }
    } else if (rawAmenities is Map) {
        // En algunos casos raros podría venir como mapa indexado
        rawAmenities.forEach((k, v) {
            if (v is Map) {
              amenidades.add(v['id']?.toString() ?? '');
            } else {
              amenidades.add(v.toString());
            }
        });
    }

    final moneda = json['moneda']?.toString() ?? '\$';
    final urlDet = json['url_detalle']?.toString() ?? '';

    return PropiedadEntity(
      id: '${json['id_vivienda'] ?? json['id'] ?? '0'}',
      titulo: json['modelo']?.toString() ?? json['titulo']?.toString() ?? 'Propiedad',
      descripcion: json['direccion']?.toString() ?? json['descripcion']?.toString() ?? '',
      precio: double.tryParse(json['precio']?.toString() ?? '0') ?? 0,
      tipoOperacion: nombreOperacion.toLowerCase(),
      tipoPropiedad: nombreTipo,
      area: double.tryParse(json['area']?.toString() ?? '0') ?? 0,
      areaLote: double.tryParse(json['area_lote']?.toString() ?? json['terreno']?.toString() ?? '0') ?? 0,
      habitaciones: int.tryParse(json['habitaciones']?.toString() ?? json['cuartos']?.toString() ?? '0') ?? 0,
      banos: int.tryParse(json['banios']?.toString() ?? '0') ?? 0,
      niveles: int.tryParse(json['niveles']?.toString() ?? '0') ?? 0,
      garage: int.tryParse(json['garage']?.toString() ?? '0') ?? 0,
      antiguedad: json['antiguedad']?.toString() ?? '',
      video: json['enlace_video']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      ciudad: nombreCiudad,
      provincia: nombreProvincia,
      imagenes: imagenes,
      amenidades: amenidades,
      moneda: moneda,
      corredorId: '${corredorMap['id'] ?? json['id_corredor'] ?? ''}',
      corredorNombre: json['corredor_nombre']?.toString() ?? corredorMap['nombre']?.toString() ?? json['nombre_corredor']?.toString() ?? 'Asesor',
      corredorImagen: normalizeImage(json['corredor_img']?.toString() ?? corredorMap['imagen']?.toString() ?? ''),
      corredorImagenPlaceholder: corredorMap['imagen_placeholder']?.toString() ?? '',
      corredorTelefono: json['corredor_telefono']?.toString() ?? corredorMap['telefono']?.toString() ?? '',
      corredorEmail: json['corredor_email']?.toString() ?? corredorMap['email']?.toString() ?? '',
      corredorEmpresa: json['corredor_empresa']?.toString() ?? corredorMap['empresa']?.toString() ?? '',
      corredorCargo: json['corredor_cargo']?.toString() ?? corredorMap['cargo']?.toString() ?? '',
      urlDetalle: urlDet,
      fechaPublicacion: DateTime.tryParse(json['fecha_publicacion']?.toString() ?? '') ?? DateTime.now(),
      activa: json['estado']?.toString() == '1',
      propietarioId: null,
    );
  }



  int? _parseIntOrNull(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }
}
