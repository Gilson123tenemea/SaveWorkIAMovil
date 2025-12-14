import '../../servicios/evidencias_fallo_api.dart';

class EvidenciasFalloController {
  final EvidenciasFalloApi _api = EvidenciasFalloApi();

  Future<Map<String, dynamic>> actualizarEvidencia({
    required int idEvidencia,
    dynamic estado, // ✅ antes String? -> ahora dynamic para enviar bool/int
    String? observaciones,
  }) async {
    if (estado == null && observaciones == null) {
      throw Exception('Debe enviar al menos un campo para actualizar');
    }

    return await _api.actualizarEvidenciaFallo(
      idEvidencia: idEvidencia,
      estado: estado,
      observaciones: observaciones,
    );
  }
}
