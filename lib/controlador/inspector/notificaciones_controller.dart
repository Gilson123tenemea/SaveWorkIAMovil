import '../../servicios/notificaciones_api.dart';

class NotificacionesController {
  final NotificacionesApi api = NotificacionesApi();

  Future<List<dynamic>> obtenerNotificaciones(int idInspector) async {
    return await api.obtenerNotificacionesInspector(idInspector);
  }

  Future<Map<String, dynamic>> marcarComoRevisada(int idEvidencia) async {
    return await api.marcarNotificacionRevisada(idEvidencia);
  }

  Future<int> contarNotificacionesPendientes(int idInspector) async {
    final notificaciones = await api.obtenerNotificacionesInspector(idInspector);
    return notificaciones.where((n) => n['estado'] == true || n['estado'] == null).length;
  }
}