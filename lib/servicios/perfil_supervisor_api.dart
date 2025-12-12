import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class PerfilSupervisorApi {

  /// 🔹 Obtener perfil completo del supervisor por ID
  Future<Map<String, dynamic>> obtenerPerfilSupervisor(int idSupervisor) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/supervisores/perfil/$idSupervisor',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener perfil del supervisor');
    }
  }
}
