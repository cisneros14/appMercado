import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_init_controller.dart';
import '../../core/theme/app_theme.dart';

/// Página de splash que maneja la lógica de inicialización
///
/// Se muestra brevemente mientras se verifica:
/// - Si es la primera vez que se abre la app
/// - Si hay una sesión activa guardada
/// Luego navega automáticamente a la ruta correcta
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador
    Get.put(AppInitController());

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a2c5b), Color(0xFF2e4170), Color(0xFF405a8a)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo o icono de la app
              Icon(Icons.home_work, size: 80, color: Colors.white),
              SizedBox(height: 24),

              // Nombre de la app
              Text(
                'BIE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),

              // Subtitle
              Text(
                'Asesores Inmobiliarios',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 48),

              // Loading indicator
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
