import '../../servicios/inspectores_api.dart';

class InspectoresController {

  final InspectoresApi api = InspectoresApi();

  /// 🔹 Inspectores por supervisor
  Future<List<dynamic>> obtenerInspectoresPorSupervisor(int idSupervisor) async {
    return await api.listarInspectoresPorSupervisor(idSupervisor);
  }

  /// 🔹 Zonas asignadas a inspector
  Future<List<dynamic>> obtenerZonasInspector(int idInspector) async {
    return await api.obtenerZonasPorInspector(idInspector);
  }

  /// 🔹 Perfil del inspector
  Future<Map<String, dynamic>> obtenerPerfilInspector(int idInspector) async {
    return await api.obtenerPerfilInspector(idInspector);
  }
}
