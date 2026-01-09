import 'package:flutter/material.dart';
import '../../../sesion/user_session.dart';
import '../../../controlador/inspector/notificaciones_controller.dart';

class NotificacionesInspectorPage extends StatefulWidget {
  const NotificacionesInspectorPage({super.key});

  @override
  State<NotificacionesInspectorPage> createState() =>
      _NotificacionesInspectorPageState();
}

class _NotificacionesInspectorPageState
    extends State<NotificacionesInspectorPage> {
  int? idInspector;
  final NotificacionesController _controller = NotificacionesController();
  late Future<List<dynamic>> futureNotificaciones;
  bool _cargando = false;
  int? _idEvidenciaEnProceso;

  @override
  void initState() {
    super.initState();
    idInspector = UserSession().idInspector;
    _cargarNotificaciones();
  }

  void _cargarNotificaciones() {
    if (idInspector != null) {
      setState(() {
        futureNotificaciones = _controller.obtenerNotificaciones(idInspector!);
      });
    }
  }

  Future<void> _marcarComoRevisada(int idEvidencia) async {
    setState(() {
      _cargando = true;
      _idEvidenciaEnProceso = idEvidencia;
    });
    try {
      await _controller.marcarComoRevisada(idEvidencia);
      _cargarNotificaciones();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación marcada como revisada'),
            backgroundColor: Color(0xff073375),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _cargando = false;
        _idEvidenciaEnProceso = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Column(
        children: [
          // 🔷 HEADER
          Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff073375), Color(0xff0a4a9f)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "Notificaciones",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // 📋 CONTENIDO DE NOTIFICACIONES
          Expanded(
            child: idInspector == null
                ? const Center(
              child: Text(
                "ID Inspector no disponible",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            )
                : FutureBuilder<List<dynamic>>(
              future: futureNotificaciones,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Error al cargar notificaciones",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No hay notificaciones",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final notificaciones = snapshot.data!;

                // Separar notificaciones pendientes y revisadas
                final pendientes = notificaciones
                    .where((n) => n['estado'] == true || n['estado'] == null)
                    .toList();
                final revisadas = notificaciones
                    .where((n) => n['estado'] == false)
                    .toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    _cargarNotificaciones();
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: const Color(0xff073375),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    children: [
                      // SECCIÓN PENDIENTES
                      if (pendientes.isNotEmpty) ...[
                        _buildSeccionTitulo(
                          "Pendientes de Revisión",
                          pendientes.length,
                          const Color(0xff073375),
                        ),
                        const SizedBox(height: 16),
                        ...pendientes.map(
                              (notif) => _buildNotificacionCard(notif, true),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // SECCIÓN REVISADAS
                      if (revisadas.isNotEmpty) ...[
                        _buildSeccionTitulo(
                          "Revisadas",
                          revisadas.length,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        ...revisadas.map(
                              (notif) => _buildNotificacionCard(notif, false),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🏷️ TÍTULO DE SECCIÓN
  Widget _buildSeccionTitulo(String titulo, int cantidad, Color color) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xff073375),
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            cantidad.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // 🎴 TARJETA DE NOTIFICACIÓN
  Widget _buildNotificacionCard(Map<String, dynamic> notif, bool esPendiente) {
    final idNotif = notif['id'];
    final isLoading = _cargando && _idEvidenciaEnProceso == idNotif;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: esPendiente
              ? const Color(0xff073375).withOpacity(0.15)
              : Colors.grey.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER DE LA NOTIFICACIÓN
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: esPendiente
                  ? const Color(0xff073375).withOpacity(0.06)
                  : Colors.green.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: esPendiente
                        ? const Color(0xff073375)
                        : Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    esPendiente ? Icons.pending_actions : Icons.check_circle,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esPendiente ? "PENDIENTE" : "REVISADA",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: esPendiente
                              ? const Color(0xff073375)
                              : Colors.green,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notif['detalle'] ?? 'Sin detalle',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1a1a1a),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CONTENIDO DE LA NOTIFICACIÓN
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.location_on,
                  "Zona",
                  notif['zona'] ?? 'N/A',
                  const Color(0xff2196F3),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person_outline,
                  "Trabajador",
                  notif['trabajador'] ?? 'N/A',
                  const Color(0xff9C27B0),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.access_time,
                  "Fecha",
                  _formatearFecha(notif['fecha']),
                  const Color(0xff009688),
                ),
                if (esPendiente) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _marcarComoRevisada(notif['id']),
                      icon: isLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        isLoading ? "Procesando..." : "Marcar como Revisada",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff073375),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📝 FILA DE INFORMACIÓN
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
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
    );
  }

  // 📅 FORMATEAR FECHA
  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(fecha);
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return "${dateTime.day} ${meses[dateTime.month - 1]} ${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return fecha.split('T')[0];
    }
  }
}