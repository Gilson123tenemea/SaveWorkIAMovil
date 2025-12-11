import '../../servicios/auth_api.dart';

class LoginController {
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    if (correo.isEmpty || contrasena.isEmpty) {
      return {"error": "Todos los campos son obligatorios"};
    }

    // 1️⃣ Intentar login como supervisor
    final sup = await AuthApi.loginSupervisor(correo, contrasena);
    if (!sup.containsKey("error") && !sup.containsKey("detail")) {
      return sup;
    }

    // 2️⃣ Intentar login como inspector
    final ins = await AuthApi.loginInspector(correo, contrasena);
    if (!ins.containsKey("error") && !ins.containsKey("detail")) {
      return ins;
    }

    // 3️⃣ Intentar login como trabajador
    final trab = await AuthApi.loginTrabajador(correo, contrasena);
    if (!trab.containsKey("error") && !trab.containsKey("detail")) {
      return trab;
    }

    // Si ninguno funciona
    return {"error": "Credenciales incorrectas"};
  }
}
