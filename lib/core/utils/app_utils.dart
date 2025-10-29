/// Utilidades generales para la aplicación Triara
/// 
/// Contiene funciones auxiliares y utilidades comunes
/// utilizadas en toda la aplicación.

class AppUtils {
  /// Formatea un precio para mostrar en la UI
  static String formatPrice(double price, {String currency = 'USD'}) {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(1)}M $currency';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(1)}K $currency';
    } else {
      return '\$${price.toStringAsFixed(0)} $currency';
    }
  }
  
  /// Valida si un email es válido
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Valida si un teléfono es válido (Ecuador)
  static bool isValidPhone(String phone) {
    // Formato: +593XXXXXXXXX o 09XXXXXXXX
    return RegExp(r'^(\+593|0)[0-9]{9}$').hasMatch(phone);
  }
  
  /// Capitaliza la primera letra de una cadena
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Trunca un texto a una longitud específica
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Convierte metros cuadrados a formato legible
  static String formatArea(double area) {
    return '${area.toStringAsFixed(0)} m²';
  }
  
  /// Genera una imagen placeholder URL
  static String getPlaceholderImageUrl(int width, int height) {
    return 'https://picsum.photos/$width/$height';
  }
}