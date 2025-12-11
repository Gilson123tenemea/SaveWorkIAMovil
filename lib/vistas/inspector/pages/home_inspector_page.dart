import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class HomeInspectorPage extends StatelessWidget {
  const HomeInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idInspector = UserSession().idInspector;
    final nombre = UserSession().nombre;
    final correo = UserSession().correo;

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio Inspector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bienvenido Inspector",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              "👤 Nombre: $nombre",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "📧 Correo: $correo",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "🆔 ID Inspector: $idInspector",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
