import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/feed_entity.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_card.dart';
import '../widgets/feed_detail_modal.dart';
import '../../core/theme/app_theme.dart';

/// Pantalla principal del feed de propiedades
/// 
/// Muestra una lista de cards con elementos del feed, permitiendo:
/// - Carga inicial de datos
/// - Pull to refresh
/// - Scroll infinito para paginación
/// - Navegación a detalles mediante modal
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late ScrollController _scrollController;
  final FeedController controller = Get.find<FeedController>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Cargar feed inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadInitialFeed();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Maneja el scroll para cargar más contenido
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreFeed();
    }
  }

  /// Maneja el refresh del feed
  Future<void> _onRefresh() async {
    await controller.refreshFeed();
  }

  /// Maneja el clic en una card del feed
  void _onFeedCardTap(FeedEntity feedItem) {
    FeedDetailModal.show(context, feedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading && controller.feedItems.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.errorMessage != null && controller.feedItems.isEmpty) {
          return _buildErrorState();
        }

        if (controller.feedItems.isEmpty) {
          return _buildEmptyState();
        }

        return _buildFeedList();
      }),
    );
  }

  /// Construye la app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Feed de Propiedades'),
      actions: [
        Obx(() {
          return IconButton(
            onPressed: controller.isRefreshing
                ? null
                : () => controller.refreshFeed(),
            icon: controller.isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Actualizar feed',
          );
        }),
      ],
    );
  }

  /// Construye el estado de carga inicial
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando feed...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado de error
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el feed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'Error desconocido',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el estado vacío
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.feed,
              size: 64,
              color: AppTheme.lightAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay elementos en el feed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Actualiza para ver las últimas propiedades',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => controller.refreshFeed(),
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la lista del feed
  Widget _buildFeedList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: controller.feedItems.length + 
                   (controller.hasMoreData ? 1 : 0) +
                   (controller.errorMessage != null ? 1 : 0),
        itemBuilder: (context, index) {
          // Mostrar cards del feed
          if (index < controller.feedItems.length) {
            final feedItem = controller.feedItems[index];
            return FeedCard(
              feedItem: feedItem,
              onTap: () => _onFeedCardTap(feedItem),
            );
          }

          // Mostrar mensaje de error si existe
          if (controller.errorMessage != null && 
              index == controller.feedItems.length) {
            return _buildInlineError();
          }

          // Mostrar indicador de carga más elementos
          if (controller.hasMoreData) {
            return _buildLoadMoreIndicator();
          }

          // No más elementos
          return _buildNoMoreItemsIndicator();
        },
      ),
    );
  }

  /// Construye el error inline para problemas durante paginación
  Widget _buildInlineError() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error al cargar más elementos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                  ),
                ),
                Text(
                  controller.errorMessage ?? 'Error desconocido',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => controller.loadMoreFeed(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Construye el indicador de carga más elementos
  Widget _buildLoadMoreIndicator() {
    if (controller.isLoadingMore) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Construye el indicador de fin de elementos
  Widget _buildNoMoreItemsIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Has visto todos los elementos',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}