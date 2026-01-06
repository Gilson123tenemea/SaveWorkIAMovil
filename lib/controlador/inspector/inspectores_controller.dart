import '../../servicios/inspectores_api.dart';

class InspectoresController {

  final InspectoresApi api = InspectoresApi();

  Future<List<dynamic>> obtenerInspectoresPorSupervisor(int idSupervisor) async {
    return await api.listarInspectoresPorSupervisor(idSupervisor);
  }

  Future<List<dynamic>> obtenerZonasInspector(int idInspector) async {
    return await api.obtenerZonasPorInspector(idInspector);
  }

  Future<Map<String, dynamic>> obtenerPerfilInspector(int idInspector) async {
    return await api.obtenerPerfilInspector(idInspector);
  }

  Future<Map<String, dynamic>> actualizarPerfilInspector(
      int idInspector,
      Map<String, dynamic> datosPerfil,
      ) async {
    return await api.actualizarPerfilInspector(idInspector, datosPerfil);
  }
}
