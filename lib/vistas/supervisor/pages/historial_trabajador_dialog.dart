import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class HistorialTrabajadorDialog extends StatelessWidget {
  final String nombre;
  final Map<String, dynamic> stats;
  final List<dynamic> historial;

  const HistorialTrabajadorDialog({
    super.key,
    required this.nombre,
    required this.stats,
    required this.historial,
  });

  // ✅ Mapeo de implementos con iconos y nombres en español
  final Map<String, IconData> implementosIconos = const {
    "gafas": Icons.remove_red_eye,
    "botas": Icons.safety_check,
    "chaleco": Icons.checkroom,
    "casco": Icons.health_and_safety,
    "guantes": Icons.pan_tool,
    "arnés": Icons.shield,
    "protección auditiva": Icons.volume_off,
    "mascarilla": Icons.masks,
  };

  final Map<String, String> implementosNombres = const {
    "gafas": "Gafas",
    "botas": "Botas",
    "chaleco": "Chaleco",
    "casco": "Casco",
    "guantes": "Guantes",
    "arnés": "Arnés",
    "protección auditiva": "Protección Auditiva",
    "mascarilla": "Mascarilla",
  };

  Uint8List? decode(String? base64) {
    if (base64 == null) return null;
    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }

  // ✅ Determinar si un implemento fue detectado
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

  // ✅ Construir lista dinámica de implementos por zona
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

  @override
  Widget build(BuildContext context) {
    // Agrupar por fecha
    Map<String, List<dynamic>> grouped = {};

    for (var item in historial) {
      String fecha = item["fecha_registro"] ?? item["timestamp"] ?? "Sin fecha";
      grouped.putIfAbsent(fecha, () => []);
      grouped[fecha]!.add(item);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================================================
            // ENCABEZADO
            // ====================================================
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Historial de $nombre",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff073375),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 28),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),

            const SizedBox(height: 4),
            const Text(
              "Registro completo de detecciones y cumplimiento de EPP",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // ESTADÍSTICAS
            // ====================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard("Total", stats["total"].toString()),
                _statCard("Cumple", stats["cumple"].toString(),
                    color: Colors.green),
                _statCard("Incumple", stats["incumple"].toString(),
                    color: Colors.red),
                _statCard("Tasa", "${stats["tasa"]}%", color: Colors.blue),
              ],
            ),

            const SizedBox(height: 20),

            // ====================================================
            // SCROLL DEL HISTORIAL
            // ====================================================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: grouped.entries.map((entry) {
                    final fecha = entry.key;
                    final registros = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FECHA
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(
                                fecha,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // REGISTROS DEL DÍA
                        Column(
                          children: registros.map((item) {
                            return _buildHistorialCard(item, context);
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD DE ESTADÍSTICA
  // ============================================================
  Widget _statCard(String title, String value, {Color color = Colors.black}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 11, color: Colors.black54),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARD DE CADA REGISTRO DEL HISTORIAL
  // ============================================================
  Widget _buildHistorialCard(dynamic r, BuildContext context) {
    final trabajador = r["trabajador"];
    final evidencia = r["evidencia"];
    final camara = r["camara"];
    final inspector = r["inspector"];
    final eppsZona = r["epps_zona"] as List<dynamic>? ?? [];
    final detecciones = r["detecciones"] as List<dynamic>? ?? [];

    // Decodificar foto
    final foto = decode(evidencia?["foto_base64"]);

    // Determinar si hay incumplimiento
    final detalle = evidencia?["detalle"]?.toString().toLowerCase() ?? "";
    final hasViolation = detalle.contains("incumplimiento") ||
        detalle.contains("falta") ||
        detecciones.isNotEmpty;

    // ✅ Construir lista dinámica de implementos
    final implementos = construirImplementosPorZona(
      eppsZona,
      detecciones,
      detalle,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // IMAGEN + BADGE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (foto != null) {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: InteractiveViewer(
                            child: Image.memory(foto),
                          ),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 110,
                      height: 85,
                      color: Colors.grey.shade200,
                      child: foto != null
                          ? Image.memory(foto, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BADGE INCUMPLIMIENTO
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: hasViolation
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          hasViolation ? "Incumplimiento" : "Cumplimiento",
                          style: TextStyle(
                            color: hasViolation
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text("${r["fecha_registro"] ?? ""}",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 4),

                      Text("Cámara: ${camara?["codigo"] ?? "N/A"}",
                          style: const TextStyle(fontSize: 12)),
                      Text("Zona: ${camara?["zona"] ?? "N/A"}",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ IMPLEMENTOS DINÁMICOS
            implementos.isEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Sin EPPs requeridos para esta zona",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            )
                : GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.8,
              children: implementos.map((item) {
                final detectado = item["detectado"];

                return Container(
                  decoration: BoxDecoration(
                    color: detectado
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: detectado ? Colors.green : Colors.red,
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(
                        item["icon"],
                        color: detectado ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item["nombre"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: detectado
                                    ? Colors.green.shade900
                                    : Colors.red,
                              ),
                            ),
                            Text(
                              detectado ? "Detectado" : "No detectado",
                              style: TextStyle(
                                color: detectado
                                    ? Colors.green.shade700
                                    : Colors.red,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),


          ],
        ),
      ),
    );
  }
}