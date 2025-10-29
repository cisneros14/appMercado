import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../domain/entities/propiedad_entity.dart';
import '../../data/repositories/propiedad_repository_impl.dart';
import '../../data/data_sources/remote/propiedad_remote_data_source.dart';
import '../../core/widgets/smart_network_image.dart';

class GestionPropiedadesPage extends StatefulWidget {
  const GestionPropiedadesPage({super.key});

  @override
  State<GestionPropiedadesPage> createState() => _GestionPropiedadesPageState();
}

class _GestionPropiedadesPageState extends State<GestionPropiedadesPage> {
  late final PropiedadRepositoryImpl _repo;
  final _formatter = NumberFormat.currency(locale: 'es_EC', symbol: '\u0024');

  bool _loading = false;
  String? _error;
  List<PropiedadEntity> _items = [];

  int _pagina = 1;
  static const int _limite = 20;
  bool _cargandoMas = false;
  bool _sinMas = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _repo = PropiedadRepositoryImpl(
      remoteDataSource: PropiedadRemoteDataSource(),
    );
    _scrollController.addListener(_onScroll);
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetch({bool reset = false}) async {
    if (_loading || _cargandoMas) return;
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _pagina = 1;
        _sinMas = false;
      });
    } else {
      if (_sinMas) return;
      setState(() {
        _cargandoMas = true;
      });
    }

    try {
      final data = await _repo.obtenerMisPropiedades(
        pagina: _pagina,
        limite: _limite,
      );

      setState(() {
        if (reset) {
          _items = data;
        } else {
          _items = [..._items, ...data];
        }

        if (data.length < _limite) {
          _sinMas = true;
        } else {
          _pagina += 1;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar propiedades';
      });
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        _loading = false;
        _cargandoMas = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetch(reset: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Propiedades'),
        backgroundColor: const Color(0xFF1a2c5b),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetch(reset: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return _EmptyState(
        title: 'Ocurrió un error',
        message: _error!,
        actionText: 'Reintentar',
        onAction: () => _fetch(reset: true),
      );
    }

    if (_items.isEmpty) {
      return _EmptyState(
        title: 'Sin propiedades',
        message: 'No has publicado propiedades todavía.',
        actionText: 'Refrescar',
        onAction: () => _fetch(reset: true),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      itemCount: _items.length + (_cargandoMas ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final p = _items[index];
        return InkWell(
          onTap: () => Get.toNamed('/propiedad-detalle', arguments: p),
          child: _PropiedadCard(propiedad: p, precioFormatter: _formatter),
        );
      },
    );
  }
}

// Reuse card and helpers from buscar_propiedades_page
class _PropiedadCard extends StatelessWidget {
  final PropiedadEntity propiedad;
  final NumberFormat precioFormatter;

  const _PropiedadCard({
    required this.propiedad,
    required this.precioFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final imagen = propiedad.imagenes.isNotEmpty
        ? propiedad.imagenes.first
        : null;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imagen != null && imagen.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: SmartNetworkImage(
                src: imagen,
                fit: BoxFit.cover,
                placeholder: Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            )
          else
            Container(
              height: 180,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.image, size: 48, color: Colors.grey),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propiedad.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Chip(
                      text: propiedad.tipoPropiedad.isEmpty
                          ? '—'
                          : propiedad.tipoPropiedad,
                      icon: Icons.home_work,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      text: propiedad.tipoOperacion.isEmpty
                          ? '—'
                          : propiedad.tipoOperacion,
                      icon: Icons.sell,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        [
                          propiedad.direccion,
                          propiedad.ciudad,
                          propiedad.provincia,
                        ].where((e) => e.isNotEmpty).join(' · '),
                        style: const TextStyle(color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.square_foot, size: 16),
                    const SizedBox(width: 4),
                    Text('${propiedad.area.toStringAsFixed(0)} m²'),
                    const SizedBox(width: 12),
                    const Icon(Icons.bed, size: 16),
                    const SizedBox(width: 4),
                    Text('${propiedad.habitaciones} hab'),
                    const SizedBox(width: 12),
                    const Icon(Icons.bathtub, size: 16),
                    const SizedBox(width: 4),
                    Text('${propiedad.banos} baños'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  precioFormatter.format(propiedad.precio),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a2c5b),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Chip({required this.text, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF9),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1a2c5b)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1a2c5b),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String actionText;
  final VoidCallback onAction;

  const _EmptyState({
    required this.title,
    required this.message,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1a2c5b),
                foregroundColor: Colors.white,
              ),
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}
