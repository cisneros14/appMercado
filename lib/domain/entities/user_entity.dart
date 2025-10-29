import 'package:equatable/equatable.dart';

/// Entidad que representa un usuario del sistema.
///
/// Define la estructura básica de un usuario con sus propiedades
/// fundamentales como identificación, información personal y rol.
class UserEntity extends Equatable {
  /// ID único del usuario
  final int userId;

  /// Nombre de usuario único
  final String userName;

  /// Nombre del usuario
  final String firstName;

  /// Apellido del usuario
  final String lastName;

  /// Email del usuario
  final String userEmail;

  /// Rol del usuario en el sistema
  final String rol;

  /// Token de autenticación
  final String? token;

  /// Constructor de la entidad usuario
  const UserEntity({
    required this.userId,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.userEmail,
    required this.rol,
    this.token,
  });

  /// Nombre completo del usuario
  String get fullName => '$firstName $lastName';

  /// Indica si el usuario es administrador
  bool get isAdmin => rol.toLowerCase() == 'admin';

  /// Indica si el usuario es asesor
  bool get isAsesor => rol.toLowerCase() == 'asesor';

  /// Crea una copia de la entidad con valores modificados
  UserEntity copyWith({
    int? userId,
    String? userName,
    String? firstName,
    String? lastName,
    String? userEmail,
    String? rol,
    String? token,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userEmail: userEmail ?? this.userEmail,
      rol: rol ?? this.rol,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    userName,
    firstName,
    lastName,
    userEmail,
    rol,
    token,
  ];

  @override
  String toString() {
    return 'UserEntity(userId: $userId, userName: $userName, fullName: $fullName, rol: $rol)';
  }
}
