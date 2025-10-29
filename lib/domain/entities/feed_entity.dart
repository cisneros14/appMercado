/// Entidad que representa un elemento del feed de propiedades
///
/// Esta entidad encapsula toda la información de una entrada del feed,
/// incluyendo datos de la propiedad, ubicación y usuario asociado.
class FeedEntity {
  /// Fecha y hora de la publicación del feed
  final DateTime fechaHora;

  /// Notificación o mensaje asociado al elemento del feed
  final String notificacion;

  /// ID único de la vivienda/propiedad
  final String idVivienda;

  /// Modelo o tipo de la propiedad
  final String modelo;

  /// Precio de la propiedad
  final double precio;

  /// Área de la propiedad en metros cuadrados
  final double area;

  /// URL de la imagen principal de la propiedad
  final String imgPrincipal;

  /// Información de ubicación (provincia - cantón)
  final String ciudad;

  /// Parroquia específica de la propiedad
  final String localidad;

  /// Información del usuario/corredor asociado
  final FeedUserEntity user;

  const FeedEntity({
    required this.fechaHora,
    required this.notificacion,
    required this.idVivienda,
    required this.modelo,
    required this.precio,
    required this.area,
    required this.imgPrincipal,
    required this.ciudad,
    required this.localidad,
    required this.user,
  });

  /// Obtiene el precio formateado como texto para mostrar en UI
  String get precioFormateado {
    if (precio >= 1000000) {
      return '\$${(precio / 1000000).toStringAsFixed(1)}M';
    } else if (precio >= 1000) {
      return '\$${(precio / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${precio.toStringAsFixed(0)}';
    }
  }

  /// Obtiene el área formateada como texto
  String get areaFormateada => '${area.toStringAsFixed(0)} m²';

  /// Obtiene la ubicación completa (ciudad + localidad)
  String get ubicacionCompleta => '$ciudad - $localidad';

  /// Obtiene la fecha formateada para mostrar en el feed
  String get fechaFormateada {
    final now = DateTime.now();
    final difference = now.difference(fechaHora);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${fechaHora.day}/${fechaHora.month}/${fechaHora.year}';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedEntity &&
          runtimeType == other.runtimeType &&
          idVivienda == other.idVivienda;

  @override
  int get hashCode => idVivienda.hashCode;

  @override
  String toString() {
    return 'FeedEntity{idVivienda: $idVivienda, modelo: $modelo, precio: $precio}';
  }
}

/// Entidad que representa la información del usuario en el feed
class FeedUserEntity {
  /// Nombre del usuario
  final String firstname;

  /// Apellido del usuario
  final String lastname;

  /// URL de la imagen de perfil del usuario
  final String imgUrl;

  const FeedUserEntity({
    required this.firstname,
    required this.lastname,
    required this.imgUrl,
  });

  /// Obtiene el nombre completo del usuario
  String get nombreCompleto => '$firstname $lastname';

  /// Obtiene las iniciales del usuario para avatar por defecto
  String get iniciales {
    final firstInitial = firstname.isNotEmpty ? firstname[0].toUpperCase() : '';
    final lastInitial = lastname.isNotEmpty ? lastname[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedUserEntity &&
          runtimeType == other.runtimeType &&
          firstname == other.firstname &&
          lastname == other.lastname;

  @override
  int get hashCode => firstname.hashCode ^ lastname.hashCode;

  @override
  String toString() {
    return 'FeedUserEntity{nombreCompleto: $nombreCompleto}';
  }
}
