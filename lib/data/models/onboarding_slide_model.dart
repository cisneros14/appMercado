import '../../domain/entities/onboarding_slide_entity.dart';

/// Modelo de datos para OnboardingSlide con capacidades de serialización.
///
/// Extiende OnboardingSlideEntity y añade funcionalidades para convertir
/// desde/hacia JSON y SQLite Map.
class OnboardingSlideModel extends OnboardingSlideEntity {
  /// Constructor del modelo OnboardingSlide
  const OnboardingSlideModel({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.imagenAsset,
    required super.esUltimoSlide,
    required super.colorFondo,
    required super.orden,
  });

  /// Crea una instancia desde un Map (usado para SQLite)
  factory OnboardingSlideModel.fromMap(Map<String, dynamic> map) {
    return OnboardingSlideModel(
      id: map['id'] as int,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      imagenAsset: map['imagen_asset'] as String,
      esUltimoSlide: (map['es_ultimo_slide'] as int) == 1,
      colorFondo: map['color_fondo'] as String,
      orden: map['orden'] as int,
    );
  }

  /// Crea una instancia desde JSON
  factory OnboardingSlideModel.fromJson(Map<String, dynamic> json) {
    return OnboardingSlideModel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      imagenAsset: json['imagenAsset'] as String,
      esUltimoSlide: json['esUltimoSlide'] as bool,
      colorFondo: json['colorFondo'] as String,
      orden: json['orden'] as int,
    );
  }

  /// Crea una instancia desde una entidad
  factory OnboardingSlideModel.fromEntity(OnboardingSlideEntity entity) {
    return OnboardingSlideModel(
      id: entity.id,
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      imagenAsset: entity.imagenAsset,
      esUltimoSlide: entity.esUltimoSlide,
      colorFondo: entity.colorFondo,
      orden: entity.orden,
    );
  }

  /// Convierte a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagen_asset': imagenAsset,
      'es_ultimo_slide': esUltimoSlide ? 1 : 0,
      'color_fondo': colorFondo,
      'orden': orden,
    };
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagenAsset': imagenAsset,
      'esUltimoSlide': esUltimoSlide,
      'colorFondo': colorFondo,
      'orden': orden,
    };
  }

  /// Crea una copia del modelo con valores modificados
  @override
  OnboardingSlideModel copyWith({
    int? id,
    String? titulo,
    String? descripcion,
    String? imagenAsset,
    bool? esUltimoSlide,
    String? colorFondo,
    int? orden,
  }) {
    return OnboardingSlideModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      imagenAsset: imagenAsset ?? this.imagenAsset,
      esUltimoSlide: esUltimoSlide ?? this.esUltimoSlide,
      colorFondo: colorFondo ?? this.colorFondo,
      orden: orden ?? this.orden,
    );
  }

  /// Lista predefinida de slides de onboarding para BIE
  static List<OnboardingSlideModel> getSlidesData() {
    return [
      const OnboardingSlideModel(
        id: 1,
        titulo: '¡Bienvenid@!',
        descripcion:
            'El ecosistema integral dirigido a profesionales y empresas inmobiliarias legalmente acreditadas en el Ecuador, orientado a potenciar su productividad y maximizar sus ventas.',
        imagenAsset: 'assets/images/onboarding_welcome.png',
        esUltimoSlide: false,
        colorFondo: '#1a2c5b',
        orden: 1,
      ),
      const OnboardingSlideModel(
        id: 2,
        titulo: 'Gestiona tu portafolio inmobiliario',
        descripcion:
            'Administra todas tus propiedades desde un solo lugar. Carga fotos, actualiza precios y mantén tu inventario siempre actualizado.',
        imagenAsset: 'assets/images/onboarding_search.png',
        esUltimoSlide: false,
        colorFondo: '#2e4170',
        orden: 2,
      ),
      const OnboardingSlideModel(
        id: 3,
        titulo: 'Conecta con clientes potenciales',
        descripcion:
            'Recibe leads y calificaciones, gestiona consultas en tiempo real y da seguimiento a todas tus oportunidades de negocio con la red inmobiliaria más grande del país.',
        imagenAsset: 'assets/images/onboarding_connect.png',
        esUltimoSlide: false,
        colorFondo: '#405a8a',
        orden: 3,
      ),
      const OnboardingSlideModel(
        id: 4,
        titulo: '¡Impulsa tu negocio!',
        descripcion:
            'Únete a los asesores inmobiliarios más exitosos que ya están aumentando sus ventas con BIE.',
        imagenAsset: 'assets/images/onboarding_start.png',
        esUltimoSlide: true,
        colorFondo: '#5f7bb0',
        orden: 4,
      ),
    ];
  }
}
