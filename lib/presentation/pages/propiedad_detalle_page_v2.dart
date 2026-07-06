import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/screen_header_description.dart';
// import 'package:url_launcher/url_launcher.dart'; // Si estuviera disponible
import '../../domain/entities/propiedad_entity.dart';
import '../../data/repositories/propiedad_repository_impl.dart';
import '../../data/data_sources/remote/propiedad_remote_data_source.dart';
import '../../core/widgets/smart_network_image.dart';
import '../../core/utils/image_utils.dart';
import '../../data/data_sources/local/auth_local_datasource.dart';

class PropiedadDetallePageV2 extends StatefulWidget {
  const PropiedadDetallePageV2({super.key});

  @override
  State<PropiedadDetallePageV2> createState() => _PropiedadDetallePageV2State();
}

class _PropiedadDetallePageV2State extends State<PropiedadDetallePageV2> {
  late PropiedadEntity _propiedad;
  bool _loading = true;
  int _currentImage = 0;
  final PageController _pageController = PageController();
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _propiedad = Get.arguments as PropiedadEntity;
    _loadCurrentUser();
    _loadDetail();
  }

  Future<void> _loadCurrentUser() async {
    final auth = AuthLocalDataSource();
    final user = await auth.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUserId = user?.userId;
      });
    }
  }

  Future<void> _loadDetail() async {
    try {
      final repo = PropiedadRepositoryImpl(
        remoteDataSource: PropiedadRemoteDataSource(),
      );
      final full = await repo.obtenerPropiedadPorId(_propiedad.id);
      if (mounted) {
        setState(() {
          _propiedad = full;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _propiedad;
    final formatter = NumberFormat.currency(locale: 'es_EC', symbol: '\u0024');
    final imagenes = p.imagenes;
    
    // Verificar si es dueño (compara ID de usuario con ID de corredor/creador)
    final isOwner = _currentUserId != null && _propiedad.corredorId == _currentUserId.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Propiedad'),
        backgroundColor: const Color(0xFF1a2c5b),
        foregroundColor: Colors.white,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Propiedad',
              onPressed: () async {
                 final result = await Get.toNamed('/subir-propiedad', arguments: _propiedad);
                 if (result == true) {
                   _loadDetail();
                 }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image Carousel
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imagenes.isEmpty 
                    ? Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        onPageChanged: (idx) => setState(() => _currentImage = idx),
                        itemCount: imagenes.length,
                        itemBuilder: (ctx, idx) => SmartNetworkImage(
                          src: imagenes[idx],
                          fit: BoxFit.cover,
                        ),
                      ),
                ),
                if (imagenes.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImage + 1} / ${imagenes.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (_loading)
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
              ],
            ),

            // 2. Header Description
            const ScreenHeaderDescription(
              title: 'Información Completa', 
              description: 'Revise las características, ubicación y amenidades de esta propiedad.',
              icon: null,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Title & Tags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          p.titulo,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // ID y Fecha Publicación
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ID: ${p.id}',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Publicado hace ${_getTimeAgo(p.fechaPublicacion)}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatusChip(text: p.tipoOperacion, color: Colors.blue.shade100, textColor: Colors.blue.shade900),
                      const SizedBox(width: 8),
                      _StatusChip(text: p.tipoPropiedad, color: Colors.orange.shade100, textColor: Colors.orange.shade900),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 4. Price & Address
                  Text(
                    formatter.format(p.precio),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1a2c5b),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [p.direccion, p.ciudad, p.provincia].where((e) => e.isNotEmpty).join(', '),
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // 5. Stats Grid
                  const Text('Características Principales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  
                  // Usamos GridView para distribuir equitativamente en 3 columnas
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1, // Ajustar para que las tarjetas se vean bien
                    children: [
                      _StatCard(icon: Icons.square_foot, label: '${p.area.toStringAsFixed(0)} m²', sublabel: 'Construcción'),
                      if (p.areaLote > 0)
                        _StatCard(icon: Icons.landscape, label: '${p.areaLote.toStringAsFixed(0)} m²', sublabel: 'Terreno'),
                      _StatCard(icon: Icons.bed, label: '${p.habitaciones}', sublabel: 'Habitaciones'),
                      _StatCard(icon: Icons.bathtub, label: '${p.banos}', sublabel: 'Baños'),
                      if (p.garage > 0)
                        _StatCard(icon: Icons.garage, label: '${p.garage}', sublabel: 'Garage'),
                      if (p.niveles > 0)
                        _StatCard(icon: Icons.layers, label: '${p.niveles}', sublabel: 'Niveles'),
                    ],
                  ),
                  const Divider(height: 32),

                  // 6. Amenities (If any)
                  if (p.amenidades.isNotEmpty) ...[
                    const Text('Amenidades', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: p.amenidades.map((a) => Chip(
                        label: Text(a),
                        backgroundColor: const Color(0xFFF5F7FA),
                        avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                    const Divider(height: 32),
                  ],

                  // 7. Description
                  const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(
                    p.descripcion.isEmpty ? 'Sin descripción disponible.' : p.descripcion,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  // 8. Agent Card
                  _AgentCard(propiedad: p),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} años';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} meses';
    } else if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()} sem';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'un momento';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _StatusChip({required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  const _StatCard({required this.icon, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF1a2c5b), size: 24),
          const SizedBox(height: 8),
          Text(
            label, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center
          ),
          const SizedBox(height: 4),
          Text(
            sublabel, 
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10), 
            textAlign: TextAlign.center
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final PropiedadEntity propiedad;
  const _AgentCard({required this.propiedad});

  @override
  Widget build(BuildContext context) {
    final nombre = propiedad.corredorNombre.isNotEmpty ? propiedad.corredorNombre : 'Agente Inmobiliario';
    final cargo = propiedad.corredorCargo.isNotEmpty ? propiedad.corredorCargo : 'Agente Autorizado';
    final empresa = propiedad.corredorEmpresa.isNotEmpty ? propiedad.corredorEmpresa : 'Triara';
    final telefono = propiedad.corredorTelefono;
    final email = propiedad.corredorEmail;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: NetworkImage(normalizeImage(propiedad.corredorImagen)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a2c5b),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cargo,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (propiedad.corredorEmpresa.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        empresa,
                        style: const TextStyle(
                          color: Color(0xFF1a2c5b),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (telefono.isNotEmpty || email.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (telefono.isNotEmpty)
                  _ContactButton(
                    icon: Icons.phone,
                    label: 'Llamar',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: telefono));
                      Get.snackbar(
                        'Contacto',
                        'Teléfono: $telefono (Copiado al portapapeles)',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF1a2c5b),
                        colorText: Colors.white,
                      );
                    },
                  ),
                if (telefono.isNotEmpty)
                  _ContactButton(
                    icon: Icons.chat,
                    label: 'WhatsApp',
                    color: Colors.green,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: telefono));
                      Get.snackbar(
                        'WhatsApp',
                        'Número: $telefono (Copiado). Chat con $nombre.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade800,
                        colorText: Colors.white,
                      );
                    },
                  ),
                if (email.isNotEmpty)
                  _ContactButton(
                    icon: Icons.email,
                    label: 'Correo',
                    color: Colors.orange,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: email));
                      Get.snackbar(
                        'Correo',
                        'Email: $email (Copiado al portapapeles)',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange.shade800,
                        colorText: Colors.white,
                      );
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF1a2c5b),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
