import '../../domain/entities/propiedad_entity.dart';

/// Modelo de datos para propiedades
/// 
/// Extiende la entidad del dominio agregando funcionalidades
/// específicas de la capa de datos como serialización JSON.

class PropiedadModel extends PropiedadEntity {
  const PropiedadModel({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.precio,
    required super.tipoOperacion,
    required super.tipoPropiedad,
    required super.area,
    required super.habitaciones,
    required super.banos,
    required super.direccion,
    required super.ciudad,
    required super.provincia,
    required super.imagenes,
    required super.fechaPublicacion,
    required super.activa,
    super.propietarioId,
  });
  
  /// Crea una instancia desde JSON
  factory PropiedadModel.fromJson(Map<String, dynamic> json) {
    return PropiedadModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      precio: (json['precio'] as num).toDouble(),
      tipoOperacion: json['tipo_operacion'] as String,
      tipoPropiedad: json['tipo_propiedad'] as String,
      area: (json['area'] as num).toDouble(),
      habitaciones: json['habitaciones'] as int,
      banos: json['banos'] as int,
      direccion: json['direccion'] as String,
      ciudad: json['ciudad'] as String,
      provincia: json['provincia'] as String,
      imagenes: List<String>.from(json['imagenes'] as List),
      fechaPublicacion: DateTime.parse(json['fecha_publicacion'] as String),
      activa: json['activa'] as bool,
      propietarioId: json['propietario_id'] as String?,
    );
  }
  
  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'tipo_operacion': tipoOperacion,
      'tipo_propiedad': tipoPropiedad,
      'area': area,
      'habitaciones': habitaciones,
      'banos': banos,
      'direccion': direccion,
      'ciudad': ciudad,
      'provincia': provincia,
      'imagenes': imagenes,
      'fecha_publicacion': fechaPublicacion.toIso8601String(),
      'activa': activa,
      'propietario_id': propietarioId,
    };
  }
  
  /// Crea una copia con valores modificados
  PropiedadModel copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    double? precio,
    String? tipoOperacion,
    String? tipoPropiedad,
    double? area,
    int? habitaciones,
    int? banos,
    String? direccion,
    String? ciudad,
    String? provincia,
    List<String>? imagenes,
    DateTime? fechaPublicacion,
    bool? activa,
    String? propietarioId,
  }) {
    return PropiedadModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      tipoOperacion: tipoOperacion ?? this.tipoOperacion,
      tipoPropiedad: tipoPropiedad ?? this.tipoPropiedad,
      area: area ?? this.area,
      habitaciones: habitaciones ?? this.habitaciones,
      banos: banos ?? this.banos,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      provincia: provincia ?? this.provincia,
      imagenes: imagenes ?? this.imagenes,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      activa: activa ?? this.activa,
      propietarioId: propietarioId ?? this.propietarioId,
    );
  }
}