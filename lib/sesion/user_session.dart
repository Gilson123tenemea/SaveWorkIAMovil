class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;

  UserSession._internal();

  int? idSupervisor;
  int? idInspector;
  int? idTrabajador;

  int? idEmpresa;
  int? idEmpresaSupervisor;
  int? idEmpresaTrabajador;

  String? nombre;
  String? correo;
  String? rol;
  String? nombreEmpresa;

  void clear() {
    idSupervisor = null;
    idInspector = null;
    idTrabajador = null;
    idEmpresa = null;
    idEmpresaSupervisor = null;
    idEmpresaTrabajador = null;
    nombre = null;
    correo = null;
    rol = null;
    nombreEmpresa = null;
  }

  bool get tieneEmpresa => idEmpresa != null;
  bool get esInspector => rol == 'inspector' && idInspector != null;
  bool get puedeVerEstadisticas => esInspector && tieneEmpresa;
}