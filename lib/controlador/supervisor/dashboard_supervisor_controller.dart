import '../../servicios/dashboard_supervisor_api.dart';

class DashboardSupervisorController {

  Future<Map<String, dynamic>> obtenerDatosDashboard(int idEmpresa) async {
    if (idEmpresa == 0 || idEmpresa == null) {
      return {"error": "ID de empresa inválido"};
    }

    try {
      final data = await DashboardSupervisorApi.obtenerDashboard(idEmpresa);
      return data;
    } catch (e) {
      return {"error": "No se pudo obtener el dashboard: $e"};
    }
  }
}
