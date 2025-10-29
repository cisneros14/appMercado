import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_card.dart';
import '../widgets/feed_detail_modal.dart';
import '../bindings/feed_binding.dart';
import '../../domain/entities/feed_entity.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/data_sources/remote/auth_remote_datasource.dart';
import '../../data/data_sources/local/auth_local_datasource.dart';

/// Página de inicio con feed de propiedades.
///
/// Página principal después del login exitoso.
/// Muestra cards del feed y menú en bottom sheet.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏠 HomePage build() - Inicializando...');

    // Método alternativo: Inicializar directamente si no existe
    late FeedController feedController;

    try {
      feedController = Get.find<FeedController>();
      print('✅ FeedController ya existe');
    } catch (e) {
      print('⚠️ FeedController no encontrado, inicializando dependencias...');
      FeedBinding().dependencies();
      feedController = Get.find<FeedController>();
      print('✅ FeedController creado');
    }

    print(
      '📊 FeedController estado - feedItems: ${feedController.feedItems.length}, isLoading: ${feedController.isLoading}',
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'BIE - Propiedades',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1a2c5b),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _showMenuBottomSheet(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _performLogout(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a2c5b), Color(0xFF2e4170)],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (feedController.isLoading && feedController.feedItems.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (feedController.errorMessage != null &&
                feedController.feedItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feedController.errorMessage!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => feedController.loadInitialFeed(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1a2c5b),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (feedController.feedItems.isEmpty) {
              return const Center(
                child: Text(
                  'No hay propiedades disponibles',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => feedController.refreshFeed(),
              color: const Color(0xFF1a2c5b),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount:
                    feedController.feedItems.length +
                    (feedController.hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == feedController.feedItems.length) {
                    // Cargar más datos
                    if (feedController.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Trigger para cargar más
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        feedController.loadMoreFeed();
                      });
                      return const SizedBox.shrink();
                    }
                  }

                  final feed = feedController.feedItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FeedCard(
                      feedItem: feed,
                      onTap: () => _showFeedDetail(context, feed),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Realiza el proceso completo de logout: logout remoto opcional, limpieza local
  /// y navegación a onboarding.
  Future<void> _performLogout(BuildContext context) async {
    try {
      // Mostrar indicador temporal
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final authRepository = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSource(),
        localDataSource: AuthLocalDataSource(),
      );

      await authRepository.logout();

      // Cerrar dialogo de progreso
      if (Get.isDialogOpen ?? false) Get.back();

      // Navegar a onboarding limpiando el stack
      Get.offAllNamed('/onboarding');
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      // Aun en error, intentar navegar y notificar
      Get.offAllNamed('/onboarding');
      Get.snackbar(
        'Error',
        'Ocurrió un error cerrando sesión: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Muestra el bottom sheet con el menú de opciones
  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del bottom sheet
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Menú Principal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a2c5b),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Opciones del menú
                _buildMenuOption(
                  icon: Icons.home_work,
                  title: 'Gestión de Propiedades',
                  description: 'Administra tu portafolio de propiedades',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/gestion-propiedades');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.search,
                  title: 'Buscar propiedades',
                  description: 'Explora y filtra propiedades disponibles',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/buscar-propiedades');
                  },
                ),
                _buildMenuOption(
                  icon: Icons.group,
                  title: 'Mi Red',
                  description: 'Contactos, agentes e invitaciones',
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/mi-red');
                  },
                ),

                const SizedBox(height: 16),

                // Botón de cerrar sesión
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Cerrar el bottom sheet primero
                      Navigator.pop(context);
                      await _performLogout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a2c5b),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Muestra el modal con el detalle completo del feed
  void _showFeedDetail(BuildContext context, FeedEntity feed) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FeedDetailModal(feedItem: feed),
    );
  }

  /// Widget para las opciones del menú en el bottom sheet
  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a2c5b).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1a2c5b).withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1a2c5b),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a2c5b),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF1a2c5b),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
