import 'package:flutter/material.dart';
import '../../controlador/auth/login_controller.dart';
import '../../sesion/user_session.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final controller = LoginController();

  bool loading = false;
  String? errorMsg;

  void _doLogin() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    final result = await controller.login(
      correoCtrl.text.trim(),
      passCtrl.text.trim(),
    );
    print("RESPUESTA DEL SERVIDOR: $result");
    setState(() => loading = false);

    final rol = result["rol"] ?? result["role"];
    UserSession().rol = rol;
    UserSession().nombre = result["nombre"];
    UserSession().correo = result["correo"];

    if (rol == null) {
      setState(() => errorMsg = "Rol no reconocido: null");
      return;
    }

    if (rol == "supervisor") {
      UserSession().idSupervisor = result["id_supervisor"];
      UserSession().idEmpresaSupervisor = result["id_empresa_supervisor"];

      Navigator.pushReplacementNamed(context, "/supervisor/menu");
    }

    else if (rol == "inspector") {
      UserSession().idInspector = result["id_inspector"];

      Navigator.pushReplacementNamed(context, "/inspector/menu");
    }

    else if (rol == "trabajador") {
      UserSession().idTrabajador = result["id_trabajador"];
      UserSession().idEmpresaTrabajador = result["id_empresa_trabajador"];

      Navigator.pushReplacementNamed(context, "/trabajador/menu");
    }

    else {
      setState(() => errorMsg = "Rol no reconocido: $rol");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Iniciar Sesión", style: TextStyle(fontSize: 28)),
            SizedBox(height: 25),

            TextField(
              controller: correoCtrl,
              decoration: InputDecoration(labelText: "Correo"),
            ),

            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: "Contraseña"),
            ),

            if (errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(errorMsg!,
                    style: TextStyle(color: Colors.red, fontSize: 15)),
              ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : _doLogin,
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Ingresar"),
            ),
          ],
        ),
      ),
    );
  }
}
