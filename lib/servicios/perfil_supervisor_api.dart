import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class PerfilSupervisorApi {
  /// Obtener perfil completo del supervisor por ID
  Future<Map<String, dynamic>> obtenerPerfilSupervisor(int idSupervisor) async {
    final url = Uri.parse(
      api("/supervisores/perfil/$idSupervisor"),
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener perfil del supervisor');
    }
  }

  /// Actualizar perfil del supervisor (nombre, correo, telefono)
  Future<Map<String, dynamic>> actualizarPerfilSupervisor(
      int idSupervisor,
      String nombre,
      String apellido,
      String correo,
      String telefono,
      ) async {
    final url = Uri.parse(
      api("/supervisores/perfil/$idSupervisor"),
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "nombre": nombre,
        "apellido": apellido,
        "correo": correo,
        "telefono": telefono,
      }),

    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar perfil del supervisor');
    }
  }

  /// Actualizar foto de perfil del supervisor
  Future<Map<String, dynamic>> actualizarFotoSupervisor(
      int idPersona,
      String fotoBase64,
      ) async {
    final url = Uri.parse(
      api("/personas/foto/$idPersona"),
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "fotoBase64": fotoBase64,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar foto del perfil');
    }
  }
}