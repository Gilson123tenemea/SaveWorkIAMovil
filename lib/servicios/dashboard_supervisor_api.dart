import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class DashboardSupervisorApi {

  /// Obtener el resumen del dashboard para el supervisor
  static Future<Map<String, dynamic>> obtenerDashboard(int idEmpresa) async {
    final url = Uri.parse(api("/dashboard-supervisor/$idEmpresa"));

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Error al obtener dashboard: ${response.body}");
  }
}
