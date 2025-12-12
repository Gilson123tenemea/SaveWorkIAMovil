import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../sesion/user_session.dart';
import '../../../controlador/supervisor/perfil_supervisor_controller.dart';

class PerfilSupervisorPage extends StatefulWidget {
  const PerfilSupervisorPage({super.key});

  @override
  State<PerfilSupervisorPage> createState() => _PerfilSupervisorPageState();
}

class _PerfilSupervisorPageState extends State<PerfilSupervisorPage> {

  final PerfilSupervisorController controller =
  PerfilSupervisorController();

  late Future<Map<String, dynamic>> futurePerfil;

  @override
  void initState() {
    super.initState();
    final idSupervisor = UserSession().idSupervisor!;
    futurePerfil = controller.obtenerPerfilSupervisor(idSupervisor);
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
          final empresa = data["empresa"];

          return Column(
            children: [

              // =============================
              // ENCABEZADO + CERRAR SESIÓN
              // =============================
              Stack(
                children: [
                  Container(
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff073375), Color(0xff073375)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
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

                  // TÍTULO
                  const Positioned(
                    top: 70,
                    left: 0,
                    right: 0,
                    child: Text(
                      "Perfil del Supervisor",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // BOTÓN CERRAR SESIÓN
                  Positioned(
                    top: 40,
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
              // FOTO + NOMBRE
              // =============================
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: data["foto"] != null
                    ? MemoryImage(base64Decode(data["foto"]))
                    : null,
                child: data["foto"] == null
                    ? const Icon(Icons.person, size: 45)
                    : null,
              ),

              const SizedBox(height: 12),

              Text(
                "${data["nombre"]} ${data["apellido"]}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff073375),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                data["correo"],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              // =============================
              // CONTENIDO
              // =============================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [

                      _buildInfoCard(
                        title: "Información Personal",
                        items: {
                          "Teléfono": data["telefono"],
                          "Dirección": data["direccion"],
                          "Género": data["genero"],
                          "Fecha nacimiento": data["fecha_nacimiento"],
                        },
                      ),

                      _buildInfoCard(
                        title: "Información Profesional",
                        items: {
                          "Especialidad": data["especialidad_seguridad"],
                          "Experiencia": "${data["experiencia"]} años",
                        },
                      ),

                      _buildInfoCard(
                        title: "Empresa",
                        items: {
                          "Nombre": empresa["nombre"],
                          "RUC": empresa["ruc"],
                          "Dirección": empresa["direccion"],
                          "Teléfono": empresa["telefono"],
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =============================
  // CARD REUTILIZABLE
  // =============================
  Widget _buildInfoCard({
    required String title,
    required Map<String, dynamic> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff073375),
            ),
          ),
          const Divider(),
          ...items.entries.map(
                (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value?.toString() ?? "-",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
