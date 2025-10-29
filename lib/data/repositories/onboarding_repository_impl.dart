import '../../domain/entities/onboarding_slide_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../data_sources/local/onboarding_local_datasource.dart';
import '../models/onboarding_slide_model.dart';

/// Implementación concreta del repositorio de slides de onboarding.
///
/// Coordina el acceso a datos locales y mapea entre modelos y entidades
/// siguiendo los principios de Clean Architecture.
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDatasource _localDatasource;

  /// Constructor que recibe el data source local
  OnboardingRepositoryImpl({required OnboardingLocalDatasource localDatasource})
    : _localDatasource = localDatasource;

  @override
  Future<List<OnboardingSlideEntity>> getAllSlides() async {
    try {
      final slideModels = await _localDatasource.getAllSlides();
      return slideModels.map(_mapModelToEntity).toList();
    } catch (e) {
      throw Exception('Error al obtener slides de onboarding: $e');
    }
  }

  @override
  Future<OnboardingSlideEntity?> getSlideById(int id) async {
    try {
      final slideModel = await _localDatasource.getSlideById(id);
      return slideModel != null ? _mapModelToEntity(slideModel) : null;
    } catch (e) {
      throw Exception('Error al obtener slide por ID: $e');
    }
  }

  @override
  Future<OnboardingSlideEntity?> getLastSlide() async {
    try {
      final slideModel = await _localDatasource.getLastSlide();
      return slideModel != null ? _mapModelToEntity(slideModel) : null;
    } catch (e) {
      throw Exception('Error al obtener último slide: $e');
    }
  }

  @override
  Future<void> initializeSlides() async {
    try {
      // Forzar actualización de slides para reflejar cambios en el modelo
      await _localDatasource.forceUpdateSlides();
    } catch (e) {
      throw Exception('Error al inicializar slides: $e');
    }
  }

  @override
  Future<int> getSlidesCount() async {
    try {
      return await _localDatasource.getSlidesCount();
    } catch (e) {
      throw Exception('Error al obtener conteo de slides: $e');
    }
  }

  /// Mapea un modelo de slide a una entidad
  OnboardingSlideEntity _mapModelToEntity(OnboardingSlideModel model) {
    return OnboardingSlideEntity(
      id: model.id,
      titulo: model.titulo,
      descripcion: model.descripcion,
      imagenAsset: model.imagenAsset,
      esUltimoSlide: model.esUltimoSlide,
      colorFondo: model.colorFondo,
      orden: model.orden,
    );
  }
}
