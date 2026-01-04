import '../../servicios/auth_api.dart';
import '../../sesion/user_session.dart';

class LoginController {
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    if (correo.isEmpty || contrasena.isEmpty) {
      return {"error": "Todos los campos son obligatorios"};
    }

    UserSession().clear();

    final sup = await AuthApi.loginSupervisor(correo, contrasena);
    if (!sup.containsKey("error") && !sup.containsKey("detail")) {
      _guardarSesionSupervisor(sup);
      return sup;
    }

    final ins = await AuthApi.loginInspector(correo, contrasena);
    if (!ins.containsKey("error") && !ins.containsKey("detail")) {
      _guardarSesionInspector(ins);
      return ins;
    }

    final trab = await AuthApi.loginTrabajador(correo, contrasena);
    if (!trab.containsKey("error") && !trab.containsKey("detail")) {
      _guardarSesionTrabajador(trab);
      return trab;
    }

    return {"error": "Credenciales incorrectas"};
  }

  void _guardarSesionSupervisor(Map<String, dynamic> data) {
    final session = UserSession();

    session.idSupervisor = data['id_supervisor'];
    session.idEmpresaSupervisor = data['id_empresa'];
    session.nombreEmpresa = data['empresa'];
    session.nombre = data['nombre'];
    session.correo = data['correo'];
    session.rol = data['rol'];

    print("✅ Sesión Supervisor guardada:");
    print("   ID: ${session.idSupervisor}");
    print("   Empresa ID: ${session.idEmpresaSupervisor}");
    print("   Empresa: ${session.nombreEmpresa}");
  }

  void _guardarSesionInspector(Map<String, dynamic> data) {
    final session = UserSession();

    session.idInspector = data['id_inspector'];
    session.idEmpresa = data['id_empresa'];
    session.nombreEmpresa = data['empresa'];
    session.nombre = data['nombre'];
    session.correo = data['correo'];
    session.rol = data['rol'];

    print("✅ Sesión Inspector guardada:");
    print("   ID: ${session.idInspector}");
    print("   Empresa ID: ${session.idEmpresa}");
    print("   Empresa: ${session.nombreEmpresa}");
    print("   Puede ver estadísticas: ${session.puedeVerEstadisticas}");
  }

  void _guardarSesionTrabajador(Map<String, dynamic> data) {
    final session = UserSession();

    session.idTrabajador = data['id_trabajador'];
    session.idEmpresaTrabajador = data['id_empresa'];
    session.nombreEmpresa = data['empresa'];
    session.nombre = data['nombre'];
    session.correo = data['correo'];
    session.rol = data['rol'];

    print("✅ Sesión Trabajador guardada:");
    print("   ID: ${session.idTrabajador}");
    print("   Empresa ID: ${session.idEmpresaTrabajador}");
    print("   Empresa: ${session.nombreEmpresa}");
  }

  bool tieneSesionActiva() {
    final session = UserSession();
    return session.rol != null &&
        (session.idSupervisor != null ||
            session.idInspector != null ||
            session.idTrabajador != null);
  }

  void logout() {
    UserSession().clear();
    print("🔓 Sesión cerrada");
  }
}