import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class PerfilTrabajadorPage extends StatelessWidget {
  const PerfilTrabajadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idTrabajador = UserSession().idTrabajador;
    final idSupervisor = UserSession().idSupervisor;
    final idEmpresa = UserSession().idEmpresaTrabajador;

    final nombre = UserSession().nombre;
    final correo = UserSession().correo;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil del Trabajador")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Perfil del Trabajador",
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
              "👨‍💼 Supervisor: $idSupervisor",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "🏭 Empresa: $idEmpresa",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Aquí luego puedes poner pantalla para editar perfil
              },
              child: const Text("Editar Información"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
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
