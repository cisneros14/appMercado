import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_init_controller.dart';
import '../../core/config/database_config.dart';
import '../../core/utils/network_test_util.dart';
import '../../data/data_sources/local/auth_local_datasource.dart';
import '../../data/data_sources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/use_cases/auth_use_cases.dart';

/// Controlador para la pantalla de login usando GetX.
///
/// Maneja el estado de la interfaz de login, validaciones
/// y comunicación con los casos de uso de autenticación.
class LoginController extends GetxController {
  // Controladores de texto para los campos del formulario
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

  // Clave del formulario para validaciones
  final formKey = GlobalKey<FormState>(debugLabel: 'loginFormKey');

  // Estados reactivos
  final _isLoading = false.obs;
  final _isPasswordVisible = false.obs;
  final _loginError = ''.obs;

  // Casos de uso
  late final LoginUseCase _loginUseCase;
  late final IsLoggedInUseCase _isLoggedInUseCase;

  // Getters para estados reactivos
  bool get isLoading => _isLoading.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  String get loginError => _loginError.value;

  @override
  void onInit() {
    super.onInit();
    _initializeUseCases();
    _checkCurrentSession();
  }

  /// Inicializa los casos de uso con sus dependencias
  void _initializeUseCases() {
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSource(),
      localDataSource: AuthLocalDataSource(),
    );

    _loginUseCase = LoginUseCase(authRepository: authRepository);
    _isLoggedInUseCase = IsLoggedInUseCase(authRepository: authRepository);
  }

  /// Verifica si hay una sesión activa al inicializar
  Future<void> _checkCurrentSession() async {
    try {
      final isLoggedIn = await _isLoggedInUseCase.execute();
      if (isLoggedIn) {
        // Usuario ya está autenticado - marcar como no primera vez y navegar al home
        await _markFirstTimeComplete();
        Get.offAllNamed('/home');
      }
    } catch (e) {
      // Error al verificar sesión, continuar con login
    }
  }

  /// Alterna la visibilidad de la contraseña
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  /// Limpia el error de login
  void clearError() {
    _loginError.value = '';
  }

  /// Valida el campo de nombre de usuario
  String? validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su nombre de usuario o email';
    }

    if (value.trim().length < 3) {
      return 'El nombre de usuario debe tener al menos 3 caracteres';
    }

    return null;
  }

  /// Valida el campo de contraseña
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Método temporal para resetear la base de datos durante desarrollo
  Future<void> resetDatabaseForDevelopment() async {
    try {
      print('🔧 Reseteando base de datos para desarrollo...');
      await DatabaseConfig.resetDatabase();
      Get.snackbar(
        'Desarrollo',
        'Base de datos reseteada exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error reseteando base de datos: $e');
      Get.snackbar(
        'Error',
        'No se pudo resetear la base de datos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Ejecuta el proceso de login
  Future<void> login() async {
    // Limpiar error anterior
    clearError();

    // Validar formulario
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Iniciar estado de carga
    _isLoading.value = true;

    try {
      // Ejecutar caso de uso de login
      final user = await _loginUseCase.execute(
        userName: userNameController.text.trim(),
        password: passwordController.text,
      );

      // Login exitoso - marcar como no primera vez y navegar al home
      await _markFirstTimeComplete();

      Get.snackbar(
        'Bienvenido',
        'Hola ${user.firstName}, ¡bienvenid@!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Navegar al home y limpiar stack de navegación
      Get.offAllNamed('/home');
    } catch (e) {
      // Mostrar error
      _loginError.value = e.toString();

      Get.snackbar(
        'Error de Login',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      // Detener estado de carga
      _isLoading.value = false;
    }
  }

  /// Navega a la pantalla de registro (si existe)
  void goToRegister() {
    Get.toNamed('/register');
  }

  /// Navega a la pantalla de recuperación de contraseña (si existe)
  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  /// Vuelve a la pantalla anterior
  void goBack() {
    Get.back();
  }

  /// Marca la app como no primera vez usando el AppInitController
  Future<void> _markFirstTimeComplete() async {
    try {
      final appInitController = Get.find<AppInitController>();
      await appInitController.markFirstTimeComplete();
    } catch (e) {
      // Si no existe el controlador, crearlo
      final appInitController = Get.put(AppInitController());
      await appInitController.markFirstTimeComplete();
    }
  }

  /// Test de conectividad para debug
  Future<void> testConnectivity() async {
    try {
      Get.snackbar(
        'Prueba de Conectividad',
        'Probando conexión...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      final hasConnectivity = await NetworkTestUtil.testConnectivity();
      final apiWorks = await NetworkTestUtil.testApiEndpoint();

      if (hasConnectivity && apiWorks) {
        Get.snackbar(
          'Conectividad',
          '✅ Conexión exitosa a internet y API',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (hasConnectivity) {
        Get.snackbar(
          'Conectividad',
          '⚠️ Internet OK, pero API no responde',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Conectividad',
          '❌ Sin conexión a internet',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error de Prueba',
        'Error al probar conectividad: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    userNameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
