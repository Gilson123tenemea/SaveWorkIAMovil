import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../sesion/user_session.dart';
import '../../../controlador/inspector/inspectores_controller.dart';

class PerfilInspectorPage extends StatefulWidget {
  const PerfilInspectorPage({super.key});

  @override
  State<PerfilInspectorPage> createState() => _PerfilInspectorPageState();
}

class _PerfilInspectorPageState extends State<PerfilInspectorPage> {

  final InspectoresController controller = InspectoresController();
  late Future<Map<String, dynamic>> futurePerfil;

  @override
  void initState() {
    super.initState();
    final idInspector = UserSession().idInspector!;
    futurePerfil = controller.obtenerPerfilInspector(idInspector);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futurePerfil,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar perfil:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [

                // =============================
                // ENCABEZADO + CERRAR SESIÓN
                // =============================
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
                      child: Text(
                        "Perfil del Inspector",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 30,
                      right: 12,
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 26,
                        ),
                        tooltip: "Cerrar sesión",
                        onPressed: () {
                          UserSession().clear();
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =============================
                // FOTO + NOMBRE + CORREO
                // =============================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff073375).withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: data["fotoBase64"] != null
                              ? MemoryImage(base64Decode(data["fotoBase64"]))
                              : null,
                          child: data["fotoBase64"] == null
                              ? const Icon(Icons.person, size: 50, color: Color(0xff073375))
                              : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "${data["nombre"]} ${data["apellido"]}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff073375),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xff073375).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data["correo"],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff073375),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =============================
                // INFORMACIÓN PERSONAL
                // =============================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Información Personal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff073375),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
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
                    children: [
                      _buildInfoRow(
                        icon: Icons.credit_card,
                        label: "Cédula",
                        value: data["cedula"],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),
                      _buildInfoRow(
                        icon: Icons.phone,
                        label: "Teléfono",
                        value: data["telefono"],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: "Dirección",
                        value: data["direccion"],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),
                      _buildInfoRow(
                        icon: Icons.person,
                        label: "Género",
                        value: data["genero"],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.2)),
                      _buildInfoRow(
                        icon: Icons.cake,
                        label: "Fecha nacimiento",
                        value: data["fecha_nacimiento"],
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =============================
                // INFORMACIÓN PROFESIONAL
                // =============================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Información Profesional",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff073375),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
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
                    children: [
                      _buildInfoRow(
                        icon: Icons.schedule,
                        label: "Frecuencia de visita",
                        value: data["frecuenciaVisita"],
                      ),
                      _buildInfoRow(
                        icon: Icons.schedule,
                        label: "Frecuencia de visita",
                        value: data["frecuenciaVisita"],
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // =============================
                // ZONAS ASIGNADAS
                // =============================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Zonas Asignadas",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff073375),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: (data["zonas_asignadas"] as List).length,
                  itemBuilder: (context, index) {
                    final zona = (data["zonas_asignadas"] as List)[index];

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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xff073375).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xff073375),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Fecha asignación",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      zona["fecha_asignacion"]?.toString() ?? "-",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // =============================
  // FILA DE INFORMACIÓN
  // =============================
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required dynamic value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff073375).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xff073375),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.toString() ?? "-",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}