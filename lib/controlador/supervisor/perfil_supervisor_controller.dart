import '../../servicios/perfil_supervisor_api.dart';

class PerfilSupervisorController {

  final PerfilSupervisorApi _api = PerfilSupervisorApi();

  /// 🔹 Obtener perfil del supervisor
  Future<Map<String, dynamic>> obtenerPerfilSupervisor(int idSupervisor) async {
    return await _api.obtenerPerfilSupervisor(idSupervisor);
  }
}
