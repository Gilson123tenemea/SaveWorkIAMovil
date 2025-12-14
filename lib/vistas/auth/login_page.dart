import 'package:flutter/material.dart';
import '../../controlador/auth/login_controller.dart';
import '../../sesion/user_session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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

    setState(() => loading = false);

    final rol = result["rol"] ?? result["role"];
    UserSession().rol = rol;
    UserSession().nombre = result["nombre"];
    UserSession().correo = result["correo"];

    if (rol == null) {
      setState(() => errorMsg = "Rol no reconocido");
      return;
    }

    if (rol == "supervisor") {
      UserSession().idSupervisor = result["id_supervisor"];
      UserSession().idEmpresaSupervisor = result["id_empresa_supervisor"];
      Navigator.pushReplacementNamed(context, "/supervisor/menu");
    } else if (rol == "inspector") {
      UserSession().idInspector = result["id_inspector"];
      Navigator.pushReplacementNamed(context, "/inspector/menu");
    } else if (rol == "trabajador") {
      UserSession().idTrabajador = result["id_trabajador"];
      UserSession().idEmpresaTrabajador = result["id_empresa_trabajador"];
      Navigator.pushReplacementNamed(context, "/trabajador/menu");
    } else {
      setState(() => errorMsg = "Rol no reconocido: $rol");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO / TITULO
                  const Icon(Icons.lock_outline,
                      size: 70, color: Color(0xff2563eb)),
                  const SizedBox(height: 15),

                  const Text(
                    "SaveWorkIA",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Inicio de sesión",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CORREO
                  TextField(
                    controller: correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // CONTRASEÑA
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  if (errorMsg != null) ...[
                    const SizedBox(height: 15),
                    Text(
                      errorMsg!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 28),

                  // BOTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _doLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2563eb),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Ingresar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
