import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_slide_entity.dart';

/// Widget reutilizable para mostrar un slide de onboarding.
///
/// Renderiza el contenido de un slide individual incluyendo imagen,
/// título, descripción y maneja diferentes colores de fondo.
class OnboardingSlideWidget extends StatelessWidget {
  /// El slide a mostrar
  final OnboardingSlideEntity slide;

  /// Callback opcional cuando se presiona el área del slide
  final VoidCallback? onTap;

  /// Callback para el botón de login (solo último slide)
  final VoidCallback? onLoginPressed;

  /// Callback para el botón de registro (solo último slide)
  final VoidCallback? onRegisterPressed;

  const OnboardingSlideWidget({
    super.key,
    required this.slide,
    this.onTap,
    this.onLoginPressed,
    this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _hexToColor(slide.colorFondo),
              _hexToColor(slide.colorFondo).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                // Espaciador superior
                const SizedBox(height: 60),

                // Imagen del slide con altura ajustada
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                      (slide.esUltimoSlide ? 0.25 : 0.35),
                  child: _buildImage(),
                ),

                SizedBox(height: slide.esUltimoSlide ? 24 : 40),

                // Contenido de texto con mejor espaciado
                Expanded(
                  child: Column(
                    children: [
                      // Título con mejor tipografía
                      if (slide.orden != 4)
                        Text(
                          slide.titulo,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: slide.esUltimoSlide ? 28 : 32,
                                height: 1.2,
                              ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),

                      SizedBox(height: slide.esUltimoSlide ? 16 : 24),

                      // Descripción con mejor legibilidad
                      if (slide.orden != 4)
                        Text(
                          slide.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: slide.esUltimoSlide ? 16 : 18,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),

                      // Espaciador flexible para separar texto de botones
                      if (slide.esUltimoSlide) const SizedBox(height: 32),

                      // Botones de acción si es el último slide
                      if (slide.esUltimoSlide &&
                          onLoginPressed != null &&
                          onRegisterPressed != null)
                        _buildActionButtons(context),

                      // Espaciador para slides normales
                      if (!slide.esUltimoSlide) const Spacer(),
                    ],
                  ),
                ),

                // Espaciador inferior
                SizedBox(height: slide.esUltimoSlide ? 40 : 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la imagen del slide con fallback
  Widget _buildImage() {
    return Container(width: double.infinity, child: _buildImageContent());
  }

  /// Construye el contenido específico de la imagen
  Widget _buildImageContent() {
    // Para el primer slide, mostrar el logo
    if (slide.orden == 1 || slide.orden == 4) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback al icono si el logo no se encuentra
            return _buildIconFallback();
          },
        ),
      );
    }

    // Para otros slides, mostrar la imagen del slide
    return Container(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        slide.imagenAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildIconFallback();
        },
      ),
    );
  }

  /// Construye el widget de fallback con icono
  Widget _buildIconFallback() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Icon(
        _getIconForSlide(),
        size: 100,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  /// Obtiene un icono apropiado basado en el orden del slide
  IconData _getIconForSlide() {
    switch (slide.orden) {
      case 1:
        return Icons.home;
      case 2:
        return Icons.search;
      case 3:
        return Icons.people;
      case 4:
        return Icons.rocket_launch;
      default:
        return Icons.info;
    }
  }

  /// Convierte un string hexadecimal a Color
  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      // Color por defecto si hay error en el parsing
      return const Color(0xFF1a2c5b);
    }
  }

  /// Construye los botones de acción para el último slide
  Widget _buildActionButtons(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón de Iniciar Sesión (principal)
        SizedBox(
          width: double.infinity,
          height: isSmallScreen ? 44 : 50,
          child: ElevatedButton(
            onPressed: onLoginPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1a2c5b),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: const Color(0xFF1a2c5b),
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 14 : 15,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 10 : 12),

        // Botón de Registrarse (secundario)
        SizedBox(
          width: double.infinity,
          height: isSmallScreen ? 44 : 50,
          child: OutlinedButton(
            onPressed: onRegisterPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Registrarse',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 14 : 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
