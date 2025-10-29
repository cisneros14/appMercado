import 'package:flutter/material.dart';
import '../../domain/entities/feed_entity.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/smart_network_image.dart';

/// Modal que muestra la información completa de un elemento del feed
///
/// Presenta todos los datos disponibles de la propiedad de forma detallada,
/// incluyendo imagen grande, especificaciones completas y datos del corredor.
class FeedDetailModal extends StatelessWidget {
  final FeedEntity feedItem;

  const FeedDetailModal({super.key, required this.feedItem});

  /// Método estático para mostrar el modal
  static Future<void> show(BuildContext context, FeedEntity feedItem) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedDetailModal(feedItem: feedItem),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle para indicar que es un modal
          _buildHandle(),

          // Header con botón cerrar
          _buildHeader(context),

          // Contenido scrolleable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen principal
                  _buildMainImage(context),
                  const SizedBox(height: 20),

                  // Información de la notificación
                  _buildNotificationSection(context),
                  const SizedBox(height: 20),

                  // Información básica de la propiedad
                  _buildPropertyBasicInfo(context),
                  const SizedBox(height: 20),

                  // Especificaciones detalladas
                  _buildPropertySpecs(context),
                  const SizedBox(height: 20),

                  // Información de ubicación
                  _buildLocationInfo(context),
                  const SizedBox(height: 20),

                  // Información del corredor
                  _buildRealtorInfo(context),
                  const SizedBox(height: 20),

                  // Información temporal
                  _buildTimeInfo(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el handle superior del modal
  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Construye el header con título y botón cerrar
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Detalles de la Propiedad',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
          ),
        ],
      ),
    );
  }

  /// Construye la imagen principal de la propiedad
  Widget _buildMainImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: feedItem.imgPrincipal.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SmartNetworkImage(
                src: feedItem.imgPrincipal,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                placeholder: _buildImagePlaceholder(),
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  /// Construye el placeholder para la imagen
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work, size: 60, color: AppTheme.lightAccent),
            SizedBox(height: 8),
            Text(
              'Sin imagen disponible',
              style: TextStyle(color: AppTheme.lightAccent),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la sección de notificación
  Widget _buildNotificationSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Actividad Reciente',
      icon: Icons.notifications,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
        ),
        child: Text(
          feedItem.notificacion,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// Construye la información básica de la propiedad
  Widget _buildPropertyBasicInfo(BuildContext context) {
    return _buildSection(
      context,
      title: 'Información General',
      icon: Icons.info,
      child: Column(
        children: [
          _buildInfoRow(
            context,
            label: 'Modelo',
            value: feedItem.modelo,
            icon: Icons.home,
          ),
          const Divider(),
          _buildInfoRow(
            context,
            label: 'Precio',
            value: '\$${feedItem.precio.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            valueColor: AppTheme.successColor,
            isHighlight: true,
          ),
          const Divider(),
          _buildInfoRow(
            context,
            label: 'ID de Vivienda',
            value: feedItem.idVivienda,
            icon: Icons.tag,
          ),
        ],
      ),
    );
  }

  /// Construye las especificaciones de la propiedad
  Widget _buildPropertySpecs(BuildContext context) {
    return _buildSection(
      context,
      title: 'Especificaciones',
      icon: Icons.architecture,
      child: Column(
        children: [
          _buildInfoRow(
            context,
            label: 'Área Total',
            value: '${feedItem.area.toStringAsFixed(2)} m²',
            icon: Icons.square_foot,
          ),
        ],
      ),
    );
  }

  /// Construye la información de ubicación
  Widget _buildLocationInfo(BuildContext context) {
    return _buildSection(
      context,
      title: 'Ubicación',
      icon: Icons.location_on,
      child: Column(
        children: [
          _buildInfoRow(
            context,
            label: 'Región',
            value: feedItem.ciudad,
            icon: Icons.public,
          ),
          const Divider(),
          _buildInfoRow(
            context,
            label: 'Localidad',
            value: feedItem.localidad,
            icon: Icons.place,
          ),
          const Divider(),
          _buildInfoRow(
            context,
            label: 'Ubicación Completa',
            value: feedItem.ubicacionCompleta,
            icon: Icons.map,
          ),
        ],
      ),
    );
  }

  /// Construye la información del corredor
  Widget _buildRealtorInfo(BuildContext context) {
    return _buildSection(
      context,
      title: 'Corredor Inmobiliario',
      icon: Icons.person,
      child: Row(
        children: [
          // Avatar del corredor
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.lightAccent,
            backgroundImage:
                feedItem.user.imgUrl.isNotEmpty &&
                    !feedItem.user.imgUrl.contains('default-avatar.png')
                ? NetworkImage(normalizeImage(feedItem.user.imgUrl))
                : null,
            child:
                feedItem.user.imgUrl.isEmpty ||
                    feedItem.user.imgUrl.contains('default-avatar.png')
                ? Text(
                    feedItem.user.iniciales,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),

          // Información del corredor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedItem.user.nombreCompleto,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Agente inmobiliario',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la información temporal
  Widget _buildTimeInfo(BuildContext context) {
    return _buildSection(
      context,
      title: 'Información Temporal',
      icon: Icons.schedule,
      child: Column(
        children: [
          _buildInfoRow(
            context,
            label: 'Fecha de Publicación',
            value:
                '${feedItem.fechaHora.day}/${feedItem.fechaHora.month}/${feedItem.fechaHora.year}',
            icon: Icons.calendar_today,
          ),
          const Divider(),
          _buildInfoRow(
            context,
            label: 'Hora',
            value:
                '${feedItem.fechaHora.hour.toString().padLeft(2, '0')}:${feedItem.fechaHora.minute.toString().padLeft(2, '0')}',
            icon: Icons.access_time,
          ),
          const Divider(),
          _buildInfoRow(
            context,
            label: 'Hace',
            value: feedItem.fechaFormateada,
            icon: Icons.history,
          ),
        ],
      ),
    );
  }

  /// Construye una sección con título e icono
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: child,
        ),
      ],
    );
  }

  /// Construye una fila de información
  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.lightAccent),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black87,
                fontSize: isHighlight ? 16 : null,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
