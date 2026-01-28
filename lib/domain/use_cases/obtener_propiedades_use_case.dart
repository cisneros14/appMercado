import '../entities/propiedad_entity.dart';
import '../repositories/propiedad_repository.dart';

/// Caso de uso para obtener todas las propiedades
/// 
/// Implementa la lógica de negocio para obtener propiedades
/// con filtros y paginación.

class ObtenerPropiedadesUseCase {
  final PropiedadRepository repository;
  
  const ObtenerPropiedadesUseCase(this.repository);
  
  /// Ejecuta el caso de uso
  Future<List<PropiedadEntity>> call({
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
    // Validaciones de negocio
    if (pagina < 1) {
      throw ArgumentError('La página debe ser mayor a 0');
    }
    
    if (limite < 1 || limite > 100) {
      throw ArgumentError('El límite debe estar entre 1 y 100');
    }
    
    if (precioMin != null && precioMin < 0) {
      throw ArgumentError('El precio mínimo no puede ser negativo');
    }
    
    if (precioMax != null && precioMax < 0) {
      throw ArgumentError('El precio máximo no puede ser negativo');
    }
    
    if (precioMin != null && precioMax != null && precioMin > precioMax) {
      throw ArgumentError('El precio mínimo no puede ser mayor al máximo');
    }
    
    return await repository.obtenerPropiedades(
      pagina: pagina,
      limite: limite,
      searchTerm: searchTerm,
      tipoOperacion: tipoOperacion,
      tipoPropiedad: tipoPropiedad,
      precioMin: precioMin,
      precioMax: precioMax,
      ciudad: ciudad,
      provinciaId: provinciaId,
      cantonId: cantonId,
      ciudadId: ciudadId,
      habitacionesMin: habitacionesMin,
      banosMin: banosMin,
    );
  }
}