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

  void clear() {
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
  }

  bool get tieneEmpresa => idEmpresa != null;
  bool get esInspector => rol == 'inspector' && idInspector != null;
  bool get puedeVerEstadisticas => esInspector && tieneEmpresa;
}