import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class ReportesIncumplimientosApi {
  final String baseUrl = ApiConfig.baseUrl;

  // =========================================================
  // 1️⃣ INCUMPLIMIENTOS POR SUPERVISOR (HOY)
  // =========================================================
  Future<List<dynamic>> obtenerIncumplimientosSupervisor(int idSupervisor) async {
    final url = Uri.parse('$baseUrl/reportes/incumplimientos?id_supervisor=$idSupervisor');

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Error obteniendo incumplimientos');
    }
  }

  // =========================================================
  // 2️⃣ HISTORIAL DEL TRABAJADOR
  // =========================================================
  Future<Map<String, dynamic>> obtenerHistorialTrabajador({
    String? cedula,
    String? codigoTrabajador,
    int? idTrabajador,
  }) async {
    final query = Uri(queryParameters: {
      'cedula': cedula,
      'codigo_trabajador': codigoTrabajador,
      'id_trabajador': idTrabajador?.toString()
    });

    final url = Uri.parse('$baseUrl/reportes/incumplimientos/trabajador${query.toString()}');

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Error obteniendo historial de trabajador');
    }
  }

  // =========================================================
  // 3️⃣ FILTRAR DETECCIONES
  // =========================================================
  Future<List<dynamic>> obtenerDeteccionesFiltradas({
    required int idEmpresa,
    String? fechaDesde,
    String? fechaHasta,
    int? idInspector,
    int? idZona,
  }) async {
    final query = {
      'id_empresa': idEmpresa.toString(),
      if (fechaDesde != null) 'fecha_desde': fechaDesde,
      if (fechaHasta != null) 'fecha_hasta': fechaHasta,
      if (idInspector != null) 'id_inspector': idInspector.toString(),
      if (idZona != null) 'id_zona': idZona.toString(),
    };

    final url = Uri.parse('$baseUrl/reportes/incumplimientos/detecciones')
        .replace(queryParameters: query);

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Error obteniendo detecciones filtradas');
    }
  }

  // =========================================================
  // 4️⃣ LISTAR INSPECTORES POR EMPRESA
  // =========================================================
  Future<List<dynamic>> obtenerInspectores(int idEmpresa) async {
    final url =
    Uri.parse('$baseUrl/reportes/incumplimientos/inspectores?id_empresa=$idEmpresa');

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Error listando inspectores');
    }
  }

  // =========================================================
  // 5️⃣ LISTAR ZONAS (POR EMPRESA O POR INSPECTOR)
  // =========================================================
  Future<List<dynamic>> obtenerZonas(int idEmpresa, {int? idInspector}) async {
    final url = Uri.parse(
        '$baseUrl/reportes/incumplimientos/zonas?id_empresa=$idEmpresa${idInspector != null ? '&id_inspector=$idInspector' : ''}');

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception('Error listando zonas');
    }
  }
}
