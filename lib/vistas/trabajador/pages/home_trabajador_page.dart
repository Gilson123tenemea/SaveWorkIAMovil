import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class HomeTrabajadorPage extends StatelessWidget {
  const HomeTrabajadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idTrabajador = UserSession().idTrabajador;
    final idSupervisor = UserSession().idSupervisor;
    final idEmpresa = UserSession().idEmpresaTrabajador;

    final nombre = UserSession().nombre;
    final correo = UserSession().correo;

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio Trabajador")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Bienvenido Trabajador",
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
              "🆔 ID Trabajador: $idTrabajador",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "📌 ID Supervisor Asignado: $idSupervisor",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "🏭 Empresa: $idEmpresa",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
