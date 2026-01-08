import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../esquemas/fcm_token_esquema.dart';

class FCMTokenApi {
  /// 📤 Registra el token FCM en el backend
  static Future<FCMTokenResponse> registrarTokenFCM(
      int idInspector,
      String tokenFcm,
      ) async {
    final url = Uri.parse(api("/inspectores/$idInspector/fcm-token"));

    final body = FCMTokenRegistro(
      tokenFcm: tokenFcm,
    ).toJson();

    print('📤 Enviando token FCM al backend');
    print('   Inspector: $idInspector');
    print('   Token: ${tokenFcm.substring(0, 20)}...');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✅ Token FCM registrado exitosamente');
        return FCMTokenResponse.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al registrar token FCM');
      }
    } catch (e) {
      print('❌ Excepción al registrar token: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// 📋 Obtiene todos los tokens del inspector
  static Future<List<Map<String, dynamic>>> obtenerTokens(
      int idInspector,
      ) async {
    final url = Uri.parse(api("/inspectores/$idInspector/fcm-tokens"));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error al obtener tokens');
      }
    } catch (e) {
      print('Error obteniendo tokens: $e');
      throw Exception('Error de conexión');
    }
  }

  /// 🗑️ Elimina un token del inspector
  static Future<void> eliminarToken(
      int idInspector,
      String tokenFcm,
      ) async {
    final url = Uri.parse(api("/inspectores/$idInspector/fcm-token"));

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'token_fcm': tokenFcm}),
      );

      if (response.statusCode == 200) {
        print('✅ Token eliminado exitosamente');
      } else {
        throw Exception('Error al eliminar token');
      }
    } catch (e) {
      print('Error eliminando token: $e');
      throw Exception('Error de conexión');
    }
  }
}