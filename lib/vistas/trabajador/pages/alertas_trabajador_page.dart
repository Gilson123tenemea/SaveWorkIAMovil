import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class AlertasTrabajadorPage extends StatelessWidget {
  const AlertasTrabajadorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idTrabajador = UserSession().idTrabajador;
    final nombre = UserSession().nombre;
    final correo = UserSession().correo;
    final idEmpresa = UserSession().idEmpresaTrabajador;

    return Scaffold(
      appBar: AppBar(title: const Text("Alertas del Trabajador")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Alertas del trabajador",
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
              "🏭 Empresa: $idEmpresa",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Aquí luego conectas con tu backend:
                // ApiAlertas.obtenerAlertasTrabajador(idTrabajador);
              },
              child: const Text("Ver Alertas"),
            ),
          ],
        ),
      ),
    );
  }
}
