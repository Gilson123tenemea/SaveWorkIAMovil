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
  bool obscurePassword = true;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CONTENEDOR PRINCIPAL CON DISEÑO PROFESIONAL
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // HEADER CON GRADIENTE
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff073375), Color(0xff0d47a1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff073375)
                                .withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // TITULO
                    const Text(
                      "SaveWorkIA",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff073375),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // SUBTITULO
                    const Text(
                      "Inicio de sesión seguro",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // CORREO
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: correoCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Correo electrónico",
                          labelStyle: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xff073375),
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // CONTRASEÑA
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: passCtrl,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          labelStyle: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xff073375),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xff073375),
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    // MENSAJE DE ERROR
                    if (errorMsg != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMsg!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // BOTON DE INGRESO
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : _doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff073375),
                          disabledBackgroundColor:
                          const Color(0xff073375).withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor:
                          const Color(0xff073375).withOpacity(0.4),
                        ),
                        child: loading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : const Text(
                          "Ingresar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // INFO ADICIONAL
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Usa tus credenciales de SafeWorkIA",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}