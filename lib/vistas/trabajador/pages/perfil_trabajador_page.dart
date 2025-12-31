import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../servicios/trabajador_api.dart';

class PerfilTrabajadorPage extends StatefulWidget {
  const PerfilTrabajadorPage({super.key});

  @override
  State<PerfilTrabajadorPage> createState() => _PerfilTrabajadorPageState();
}

class _PerfilTrabajadorPageState extends State<PerfilTrabajadorPage> {
  bool loading = true;
  Map<String, dynamic>? perfil;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final idTrabajador = UserSession().idTrabajador;

    if (idTrabajador == null) return;

    final data = await TrabajadorApi.obtenerPerfil(idTrabajador);

    setState(() {
      perfil = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    "Perfil del Trabajador",
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
                      Navigator.pushReplacementNamed(
                          context, "/login");
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
                          color: const Color(0xff073375)
                              .withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage:
                      perfil!["fotoBase64"] != null
                          ? MemoryImage(
                          base64Decode(
                              perfil!["fotoBase64"]))
                          : null,
                      child: perfil!["fotoBase64"] == null
                          ? const Icon(Icons.person,
                          size: 50,
                          color: Color(0xff073375))
                          : null,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "${perfil!["nombre"]} ${perfil!["apellido"]}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff073375),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xff073375)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      perfil!["correo"],
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
                    value: perfil!["cedula"],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  _buildInfoRow(
                    icon: Icons.email,
                    label: "Correo",
                    value: perfil!["correo"],
                  ),
                  if (perfil!["telefono"] != null) ...[
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: "Teléfono",
                      value: perfil!["telefono"],
                      isLast: true,
                    ),
                  ],
                  if (perfil!["telefono"] == null)
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: "Teléfono",
                      value: "-",
                      isLast: true,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =============================
            // INFORMACIÓN LABORAL
            // =============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Información Laboral",
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
                    icon: Icons.work,
                    label: "Cargo",
                    value: perfil!["cargo"],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  _buildInfoRow(
                    icon: Icons.business,
                    label: "Área",
                    value: perfil!["area_trabajo"],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  _buildInfoRow(
                    icon: Icons.badge,
                    label: "ID Trabajador",
                    value: perfil!["id_trabajador"].toString(),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =============================
            // INFORMACIÓN DE EMPRESA
            // =============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Información de Empresa",
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
                    icon: Icons.business_center,
                    label: "Nombre Empresa",
                    value: perfil!["empresa"]["nombreEmpresa"],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  _buildInfoRow(
                    icon: Icons.code,
                    label: "RUC",
                    value: perfil!["empresa"]["ruc"],
                  ),
                  Divider(color: Colors.grey.withOpacity(0.2)),
                  _buildInfoRow(
                    icon: Icons.category,
                    label: "Sector",
                    value: perfil!["empresa"]["sector"],
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =============================
            // ZONA ASIGNADA
            // =============================
            if (perfil!["zona_asignada"] != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Zona Asignada",
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
                            borderRadius:
                            BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            perfil!["zona_asignada"]
                            ["nombreZona"],
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
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: "Latitud",
                      value: perfil!["zona_asignada"]["latitud"]
                          .toString(),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: "Longitud",
                      value: perfil!["zona_asignada"]
                      ["longitud"]
                          .toString(),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],

            const SizedBox(height: 30),
          ],
        ),
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