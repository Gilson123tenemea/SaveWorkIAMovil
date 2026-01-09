import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;

  UserSession._internal();

  int? idSupervisor;
  int? idInspector;
  int? idTrabajador;
  int? idPersona;
  int? idEmpresa;
  int? idEmpresaSupervisor;
  int? idEmpresaTrabajador;

  String? nombre;
  String? correo;
  String? rol;
  String? nombreEmpresa;
  String? fcmToken;

  Future<void> guardarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    if (idSupervisor != null) await prefs.setInt('idSupervisor', idSupervisor!);
    if (idInspector != null) await prefs.setInt('idInspector', idInspector!);
    if (idTrabajador != null) await prefs.setInt('idTrabajador', idTrabajador!);
    if (idPersona != null) await prefs.setInt('idPersona', idPersona!);
    if (idEmpresa != null) await prefs.setInt('idEmpresa', idEmpresa!);
    if (idEmpresaSupervisor != null) await prefs.setInt('idEmpresaSupervisor', idEmpresaSupervisor!);
    if (idEmpresaTrabajador != null) await prefs.setInt('idEmpresaTrabajador', idEmpresaTrabajador!);

    if (nombre != null) await prefs.setString('nombre', nombre!);
    if (correo != null) await prefs.setString('correo', correo!);
    if (rol != null) await prefs.setString('rol', rol!);
    if (nombreEmpresa != null) await prefs.setString('nombreEmpresa', nombreEmpresa!);
    if (fcmToken != null) await prefs.setString('fcmToken', fcmToken!);

    print("💾 Sesión guardada en SharedPreferences");
  }

  Future<bool> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    idSupervisor = prefs.getInt('idSupervisor');
    idInspector = prefs.getInt('idInspector');
    idTrabajador = prefs.getInt('idTrabajador');
    idPersona = prefs.getInt('idPersona');
    idEmpresa = prefs.getInt('idEmpresa');
    idEmpresaSupervisor = prefs.getInt('idEmpresaSupervisor');
    idEmpresaTrabajador = prefs.getInt('idEmpresaTrabajador');

    nombre = prefs.getString('nombre');
    correo = prefs.getString('correo');
    rol = prefs.getString('rol');
    nombreEmpresa = prefs.getString('nombreEmpresa');
    fcmToken = prefs.getString('fcmToken');

    bool tieneSesion = rol != null &&
        (idSupervisor != null || idInspector != null || idTrabajador != null);

    if (tieneSesion) {
      print("✅ Sesión cargada desde SharedPreferences");
      print("   Rol: $rol");
      print("   Nombre: $nombre");
    } else {
      print("⚠️ No hay sesión guardada");
    }

    return tieneSesion;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    idSupervisor = null;
    idInspector = null;
    idTrabajador = null;
    idPersona = null;
    idEmpresa = null;
    idEmpresaSupervisor = null;
    idEmpresaTrabajador = null;
    nombre = null;
    correo = null;
    rol = null;
    nombreEmpresa = null;
    fcmToken = null;

    print("🗑️ Sesión eliminada de SharedPreferences");
  }

  bool get tieneEmpresa => idEmpresa != null;
  bool get esInspector => rol == 'inspector' && idInspector != null;
  bool get puedeVerEstadisticas => esInspector && tieneEmpresa;
}