import 'package:flutter/material.dart';
import '/../../sesion/user_session.dart';

class HomeSupervisorPage extends StatelessWidget {
  const HomeSupervisorPage({super.key});

  @override
  Widget build(BuildContext context) {

    // EXTRAER EL ID DEL SUPERVISOR
    final idSupervisor = UserSession().idSupervisor;
    final idEmpresa = UserSession().idEmpresaSupervisor;

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio Supervisor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Bienvenido Supervisor",
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
          ],
        ),
      ),
    );
  }
}
