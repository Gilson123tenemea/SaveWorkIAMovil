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

  Uint8List? decode(String? base64) {
    if (base64 == null) return null;
    try {
      return base64Decode(base64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> grouped = {};

    for (var item in historial) {
      String fecha = item["timestamp"].split(",")[0];
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Historial de $nombre",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff073375),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 28),
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
                _statCard("Cumplimientos", stats["cumple"].toString(),
                    color: Colors.green),
                _statCard("Incumplimientos", stats["incumple"].toString(),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
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
    final foto = decode(r["image"]);
    final detections = r["detections"] as List<dynamic>;
    final hasViolation = detections.any((d) => d["detected"] == false);

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
                      width: 130,
                      height: 95,
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
                      // BADGE INFRACCIÓN
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasViolation
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hasViolation ? "Incumplimiento" : "Cumplimiento",
                          style: TextStyle(
                            color: hasViolation
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text("${r["timestamp"]}",
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),

                      Text("Cámara: ${r["camera"]}"),
                      Text("Zona: ${r["zone"]}"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // DETECCIONES
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: detections.map((d) {
                final detected = d["detected"];
                return Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                    detected ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: detected ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    "${d["item"]} - ${detected ? "Detectado" : "No detectado"}",
                    style: TextStyle(
                      color: detected ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
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
