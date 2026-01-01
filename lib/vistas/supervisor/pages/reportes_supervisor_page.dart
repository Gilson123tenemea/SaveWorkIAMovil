import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../controlador/supervisor/reportes_supervisor_controller.dart';
import 'historial_trabajador_dialog.dart';
import 'dart:convert';
import 'dart:typed_data';

class ReportesSupervisorPage extends StatefulWidget {
  const ReportesSupervisorPage({super.key});

  @override
  State<ReportesSupervisorPage> createState() => _ReportesSupervisorPageState();
}

class _ReportesSupervisorPageState extends State<ReportesSupervisorPage> {
  final ReportesSupervisorController controller = ReportesSupervisorController();

  List<dynamic> reportes = [];
  List<dynamic> inspectores = [];
  List<dynamic> zonas = [];

  bool isLoading = true;

  String? filtroInspector;
  String? filtroZona;
  String? fechaDesde;
  String? fechaHasta;

  // Mapeo de implementos con iconos y nombres en español
  final Map<String, IconData> implementosIconos = {
    "gafas": Icons.remove_red_eye,
    "botas": Icons.safety_check,
    "chaleco": Icons.checkroom,
    "casco": Icons.health_and_safety,
    "guantes": Icons.pan_tool,
    "arnés": Icons.shield,
    "protección auditiva": Icons.volume_off,
    "mascarilla": Icons.masks,
  };

  final Map<String, String> implementosNombres = {
    "gafas": "Gafas",
    "botas": "Botas",
    "chaleco": "Chaleco",
    "casco": "Casco",
    "guantes": "Guantes",
    "arnés": "Arnés",
    "protección auditiva": "Protección Auditiva",
    "mascarilla": "Mascarilla",
  };

  @override
  void initState() {
    super.initState();
    cargarDatosIniciales();
  }

