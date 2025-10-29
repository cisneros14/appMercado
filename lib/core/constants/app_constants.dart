/// Constantes globales de la aplicación Triara
/// 
/// Este archivo contiene todas las constantes utilizadas en la aplicación
/// siguiendo la nomenclatura SCREAMING_SNAKE_CASE para constantes.

class AppConstants {
  // URL Base de la API
  static const String API_BASE_URL = 'https://mercadoinmobiliario.ec/admin/apis/';
  
  // Endpoints principales
  static const String PROPIEDADES_ENDPOINT = 'propiedades';
  static const String USUARIOS_ENDPOINT = 'usuarios';
  static const String AUTH_ENDPOINT = 'auth';
  
  // Configuración de la aplicación
  static const String APP_NAME = 'Triara';
  static const String APP_VERSION = '1.0.0';
  
  // Timeouts
  static const int CONNECTION_TIMEOUT = 30000; // 30 segundos
  static const int RECEIVE_TIMEOUT = 30000;    // 30 segundos
  
  // Claves de almacenamiento local
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_DATA_KEY = 'user_data';
  static const String THEME_KEY = 'theme_preference';
  
  // Tipos de propiedad
  static const String TIPO_VENTA = 'venta';
  static const String TIPO_RENTA = 'renta';
  static const String TIPO_COMPRA = 'compra';
  
  // Configuración de paginación
  static const int PAGE_SIZE = 20;
  static const int MAX_PAGE_SIZE = 100;
}