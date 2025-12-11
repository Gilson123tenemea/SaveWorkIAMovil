import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class AsistenciaTrabajadorPage extends StatelessWidget {
  const AsistenciaTrabajadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idTrabajador = UserSession().idTrabajador;
    final idEmpresa = UserSession().idEmpresaTrabajador;
    final nombre = UserSession().nombre;
    final correo = UserSession().correo;

    return Scaffold(
      appBar: AppBar(title: const Text("Asistencia del Trabajador")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Registro de asistencia",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text("👤 Nombre: $nombre",
                style: const TextStyle(fontSize: 18)),

            Text("📧 Correo: $correo",
                style: const TextStyle(fontSize: 18)),

            Text("🆔 ID Trabajador: $idTrabajador",
                style: const TextStyle(fontSize: 18)),

            Text("🏭 Empresa: $idEmpresa",
                style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Aquí irá tu endpoint real:
                // ApiAsistencia.registrarAsistencia(idTrabajador, idEmpresa);
              },
              child: const Text("Registrar Asistencia"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Aquí luego conectas con tu backend:
                // ApiAsistencia.obtenerHistorial(idTrabajador);
              },
              child: const Text("Ver Historial de Asistencia"),
            ),
          ],
        ),
      ),
    );
  }
}
