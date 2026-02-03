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
        color: Colors.white, // Fondo blanco solicitado
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                // Espaciador superior
                const SizedBox(height: 40),

                // Imagen del slide con altura ajustada
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: _buildImage(),
                ),

                const SizedBox(height: 40),

                // Contenido de texto
                Expanded(
                  child: Column(
                    children: [

                      // Título
                      Text(
                        slide.titulo,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: const Color(0xFF1a2c5b), // Azul corporativo
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              height: 1.2,
                            ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),

                      SizedBox(height: slide.esUltimoSlide ? 16 : 24),

                      // Descripción
                      Text(
                        slide.descripcion,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(
                              color: const Color(0xFF1a2c5b).withOpacity(0.8),
                              fontSize: 16,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),

                      // Espaciador flexible
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
                SizedBox(height: slide.esUltimoSlide ? 20 : 60),
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
    // Para el primer slide o el último (bienvenida/login), mostrar el logo
    if (slide.orden == 1 || slide.orden == 4) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a2c5b), // Fondo azul
            borderRadius: BorderRadius.circular(30), // Bordes redondeados
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildIconFallback();
            },
          ),
        ),
      );
    }

    // Para otros slides, mostrar la imagen del slide (sin fondo azul, o como se desee)
    // El usuario pidió logo con fondo azul. Las otras imágenes (vectoriales/ilustraciones)
    // probablemente se vean bien sobre blanco.
    return Container(
      padding: const EdgeInsets.all(20),
      child: Image.asset(
        slide.imagenAsset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildIconFallback(); // Fallback genérico
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
        color: const Color(0xFF1a2c5b).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(
        _getIconForSlide(),
        size: 100,
        color: const Color(0xFF1a2c5b),
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

  Color _hexToColor(String hexString) {
    // Implementación original por si se necesita, aunque ya no usamos el gradiente del slide
     try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF1a2c5b);
    }
  }

  /// Construye los botones de acción para el último slide
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón de Iniciar Sesión (principal)
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: onLoginPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1a2c5b), // Azul
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF1a2c5b).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Botón de Registrarse (secundario)
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: onRegisterPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1a2c5b),
              side: const BorderSide(color: Color(0xFF1a2c5b), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
            ),
            child: const Text(
              'Registrarse',
              style: TextStyle(
                color: Color(0xFF1a2c5b),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
