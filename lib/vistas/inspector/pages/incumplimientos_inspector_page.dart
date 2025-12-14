import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../../../sesion/user_session.dart';
import '../../../controlador/inspector/reportes_inspector_controller.dart';
import '../../../controlador/inspector/evidencias_fallo_controller.dart';
import 'historial_inspector_dialog.dart';

class IncumplimientosInspectorPage extends StatefulWidget {
  const IncumplimientosInspectorPage({super.key});

  @override
  State<IncumplimientosInspectorPage> createState() =>
      _IncumplimientosInspectorPageState();
}

class _IncumplimientosInspectorPageState
    extends State<IncumplimientosInspectorPage> {
  final ReportesInspectorController reportesController =
  ReportesInspectorController();
  final EvidenciasFalloController evidenciasController =
  EvidenciasFalloController();

  List<dynamic> reportes = [];
  List<dynamic> zonas = [];

  bool isLoading = true;

  String filtroEstado = "todos";
  String? filtroZona;
  String? fechaDesde;
  String? fechaHasta;

  int? evidenciaSeleccionada;
  final TextEditingController observacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final idInspector = UserSession().idInspector!;
    setState(() => isLoading = true);

    final data = await reportesController.obtenerIncumplimientos(
      idInspector: idInspector,
    );

    final zonasData =
    await reportesController.obtenerZonasInspector(idInspector);

    setState(() {
      reportes = data;
      zonas = zonasData;
      isLoading = false;
    });
  }

  Future<void> aplicarFiltros() async {
    final idInspector = UserSession().idInspector!;
    setState(() => isLoading = true);

    final data = await reportesController.obtenerIncumplimientos(
      idInspector: idInspector,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      idZona: filtroZona != null ? int.parse(filtroZona!) : null,
    );

    setState(() {
      reportes = data;
      isLoading = false;
    });
  }

  Widget _buildHeader() {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff073375), Color(0xff0a4499)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 20),
      child: const Text(
        "Incumplimientos Detectados",
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _estadoButton("todos", "Todos"),
              _estadoButton("pendientes", "Pendientes"),
              _estadoButton("revisados", "Revisados"),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Zona",
              labelStyle: const TextStyle(color: Color(0xff073375)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xff073375), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xff073375), width: 1.5),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            items: [
              const DropdownMenuItem(value: "todas", child: Text("Todas")),
              ...zonas.map((z) => DropdownMenuItem(
                value: z["id"].toString(),
                child: Text(z["nombre"]),
              )),
            ],
            onChanged: (val) {
              filtroZona = val == "todas" ? null : val;
              aplicarFiltros();
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _dateField("Desde", true)),
              const SizedBox(width: 12),
              Expanded(child: _dateField("Hasta", false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estadoButton(String value, String label) {
    final selected = filtroEstado == value;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor:
            selected ? const Color(0xff073375) : Colors.transparent,
            foregroundColor: selected ? Colors.white : const Color(0xff073375),
            side: const BorderSide(
              color: Color(0xff073375),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: () {
            setState(() => filtroEstado = value);
          },
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _dateField(String label, bool desde) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff073375)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff073375), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff073375), width: 1.5),
        ),
        suffixIcon: const Icon(Icons.calendar_today,
            color: Color(0xff073375), size: 20),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      controller: TextEditingController(text: desde ? fechaDesde : fechaHasta),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(2023),
          lastDate: DateTime.now(),
          initialDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            if (desde) {
              fechaDesde = date.toString().split(" ")[0];
            } else {
              fechaHasta = date.toString().split(" ")[0];
            }
          });
          aplicarFiltros();
        }
      },
    );
  }

  // ✅ helper: normaliza estado venga como bool/int/null/String
  bool _esRevisado(dynamic estadoRaw) {
    if (estadoRaw == null) return false;
    if (estadoRaw is bool) return estadoRaw;          // true/false
    if (estadoRaw is int) return estadoRaw == 1;      // 1/0
    if (estadoRaw is String) {
      final v = estadoRaw.toLowerCase().trim();
      return v == "revisado" || v == "true" || v == "1";
    }
    return false;
  }

  Widget _buildReporteCard(dynamic rep) {
    final trabajador = rep["trabajador"];
    final evidencia = rep["evidencia"];
    final camara = rep["camara"];

    // ✅ estado normalizado
    final dynamic estadoRaw = evidencia["estado"];
    final bool estaRevisado = _esRevisado(estadoRaw);

    Uint8List? fotoBytes = evidencia["foto_base64"] != null
        ? base64Decode(evidencia["foto_base64"])
        : null;

    // ✅ filtros SIN cambiar tu UI
    if (filtroEstado == "pendientes" && estaRevisado) {
      return const SizedBox.shrink();
    }
    if (filtroEstado == "revisados" && !estaRevisado) {
      return const SizedBox.shrink();
    }

    final borderColor =
    estaRevisado ? Colors.green.shade300 : Colors.red.shade300;

    final tieneObservacion = evidencia["observaciones"] != null &&
        evidencia["observaciones"].toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER CON FOTO E INFO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (fotoBytes != null) {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: InteractiveViewer(
                            child: Image.memory(fotoBytes),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: fotoBytes != null
                          ? DecorationImage(
                        image: MemoryImage(fotoBytes),
                        fit: BoxFit.cover,
                      )
                          : null,
                      color: Colors.grey.shade200,
                    ),
                    child: fotoBytes == null
                        ? const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${trabajador["nombre"]} ${trabajador["apellido"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xff073375),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.videocam,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Cámara: ${camara["codigo"]}",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Zona: ${camara["zona"]}",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rep["fecha_registro"],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: estaRevisado
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estaRevisado ? "Revisado" : "Pendiente",
                    style: TextStyle(
                      color: estaRevisado
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // GRID DE IMPLEMENTOS
            _buildImplementosGrid(evidencia["detalle"] ?? ""),
            const SizedBox(height: 16),

            // MOSTRAR OBSERVACIONES SI EXISTEN
            if (tieneObservacion)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.comment,
                            color: Colors.blue.shade600, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Observación",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      evidencia["observaciones"].toString(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // BOTONES
            Row(
              children: [
                // ✅ Observación BLOQUEADA si ya existe
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: tieneObservacion
                        ? null
                        : () {
                      evidenciaSeleccionada = evidencia["id_evidencia"];
                      _mostrarDialogoObservacion();
                    },
                    icon: const Icon(Icons.note_add, size: 18),
                    label: const Text("Observación"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      disabledBackgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // ✅ Botón revisado SOLO si NO está revisado
                if (!estaRevisado)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await evidenciasController.actualizarEvidencia(
                            idEvidencia: evidencia["id_evidencia"],
                            estado: true, // ✅ envía bool (backend lo espera)
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text("Marcado como revisado correctamente"),
                              backgroundColor: Colors.green,
                            ),
                          );

                          cargarDatos();
                        } catch (e) {
                          print("Error detallado: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: ${e.toString()}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text("Revisado"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),

                if (!estaRevisado) const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarHistorial(trabajador["cedula"]),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text("Historial"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff073375),
                      side: const BorderSide(
                        color: Color(0xff073375),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  Widget _buildImplementosGrid(String detalle) {
    final detalleMin = detalle.toLowerCase();

    final items = [
      {"name": "Casco", "key": "casco", "icon": Icons.health_and_safety},
      {"name": "Chaleco", "key": "chaleco", "icon": Icons.checkroom},
      {"name": "Botas", "key": "botas", "icon": Icons.safety_check},
      {"name": "Guantes", "key": "guantes", "icon": Icons.pan_tool},
      {"name": "Lentes", "key": "lentes", "icon": Icons.remove_red_eye},
    ];

    for (var item in items) {
      item["detected"] = !detalleMin.contains(item["key"] as String);
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: items.map((item) {
        final detected = item["detected"] as bool;
        final name = (item["name"] as String?) ?? "Implemento";
        final icon = item["icon"] as IconData;

        return Container(
          decoration: BoxDecoration(
            color: detected ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: detected ? Colors.green : Colors.red,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: detected ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: detected ? Colors.green.shade900 : Colors.red.shade900,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                detected ? "Detectado" : "No detectado",
                style: TextStyle(
                  color: detected ? Colors.green : Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _mostrarDialogoObservacion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          "Agregar Observación",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff073375),
          ),
        ),
        content: TextField(
          controller: observacionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Escribe la observación",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xff073375)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xff073375), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (observacionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Por favor escribe una observación"),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                await evidenciasController.actualizarEvidencia(
                  idEvidencia: evidenciaSeleccionada!,
                  observaciones: observacionController.text,
                );
                observacionController.clear();
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Observación guardada correctamente"),
                    backgroundColor: Colors.green,
                  ),
                );

                cargarDatos();
              } catch (e) {
                Navigator.pop(context);
                print("Error observacion: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error al guardar: ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.save, size: 18),
            label: const Text("Guardar"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarHistorial(String cedula) async {
    try {
      final Map<String, dynamic> data =
      await reportesController.obtenerHistorialTrabajador(cedula);

      print("=============== RESPUESTA COMPLETA DE API ===============");
      print(jsonEncode(data));
      print("=========================================================");

      final List<dynamic> historial =
      (data["historial"] ?? []) as List<dynamic>;

      final Map<String, dynamic>? stats =
      data["estadisticas"] as Map<String, dynamic>?;

      if (historial.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No hay historial disponible"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final nombreCompleto =
          "${historial[0]["trabajador"]["nombre"]} ${historial[0]["trabajador"]["apellido"]}";

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => HistorialInspectorDialog(
          nombre: nombreCompleto,
          historial: historial,
          stats: stats,
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
              itemCount: reportes.length + 1,
              itemBuilder: (_, index) {
                if (index == 0) return _buildFiltersSection();
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
