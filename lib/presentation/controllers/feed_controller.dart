import 'package:get/get.dart';
import '../../domain/entities/feed_entity.dart';
import '../../domain/use_cases/get_feed_use_case.dart';
import '../../core/errors/exceptions.dart';

/// Controlador para la gestión del estado del feed usando GetX
///
/// Maneja el estado reactivo del feed usando GetX para notificar
/// cambios en el estado a la interfaz de usuario.
class FeedController extends GetxController {
  final GetFeedUseCase _getFeedUseCase;

  FeedController({required GetFeedUseCase getFeedUseCase})
    : _getFeedUseCase = getFeedUseCase;

  @override
  void onInit() {
    super.onInit();
    print('🎯 FeedController onInit() - Iniciando carga del feed...');
    // Cargar feed inicial automáticamente
    loadInitialFeed();
  }

  // Estado del feed
  final RxList<FeedEntity> _feedItems = <FeedEntity>[].obs;
  List<FeedEntity> get feedItems => _feedItems;

  // Estados de carga
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxBool _isLoadingMore = false.obs;
  bool get isLoadingMore => _isLoadingMore.value;

  final RxBool _isRefreshing = false.obs;
  bool get isRefreshing => _isRefreshing.value;

  // Estado de error
  final RxnString _errorMessage = RxnString();
  String? get errorMessage => _errorMessage.value;

  // Paginación
  static const int _pageSize = 10;
  final RxBool _hasMoreData = true.obs;
  bool get hasMoreData => _hasMoreData.value;

  /// Carga inicial del feed
  Future<void> loadInitialFeed() async {
    print('📡 FeedController loadInitialFeed() - Iniciando...');
    if (_isLoading.value) {
      print('⚠️ Ya está cargando, saltando...');
      return;
    }

    _setLoading(true);
    _clearError();
    print('🔄 Estado de carga activado');

    try {
      print('🌐 Llamando al caso de uso...');
      final feedItems = await _getFeedUseCase.getInitialFeed(limit: _pageSize);

      print('✅ Recibidos ${feedItems.length} elementos del feed');
      _feedItems.value = feedItems;
      _hasMoreData.value = feedItems.length >= _pageSize;
      print('📱 Feed actualizado en la UI');
    } on AppException catch (e) {
      print('❌ AppException: ${e.message}');
      _setError('Error al cargar el feed: ${e.message}');
    } catch (e) {
      print('❌ Error general: $e');
      _setError('Error inesperado al cargar el feed');
    } finally {
      _setLoading(false);
      print('🏁 Carga finalizada. Total items: ${_feedItems.length}');
    }
  }

  /// Carga más elementos del feed (scroll infinito)
  Future<void> loadMoreFeed() async {
    if (_isLoadingMore.value || !_hasMoreData.value || _isLoading.value) return;

    _setLoadingMore(true);
    _clearError();

    try {
      final moreFeedItems = await _getFeedUseCase.getMoreFeed(
        currentCount: _feedItems.length,
        limit: _pageSize,
      );

      if (moreFeedItems.isNotEmpty) {
        _feedItems.addAll(moreFeedItems);
        _hasMoreData.value = moreFeedItems.length >= _pageSize;
      } else {
        _hasMoreData.value = false;
      }
    } on AppException catch (e) {
      _setError('Error al cargar más elementos: ${e.message}');
    } catch (e) {
      _setError('Error inesperado al cargar más elementos');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Refresca el feed (pull to refresh)
  Future<void> refreshFeed() async {
    if (_isRefreshing.value) return;

    _setRefreshing(true);
    _clearError();

    try {
      final refreshedFeedItems = await _getFeedUseCase.refreshFeed(
        limit: _pageSize * 2,
      );

      _feedItems.value = refreshedFeedItems;
      _hasMoreData.value = refreshedFeedItems.length >= _pageSize;
    } on AppException catch (e) {
      _setError('Error al actualizar el feed: ${e.message}');
    } catch (e) {
      _setError('Error inesperado al actualizar el feed');
    } finally {
      _setRefreshing(false);
    }
  }

  /// Reintenta la operación en caso de error
  Future<void> retry() async {
    if (_feedItems.isEmpty) {
      await loadInitialFeed();
    } else {
      await refreshFeed();
    }
  }

  /// Busca un elemento del feed por ID de vivienda
  FeedEntity? findFeedItemById(String idVivienda) {
    try {
      return _feedItems.firstWhere((item) => item.idVivienda == idVivienda);
    } catch (e) {
      return null;
    }
  }

  /// Limpia todos los datos del feed
  void clearFeed() {
    _feedItems.clear();
    _hasMoreData.value = true;
    _clearError();
  }

  // Métodos privados para gestión de estado

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setLoadingMore(bool loading) {
    _isLoadingMore.value = loading;
  }

  void _setRefreshing(bool refreshing) {
    _isRefreshing.value = refreshing;
  }

  void _setError(String message) {
    _errorMessage.value = message;
  }

  void _clearError() {
    _errorMessage.value = null;
  }
}
