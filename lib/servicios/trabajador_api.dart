import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';  // Usamos api.dart para la URL base

class TrabajadorApi {

  // 🔹 Obtener perfil del trabajador
  static Future<Map<String, dynamic>> obtenerPerfil(int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/perfil")); // Reemplazamos el id del trabajador en la URL

    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  // 🔹 Obtener estadísticas del trabajador
    static Future<Map<String, dynamic>> obtenerEstadisticas(int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/estadisticas")); // URL con el id

    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  // 🔹 Obtener historial de incumplimientos del trabajador
  static Future<Map<String, dynamic>> obtenerIncumplimientos(int idTrabajador) async {
    final url = Uri.parse(api("/trabajadores/$idTrabajador/incumplimientos")); // URL con el id

    final response = await http.get(url);
    return jsonDecode(response.body);
  }
}
