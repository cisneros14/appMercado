import 'package:flutter/material.dart';
import 'presentation/pages/onboarding_page.dart';

/// Ejemplo de uso del sistema de onboarding
///
/// Esta clase demuestra cómo integrar el onboarding en la aplicación principal.
void main() {
  runApp(const TriaraApp());
}

class TriaraApp extends StatelessWidget {
  const TriaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Terra - Tu Hogar Ideal',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF1a2c5b, const <int, Color>{
          50: Color(0xFFe3e7f0),
          100: Color(0xFFb9c4da),
          200: Color(0xFF8b9dc2),
          300: Color(0xFF5d76aa),
          400: Color(0xFF3b5998),
          500: Color(0xFF1a2c5b),
          600: Color(0xFF172753),
          700: Color(0xFF132149),
          800: Color(0xFF0f1b3f),
          900: Color(0xFF081026),
        }),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1a2c5b),
          secondary: Color(0xFF5f7bb0),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const OnboardingPage(
        onLoginPressed: _handleLogin,
        onRegisterPressed: _handleRegister,
      ),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }

  /// Maneja la acción de iniciar sesión
  static void _handleLogin() {
    // En una implementación real, esto navegaría a la página de login
    debugPrint('Usuario eligió iniciar sesión');
  }

  /// Maneja la acción de registrarse
  static void _handleRegister() {
    // En una implementación real, esto navegaría a la página de registro
    debugPrint('Usuario eligió registrarse');
  }
}

/// Página de login placeholder
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64),
            SizedBox(height: 20),
            Text('Página de Login'),
            Text('(Por implementar)'),
          ],
        ),
      ),
    );
  }
}

/// Página de registro placeholder
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrarse')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 64),
            SizedBox(height: 20),
            Text('Página de Registro'),
            Text('(Por implementar)'),
          ],
        ),
      ),
    );
  }
}

/// Página principal placeholder
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terra - Inicio')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64),
            SizedBox(height: 20),
            Text('Página Principal'),
            Text('(Por implementar)'),
          ],
        ),
      ),
    );
  }
}
