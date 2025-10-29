import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/app_init_controller.dart';
import '../widgets/onboarding_slide_widget.dart';
import '../widgets/onboarding_page_indicator_widget.dart';
import '../../domain/use_cases/get_onboarding_slides_use_case.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../data/data_sources/local/onboarding_local_datasource.dart';

/// Página principal de onboarding que muestra los slides de bienvenida.
///
/// Presenta una serie de slides informativos sobre la aplicación Terra
/// y proporciona opciones para iniciar sesión o registrarse al final.
class OnboardingPage extends StatefulWidget {
  /// Callback cuando el usuario decide iniciar sesión
  final VoidCallback? onLoginPressed;

  /// Callback cuando el usuario decide registrarse
  final VoidCallback? onRegisterPressed;

  const OnboardingPage({
    super.key,
    this.onLoginPressed,
    this.onRegisterPressed,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  /// Inicializa el controlador con sus dependencias
  void _initializeController() {
    // Inyección de dependencias manual (en una app real se usaría get_it, provider, etc.)
    final localDatasource = OnboardingLocalDatasource();
    final repository = OnboardingRepositoryImpl(
      localDatasource: localDatasource,
    );
    final useCase = GetOnboardingSlidesUseCase(repository: repository);

    _controller = OnboardingController(getSlidesUseCase: useCase);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return _buildBody();
        },
      ),
    );
  }

  /// Construye el cuerpo principal de la página
  Widget _buildBody() {
    switch (_controller.state) {
      case OnboardingState.loading:
        return _buildLoadingState();
      case OnboardingState.error:
        return _buildErrorState();
      case OnboardingState.loaded:
        return _buildLoadedState();
      default:
        return _buildLoadingState();
    }
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1a2c5b)),
          ),
          SizedBox(height: 20),
          Text(
            'Preparando la bienvenida...',
            style: TextStyle(fontSize: 16, color: Color(0xFF1a2c5b)),
          ),
        ],
      ),
    );
  }

  /// Estado de error
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Error al cargar los slides',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _controller.retry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado cargado con los slides
  Widget _buildLoadedState() {
    return Stack(
      children: [
        // PageView con los slides
        PageView.builder(
          controller: _controller.pageController,
          onPageChanged: _controller.onPageChanged,
          itemCount: _controller.slides.length,
          itemBuilder: (context, index) {
            final slide = _controller.slides[index];
            return OnboardingSlideWidget(
              slide: slide,
              onLoginPressed: slide.esUltimoSlide ? _handleLoginPressed : null,
              onRegisterPressed: slide.esUltimoSlide
                  ? _handleRegisterPressed
                  : null,
            );
          },
        ),

        // Botón Omitir en la esquina superior derecha (solo si no es el último slide)
        if (!_controller.isLastSlide)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _controller.skipToEnd,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Omitir',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),

        // Indicadores de página en la parte inferior (solo si no es el último slide)
        if (!_controller.isLastSlide)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Center(
                  child: OnboardingPageIndicatorWidget(
                    currentIndex: _controller.currentIndex,
                    totalPages: _controller.totalSlides,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Maneja la acción de iniciar sesión
  void _handleLoginPressed() async {
    // Marcar que ya no es la primera vez
    try {
      final appInitController = Get.find<AppInitController>();
      await appInitController.markFirstTimeComplete();
    } catch (e) {
      // Si no existe el controlador, crearlo
      final appInitController = Get.put(AppInitController());
      await appInitController.markFirstTimeComplete();
    }

    if (widget.onLoginPressed != null) {
      widget.onLoginPressed!();
    } else {
      // Navegación por defecto a la página de login usando GetX
      Get.toNamed('/login');
    }
  }

  /// Maneja la acción de registrarse
  void _handleRegisterPressed() async {
    // Marcar que ya no es la primera vez
    try {
      final appInitController = Get.find<AppInitController>();
      await appInitController.markFirstTimeComplete();
    } catch (e) {
      // Si no existe el controlador, crearlo
      final appInitController = Get.put(AppInitController());
      await appInitController.markFirstTimeComplete();
    }

    if (widget.onRegisterPressed != null) {
      widget.onRegisterPressed!();
    } else {
      // Navegación por defecto a la página de registro
      Navigator.of(context).pushReplacementNamed('/register');
    }
  }
}
