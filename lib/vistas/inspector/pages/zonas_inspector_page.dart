import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class ZonasInspectorPage extends StatelessWidget {
  const ZonasInspectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idInspector = UserSession().idInspector;
    final nombre = UserSession().nombre;

    return Scaffold(
      appBar: AppBar(title: const Text("Zonas Asignadas")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Zonas del inspector",
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
                // Aquí irá la llamada real al backend:
                // ApiZonas.obtenerZonasPorInspector(idInspector);
              },
              child: const Text("Ver Zonas Asignadas"),
            ),
          ],
        ),
      ),
    );
  }
}
