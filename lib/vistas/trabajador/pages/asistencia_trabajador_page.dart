import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../servicios/trabajador_api.dart';

class AsistenciaTrabajadorPage extends StatefulWidget {
  const AsistenciaTrabajadorPage({super.key});

  @override
  State<AsistenciaTrabajadorPage> createState() =>
      _AsistenciaTrabajadorPageState();
}

class _AsistenciaTrabajadorPageState extends State<AsistenciaTrabajadorPage> {
  Map<String, dynamic>? asistencias;
  bool loading = true;
  int? mesSeleccionado;
  int? anoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarAsistencias();
  }

  Future<void> _cargarAsistencias({int? mes, int? ano}) async {
    final idTrabajador = UserSession().idTrabajador;
    if (idTrabajador == null) return;

    setState(() => loading = true);

    try {
      final data = await TrabajadorApi.obtenerAsistencias(
        idTrabajador,
        mes: mes,
        ano: ano,
      );

      setState(() {
        asistencias = data;
        mesSeleccionado = mes;
        anoSeleccionado = ano;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = UserSession().nombre;

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
                      "Historial de Asistencia",
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

            // 👤 NOMBRE DEL TRABAJADOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Trabajador: $nombre",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff073375),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔍 FILTROS
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filtrar por:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff073375),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // 📅 MES
                        Expanded(
                          child: DropdownButton<int?>(
                            isExpanded: true,
                            value: mesSeleccionado,
                            hint: const Text("Seleccionar mes"),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("Todos los meses"),
                              ),
                              ...List.generate(
                                12,
                                    (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(_getNombreMes(i + 1)),
                                ),
                              ),
                            ],
                            onChanged: (mes) {
                              _cargarAsistencias(
                                mes: mes,
                                ano: anoSeleccionado,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 📆 AÑO
                        Expanded(
                          child: DropdownButton<int?>(
                            isExpanded: true,
                            value: anoSeleccionado,
                            hint: const Text("Seleccionar año"),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("Todos los años"),
                              ),
                              ...List.generate(
                                5,
                                    (i) => DropdownMenuItem(
                                  value: DateTime.now().year - i,
                                  child: Text(
                                    (DateTime.now().year - i).toString(),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (ano) {
                          _cargarAsistencias(
                          mes: mesSeleccionado,
                          ano: ano,
                          );
                          },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📋 TABLA DE REGISTROS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Registros de Asistencia",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff073375),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTablaAsistencias(),
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
  // 📊 TARJETAS DE ESTADÍSTICAS - REMOVIDO
  // =============================

  // =============================
  // 📋 TABLA DE REGISTROS
  // =============================
  Widget _buildTablaAsistencias() {
    final registros = asistencias!["registros"] as List<dynamic>;

    if (registros.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            "No hay registros disponibles",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final registro = registros[index];
        final cumple = registro["cumple_epp"] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: cumple ? Colors.green : Colors.red,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FECHA Y HORA + ESTADO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${registro['fecha']} ${registro['hora']}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff073375),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cumple
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cumple ? "✓ Cumple" : "✗ No Cumple",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cumple ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ZONA Y CÁMARA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Zona",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          registro['nombre_zona'] ?? "N/A",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cámara",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          registro['codigo_camara'] ?? "N/A",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // INSPECTOR
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inspector",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    "${registro['nombre_inspector']} ${registro['apellido_inspector']}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =============================
  // 🔧 HELPER: NOMBRE DEL MES
  // =============================
  String _getNombreMes(int mes) {
    const meses = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre",
    ];
    return meses[mes - 1];
  }
}