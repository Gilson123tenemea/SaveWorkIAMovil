import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class NotificacionesApi {
  Future<List<dynamic>> obtenerNotificacionesInspector(int idInspector) async {
    final url = Uri.parse(
      api("/inspectores/$idInspector/notificaciones"),
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
      throw Exception('Error al obtener notificaciones del inspector');
    }
  }

  Future<Map<String, dynamic>> marcarNotificacionRevisada(int idEvidencia) async {
    final url = Uri.parse(
      api("/inspectores/notificaciones/$idEvidencia/revisar"),
    );

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al marcar notificación como revisada');
    }
  }
}