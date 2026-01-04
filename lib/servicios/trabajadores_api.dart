import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class TrabajadoresApi {
  // 🔹 Listar Trabajadores de un Supervisor
  static Future<List<dynamic>> listarTrabajadoresPorSupervisor(int idSupervisor) async {
    final url = Uri.parse(api("/trabajadores/supervisor/$idSupervisor"));

    final response = await http.get(url);

    return jsonDecode(response.body);
  }

  // 🔹 Obtener Detalles de Trabajador Zonas (asignaciones activas)
  static Future<List<dynamic>> obtenerDetallesTrabajadorZonas() async {
    final url = Uri.parse(api("/trabajador_zonas/detalles"));

    final response = await http.get(url);

    return jsonDecode(response.body);
  }

  // 🔹 Listar Zonas por Supervisor (con detalles)
  static Future<List<dynamic>> listarZonasDetallesPorSupervisor(int idSupervisor) async {
    final url = Uri.parse(api("/trabajador_zonas/supervisor/$idSupervisor"));

    final response = await http.get(url);

    return jsonDecode(response.body);
  }

  // 🔹 Eliminar Lógico de Asignación Trabajador - Zona
  static Future<Map<String, dynamic>> eliminarLogicaAsignacionZona(int idAsignacion) async {
    final url = Uri.parse(api("/trabajador_zonas/eliminar-logico/$idAsignacion"));

    final response = await http.put(url);

    return jsonDecode(response.body);
  }

  // 🔹 Crear Asignación Trabajador - Zona
  static Future<Map<String, dynamic>> crearAsignacionTrabajadorZona(
      Map<String, dynamic> data,
      ) async {
    final url = Uri.parse(api("/trabajador_zonas/"));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    return jsonDecode(response.body);
  }
}