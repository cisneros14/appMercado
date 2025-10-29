import 'package:flutter/material.dart';

/// Widget que muestra indicadores de página para el onboarding.
///
/// Muestra puntos que indican la página actual y el total de páginas,
/// con animaciones suaves entre transiciones.
class OnboardingPageIndicatorWidget extends StatelessWidget {
  /// Índice de la página actual (0-based)
  final int currentIndex;

  /// Total de páginas
  final int totalPages;

  /// Color activo de los indicadores
  final Color? activeColor;

  /// Color inactivo de los indicadores
  final Color? inactiveColor;

  /// Tamaño de los puntos indicadores
  final double size;

  const OnboardingPageIndicatorWidget({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    this.activeColor,
    this.inactiveColor,
    this.size = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final activeIndicatorColor = activeColor ?? Colors.white;
    final inactiveIndicatorColor =
        inactiveColor ?? Colors.white.withOpacity(0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalPages,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            height: size + 2,
            width: currentIndex == index ? (size + 2) * 3 : size + 2,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? activeIndicatorColor
                  : inactiveIndicatorColor,
              borderRadius: BorderRadius.circular((size + 2) / 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para navegación entre slides (botones Anterior/Siguiente)
class OnboardingNavigationWidget extends StatelessWidget {
  /// Índice de la página actual (0-based)
  final int currentIndex;

  /// Total de páginas
  final int totalPages;

  /// Callback cuando se presiona el botón anterior
  final VoidCallback? onPreviousPressed;

  /// Callback cuando se presiona el botón siguiente
  final VoidCallback? onNextPressed;

  /// Callback cuando se presiona el botón omitir
  final VoidCallback? onSkipPressed;

  const OnboardingNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    this.onPreviousPressed,
    this.onNextPressed,
    this.onSkipPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstPage = currentIndex == 0;
    final isLastPage = currentIndex == totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicadores de página (arriba)
          OnboardingPageIndicatorWidget(
            currentIndex: currentIndex,
            totalPages: totalPages,
          ),

          const SizedBox(height: 20),

          // Botones de navegación (abajo)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Anterior o espacio vacío
              SizedBox(
                width: 100,
                child: !isFirstPage
                    ? TextButton(
                        onPressed: onPreviousPressed,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Anterior',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Botón Omitir (centro) si no es la última página
              if (!isLastPage && onSkipPressed != null)
                TextButton(
                  onPressed: onSkipPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Omitir',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

              // Botón Siguiente o espacio vacío
              SizedBox(
                width: 100,
                child: !isLastPage
                    ? TextButton(
                        onPressed: onNextPressed,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Siguiente',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
