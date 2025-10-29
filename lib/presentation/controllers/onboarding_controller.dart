import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_slide_entity.dart';
import '../../domain/use_cases/get_onboarding_slides_use_case.dart';

/// Estados posibles del onboarding
enum OnboardingState { initial, loading, loaded, error }

/// Controlador MVVM para manejar el estado del onboarding.
///
/// Gestiona la navegación entre slides, carga de datos y estado de la UI
/// siguiendo el patrón MVVM con ChangeNotifier.
class OnboardingController extends ChangeNotifier {
  final GetOnboardingSlidesUseCase _getSlidesUseCase;

  /// Constructor que recibe el caso de uso
  OnboardingController({required GetOnboardingSlidesUseCase getSlidesUseCase})
    : _getSlidesUseCase = getSlidesUseCase;

  // Estado privado
  OnboardingState _state = OnboardingState.initial;
  List<OnboardingSlideEntity> _slides = [];
  int _currentIndex = 0;
  String? _errorMessage;

  // PageController para manejar el PageView
  late PageController _pageController;

  // Getters públicos
  OnboardingState get state => _state;
  List<OnboardingSlideEntity> get slides => _slides;
  int get currentIndex => _currentIndex;
  String? get errorMessage => _errorMessage;
  PageController get pageController => _pageController;

  /// Slide actual
  OnboardingSlideEntity? get currentSlide {
    if (_slides.isEmpty || _currentIndex >= _slides.length) {
      return null;
    }
    return _slides[_currentIndex];
  }

  /// Indica si es el primer slide
  bool get isFirstSlide => _currentIndex == 0;

  /// Indica si es el último slide
  bool get isLastSlide => _currentIndex == _slides.length - 1;

  /// Total de slides
  int get totalSlides => _slides.length;

  /// Inicializa el controlador
  void initialize() {
    _pageController = PageController(initialPage: 0);
    loadSlides();
  }

  /// Libera recursos
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Carga los slides de onboarding
  Future<void> loadSlides() async {
    try {
      _setState(OnboardingState.loading);

      final slides = await _getSlidesUseCase.call();

      _slides = slides;
      _currentIndex = 0;
      _errorMessage = null;

      _setState(OnboardingState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(OnboardingState.error);
    }
  }

  /// Navega al siguiente slide
  void nextSlide() {
    if (_currentIndex < _slides.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  /// Navega al slide anterior
  void previousSlide() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  /// Navega a un slide específico
  void goToSlide(int index) {
    if (index >= 0 && index < _slides.length) {
      _currentIndex = index;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  /// Salta al último slide
  void skipToEnd() {
    if (_slides.isNotEmpty) {
      _currentIndex = _slides.length - 1;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  /// Maneja el cambio de página del PageView
  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  /// Reintenta cargar los slides en caso de error
  Future<void> retry() async {
    await loadSlides();
  }

  /// Reinicia el onboarding al primer slide
  void reset() {
    _currentIndex = 0;
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  /// Actualiza el estado interno
  void _setState(OnboardingState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Verifica si los slides están cargados
  bool get isLoaded => _state == OnboardingState.loaded && _slides.isNotEmpty;

  /// Verifica si está cargando
  bool get isLoading => _state == OnboardingState.loading;

  /// Verifica si hay error
  bool get hasError => _state == OnboardingState.error;

  /// Obtiene el progreso actual (0.0 - 1.0)
  double get progress {
    if (_slides.isEmpty) return 0.0;
    return (_currentIndex + 1) / _slides.length;
  }
}
