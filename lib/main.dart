import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/buscar_propiedades_page.dart';
import 'presentation/pages/gestion_propiedades_page.dart';
import 'presentation/pages/propiedad_detalle_page_v2.dart';
import 'presentation/pages/mi_red_page.dart';
import 'presentation/bindings/feed_binding.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const TriaraApp());
}

class TriaraApp extends StatelessWidget {
  const TriaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BIE - Asesores Inmobiliarios',
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(
          name: '/onboarding',
          page: () => OnboardingPage(
            onLoginPressed: () {
              print('🔐 Navegando a login...');
              Get.toNamed('/login');
            },
            onRegisterPressed: () {
              Get.snackbar(
                'Registro',
                'La función de registro estará disponible próximamente',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                icon: const Icon(Icons.info, color: Colors.white),
              );
            },
          ),
        ),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(
          name: '/home',
          page: () => const HomePage(),
          binding: FeedBinding(),
        ),
        GetPage(
          name: '/buscar-propiedades',
          page: () => const BuscarPropiedadesPage(),
        ),
        GetPage(
          name: '/gestion-propiedades',
          page: () => const GestionPropiedadesPage(),
        ),
        GetPage(name: '/mi-red', page: () => const MiRedPage()),
        GetPage(
          name: '/propiedad-detalle',
          page: () => const PropiedadDetallePageV2(),
        ),
      ],
    );
  }
}
