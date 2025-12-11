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

    // Decodificar foto
    final foto = decode(evidencia?["foto_base64"]);

    // Determinar si hay incumplimiento
    final detalle = evidencia?["detalle"]?.toString().toLowerCase() ?? "";
    final hasViolation = detalle.contains("incumplimiento") || detalle.contains("falta");

    // Extraer implementos del detalle
    List<Map<String, dynamic>> implementos = [
      {"name": "Casco", "key": "casco", "icon": Icons.health_and_safety},
      {"name": "Chaleco", "key": "chaleco", "icon": Icons.checkroom},
      {"name": "Botas", "key": "botas", "icon": Icons.safety_check},
      {"name": "Guantes", "key": "guantes", "icon": Icons.pan_tool},
      {"name": "Lentes", "key": "lentes", "icon": Icons.remove_red_eye},
    ];

    for (var item in implementos) {
      item["detected"] = !detalle.contains(item["key"]);
    }

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

            // IMPLEMENTOS
            Column(
              children: implementos.map((item) {
                final detected = item["detected"];

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: detected ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: detected ? Colors.green : Colors.red,
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(item["icon"],
                          color: detected ? Colors.green : Colors.red,
                          size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item["name"],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: detected
                                    ? Colors.green.shade900
                                    : Colors.red)),
                      ),
                      Text(detected ? "✓" : "✗",
                          style: TextStyle(
                              color: detected
                                  ? Colors.green.shade700
                                  : Colors.red,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // DESCRIPCIÓN DEL DETALLE
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                evidencia?["detalle"] ?? "Sin detalle",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}