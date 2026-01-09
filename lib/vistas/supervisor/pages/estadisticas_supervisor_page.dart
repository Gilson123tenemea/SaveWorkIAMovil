import 'package:flutter/material.dart';
import '/sesion/user_session.dart';
import '/controlador/supervisor/trabajadores_controller.dart';

class EstadisticasSupervisorPage extends StatefulWidget {
  const EstadisticasSupervisorPage({super.key});

  @override
  State<EstadisticasSupervisorPage> createState() => _TrabajadoresPageState();
}

class _TrabajadoresPageState extends State<EstadisticasSupervisorPage> {
  final TrabajadoresController controller = TrabajadoresController();

  late Future<Map<String, dynamic>> futureTrabajadores;
  final TextEditingController searchController = TextEditingController();

  List<dynamic> trabajadorosFiltrados = [];
  List<dynamic> trabajadoresCompletos = [];

  @override
  void initState() {
    super.initState();
    final idSupervisor = UserSession().idSupervisor;
    futureTrabajadores = controller.listarTrabajadoresPorSupervisor(idSupervisor!);

    futureTrabajadores.then((resultado) {
      if (resultado['success']) {
        setState(() {
          trabajadoresCompletos = resultado['data'] ?? [];
          trabajadorosFiltrados = trabajadoresCompletos;
        });
      }
    });
  }

  void _filtrarTrabajadores(String query) {
    setState(() {
      if (query.isEmpty) {
        trabajadorosFiltrados = trabajadoresCompletos;
      } else {
        trabajadorosFiltrados = trabajadoresCompletos
            .where((trabajador) {
          final nombre =
          '${trabajador['persona']['nombre']} ${trabajador['persona']['apellido']}'
              .toLowerCase();
          final cedula = trabajador['persona']['cedula'].toString();
          return nombre.contains(query.toLowerCase()) ||
              cedula.contains(query);
        })
            .toList();
      }
    });
  }

