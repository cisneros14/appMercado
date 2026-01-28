// Helper para normalizar rutas de imágenes provenientes del backend.
// Acepta valores nulos, rutas relativas, paths con ../, rutas que empiezan con
// img/, admin/img/, /img/, /admin/img/, //host/... o URLs completas y devuelve
// una URL absoluta percent-encoded para evitar problemas con espacios u
// caracteres inválidos en NetworkImage.
String normalizeImage(dynamic img) {
  const baseHost = 'https://mercadoinmobiliario.ec';
  const defaultPath = '$baseHost/admin/img/default.jpg';

  if (img == null) return defaultPath;
  final s = img.toString().trim();
  if (s.isEmpty) return defaultPath;
  if (s.startsWith('http')) return Uri.encodeFull(s);
  if (s.startsWith('//')) return Uri.encodeFull('https:$s');
  if (s.startsWith('file:')) return s; // Mantener local para Image.file

  // Limpiar referencias relativas (./ ../) y backslashes
  var cleaned = s.replaceAll(RegExp(r'^(?:\./|\.\./)+'), '');
  cleaned = cleaned.replaceAll('\\', '/');

  // Si ya contiene el host pero sin esquema
  if (cleaned.contains('mercadoinmobiliario.ec')) {
    if (cleaned.startsWith('http')) return Uri.encodeFull(cleaned);
    if (cleaned.startsWith('//')) return Uri.encodeFull('https:$cleaned');
    return Uri.encodeFull(
      'https://$cleaned'.replaceAll('https://https://', 'https://'),
    );
  }

  // Manejar formas comunes
  if (cleaned.startsWith('images/'))
    return Uri.encodeFull('$baseHost/$cleaned');
  if (cleaned.startsWith('/admin/img/'))
    return Uri.encodeFull('$baseHost$cleaned');
  if (cleaned.startsWith('/img/'))
    return Uri.encodeFull('$baseHost/admin$cleaned');
  if (cleaned.startsWith('admin/img/'))
    return Uri.encodeFull('$baseHost/$cleaned');
  if (cleaned.startsWith('img/'))
    return Uri.encodeFull('$baseHost/admin/$cleaned');
  if (cleaned.startsWith('admin/')) return Uri.encodeFull('$baseHost/$cleaned');

  // Por defecto, asumir que es filename dentro de /admin/img/
  return Uri.encodeFull('$baseHost/admin/img/$cleaned');
}

/// Devuelve una lista de variantes de URL candidatas para intentar cargar la
/// imagen. Ordenada por preferencia.
List<String> normalizeImageVariants(dynamic img) {
  const baseHost = 'https://mercadoinmobiliario.ec';
  const defaultPath = '$baseHost/admin/img/default.jpg';

  if (img == null) return [defaultPath];
  final s = img.toString().trim();
  if (s.isEmpty) return [defaultPath];
  if (s.startsWith('http')) return [Uri.encodeFull(s)];
  if (s.startsWith('//')) return [Uri.encodeFull('https:$s')];
  if (s.startsWith('file:')) return [s]; // Mantener local para Image.file

  var cleaned = s.replaceAll(RegExp(r'^(?:\./|\.\./)+'), '');
  cleaned = cleaned.replaceAll('\\', '/');

  final List<String> out = [];

  // Si ya contiene el host
  if (cleaned.contains('mercadoinmobiliario.ec')) {
    out.add(
      Uri.encodeFull(
        'https://$cleaned'.replaceAll('https://https://', 'https://'),
      ),
    );
  }

  if (cleaned.startsWith('images/')) {
    out.add(Uri.encodeFull('$baseHost/$cleaned'));
    out.add(Uri.encodeFull('$baseHost/admin/$cleaned'));
  }
  // Variantes comunes para imagenes de usuarios/admin y propiedades
  if (cleaned.startsWith('/admin/img/'))
    out.add(Uri.encodeFull('$baseHost$cleaned'));
  if (cleaned.startsWith('/img/'))
    out.add(Uri.encodeFull('$baseHost/images$cleaned'));
  if (cleaned.startsWith('img/')) {
    out.add(Uri.encodeFull('$baseHost/images/$cleaned')); // propiedades
    out.add(Uri.encodeFull('$baseHost/admin/$cleaned')); // agentes
    out.add(Uri.encodeFull('$baseHost/admin/img/$cleaned'));
    out.add(Uri.encodeFull('$baseHost/admin/images/$cleaned'));
    out.add(Uri.encodeFull('$baseHost/images/${cleaned.replaceFirst('img/', '')}'));
    out.add(Uri.encodeFull('$baseHost/admin/img/${cleaned.replaceFirst('img/', '')}'));
  }

  if (cleaned.startsWith('admin/img/'))
    out.add(Uri.encodeFull('$baseHost/$cleaned'));
  if (cleaned.startsWith('admin/'))
    out.add(Uri.encodeFull('$baseHost/$cleaned'));

  // Asegurar que la lista tiene al menos una variante razonable
  if (out.isEmpty) out.add(Uri.encodeFull('$baseHost/admin/img/$cleaned'));

  // Añadir default al final
  out.add(defaultPath);
  // Eliminar duplicados manteniendo orden
  final seen = <String>{};
  final uniq = <String>[];
  for (final u in out) {
    if (!seen.contains(u)) {
      seen.add(u);
      uniq.add(u);
    }
  }
  return uniq;
}
