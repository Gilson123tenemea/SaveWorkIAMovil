import '../../servicios/dashboard_inspector_api.dart';

class DashboardInspectorController {

  final DashboardInspectorApi api = DashboardInspectorApi();

  Future<Map<String, dynamic>> obtenerDatosDashboard(int idInspector) async {
    return await api.obtenerDashboardInspector(idInspector);
  }
}
