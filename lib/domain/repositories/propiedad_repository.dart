import '../entities/propiedad_entity.dart';

/// Repositorio abstracto para propiedades
///
/// Define el contrato para el acceso a datos de propiedades
/// independiente de la implementación específica.

abstract class PropiedadRepository {
  /// Obtiene todas las propiedades con paginación
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
  });

  /// Obtiene una propiedad por su ID
  Future<PropiedadEntity> obtenerPropiedadPorId(String id);

  /// Crea una nueva propiedad
  Future<PropiedadEntity> crearPropiedad(PropiedadEntity propiedad);

  /// Actualiza una propiedad existente
  Future<PropiedadEntity> actualizarPropiedad(PropiedadEntity propiedad);

  /// Elimina una propiedad
  Future<void> eliminarPropiedad(String id);

  /// Busca propiedades por criterios
  Future<List<PropiedadEntity>> buscarPropiedades(String termino);

  /// Obtiene las propiedades subidas por el corredor logueado
  Future<List<PropiedadEntity>> obtenerMisPropiedades({
    int pagina = 1,
    int limite = 20,
  });

  /// Obtiene propiedades favoritas del usuario
  Future<List<PropiedadEntity>> obtenerPropiedadesFavoritas(String usuarioId);

  /// Marca/desmarca una propiedad como favorita
  Future<void> toggleFavorito(String propiedadId, String usuarioId);
}
