import '../entities/onboarding_slide_entity.dart';

/// Repositorio abstracto para manejar operaciones de slides de onboarding.
///
/// Define el contrato que debe implementar cualquier repositorio concreto
/// que maneje los slides de bienvenida de la aplicación.
abstract class OnboardingRepository {
  /// Obtiene todos los slides de onboarding ordenados por orden de presentación
  ///
  /// Lanza excepción si ocurre un error.
  Future<List<OnboardingSlideEntity>> getAllSlides();

  /// Obtiene un slide específico por su ID
  ///
  /// [id] - Identificador único del slide
  ///
  /// Retorna el slide si es encontrado, null si no existe.
  /// Lanza excepción si ocurre un error.
  Future<OnboardingSlideEntity?> getSlideById(int id);

  /// Obtiene el último slide (que contiene los botones de acción)
  ///
  /// Retorna el último slide si es encontrado, null si no existe.
  /// Lanza excepción si ocurre un error.
  Future<OnboardingSlideEntity?> getLastSlide();

  /// Inicializa los slides de onboarding con datos predeterminados
  ///
  /// Se debe llamar una vez para poblar la base de datos con los slides iniciales.
  /// Lanza excepción si ocurre un error.
  Future<void> initializeSlides();

  /// Obtiene el total de slides disponibles
  ///
  /// Lanza excepción si ocurre un error.
  Future<int> getSlidesCount();
}
