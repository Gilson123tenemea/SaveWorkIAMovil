import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class IncumplimientosInspectorPage extends StatelessWidget {
  const IncumplimientosInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idInspector = UserSession().idInspector;
    final nombre = UserSession().nombre;

    return Scaffold(
      appBar: AppBar(title: const Text("Incumplimientos del Inspector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Listado de incumplimientos",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              "👤 Inspector: $nombre",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "🆔 ID Inspector: $idInspector",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Aquí es donde luego llamas al backend:
                // ApiIncumplimientos.obtener(idInspector)
              },
              child: const Text("Cargar Incumplimientos"),
            ),
          ],
        ),
      ),
    );
  }
}
