import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../controlador/inspector/dashboard_inspector_controller.dart';
import '../../../controlador/inspector/inspectores_controller.dart';

class HomeInspectorPage extends StatefulWidget {
  const HomeInspectorPage({super.key});

  @override
  State<HomeInspectorPage> createState() => _HomeInspectorPageState();
}

class _HomeInspectorPageState extends State<HomeInspectorPage> {
  final DashboardInspectorController dashboardController =
  DashboardInspectorController();
  final InspectoresController inspectoresController =
  InspectoresController();

  late Future<Map<String, dynamic>> futureDashboard;
  late Future<List<dynamic>> futureZonas;

  @override
  void initState() {
    super.initState();
    final idInspector = UserSession().idInspector;

    futureDashboard =
        dashboardController.obtenerDatosDashboard(idInspector!);
    futureZonas =
        inspectoresController.obtenerZonasInspector(idInspector);
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
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [

                // 🔷 HEADER
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

                // 👤 NOMBRE
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

                // 👋 BIENVENIDA
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
                        Icon(
                          Icons.assignment_turned_in,
                          size: 40,
                          color: Color(0xff073375),
                        ),
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

                // 📊 TARJETAS
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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

                const SizedBox(height: 25),

                // 📍 TITULO ZONAS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Zonas Asignadas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff073375),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 📍 ZONAS ASIGNADAS
                FutureBuilder<List<dynamic>>(
                  future: futureZonas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          "No hay zonas asignadas",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    final zonas = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: zonas.length,
                      itemBuilder: (context, index) {
                        final zona = zonas[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff073375),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      zona["nombreZona"],
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff073375),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color(0xff073375),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "Lat: ${zona["latitud"]}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color(0xff073375),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "Lng: ${zona["longitud"]}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.engineering,
                                              size: 16,
                                              color: Color(0xff073375)),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Trabajadores: ${zona["total_trabajadores"]}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff073375),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.camera_alt,
                                              size: 16,
                                              color: Colors.green),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Cámaras: ${zona["total_camaras"]}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "📅 Asignado: ${zona["fecha_asignacion"].toString().split('T')[0]}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🧩 TARJETA
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