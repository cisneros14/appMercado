import 'package:flutter/material.dart';
import '../../domain/entities/feed_entity.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/smart_network_image.dart';

/// Widget card para mostrar información resumida del feed
///
/// Muestra los datos más importantes de una entrada del feed en formato card:
/// - Imagen principal de la propiedad
/// - Modelo y precio de la propiedad
/// - Ubicación y área
/// - Información del usuario/corredor
/// - Fecha de publicación
class FeedCard extends StatelessWidget {
  final FeedEntity feedItem;
  final VoidCallback onTap;

  const FeedCard({super.key, required this.feedItem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Un poco más de elevación
      color: Colors.white,
      shadowColor: const Color(0xFF1a2c5b).withOpacity(0.2), // Sombra más visible
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información del usuario y fecha
              _buildHeader(context),
              const SizedBox(height: 16),

              // Contenido principal de la propiedad (movido antes de la notificación)
              _buildPropertyContent(context),
              const SizedBox(height: 16),

              // Notificación del feed (movida después del contenido)
              _buildNotification(context),
              const SizedBox(height: 12),

              // Footer con acción
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el header con información del usuario y fecha
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Avatar del usuario
        CircleAvatar(
          radius: 24,
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
                    fontSize: 16,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),

        // Información del usuario
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
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    feedItem.fechaFormateada,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Icono para indicar que es clickeable
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.lightAccent,
          ),
        ),
      ],
    );
  }

  /// Construye la notificación del feed
  Widget _buildNotification(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            size: 18,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feedItem.notificacion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido principal de la propiedad
  Widget _buildPropertyContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen de la propiedad (ahora ocupa todo el ancho)
        _buildPropertyImage(),
        const SizedBox(height: 16),

        // Información de la propiedad
        _buildPropertyInfo(context),
      ],
    );
  }

  /// Construye la imagen de la propiedad
  Widget _buildPropertyImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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

  /// Construye el placeholder para cuando no hay imagen
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home_work, size: 60, color: AppTheme.lightAccent),
          const SizedBox(height: 8),
          Text(
            'Imagen no disponible',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Construye la información de la propiedad
  Widget _buildPropertyInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modelo de la propiedad
        Text(
          feedItem.modelo,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),

        // Precio prominente
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            feedItem.precioFormateado,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Información adicional en fila
        // Información adicional en fila
        Row(
          children: [
            // Área
            if (feedItem.areaFormateada.isNotEmpty)
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.square_foot,
                  label: feedItem.areaFormateada,
                  context: context,
                ),
              ),
            
            if (feedItem.areaFormateada.isNotEmpty && feedItem.ciudad.isNotEmpty)
              const SizedBox(width: 12),

            // Ubicación
            if (feedItem.ciudad.isNotEmpty)
              Expanded(
                flex: 2,
                child: _buildInfoChip(
                  icon: Icons.location_on,
                  label: feedItem.ciudad,
                  context: context,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Construye un chip de información
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    if (label.isEmpty || label.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.lightAccent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el footer con acción
  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 16,
            color: AppTheme.lightAccent.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            'Toca para ver más detalles',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.lightAccent.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
