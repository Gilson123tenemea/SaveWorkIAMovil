import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class EstadisticasSupervisorPage extends StatelessWidget {
  const EstadisticasSupervisorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final idSupervisor = UserSession().idSupervisor;
    final idEmpresa = UserSession().idEmpresaSupervisor;

    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas Supervisor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Visualización de estadísticas",
              style: TextStyle(fontSize: 22),
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
          ],
        ),
      ),
    );
  }
}
