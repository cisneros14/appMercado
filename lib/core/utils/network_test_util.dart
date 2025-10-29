import 'package:dio/dio.dart';

/// Utilidad para probar conectividad de red
class NetworkTestUtil {
  static Future<bool> testConnectivity() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      
      // Probar con Google primero (test general de internet)
      final googleResponse = await dio.get('https://www.google.com');
      print('✅ Conectividad general: OK (Google: ${googleResponse.statusCode})');
      
      // Probar la API específica
      final apiResponse = await dio.get('https://mercadoinmobiliario.ec/admin/apis/');
      print('✅ Conectividad API: OK (API: ${apiResponse.statusCode})');
      
      return true;
    } on DioException catch (e) {
      print('❌ Error de conectividad:');
      print('   Tipo: ${e.type}');
      print('   Mensaje: ${e.message}');
      if (e.response != null) {
        print('   Status: ${e.response?.statusCode}');
        print('   Data: ${e.response?.data}');
      }
      return false;
    } catch (e) {
      print('❌ Error general: $e');
      return false;
    }
  }
  
  static Future<bool> testApiEndpoint() async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 15);
      dio.options.receiveTimeout = const Duration(seconds: 15);
      
      // Test directo al endpoint de login
      final response = await dio.post(
        'https://mercadoinmobiliario.ec/admin/apis/login.php',
        data: FormData.fromMap({
          'user_name': 'test',
          'user_password': 'test',
        }),
      );
      
      print('✅ API Login endpoint responde: ${response.statusCode}');
      print('📝 Respuesta: ${response.data}');
      return true;
    } on DioException catch (e) {
      print('❌ Error en API endpoint:');
      print('   Tipo: ${e.type}');
      print('   Mensaje: ${e.message}');
      if (e.response != null) {
        print('   Status: ${e.response?.statusCode}');
        print('   Headers: ${e.response?.headers}');
      }
      return false;
    }
  }
}