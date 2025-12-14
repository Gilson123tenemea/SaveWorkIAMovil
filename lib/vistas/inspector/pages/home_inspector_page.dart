import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../controlador/inspector/dashboard_inspector_controller.dart';

class HomeInspectorPage extends StatefulWidget {
  const HomeInspectorPage({super.key});

  @override
  State<HomeInspectorPage> createState() => _HomeInspectorPageState();
}

class _HomeInspectorPageState extends State<HomeInspectorPage> {
  final DashboardInspectorController controller =
  DashboardInspectorController();

  late Future<Map<String, dynamic>> futureDashboard;

  @override
  void initState() {
    super.initState();
    final idInspector = UserSession().idInspector;
    futureDashboard = controller.obtenerDatosDashboard(idInspector!);
  }

  @override
  Widget build(BuildContext context) {
    final nombreInspector = UserSession().nombre ?? "Inspector";

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureDashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar dashboard:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;

          return Column(
            children: [

              /// 🔷 HEADER
              Stack(
                children: [
                  Container(
                    height: 110,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff073375), Color(0xff073375)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        "Dashboard Inspector",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// 👤 NOMBRE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nombreInspector,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff073375),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// 👋 BIENVENIDA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.assignment_turned_in,
                          size: 40, color: Color(0xff073375)),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "¡Bienvenido Inspector!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Revisa la seguridad en tus zonas",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 📊 TARJETAS
              Expanded(
                child: GridView.count(
                  physics: const BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDashboardCard(
                      icon: Icons.map,
                      title: "Zonas Asignadas",
                      value: data["zonas_asignadas"].toString(),
                      color: Colors.indigo,
                    ),
                    _buildDashboardCard(
                      icon: Icons.engineering,
                      title: "Trabajadores",
                      value: data["trabajadores"].toString(),
                      color: Colors.blueAccent,
                    ),
                    _buildDashboardCard(
                      icon: Icons.warning_amber_rounded,
                      title: "Alertas Hoy",
                      value: data["alertas_hoy"].toString(),
                      color: Colors.redAccent,
                    ),
                    _buildDashboardCard(
                      icon: Icons.report_problem,
                      title: "Pendientes",
                      value: data["incumplimientos_alta"].toString(),
                      color: Colors.deepOrange,
                    ),
                    _buildDashboardCard(
                      icon: Icons.camera_alt,
                      title: "Cámaras Activas",
                      value: data["camaras_activas"].toString(),
                      color: Colors.lightBlue,
                    ),
                    _buildDashboardCard(
                      icon: Icons.videocam,
                      title: "Cámaras Totales",
                      value: data["camaras_totales"].toString(),
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.18),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
