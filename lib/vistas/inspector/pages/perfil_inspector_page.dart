import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class PerfilInspectorPage extends StatelessWidget {
  const PerfilInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idInspector = UserSession().idInspector;
    final nombre = UserSession().nombre;
    final correo = UserSession().correo;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil del Inspector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Perfil del Inspector",
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

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Aquí podrías abrir una pantalla para editar perfil
              },
              child: const Text("Editar Información"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                // Cerrar sesión
                UserSession().clear();
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text("Cerrar Sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
