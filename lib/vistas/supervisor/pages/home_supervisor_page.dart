import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../controlador/supervisor/dashboard_supervisor_controller.dart';

class HomeSupervisorPage extends StatefulWidget {
  const HomeSupervisorPage({super.key});

  @override
  State<HomeSupervisorPage> createState() => _HomeSupervisorPageState();
}

class _HomeSupervisorPageState extends State<HomeSupervisorPage> {
  final DashboardSupervisorController controller =
  DashboardSupervisorController();

  late Future<Map<String, dynamic>> futureDashboard;

  @override
  void initState() {
    super.initState();

    final idEmpresa = UserSession().idEmpresaSupervisor;
    futureDashboard = controller.obtenerDatosDashboard(idEmpresa!);
  }

  @override
  Widget build(BuildContext context) {
    final idSupervisor = UserSession().idSupervisor;
    final idEmpresa = UserSession().idEmpresaSupervisor;

    return Scaffold(
      appBar: AppBar(title: const Text("Inicio Supervisor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureDashboard,
          builder: (context, snapshot) {
            // LOADING
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ERROR
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error al cargar dashboard:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, color: Colors.red),
                ),
              );
            }

            // DATA LISTA
            final data = snapshot.data!;

            return ListView(
              children: [
                const Text(
                  "Bienvenido Supervisor",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),

                Text("ID Supervisor: $idSupervisor"),
                Text("ID Empresa: $idEmpresa"),

                const SizedBox(height: 25),

                _buildDashboardCard(
                  "👷 Trabajadores Activos",
                  data["trabajadores_activos"].toString(),
                  Colors.blue,
                ),

                _buildDashboardCard(
                  "📋 Trabajadores Registrados",
                  data["trabajadores_registrados"].toString(),
                  Colors.deepPurple,
                ),

                _buildDashboardCard(
                  "🛡️ Cumplen EPP",
                  data["epp_completo"].toString(),
                  Colors.green,
                ),

                _buildDashboardCard(
                  "📊 Porcentaje EPP",
                  "${data["porcentaje_epp"]}%",
                  Colors.orange,
                ),

                _buildDashboardCard(
                  "🚨 Alertas Activas",
                  data["alertas_activas"].toString(),
                  Colors.redAccent,
                ),

                _buildDashboardCard(
                  "🎥 Cámaras Totales",
                  data["camaras_totales"].toString(),
                  Colors.black54,
                ),

                _buildDashboardCard(
                  "🟢 Cámaras Activas",
                  data["camaras_activas"].toString(),
                  Colors.green,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // TARJETAS PROFESIONALES
  Widget _buildDashboardCard(String title, String value, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
