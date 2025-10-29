/// Entidad base para propiedades inmobiliarias
///
/// Define la estructura de datos de una propiedad en el dominio
/// de la aplicación, independiente de la fuente de datos.

class PropiedadEntity {
  final String id;
  final String titulo;
  final String descripcion;
  final double precio;
  final String tipoOperacion; // venta, renta, compra
  final String tipoPropiedad; // casa, apartamento, terreno, etc.
  final double area;
  final int habitaciones;
  final int banos;
  final String direccion;
  final String ciudad;
  final String provincia;
  final List<String> imagenes;
  // Moneda y datos del corredor (opcional)
  final String moneda;
  final String corredorId;
  final String corredorNombre;
  final String corredorImagen;
  final String corredorImagenPlaceholder;
  // URL de detalle si el backend la provee
  final String urlDetalle;
  final DateTime fechaPublicacion;
  final bool activa;
  final String? propietarioId;

  const PropiedadEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.tipoOperacion,
    required this.tipoPropiedad,
    required this.area,
    required this.habitaciones,
    required this.banos,
    required this.direccion,
    required this.ciudad,
    required this.provincia,
    required this.imagenes,
    this.moneda = '\$',
    this.corredorId = '',
    this.corredorNombre = '',
    this.corredorImagen = '',
    this.corredorImagenPlaceholder = '',
    this.urlDetalle = '',
    required this.fechaPublicacion,
    required this.activa,
    this.propietarioId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropiedadEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
