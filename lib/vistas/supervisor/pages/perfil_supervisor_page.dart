import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class PerfilSupervisorPage extends StatelessWidget {
  const PerfilSupervisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idSupervisor = UserSession().idSupervisor;
    final nombre = UserSession().nombre;
    final correo = UserSession().correo;
    final idEmpresa = UserSession().idEmpresaSupervisor;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil del Supervisor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Configuración del perfil",
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
              "🆔 ID Supervisor: $idSupervisor",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "🏭 Empresa asignada: $idEmpresa",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
