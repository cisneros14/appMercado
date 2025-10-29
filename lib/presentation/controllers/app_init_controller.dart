import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/data_sources/local/auth_local_datasource.dart';

/// Controlador de inicialización de la aplicación
///
/// Maneja la lógica de navegación inicial basada en:
/// - Si es la primera vez que se abre la app
/// - Si hay una sesión activa guardada
class AppInitController extends GetxController {
  static const String _firstTimeKey = 'is_first_time';

  @override
  void onInit() {
    super.onInit();
    _checkAppState();
  }

  /// Verifica el estado de la app y navega a la ruta correcta
  Future<void> _checkAppState() async {
    try {
      print('🚀 AppInitController - Verificando estado de la app...');

      // Verificar si es la primera vez
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool(_firstTimeKey) ?? true;

      print('📱 Es primera vez: $isFirstTime');

      if (isFirstTime) {
        // Primera vez - ir al onboarding
        print('👋 Primera vez - navegando al onboarding');
        Get.offAllNamed('/onboarding');
        return;
      }

      // No es primera vez - verificar sesión activa
      final authLocalDatasource = AuthLocalDataSource();
      final hasActiveSession = await authLocalDatasource.isLoggedIn();

      print('🔐 Sesión activa: $hasActiveSession');

      if (hasActiveSession) {
        // Tiene sesión activa - ir directo al home
        print('✅ Sesión activa - navegando al home');
        Get.offAllNamed('/home');
      } else {
        // No hay sesión activa - ir al login
        print('🔑 Sin sesión - navegando al login');
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('❌ Error al verificar estado de la app: $e');
      // En caso de error, ir al onboarding por seguridad
      Get.offAllNamed('/onboarding');
    }
  }

  /// Marca que ya no es la primera vez que se abre la app
  Future<void> markFirstTimeComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeKey, false);
      print('✅ Marcado como no primera vez');
    } catch (e) {
      print('❌ Error al marcar primera vez completa: $e');
    }
  }
}
