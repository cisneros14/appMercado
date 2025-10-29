/// Entidad base para usuarios de la aplicación
/// 
/// Define la estructura de datos de un usuario en el dominio
/// de la aplicación.

class UsuarioEntity {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? avatar;
  final DateTime fechaRegistro;
  final bool activo;
  final String rol; // comprador, vendedor, admin
  
  const UsuarioEntity({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.avatar,
    required this.fechaRegistro,
    required this.activo,
    required this.rol,
  });
  
  /// Obtiene el nombre completo del usuario
  String get nombreCompleto => '$nombre $apellido';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}