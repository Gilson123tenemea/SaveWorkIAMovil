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
    final nombre = UserSession().nombre;

  }

  @override
  Widget build(BuildContext context) {
    final nombreSupervisor = UserSession().nombre ?? "Supervisor";

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
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Dashboard Supervisor",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nombreSupervisor,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff073375),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 12),

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
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset(
                          "assets/img/supervisor_welcome.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // TEXTO
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "¡Bienvenido!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Gestionemos la seguridad hoy",
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
                      icon: Icons.engineering,
                      title: "Trabajadores Activos",
                      value: data["trabajadores_activos"].toString(),
                      color: Colors.blueAccent,
                    ),
                    _buildDashboardCard(
                      icon: Icons.verified_user,
                      title: "Cumplen EPP",
                      value: data["epp_completo"].toString(),
                      color: Colors.green,
                    ),
                    _buildDashboardCard(
                      icon: Icons.warning_amber_rounded,
                      title: "Alertas Activas",
                      value: data["alertas_activas"].toString(),
                      color: Colors.redAccent,
                    ),
                    _buildDashboardCard(
                      icon: Icons.camera_alt_rounded,
                      title: "Cámaras Activas",
                      value: data["camaras_activas"].toString(),
                      color: Colors.lightBlue,
                    ),
                    _buildDashboardCard(
                      icon: Icons.percent,
                      title: "Porcentaje EPP",
                      value: "${data["porcentaje_epp"]}%",
                      color: Colors.orange,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
              color: Colors.black87,
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
