import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';  // Usamos api.dart para la URL base

class TrabajadorApi {

  static Future<Map<String, dynamic>> obtenerPerfil(int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/perfil"));

    final response = await http.get(url);
    return jsonDecode(response.body);
  }

    static Future<Map<String, dynamic>> obtenerEstadisticas(int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/estadisticas")); // URL con el id

    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> obtenerIncumplimientos(int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/incumplimientos")); // URL con el id

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
}