  Future<void> cargarDatosIniciales() async {
    final idSupervisor = UserSession().idSupervisor;
    final idEmpresa = UserSession().idEmpresaSupervisor;

    setState(() => isLoading = true);

    try {
      final data = await controller.obtenerIncumplimientosHoy(idSupervisor!);
      final listaInspectores = await controller.obtenerInspectores(idEmpresa!);
      final listaZonas = await controller.obtenerZonas(idEmpresa);

      setState(() {
        reportes = data;
        inspectores = listaInspectores;
        zonas = listaZonas;
      });
    } catch (e) {
      print("Error: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> aplicarFiltros() async {
    final idEmpresa = UserSession().idEmpresaSupervisor;

    setState(() => isLoading = true);

    final data = await controller.obtenerDeteccionesFiltradas(
      idEmpresa: idEmpresa!,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      idInspector: filtroInspector != null ? int.parse(filtroInspector!) : null,
      idZona: filtroZona != null ? int.parse(filtroZona!) : null,
    );

    setState(() {
      reportes = data;
      isLoading = false;
    });
  }

  void mostrarImagenGrande(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.memory(imageBytes),
          ),
        ),
      ),
    );
  }

  // ✅ NUEVA FUNCIÓN: Determinar si un implemento fue detectado
  bool fueDetectado(String implemento, List<dynamic> detecciones, String detalleEvidencia) {
    final detalleMin = detalleEvidencia.toLowerCase();

    // Si aparece en detecciones O en el detalle de evidencia = NO detectado
    for (var deteccion in detecciones) {
      if (deteccion.toString().toLowerCase().contains(implemento)) {
        return false;
      }
    }

    if (detalleMin.contains(implemento)) {
      return false;
    }

    // Si no aparece en ningún lado = detectado ✅
    return true;
  }

  // ✅ NUEVA FUNCIÓN: Construir lista dinámica de implementos por zona
  List<Map<String, dynamic>> construirImplementosPorZona(
      List<dynamic> eppsZona,
      List<dynamic> detecciones,
      String detalleEvidencia,
      ) {
    return eppsZona.map((epp) {
      final eppStr = epp.toString().toLowerCase().trim();
      final detectado = fueDetectado(eppStr, detecciones, detalleEvidencia);

      return {
        "key": eppStr,
        "nombre": implementosNombres[eppStr] ?? eppStr.toUpperCase(),
        "icon": implementosIconos[eppStr] ?? Icons.check_circle,
        "detectado": detectado,
      };
    }).toList();
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
          child: const Center(
            child: Text(
              "Reportes de Incumplimiento",
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

  Widget _buildReporteCard(dynamic rep) {
    final trabajador = rep["trabajador"];
    final evidencia = rep["evidencia"];
    final camara = rep["camara"];
    final inspector = rep["inspector"];
    final eppsZona = rep["epps_zona"] as List<dynamic>? ?? [];
    final detecciones = rep["detecciones"] as List<dynamic>? ?? [];

    Uint8List? fotoBytes;
    try {
      fotoBytes = evidencia["foto_base64"] != null
          ? base64Decode(evidencia["foto_base64"])
          : null;
    } catch (_) {}

    final detalleEvidencia = evidencia["detalle"].toString().toLowerCase();

    // ✅ Construir lista dinámica de implementos
    final implementos = construirImplementosPorZona(
      eppsZona,
      detecciones,
      detalleEvidencia,
    );

    // Contar incumplimientos
    final fails = implementos.where((i) => !i["detectado"]).length;

    Color borderColor = Colors.grey.shade300;
    if (fails >= 3) borderColor = Colors.red;
    if (fails == 2) borderColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.4),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (fotoBytes != null) mostrarImagenGrande(fotoBytes);
                  },
                  child: Container(
                    width: 140,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade300,
                      image: fotoBytes != null
                          ? DecorationImage(
                        image: MemoryImage(fotoBytes),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${trabajador["nombre"]} ${trabajador["apellido"]}",
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.camera_alt, size: 16),
                        const SizedBox(width: 6),
                        Text(camara["codigo"]),
                      ]),
                      const SizedBox(height: 4),
                      Text("Inspector: ${inspector?["nombre"] ?? "N/A"}",
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 6),
                      Text(rep["fecha_registro"],
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Grid dinámica basada en epps_zona
            implementos.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Sin EPPs requeridos para esta zona",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.8,
              children: implementos.map((item) {
                final detectado = item["detectado"];

                return Container(
                  decoration: BoxDecoration(
                    color: detectado
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: detectado ? Colors.green : Colors.red,
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Icon(item["icon"],
                          color:
                          detectado ? Colors.green : Colors.red,
                          size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item["nombre"],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: detectado
                                        ? Colors.green.shade900
                                        : Colors.red)),
                            Text(
                                detectado
                                    ? "Detectado"
                                    : "No detectado",
                                style: TextStyle(
                                    color: detectado
                                        ? Colors.green.shade700
                                        : Colors.red)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final cedula = trabajador["cedula"];
                      _mostrarHistorialTrabajador(cedula);
                    },
                    child: const Text("Ver Historial"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarHistorialTrabajador(String cedula) async {
    try {
      final data = await controller.obtenerHistorialTrabajador(cedula: cedula);

      print("=============== RESPUESTA COMPLETA DE API ===============");
      print(jsonEncode(data));
      print("=========================================================");

      final historial = data["historial"] as List<dynamic>;
      final stats = data["estadisticas"];

      if (historial.isNotEmpty) {
        print("PRIMER ELEMENTO DEL HISTORIAL:");
        print(jsonEncode(historial[0]));
      }

      final nombreCompleto = historial.isNotEmpty
          ? "${historial[0]["trabajador"]["nombre"]} ${historial[0]["trabajador"]["apellido"]}"
          : "Trabajador";

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => HistorialTrabajadorDialog(
          nombre: nombreCompleto,
          stats: stats,
          historial: historial,
        ),
      );
    } catch (e) {
      print("Error al cargar historial: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFiltersSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xff073375), width: 1.5),
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Inspector",
                  labelStyle: const TextStyle(
                    color: Color(0xff073375),
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  const DropdownMenuItem(
                    value: "todos",
                    child: Text("Todos"),
                  )
                ] +
                    inspectores
                        .map(
                          (i) => DropdownMenuItem(
                        value: i["id"].toString(),
                        child:
                        Text("${i["nombre"]} ${i["apellido"]}"),
                      ),
                    )
                        .toList(),
                onChanged: (val) {
                  setState(() => filtroInspector = val);

                  if (val == "todos") {
                    filtroInspector = null;
                    cargarDatosIniciales();
                  } else {
                    aplicarFiltros();
                  }
                },
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xff073375), width: 1.5),
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Zona",
                  labelStyle: const TextStyle(
                    color: Color(0xff073375),
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  const DropdownMenuItem(
                    value: "todas",
                    child: Text("Todas"),
                  )
                ] +
                    zonas
                        .map(
                          (z) => DropdownMenuItem(
                        value: z["id"].toString(),
                        child: Text(z["nombre"]),
                      ),
                    )
                        .toList(),
                onChanged: (val) {
                  setState(() => filtroZona = val);

                  if (val == "todas") {
                    filtroZona = null;
                    cargarDatosIniciales();
                  } else {
                    aplicarFiltros();
                  }
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xff073375), width: 1.5),
                    ),
                    child: TextFormField(
                      controller: TextEditingController(text: fechaDesde),
                      decoration: InputDecoration(
                        labelText: "Desde",
                        labelStyle: const TextStyle(
                          color: Color(0xff073375),
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        suffixIcon: fechaDesde != null
                            ? IconButton(
                          icon: const Icon(Icons.close,
                              size: 20,
                              color: Color(0xff073375)),
                          onPressed: () {
                            setState(() => fechaDesde = null);
                            if (fechaHasta == null) {
                              cargarDatosIniciales();
                            } else {
                              aplicarFiltros();
                            }
                          },
                        )
                            : null,
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() =>
                          fechaDesde = date.toString().split(" ")[0]);
                          aplicarFiltros();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xff073375), width: 1.5),
                    ),
                    child: TextFormField(
                      controller: TextEditingController(text: fechaHasta),
                      decoration: InputDecoration(
                        labelText: "Hasta",
                        labelStyle: const TextStyle(
                          color: Color(0xff073375),
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        suffixIcon: fechaHasta != null
                            ? IconButton(
                          icon: const Icon(Icons.close,
                              size: 20,
                              color: Color(0xff073375)),
                          onPressed: () {
                            setState(() => fechaHasta = null);

                            if (fechaDesde == null) {
                              cargarDatosIniciales();
                            } else {
                              aplicarFiltros();
                            }
                          },
                        )
                            : null,
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() =>
                          fechaHasta = date.toString().split(" ")[0]);
                          aplicarFiltros();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: reportes.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return _buildFiltersSection();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: _buildReporteCard(reportes[index - 1]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}