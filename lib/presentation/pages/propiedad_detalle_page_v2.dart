import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/propiedad_entity.dart';
import '../../core/widgets/smart_network_image.dart';
import '../../core/utils/image_utils.dart';

class PropiedadDetallePageV2 extends StatelessWidget {
  const PropiedadDetallePageV2({super.key});

  @override
  Widget build(BuildContext context) {
    final PropiedadEntity p = Get.arguments as PropiedadEntity;
    final formatter = NumberFormat.currency(locale: 'es_EC', symbol: '24');
    final imagen = p.imagenes.isNotEmpty ? p.imagenes.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de propiedad'),
        backgroundColor: const Color(0xFF1a2c5b),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 220,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Chip(
                        text: p.tipoPropiedad.isEmpty ? '—' : p.tipoPropiedad,
                        icon: Icons.home_work,
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        text: p.tipoOperacion.isEmpty ? '—' : p.tipoOperacion,
                        icon: Icons.sell,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatter.format(p.precio),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1a2c5b),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [
                            p.direccion,
                            p.ciudad,
                            p.provincia,
                          ].where((e) => e.isNotEmpty).join(' · '),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.square_foot, size: 18),
                      const SizedBox(width: 4),
                      Text('${p.area.toStringAsFixed(0)} m²'),
                      const SizedBox(width: 16),
                      const Icon(Icons.bed, size: 18),
                      const SizedBox(width: 4),
                      Text('${p.habitaciones} hab'),
                      const SizedBox(width: 16),
                      const Icon(Icons.bathtub, size: 18),
                      const SizedBox(width: 4),
                      Text('${p.banos} baños'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.descripcion.isEmpty ? 'Sin descripción' : p.descripcion,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Corredor / Agencia',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildCorredorSection(p),
                ],
              ),
            ),
          ],
        ),
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

// Helper methods moved here to avoid importing utils
Widget _buildCorredorSection(PropiedadEntity p) {
  final raw = p.corredorImagen;
  final nombre = p.corredorNombre.isNotEmpty
      ? p.corredorNombre
      : 'Corredor desconocido';

  return Row(
    children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey.shade300,
        // Asegurar que siempre pasamos una URL absoluta y safe a NetworkImage
        backgroundImage: NetworkImage(normalizeImage(raw)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

// NOTE: image normalization moved to `lib/core/utils/image_utils.dart` (normalizeImage)
