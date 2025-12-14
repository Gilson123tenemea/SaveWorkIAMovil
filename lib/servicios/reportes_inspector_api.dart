import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class ReportesInspectorApi {

  final String baseUrl = ApiConfig.baseUrl;

  Future<List<dynamic>> obtenerIncumplimientosInspector({
    required int idInspector,
    String? fechaDesde,
    String? fechaHasta,
    int? idZona,
  }) async {

    final query = <String, String>{
      'id_inspector': idInspector.toString(),
      if (fechaDesde != null) 'fecha_desde': fechaDesde,
      if (fechaHasta != null) 'fecha_hasta': fechaHasta,
      if (idZona != null) 'id_zona': idZona.toString(),
    };

    final url = Uri.parse('$baseUrl/reportes/inspectores')
        .replace(queryParameters: query);

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception(
        'Error obteniendo incumplimientos inspector: ${resp.statusCode} - ${resp.body}',
      );
    }
  }

  Future<Map<String, dynamic>> obtenerHistorialPorCedula(String cedula) async {
    final url = Uri.parse(
      '$baseUrl/reportes/inspectores/trabajador',
    ).replace(queryParameters: {
      'cedula': cedula,
    });

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error obteniendo historial trabajador: ${resp.statusCode} - ${resp.body}',
      );
    }
  }



  Future<List<dynamic>> obtenerZonasInspector(int idInspector) async {

    final url = Uri.parse(
      '$baseUrl/reportes/inspectores/zonas',
    ).replace(queryParameters: {
      'id_inspector': idInspector.toString(),
    });

    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception(
        'Error obteniendo zonas inspector: ${resp.statusCode} - ${resp.body}',
      );
    }
  }
}
