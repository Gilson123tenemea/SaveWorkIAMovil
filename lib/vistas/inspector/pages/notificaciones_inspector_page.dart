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
    setState(() => _cargando = true);
    try {
      await _controller.marcarComoRevisada(idEvidencia);
      _cargarNotificaciones();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación marcada como revisada'),
            backgroundColor: Colors.green,
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
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: Column(
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
                    "Notificaciones",
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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // SECCIÓN PENDIENTES
                      if (pendientes.isNotEmpty) ...[
                        _buildSeccionTitulo(
                          "Pendientes",
                          pendientes.length,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        ...pendientes.map(
                              (notif) => _buildNotificacionCard(
                            notif,
                            esPendiente: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // SECCIÓN REVISADAS
                      if (revisadas.isNotEmpty) ...[
                        _buildSeccionTitulo(
                          "Revisadas",
                          revisadas.length,
                          Colors.green,
                        ),
                        const SizedBox(height: 12),
                        ...revisadas.map(
                              (notif) => _buildNotificacionCard(
                            notif,
                            esPendiente: false,
                          ),
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
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff073375),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cantidad.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // 🎴 TARJETA DE NOTIFICACIÓN
  Widget _buildNotificacionCard(Map<String, dynamic> notif,
      {required bool esPendiente}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: esPendiente ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esPendiente
              ? Colors.orange.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // HEADER DE LA NOTIFICACIÓN
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: esPendiente
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: esPendiente ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    esPendiente ? Icons.warning_amber : Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esPendiente ? "PENDIENTE" : "REVISADA",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: esPendiente ? Colors.orange : Colors.green,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif['detalle'] ?? 'Sin detalle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: esPendiente
                              ? const Color(0xff073375)
                              : Colors.black54,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.location_on,
                  "Zona",
                  notif['zona'] ?? 'N/A',
                  Colors.blue,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.person,
                  "Trabajador",
                  notif['trabajador'] ?? 'N/A',
                  Colors.purple,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  Icons.calendar_today,
                  "Fecha",
                  _formatearFecha(notif['fecha']),
                  Colors.teal,
                ),
                if (esPendiente) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _cargando
                          ? null
                          : () => _marcarComoRevisada(notif['id']),
                      icon: _cargando
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.done_all, size: 20),
                      label: Text(
                        _cargando ? "Procesando..." : "Marcar como Revisada",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
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