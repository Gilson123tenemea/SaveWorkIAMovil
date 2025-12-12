import '../../servicios/reportes_inspector_api.dart';

class ReportesInspectorController {

  final ReportesInspectorApi _api = ReportesInspectorApi();

  // 🔹 Incumplimientos (hoy o con filtros)
  Future<List<dynamic>> obtenerIncumplimientos({
    required int idInspector,
    String? fechaDesde,
    String? fechaHasta,
    int? idZona,
  }) async {

    return await _api.obtenerIncumplimientosInspector(
      idInspector: idInspector,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      idZona: idZona,
    );
  }

  // 🔹 Historial trabajador
  Future<List<dynamic>> obtenerHistorialTrabajador(String cedula) async {
    return await _api.obtenerHistorialPorCedula(cedula);
  }

  // 🔹 Zonas del inspector
  Future<List<dynamic>> obtenerZonasInspector(int idInspector) async {
    return await _api.obtenerZonasInspector(idInspector);
  }
}
