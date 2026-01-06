import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class InspectoresApi {

  Future<List<dynamic>> listarInspectoresPorSupervisor(int idSupervisor) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/inspectores/supervisor/$idSupervisor"
    );

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Error al listar inspectores");
    }
  }

  Future<List<dynamic>> obtenerZonasPorInspector(int idInspector) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/inspectores/zonas/$idInspector"
    );

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Error al obtener zonas del inspector");
    }
  }

  Future<Map<String, dynamic>> obtenerPerfilInspector(int idInspector) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/inspectores/perfil/$idInspector"
    );

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Error al obtener perfil del inspector");
    }
  }

  Future<Map<String, dynamic>> actualizarPerfilInspector(
      int idInspector,
      Map<String, dynamic> datosPerfil,
      ) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/inspectores/perfil/$idInspector"
    );

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(datosPerfil),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? "❌ Error al actualizar perfil");
    }
  }
}
