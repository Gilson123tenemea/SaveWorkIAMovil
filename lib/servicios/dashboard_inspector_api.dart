import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class DashboardInspectorApi {

  Future<Map<String, dynamic>> obtenerDashboardInspector(int idZona) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/dashboard-inspector/$idZona"
    );

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("❌ Error al obtener dashboard inspector");
    }
  }
}
