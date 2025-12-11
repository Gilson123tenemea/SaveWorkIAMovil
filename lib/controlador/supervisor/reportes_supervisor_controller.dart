import '../../servicios/reportes_incumplimientos_api.dart';

class ReportesSupervisorController {
  final api = ReportesIncumplimientosApi();

  // 1️⃣ Obtener incumplimientos del día por supervisor
  Future<List<dynamic>> obtenerIncumplimientosHoy(int idSupervisor) async {
    return await api.obtenerIncumplimientosSupervisor(idSupervisor);
  }

  Future<Map<String, dynamic>> obtenerHistorialTrabajador({
    String? cedula,
    String? codigoTrabajador,
    int? idTrabajador,
  }) async {
    // Enviar solo los parámetros que NO son null
    return await api.obtenerHistorialTrabajador(
      cedula: cedula,
      codigoTrabajador: codigoTrabajador,
      idTrabajador: idTrabajador,
    );
  }

  // 3️⃣ Obtener detecciones filtradas
  Future<List<dynamic>> obtenerDeteccionesFiltradas({
    required int idEmpresa,
    String? fechaDesde,
    String? fechaHasta,
    int? idInspector,
    int? idZona,
  }) async {
    return await api.obtenerDeteccionesFiltradas(
      idEmpresa: idEmpresa,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      idInspector: idInspector,
      idZona: idZona,
    );
  }

  // 4️⃣ Listar inspectores
  Future<List<dynamic>> obtenerInspectores(int idEmpresa) async {
    return await api.obtenerInspectores(idEmpresa);
  }

  // 5️⃣ Listar zonas
  Future<List<dynamic>> obtenerZonas(int idEmpresa, {int? idInspector}) async {
    return await api.obtenerZonas(idEmpresa, idInspector: idInspector);
  }
}
