import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class TrabajadorApi {
  static Future<Map<String, dynamic>> obtenerPerfil(int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/perfil"));
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> obtenerEstadisticas(
      int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/estadisticas"));
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> obtenerIncumplimientos(
      int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/incumplimientos"));
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> obtenerAsistencias(
      int idTrabajador, {
        int? mes,
        int? ano,
      }) async {
    String url = "/trabajadores/$idTrabajador/asistencias";

    List<String> params = [];
    if (mes != null) {
      params.add("mes=$mes");
    }
    if (ano != null) {
      params.add("año=$ano");
    }

    if (params.isNotEmpty) {
      url += "?${params.join('&')}";
    }

    final response = await http.get(Uri.parse(api(url)));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> actualizarTrabajador(
      int idTrabajador, {
        String? nombre,
        String? apellido,
        String? correo,
        String? telefono,
        String? cargo,
      }) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador"));

    Map<String, dynamic> body = {};

    if (nombre != null && nombre.trim().isNotEmpty) {
      body['nombre'] = nombre.trim();
    }
    if (apellido != null && apellido.trim().isNotEmpty) {
      body['apellido'] = apellido.trim();
    }
    if (correo != null && correo.trim().isNotEmpty) {
      body['correo'] = correo.trim();
    }
    if (telefono != null && telefono.trim().isNotEmpty) {
      body['telefono'] = telefono.trim();
    }
    if (cargo != null && cargo.trim().isNotEmpty) {
      body['cargo'] = cargo.trim();
    }

    print('🔧 Enviando body: $body');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Error al actualizar trabajador: ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(response.body);
  }
}