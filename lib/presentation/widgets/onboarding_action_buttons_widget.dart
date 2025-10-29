import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Widget que contiene los botones de acción para el último slide de onboarding.
///
/// Proporciona botones para "Iniciar Sesión" y "Registrarse" con estilos
/// consistentes con el tema de la aplicación.
class OnboardingActionButtonsWidget extends StatelessWidget {
  /// Callback cuando se presiona el botón de iniciar sesión
  final VoidCallback onLoginPressed;

  /// Callback cuando se presiona el botón de registrarse
  final VoidCallback onRegisterPressed;

  const OnboardingActionButtonsWidget({
    super.key,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: isSmallScreen ? 16.0 : 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Espaciador adaptativo
          SizedBox(height: isSmallScreen ? 8 : 16),

          // Botón de Iniciar Sesión (principal)
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: ElevatedButton(
              onPressed: () {
                print('🔐 Botón presionado directamente');
                // Intentar navegación directa primero
                try {
                  Get.toNamed('/login');
                  print('✅ Navegación con GetX exitosa');
                } catch (e) {
                  print('❌ Error con GetX: $e');
                  // Fallback al callback original
                  onLoginPressed();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1a2c5b),
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Iniciar Sesión',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1a2c5b),
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 15 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Botón de Registrarse (secundario)
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 48 : 56,
            child: OutlinedButton(
              onPressed: onRegisterPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Registrarse',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 15 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Texto opcional
          Text(
            '¡Impulsa tu negocio inmobiliario hoy!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
