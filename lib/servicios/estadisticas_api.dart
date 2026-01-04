import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class EstadisticasApi {

  static Future<Map<String, dynamic>> obtenerIncumplimientosPorZona({
    required int idInspector,
    required int idEmpresa,
    String? fechaDesde,
    String? fechaHasta,
  }) async {

    final queryParams = {
      'id_inspector': idInspector.toString(),
      'id_empresa': idEmpresa.toString(),
      if (fechaDesde != null) 'fecha_desde': fechaDesde,
      if (fechaHasta != null) 'fecha_hasta': fechaHasta,
    };

    final uri = Uri.parse(api("/reportes/estadisticas/zonas-incumplimiento"))
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener incumplimientos por zona: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> obtenerCumplimientosPorZona({
    required int idInspector,
    required int idEmpresa,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    final queryParams = {
      'id_inspector': idInspector.toString(),
      'id_empresa': idEmpresa.toString(),
      if (fechaDesde != null) 'fecha_desde': fechaDesde,
      if (fechaHasta != null) 'fecha_hasta': fechaHasta,
    };

    final uri = Uri.parse(api("/reportes/estadisticas/zonas-cumplimiento"))
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener cumplimientos por zona: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> obtenerEppMasCumplido({
    required int idEmpresa,
    int? idInspector,
    int? idZona,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    final queryParams = {
      'id_empresa': idEmpresa.toString(),
      if (idInspector != null) 'id_inspector': idInspector.toString(),
      if (idZona != null) 'id_zona': idZona.toString(),
      if (fechaDesde != null) 'fecha_desde': fechaDesde,
      if (fechaHasta != null) 'fecha_hasta': fechaHasta,
    };

    final uri = Uri.parse(api("/reportes/estadisticas/epp-pastel"))
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener estadísticas de EPP: ${response.statusCode}');
    }
  }
}