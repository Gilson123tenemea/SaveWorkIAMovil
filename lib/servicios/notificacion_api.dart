import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../esquemas/notificacion_esquema.dart';

class NotificacionApi {
  static Future<List<Notificacion>> obtenerNotificaciones(
      int idInspector,
      ) async {
    final url = Uri.parse(api("/inspectores/$idInspector/notificaciones"));

    try {
      print('📡 Obteniendo notificaciones para inspector: $idInspector');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ ${data.length} notificaciones obtenidas');

        return data.map((json) => Notificacion.fromJson(json)).toList();
      } else {
        print('❌ Error ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error obteniendo notificaciones: $e');
      return [];
    }
  }

  static Future<bool> marcarComoRevisada(int idEvidencia) async {
    final url = Uri.parse(
        api("/inspectores/notificaciones/$idEvidencia/revisar"));

    try {
      print('📝 Marcando como revisada: $idEvidencia');

      final response = await http.put(url);

      if (response.statusCode == 200) {
        print('✅ Notificación marcada como revisada');
        return true;
      } else {
        print('❌ Error al marcar como revisada: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }
}
