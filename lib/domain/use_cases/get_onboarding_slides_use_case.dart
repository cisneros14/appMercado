import '../entities/onboarding_slide_entity.dart';
import '../repositories/onboarding_repository.dart';

/// Caso de uso para obtener los slides de onboarding.
///
/// Encapsula la lógica de negocio para recuperar y gestionar
/// los slides de bienvenida de la aplicación.
class GetOnboardingSlidesUseCase {
  final OnboardingRepository _repository;

  /// Constructor que recibe el repositorio de onboarding
  GetOnboardingSlidesUseCase({required OnboardingRepository repository})
    : _repository = repository;

  /// Obtiene todos los slides de onboarding
  ///
  /// Inicializa los slides si es necesario antes de retornarlos.
  /// Aplica cualquier lógica de negocio específica.
  Future<List<OnboardingSlideEntity>> call() async {
    try {
      // Siempre inicializar/actualizar los slides para reflejar cambios en el modelo
      await _repository.initializeSlides();

      // Obtener todos los slides
      final slides = await _repository.getAllSlides();

      // Validar que tengamos slides
      if (slides.isEmpty) {
        throw Exception('No se encontraron slides de onboarding');
      }

      // Validar que tengamos exactamente 4 slides
      if (slides.length != 4) {
        throw Exception(
          'Se esperaban 4 slides, se encontraron ${slides.length}',
        );
      }

      // Validar que el último slide esté marcado correctamente
      final lastSlide = slides.last;
      if (!lastSlide.esUltimoSlide) {
        throw Exception('El último slide debe estar marcado como último');
      }

      return slides;
    } catch (e) {
      throw Exception('Error al obtener slides de onboarding: $e');
    }
  }

  /// Obtiene un slide específico por su posición/orden
  ///
  /// [orden] - Posición del slide (1-based)
  Future<OnboardingSlideEntity?> getSlideByOrder(int orden) async {
    try {
      final slides = await call();

      // Buscar slide por orden
      for (final slide in slides) {
        if (slide.orden == orden) {
          return slide;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error al obtener slide por orden: $e');
    }
  }

  /// Obtiene el último slide (con botones de acción)
  Future<OnboardingSlideEntity?> getLastSlide() async {
    try {
      return await _repository.getLastSlide();
    } catch (e) {
      throw Exception('Error al obtener último slide: $e');
    }
  }

  /// Verifica si los slides están inicializados
  Future<bool> areSlidesInitialized() async {
    try {
      final count = await _repository.getSlidesCount();
      return count >= 4;
    } catch (e) {
      return false;
    }
  }

  /// Inicializa los slides de onboarding
  Future<void> initializeSlides() async {
    try {
      await _repository.initializeSlides();
    } catch (e) {
      throw Exception('Error al inicializar slides: $e');
    }
  }

  /// Obtiene el total de slides
  Future<int> getSlidesCount() async {
    try {
      return await _repository.getSlidesCount();
    } catch (e) {
      throw Exception('Error al obtener conteo de slides: $e');
    }
  }
}
