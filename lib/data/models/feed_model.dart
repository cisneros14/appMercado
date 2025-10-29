import '../../../domain/entities/feed_entity.dart';

/// Modelo de datos para el feed que extiende la entidad del dominio
///
/// Maneja la serialización y deserialización JSON para comunicación con la API.
/// Implementa el mapeo entre la respuesta de la API y la entidad del dominio.
class FeedModel extends FeedEntity {
  const FeedModel({
    required super.fechaHora,
    required super.notificacion,
    required super.idVivienda,
    required super.modelo,
    required super.precio,
    required super.area,
    required super.imgPrincipal,
    required super.ciudad,
    required super.localidad,
    required super.user,
  });

  /// Constructor factory para crear una instancia desde JSON
  ///
  /// Recibe el mapa JSON de la API y lo convierte a FeedModel.
  /// Maneja la conversión de tipos y valores por defecto.
  factory FeedModel.fromJson(Map<String, dynamic> json) {
    return FeedModel(
      fechaHora: DateTime.tryParse(json['fecha_hora'] ?? '') ?? DateTime.now(),
      notificacion: json['notificacion']?.toString() ?? '',
      idVivienda: json['id_vivienda']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      precio: _parseDouble(json['precio']),
      area: _parseDouble(json['area']),
      imgPrincipal: json['img_principal']?.toString() ?? '',
      ciudad: json['ciudad']?.toString() ?? '',
      localidad: json['localidad']?.toString() ?? '',
      user: FeedUserModel.fromJson(json['user'] ?? {}),
    );
  }

  /// Convierte la instancia a un mapa JSON
  ///
  /// Útil para enviar datos a la API o almacenamiento local.
  Map<String, dynamic> toJson() {
    return {
      'fecha_hora': fechaHora.toIso8601String(),
      'notificacion': notificacion,
      'id_vivienda': idVivienda,
      'modelo': modelo,
      'precio': precio,
      'area': area,
      'img_principal': imgPrincipal,
      'ciudad': ciudad,
      'localidad': localidad,
      'user': (user as FeedUserModel).toJson(),
    };
  }

  /// Convierte el modelo a la entidad del dominio
  ///
  /// Mapea de la capa de datos a la capa de dominio.
  FeedEntity toEntity() {
    return FeedEntity(
      fechaHora: fechaHora,
      notificacion: notificacion,
      idVivienda: idVivienda,
      modelo: modelo,
      precio: precio,
      area: area,
      imgPrincipal: imgPrincipal,
      ciudad: ciudad,
      localidad: localidad,
      user: (user as FeedUserModel).toEntity(),
    );
  }

  /// Crea una copia del modelo con valores opcionales actualizados
  FeedModel copyWith({
    DateTime? fechaHora,
    String? notificacion,
    String? idVivienda,
    String? modelo,
    double? precio,
    double? area,
    String? imgPrincipal,
    String? ciudad,
    String? localidad,
    FeedUserModel? user,
  }) {
    return FeedModel(
      fechaHora: fechaHora ?? this.fechaHora,
      notificacion: notificacion ?? this.notificacion,
      idVivienda: idVivienda ?? this.idVivienda,
      modelo: modelo ?? this.modelo,
      precio: precio ?? this.precio,
      area: area ?? this.area,
      imgPrincipal: imgPrincipal ?? this.imgPrincipal,
      ciudad: ciudad ?? this.ciudad,
      localidad: localidad ?? this.localidad,
      user: user ?? this.user as FeedUserModel,
    );
  }

  /// Método auxiliar para parsear valores double de forma segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Limpiar el string de caracteres no numéricos (excepto punto y coma)
      String cleanValue = value.replaceAll(RegExp(r'[^\d.,]'), '');
      // Reemplazar coma por punto para decimales
      cleanValue = cleanValue.replaceAll(',', '.');
      // Intentar parsear el valor limpio
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }
}

/// Modelo de datos para el usuario en el feed
class FeedUserModel extends FeedUserEntity {
  const FeedUserModel({
    required super.firstname,
    required super.lastname,
    required super.imgUrl,
  });

  /// Constructor factory para crear una instancia desde JSON
  factory FeedUserModel.fromJson(Map<String, dynamic> json) {
    return FeedUserModel(
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      imgUrl: json['img_url']?.toString() ?? 'img/default-avatar.png',
    );
  }

  /// Convierte la instancia a un mapa JSON
  Map<String, dynamic> toJson() {
    return {'firstname': firstname, 'lastname': lastname, 'img_url': imgUrl};
  }

  /// Convierte el modelo a la entidad del dominio
  FeedUserEntity toEntity() {
    return FeedUserEntity(
      firstname: firstname,
      lastname: lastname,
      imgUrl: imgUrl,
    );
  }

  /// Crea una copia del modelo con valores opcionales actualizados
  FeedUserModel copyWith({
    String? firstname,
    String? lastname,
    String? imgUrl,
  }) {
    return FeedUserModel(
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      imgUrl: imgUrl ?? this.imgUrl,
    );
  }
}
