import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class ReportesSupervisorPage extends StatelessWidget {
  const ReportesSupervisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idSupervisor = UserSession().idSupervisor;
    final idEmpresa = UserSession().idEmpresaSupervisor;

    return Scaffold(
      appBar: AppBar(title: const Text("Reportes del Supervisor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Gestión de reportes",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              "ID Supervisor: $idSupervisor",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "ID Empresa: $idEmpresa",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Aquí luego implementas la llamada real al backend
                // Ejemplo:
                // ApiReportes.obtenerReportes(idSupervisor, idEmpresa);
              },
              child: const Text("Ver Reportes"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                // Para crear reporte
              },
              child: const Text("Crear Nuevo Reporte"),
            ),
          ],
        ),
      ),
    );
  }
}
