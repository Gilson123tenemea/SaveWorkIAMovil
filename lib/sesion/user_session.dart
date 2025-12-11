class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;

  UserSession._internal();

  int? idSupervisor;
  int? idInspector;
  int? idTrabajador;

  int? idEmpresaSupervisor;
  int? idEmpresaTrabajador;

  String? nombre;
  String? correo;
  String? rol;

  void clear() {
    idSupervisor = null;
    idInspector = null;
    idTrabajador = null;
    idEmpresaSupervisor = null;
    idEmpresaTrabajador = null;
    nombre = null;
    correo = null;
    rol = null;
  }
}
