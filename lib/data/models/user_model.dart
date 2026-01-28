import '../../domain/entities/user_entity.dart';

/// Modelo de datos para User con capacidades de serialización.
///
/// Extiende UserEntity y añade funcionalidades para convertir
/// desde/hacia JSON y Map para interactuar con APIs y bases de datos.
class UserModel extends UserEntity {
  /// Constructor del modelo User
  const UserModel({
    required super.userId,
    required super.userName,
    required super.firstName,
    required super.lastName,
    required super.userEmail,
    required super.rol,
    super.token,
  });

  /// Crea una instancia desde JSON (respuesta de API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: _parseIntSafely(json['user_id']),
      userName: json['user_name']?.toString() ?? '',
      firstName: json['firstname']?.toString() ?? '',
      lastName: json['lastname']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      rol: json['rol']?.toString() ?? 'usuario',
      token: json['token']?.toString(),
    );
  }

  /// Parsea un valor a int de forma segura (puede ser String o int)
  static int _parseIntSafely(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw FormatException('Cannot parse $value to int');
  }

  /// Crea una instancia desde Map (para uso general)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: _parseIntSafely(map['user_id']),
      userName: map['user_name'] as String,
      firstName: map['firstname'] as String,
      lastName: map['lastname'] as String,
      userEmail: map['user_email'] as String,
      rol: map['rol'] as String,
      token: map['token'] as String?,
    );
  }

  /// Crea una instancia desde una entidad
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      userName: entity.userName,
      firstName: entity.firstName,
      lastName: entity.lastName,
      userEmail: entity.userEmail,
      rol: entity.rol,
      token: entity.token,
    );
  }

  /// Convierte a JSON para envío a API
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'firstname': firstName,
      'lastname': lastName,
      'user_email': userEmail,
      'rol': rol,
      if (token != null) 'token': token,
    };
  }

  /// Convierte a Map para uso general
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'firstname': firstName,
      'lastname': lastName,
      'user_email': userEmail,
      'rol': rol,
      if (token != null) 'token': token,
    };
  }

  /// Crea una copia del modelo con valores modificados
  @override
  UserModel copyWith({
    int? userId,
    String? userName,
    String? firstName,
    String? lastName,
    String? userEmail,
    String? rol,
    String? token,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userEmail: userEmail ?? this.userEmail,
      rol: rol ?? this.rol,
      token: token ?? this.token,
    );
  }
}
