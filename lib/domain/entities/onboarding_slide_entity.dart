/// Entidad que representa un slide de bienvenida de la aplicación.
///
/// Esta entidad define la estructura de datos para los slides informativos
/// que se muestran al usuario durante el proceso de onboarding.
class OnboardingSlideEntity {
  /// Identificador único del slide
  final int id;

  /// Título principal del slide
  final String titulo;

  /// Descripción o contenido informativo del slide
  final String descripcion;

  /// Ruta del asset de imagen del slide
  final String imagenAsset;

  /// Indica si es el último slide (con botones de acción)
  final bool esUltimoSlide;

  /// Color de fondo del slide en formato hexadecimal
  final String colorFondo;

  /// Orden de presentación del slide
  final int orden;

  /// Constructor de la entidad OnboardingSlide
  const OnboardingSlideEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagenAsset,
    required this.esUltimoSlide,
    required this.colorFondo,
    required this.orden,
  });

  /// Crea una copia de la entidad con valores modificados
  OnboardingSlideEntity copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? imagenAsset,
    bool? esUltimoSlide,
    String? colorFondo,
    int? orden,
  }) {
    return OnboardingSlideEntity(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      imagenAsset: imagenAsset ?? this.imagenAsset,
      esUltimoSlide: esUltimoSlide ?? this.esUltimoSlide,
      colorFondo: colorFondo ?? this.colorFondo,
      orden: orden ?? this.orden,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingSlideEntity &&
        other.id == id &&
        other.titulo == titulo &&
        other.descripcion == descripcion &&
        other.imagenAsset == imagenAsset &&
        other.esUltimoSlide == esUltimoSlide &&
        other.colorFondo == colorFondo &&
        other.orden == orden;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        titulo.hashCode ^
        descripcion.hashCode ^
        imagenAsset.hashCode ^
        esUltimoSlide.hashCode ^
        colorFondo.hashCode ^
        orden.hashCode;
  }

  @override
  String toString() {
    return 'OnboardingSlideEntity(id: $id, titulo: $titulo, descripcion: $descripcion, imagenAsset: $imagenAsset, esUltimoSlide: $esUltimoSlide, colorFondo: $colorFondo, orden: $orden)';
  }
}
