import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../servicios/trabajador_api.dart';

class AlertasTrabajadorPage extends StatefulWidget {
  const AlertasTrabajadorPage({super.key});

  @override
  State<AlertasTrabajadorPage> createState() => _AlertasTrabajadorPageState();
}

class _AlertasTrabajadorPageState extends State<AlertasTrabajadorPage> {
  bool loading = true;
  List<dynamic> alertas = [];

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    final idTrabajador = UserSession().idTrabajador;

    if (idTrabajador == null) return;

    final data =
    await TrabajadorApi.obtenerIncumplimientos(idTrabajador);

    setState(() {
      alertas = data["historial"] ?? [];
      loading = false;
    });
  }

  Widget _buildHeader() {
    return Stack(
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
              "Alertas y Incumplimientos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nombre = UserSession().nombre;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔷 HEADER
          _buildHeader(),

          const SizedBox(height: 20),

          // 👤 NOMBRE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                nombre ?? "Trabajador",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff073375),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

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
                    Icons.warning_amber_rounded,
                    size: 40,
                    color: Color(0xff073375),
                  ),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tus Incumplimientos",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Revisa los eventos detectados",
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

          // 📋 LISTA DE ALERTAS
          Expanded(
            child: alertas.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "¡Excelente!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff073375),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "No tienes alertas registradas",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: alertas.length,
              itemBuilder: (context, index) {
                final alerta = alertas[index];
                final evidencia = alerta["evidencia"];
                final camara = alerta["camara"];

                final bool revisado =
                    evidencia["estado"] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(16),
                    border: Border.all(
                      color: revisado
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      width: 2,
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // HEADER CON ESTADO Y FECHA
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 12,
                                  vertical: 6),
                              decoration: BoxDecoration(
                                color: revisado
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius:
                                BorderRadius.circular(
                                    20),
                              ),
                              child: Text(
                                revisado
                                    ? "REVISADO"
                                    : "PENDIENTE",
                                style: TextStyle(
                                  color: revisado
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  fontWeight:
                                  FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              alerta["fecha_registro"]
                                  .toString()
                                  .substring(0, 19),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // INFORMACIÓN DE CÁMARA Y ZONA
                        Container(
                          padding:
                          const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey
                                .withOpacity(0.05),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.videocam,
                                    size: 16,
                                    color: Color(
                                        0xff073375),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Cámara: ${camara["codigo"]}",
                                      style:
                                      const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w600,
                                        color:
                                        Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Color(
                                        0xff073375),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Zona: ${camara["zona"]}",
                                      style:
                                      const TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w600,
                                        color:
                                        Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // GRID DE IMPLEMENTOS
                        _buildImplementosGrid(
                            evidencia["detalle"] ?? ""),

                        const SizedBox(height: 16),

                        // 🖼️ IMAGEN (si existe)
                        if (evidencia["foto_base64"] !=
                            null)
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child:
                                  InteractiveViewer(
                                    child: Image.memory(
                                      base64Decode(evidencia[
                                      "foto_base64"]),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(
                                    evidencia[
                                    "foto_base64"]),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // 📝 OBSERVACIONES
                        if (evidencia["observaciones"] !=
                            null)
                          Padding(
                            padding:
                            const EdgeInsets.only(
                                top: 12),
                            child: Container(
                              padding:
                              const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                BorderRadius.circular(
                                    10),
                                border: Border.all(
                                  color:
                                  Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                          Icons.comment,
                                          color: Colors
                                              .blue.shade600,
                                          size: 18),
                                      const SizedBox(
                                          width: 8),
                                      Text(
                                        "Observación",
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          color: Colors
                                              .blue.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "📝 ${evidencia["observaciones"]}",
                                    style: const TextStyle(
                                        color: Colors
                                            .black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // =============================
  // 🧩 GRID DE IMPLEMENTOS
  // =============================
  Widget _buildImplementosGrid(String detalle) {
    final detalleMin = detalle.toLowerCase();

    final items = [
      {"name": "Casco", "key": "casco", "icon": Icons.health_and_safety},
      {"name": "Chaleco", "key": "chaleco", "icon": Icons.checkroom},
      {"name": "Botas", "key": "botas", "icon": Icons.safety_check},
      {"name": "Guantes", "key": "guantes", "icon": Icons.pan_tool},
      {"name": "Lentes", "key": "lentes", "icon": Icons.remove_red_eye},
    ];

    // Detectar si el implemento está en el detalle (si está = no detectado = rojo)
    for (var item in items) {
      item["detected"] = !detalleMin.contains(item["key"] as String);
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.5,
      children: items.map((item) {
        final detected = item["detected"] as bool;
        final name = (item["name"] as String?) ?? "Implemento";
        final icon = item["icon"] as IconData;

        return Container(
          decoration: BoxDecoration(
            color: detected ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: detected ? Colors.green.shade300 : Colors.red.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Icon(
                  icon,
                  color: detected ? Colors.green : Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detected ? "Detectado" : "No detectado",
                      style: TextStyle(
                        color: detected ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}