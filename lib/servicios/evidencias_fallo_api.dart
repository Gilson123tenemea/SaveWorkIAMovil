import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class EvidenciasFalloApi {

  final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> actualizarEvidenciaFallo({
    required int idEvidencia,
    String? estado,
    String? observaciones,
  }) async {

    final url = Uri.parse(
      '$baseUrl/evidencias-fallo/actualizar/$idEvidencia',
    );

    final body = <String, dynamic>{
      if (estado != null) 'estado': estado,
      if (observaciones != null) 'observaciones': observaciones,
    };

    final resp = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception(
        'Error actualizando evidencia: ${resp.statusCode} - ${resp.body}',
      );
    }
  }
}
