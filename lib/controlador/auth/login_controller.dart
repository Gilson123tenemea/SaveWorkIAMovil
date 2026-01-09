import '../../servicios/auth_api.dart';
import '../../sesion/user_session.dart';
import '../../services/firebase_messaging_service.dart';

class LoginController {
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    if (correo.isEmpty || contrasena.isEmpty) {
      return {"error": "Todos los campos son obligatorios"};
    }

    await UserSession().clear();

    final sup = await AuthApi.loginSupervisor(correo, contrasena);
    if (!sup.containsKey("error") && !sup.containsKey("detail")) {
      await _guardarSesionSupervisor(sup);
      print('👨‍💼 Logged as SUPERVISOR - Token FCM NOT registered');
      return sup;
    }

    final ins = await AuthApi.loginInspector(correo, contrasena);
    if (!ins.containsKey("error") && !ins.containsKey("detail")) {
      await _guardarSesionInspector(ins);
      print('👁️ Logged as INSPECTOR - Registering FCM Token...');
      await FirebaseMessagingService.registrarTokenFCMEnBackend();
      return ins;
    }

    final trab = await AuthApi.loginTrabajador(correo, contrasena);
    if (!trab.containsKey("error") && !trab.containsKey("detail")) {
      await _guardarSesionTrabajador(trab);
      print('👷 Logged as TRABAJADOR - Token FCM NOT registered');
      return trab;
    }

    return {"error": "Credenciales incorrectas"};
  }

  Future<void> _guardarSesionSupervisor(Map<String, dynamic> data) async {
    final session = UserSession();
    session.idSupervisor = data['id_supervisor'];
    session.idPersona = data['id_persona'];
    session.idEmpresaSupervisor = data['id_empresa_supervisor'];
    session.nombreEmpresa = data['empresa'];
    session.nombre = data['nombre'];
    session.correo = data['correo'];
    session.rol = data['rol'];

    await session.guardarSesion();

    print("✅ Sesión Supervisor guardada");
    print("   ID: ${session.idSupervisor}");
    print("   Nombre: ${session.nombre}");
  }

  Future<void> _guardarSesionInspector(Map<String, dynamic> data) async {
    final session = UserSession();
    session.idInspector = data['id_inspector'];
    session.idPersona = data['id_persona'];
    session.idEmpresa = data['id_empresa'];
    session.nombreEmpresa = data['empresa'];
    session.nombre = data['nombre'];
    session.correo = data['correo'];
    session.rol = data['rol'];

    await session.guardarSesion();

    print("✅ Sesión Inspector guardada");
    print("   ID Inspector: ${session.idInspector}");
    print("   ID Persona: ${session.idPersona}");
    print("   Nombre: ${session.nombre}");
  }

  Future<void> _guardarSesionTrabajador(Map<String, dynamic> data) async {
    final session = UserSession();
    session.idPersona = data['id_persona'];
    session.idTrabajador = data['id_trabajador'];
    session.idEmpresaTrabajador = data['id_empresa'];
    session.nombreEmpresa = data['empresa'];
    session.nombre = data['nombre'];
    session.correo = data['correo'];
    session.rol = data['rol'];

    await session.guardarSesion();

    print("✅ Sesión Trabajador guardada");
    print("   ID: ${session.idTrabajador}");
    print("   Nombre: ${session.nombre}");
  }

  Future<bool> tieneSesionActiva() async {
    return await UserSession().cargarSesion();
  }

  Future<void> logout() async {
    final session = UserSession();

    print('\n🔐 === LOGOUT === 🔐');
    print('Rol: ${session.rol}');

    if (session.rol == "inspector") {
      print('🗑️ Eliminando token FCM del backend...');
      await FirebaseMessagingService.eliminarTokenAlLogout();
    } else {
      print('⚠️ No es inspector, no se elimina token');
    }

    await UserSession().clear();
    print("🔓 Sesión cerrada\n");
  }
}