  void _mostrarDialogoZonas(dynamic trabajador) {
    showDialog(
      context: context,
      builder: (context) => ZonasDialog(
        trabajador: trabajador,
        onClose: () {
          Navigator.pop(context);
          setState(() {
            futureTrabajadores = controller.listarTrabajadoresPorSupervisor(
              UserSession().idSupervisor!,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final idSupervisor = UserSession().idSupervisor;

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureTrabajadores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar trabajadores:\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, color: Colors.red),
              ),
            );
          }

          return Column(
            children: [
              // ============ ENCABEZADO ============
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
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Trabajadores Registrados",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ============ BUSCADOR ============
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchController,
                  onChanged: _filtrarTrabajadores,
                  decoration: InputDecoration(
                    hintText: "Buscar trabajador...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _filtrarTrabajadores('');
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xff073375),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ============ TABLA ============
              Expanded(
                child: trabajadorosFiltrados.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "No hay trabajadores registrados",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: trabajadorosFiltrados
                          .map((trabajador) => _buildTrabajadorCard(
                        trabajador,
                        onZonasPressed: () =>
                            _mostrarDialogoZonas(trabajador),
                      ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrabajadorCard(
      dynamic trabajador, {
        required VoidCallback onZonasPressed,
      }) {
    final nombre = trabajador['persona']['nombre'] ?? '';
    final apellido = trabajador['persona']['apellido'] ?? '';
    final cedula = trabajador['persona']['cedula'] ?? '';
    final correo = trabajador['persona']['correo'] ?? '';
    final telefono = trabajador['persona']['telefono'] ?? '';
    final codigo = trabajador['codigo_trabajador'] ?? '';
    final implementos = trabajador['implementos_requeridos'] ?? 'Pendiente';
    final estado = trabajador['estado'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- ENCABEZADO CARD ----
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xff073375),
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'T',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$nombre $apellido',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Cédula: $cedula',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // ---- ESTADO ----
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: estado ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estado ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: estado ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ---- INFO DETALLES ----
            _buildInfoRow(Icons.code, 'Código', codigo),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, 'Email', correo),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Teléfono', telefono),
            const SizedBox(height: 12),

            // ---- IMPLEMENTOS ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Implementos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: implementos == 'Entregado'
                              ? Colors.blue[100]
                              : Colors.yellow[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          implementos,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: implementos == 'Entregado'
                                ? Colors.blue[700]
                                : Colors.yellow[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // ---- BOTÓN ZONAS ----
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff073375),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onZonasPressed,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Zonas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

// ============ DIÁLOGO DE ZONAS ============
class ZonasDialog extends StatefulWidget {
  final dynamic trabajador;
  final VoidCallback onClose;

  const ZonasDialog({
    required this.trabajador,
    required this.onClose,
    super.key,
  });

  @override
  State<ZonasDialog> createState() => _ZonasDialogState();
}

class _ZonasDialogState extends State<ZonasDialog> {
  final TrabajadoresController controller = TrabajadoresController();

  late Future<Map<String, dynamic>> futureZonas;
  List<dynamic> zonas = [];
  int? selectedZoneId;
  bool loading = false;
  bool mostrarListaZonas = false; // Controla si mostrar lista o zona actual

  // Variables para la zona asignada
  Map<String, dynamic>? zonaAsignada;
  bool tieneZonaAsignada = false;
  int? idAsignacionActual;

  @override
  void initState() {
    super.initState();
    _cargarZonas();
    _verificarZonaAsignada();
  }

  void _cargarZonas() {
    final idSupervisor = UserSession().idSupervisor;
    futureZonas = controller.listarZonasDetallesPorSupervisor(idSupervisor!);

    futureZonas.then((resultado) {
      print('📍 Resultado listarZonasDetallesPorSupervisor: $resultado');
      if (resultado['success']) {
        final data = resultado['data'] ?? [];
        setState(() {
          zonas = data;
          print('✅ Zonas cargadas: ${zonas.length}');
          if (zonas.isNotEmpty) {
            print('🔍 Primera zona: ${zonas[0]}');
          }
        });
      } else {
        print('❌ Error: ${resultado['mensaje']}');
      }
    }).catchError((e) {
      print('❌ Error al cargar zonas: $e');
    });
  }

  void _verificarZonaAsignada() async {
    final resultado = await controller.obtenerDetallesTrabajadorZonas();

    print('📍 Resultado obtenerDetallesTrabajadorZonas: $resultado');

    if (resultado['success']) {
      final detalles = resultado['data'] ?? [];
      print('✅ Detalles cargados: ${detalles.length}');

      if (detalles.isNotEmpty) {
        print('🔍 Primer detalle: ${detalles[0]}');
      }

      // Buscar si este trabajador tiene una zona asignada
      final asignacion = detalles.firstWhere(
            (item) => item['trabajador_id'] == widget.trabajador['id_trabajador'],
        orElse: () => null,
      );

      print('🔎 Buscando trabajador ID: ${widget.trabajador['id_trabajador']}');
      print('📌 Asignación encontrada: $asignacion');

      if (asignacion != null) {
        setState(() {
          tieneZonaAsignada = true;
          zonaAsignada = asignacion;
          idAsignacionActual = asignacion['id_asignacion'];
          selectedZoneId = asignacion['zona_id'];
          mostrarListaZonas = false; // No mostrar lista al inicio
          print('✅ Zona asignada establecida: $zonaAsignada');
        });
      } else {
        setState(() {
          mostrarListaZonas = true; // Mostrar lista si no tiene zona
        });
      }
    }
  }

  void _asignarZona() async {
    if (selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una zona'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Si ya tiene zona asignada, eliminarla primero
      if (tieneZonaAsignada && idAsignacionActual != null) {
        print('🗑️ Eliminando asignación actual: $idAsignacionActual');
        final resultadoEliminar = await controller.eliminarAsignacionZona(
          idAsignacionActual!,
        );

        if (!resultadoEliminar['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultadoEliminar['mensaje'] ?? 'Error al cambiar zona'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => loading = false);
          return;
        }
        print('✅ Asignación eliminada correctamente');
      }

      // Ahora asignar la nueva zona
      print('➕ Asignando nueva zona: $selectedZoneId');
      final resultado = await controller.crearAsignacionTrabajadorZona(
        idTrabajador: widget.trabajador['id_trabajador'],
        idZona: selectedZoneId!,
      );

      setState(() => loading = false);

      if (resultado['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tieneZonaAsignada
                  ? 'Zona cambiada correctamente'
                  : 'Zona asignada correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onClose();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['mensaje'] ?? 'Error al asignar zona'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.trabajador['persona']['nombre'] ?? '';
    final apellido = widget.trabajador['persona']['apellido'] ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- ENCABEZADO ----
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: const Color(0xff073375),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Asignación de Zona',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$nombre $apellido',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 15),

            // ---- SI TIENE ZONA ASIGNADA Y NO ESTÁ CAMBIANDO ----
            if (tieneZonaAsignada && !mostrarListaZonas && zonaAsignada != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zona Asignada:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff073375).withOpacity(0.1),
                      border: Border.all(color: const Color(0xff073375), width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zonaAsignada!['zona_nombre'] ?? 'Zona',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff073375),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child:
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff073375),
                      ),
                      onPressed: () {
                        setState(() {
                          mostrarListaZonas = true;
                          selectedZoneId = null;
                        });
                      },
                      child: const Text(
                        'Cambiar Zona',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ),
                ],
              )
            // ---- SI NO TIENE ZONA O ESTÁ CAMBIANDO ----
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona una zona:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ---- ZONA SELECCIONADA (Si existe) ----
                  if (selectedZoneId != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zona Seleccionada:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            border: Border.all(color: Colors.green, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _obtenerNombreZonaPorId(selectedZoneId),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // ---- LISTA DE ZONAS ----
                  FutureBuilder<Map<String, dynamic>>(
                    future: futureZonas,
                    builder: (context, snapshot) {
                      print('📊 FutureBuilder state: ${snapshot.connectionState}');
                      print('📊 Zonas en memoria: ${zonas.length}');

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (zonas.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No hay zonas disponibles',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }

                      // Filtrar zonas: si está cambiando, no mostrar la actual
                      final zonasDisponibles = mostrarListaZonas && tieneZonaAsignada
                          ? zonas
                          .where((zona) =>
                      zona['zona']['id'] != zonaAsignada!['zona_id'])
                          .toList()
                          : zonas;

                      if (zonasDisponibles.isEmpty && tieneZonaAsignada) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No hay otras zonas disponibles',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: zonasDisponibles
                              .map((zona) => _buildZonaOption(zona))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // ---- BOTONES ----
            if (mostrarListaZonas || !tieneZonaAsignada)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (tieneZonaAsignada && mostrarListaZonas) {
                          setState(() {
                            mostrarListaZonas = false;
                            selectedZoneId = zonaAsignada!['zona_id'];
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff073375),
                      ),
                      onPressed: loading ? null : _asignarZona,
                      child: loading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : Text(
                        tieneZonaAsignada && mostrarListaZonas ? 'Cambiar Zona' : 'Guardar',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )

                  ),
                ],
              )
            else
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                ),
                child: const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Cerrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildZonaOption(dynamic zona) {
    // Extraer datos de la estructura anidada
    final zoneId = zona['zona']['id'];
    final zoneName = zona['zona']['nombre'];
    final inspectorNombre = zona['inspector']['nombre'] ?? '';
    final inspectorApellido = zona['inspector']['apellido'] ?? '';
    final inspectorCompleto = '$inspectorNombre $inspectorApellido';

    print('🏗️ Construyendo zona: ID=$zoneId, Nombre=$zoneName');

    final isSelected = selectedZoneId == zoneId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.green[50] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            selectedZoneId = zoneId;
            print('✅ Zona seleccionada: $zoneId');
          }),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Radio<int?>(
                  value: zoneId,
                  groupValue: selectedZoneId,
                  activeColor: Colors.green,
                  onChanged: (value) => setState(() {
                    selectedZoneId = value;
                    print('✅ Zona seleccionada (radio): $value');
                  }),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zoneName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (inspectorCompleto.trim().isNotEmpty)
                        Text(
                          'Inspector: $inspectorCompleto',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _obtenerNombreZonaPorId(int? zoneId) {
    if (zoneId == null) return '';
    try {
      final zona = zonas.firstWhere(
            (z) => z['zona']['id'] == zoneId,
        orElse: () => null,
      );
      return zona != null ? zona['zona']['nombre'] : 'Zona desconocida';
    } catch (e) {
      return 'Zona desconocida';
    }
  }
}