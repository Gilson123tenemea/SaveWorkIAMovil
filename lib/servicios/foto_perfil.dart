import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class FotoPerfilApi {
  /// Obtener foto de perfil de una persona
  static Future<Map<String, dynamic>> obtenerFotoPerfil(int personaId) async {
    // Sin cambios, ya estaba correcto
    final url = Uri.parse(api("/personas/$personaId"));

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'mensaje': 'Persona no encontrada',
          'statusCode': 404,
        };
      } else {
        return {
          'success': false,
          'mensaje': 'Error al obtener foto: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: $e',
        'exception': e.toString(),
      };
    }
  }

  /// Actualizar foto de perfil de una persona
  static Future<Map<String, dynamic>> actualizarFotoPerfil(
      int personaId,
      String fotoBase64,
      ) async {
    final url = Uri.parse(api("/personas/foto/$personaId"));

    try {
      // Agregar prefijo data URI si no lo tiene
      String fotoConPrefijo = fotoBase64;
      if (!fotoBase64.startsWith('data:image/')) {
        fotoConPrefijo = 'data:image/jpeg;base64,$fotoBase64';
      }

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: jsonEncode({
          "fotoBase64": fotoConPrefijo,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📤 PUT /personas/foto/$personaId');
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'mensaje': 'Persona no encontrada',
          'statusCode': 404,
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'mensaje': 'Datos inválidos: ${response.body}',
          'statusCode': 400,
        };
      } else {
        return {
          'success': false,
          'mensaje': 'Error al actualizar foto: ${response.statusCode}',
          'body': response.body,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexión: $e',
        'exception': e.toString(),
      };
    }
  }
}