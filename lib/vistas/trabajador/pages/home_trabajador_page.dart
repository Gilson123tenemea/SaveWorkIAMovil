import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../servicios/trabajador_api.dart';

class HomeTrabajadorPage extends StatefulWidget {
  const HomeTrabajadorPage({super.key});

  @override
  State<HomeTrabajadorPage> createState() => _HomeTrabajadorPageState();
}

class _HomeTrabajadorPageState extends State<HomeTrabajadorPage> {
  Map<String, dynamic>? estadisticas;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    final idTrabajador = UserSession().idTrabajador;

    if (idTrabajador == null) return;

    final data = await TrabajadorApi.obtenerEstadisticas(idTrabajador);

    setState(() {
      estadisticas = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombre = UserSession().nombre;
    final correo = UserSession().correo;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      "Inicio Trabajador",
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

            const SizedBox(height: 20),

            // 👤 NOMBRE Y CORREO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bienvenido, $nombre",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff073375),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    correo ?? "",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 👋 TARJETA DE BIENVENIDA
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
                      Icons.fact_check,
                      size: 40,
                      color: Color(0xff073375),
                    ),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "¡Bienvenido Trabajador!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Revisa tu desempeño y cumplimiento",
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

            // 📊 TARJETAS DE ESTADÍSTICAS - ASISTENCIA Y EPP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Asistencia y EPP",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff073375),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAsistenciaCards(),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🚨 TARJETAS DE INCUMPLIMIENTOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Incumplimientos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff073375),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildIncumplimientosCards(),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =============================
  // 📊 ASISTENCIA
  // =============================
  Widget _buildAsistenciaCards() {
    final asistencia = estadisticas!["asistencia"];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.15,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildDashboardCard(
          icon: Icons.fact_check,
          title: "Registros",
          value: asistencia["total_registros"].toString(),
          color: Colors.blue,
        ),
        _buildDashboardCard(
          icon: Icons.check_circle,
          title: "Cumple EPP",
          value: asistencia["cumple_epp"].toString(),
          color: Colors.green,
        ),
        _buildDashboardCard(
          icon: Icons.cancel,
          title: "No cumple",
          value: asistencia["no_cumple_epp"].toString(),
          color: Colors.red,
        ),
        _buildDashboardCard(
          icon: Icons.percent,
          title: "Tasa %",
          value: "${asistencia["tasa_cumplimiento"]}%",
          color: Colors.orange,
        ),
      ],
    );
  }

  // =============================
  // 🚨 INCUMPLIMIENTOS
  // =============================
  Widget _buildIncumplimientosCards() {
    final inc = estadisticas!["incumplimientos"];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.15,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildDashboardCard(
          icon: Icons.warning,
          title: "Total",
          value: inc["total_fallos"].toString(),
          color: Colors.deepOrange,
        ),
        _buildDashboardCard(
          icon: Icons.verified,
          title: "Revisados",
          value: inc["revisados"].toString(),
          color: Colors.green,
        ),
        _buildDashboardCard(
          icon: Icons.hourglass_bottom,
          title: "Pendientes",
          value: inc["pendientes"].toString(),
          color: Colors.amber,
        ),
      ],
    );
  }

  // =============================
  // 🧩 TARJETA GENÉRICA (Mejorada)
  // =============================
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