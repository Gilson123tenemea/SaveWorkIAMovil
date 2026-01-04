import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '/../../sesion/user_session.dart';
import '/../../controlador/inspector/estadisticas_controller.dart';

class ZonasInspectorPage extends StatefulWidget {
  const ZonasInspectorPage({super.key});

  @override
  State<ZonasInspectorPage> createState() => _ZonasInspectorPageState();
}

class _ZonasInspectorPageState extends State<ZonasInspectorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // ✅ SOLUCIÓN: Usar addPostFrameCallback para evitar setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarEstadisticas();
    });
  }

  void _cargarEstadisticas() {
    final idInspector = UserSession().idInspector;
    final idEmpresa = UserSession().idEmpresa;

    if (idInspector != null && idEmpresa != null) {
      final controller = context.read<EstadisticasController>();

      controller.obtenerIncumplimientosPorZona(
        idInspector: idInspector,
        idEmpresa: idEmpresa,
      );

      controller.obtenerCumplimientosPorZona(
        idInspector: idInspector,
        idEmpresa: idEmpresa,
      );

      controller.obtenerEppMasCumplido(
        idEmpresa: idEmpresa,
        idInspector: idInspector,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nombre = UserSession().nombre ?? "Inspector";

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 🔷 HEADER FIJO (como HomeInspectorPage)
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
                      "Estadísticas Inspector",
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

            // 📊 CONTENIDO SCROLLABLE
            Expanded(
              child: Consumer<EstadisticasController>(
                builder: (context, controller, child) {
                  final bool cargando = controller.isLoadingIncumplimientos ||
                      controller.isLoadingCumplimientos ||
                      controller.isLoadingEpp;

                  if (cargando) {
                    return _buildLoadingState();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        // 📈 GRÁFICA DE INCUMPLIMIENTOS
                        _buildSeccionGrafica(
                          titulo: "Incumplimientos por Zona",
                          icono: Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          child: controller.errorIncumplimientos != null
                              ? _buildErrorState(controller.errorIncumplimientos!)
                              : _buildGraficaBarras(
                            controller.itemsIncumplimientos,
                            Colors.redAccent,
                            controller.totalIncumplimientos,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ✅ GRÁFICA DE CUMPLIMIENTOS
                        _buildSeccionGrafica(
                          titulo: "Cumplimientos por Zona",
                          icono: Icons.check_circle,
                          color: Colors.green,
                          child: controller.errorCumplimientos != null
                              ? _buildErrorState(controller.errorCumplimientos!)
                              : _buildGraficaBarras(
                            controller.itemsCumplimientos,
                            Colors.green,
                            controller.totalCumplimientos,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 🥽 GRÁFICA PASTEL EPP
                        _buildSeccionGrafica(
                          titulo: "EPP Más Cumplido",
                          icono: Icons.security,
                          color: Colors.blue,
                          child: controller.errorEpp != null
                              ? _buildErrorState(controller.errorEpp!)
                              : _buildGraficaPastel(
                            controller.itemsEpp,
                            controller.totalEpp,
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 SECCIÓN DE GRÁFICA
  Widget _buildSeccionGrafica({
    required String titulo,
    required IconData icono,
    required Color color,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icono, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  // 📊 GRÁFICA DE BARRAS
  Widget _buildGraficaBarras(
      List<Map<String, dynamic>> items,
      Color color,
      int total,
      ) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // TOTAL
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics, color: color, size: 28),
              const SizedBox(width: 12),
              Column(
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    total.toString(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // BARRAS
        ...items.map((item) {
          final label = item['label'] ?? '';
          final value = item['value'] ?? 0;
          final porcentaje = total > 0 ? (value / total * 100) : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "$value",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: porcentaje / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${porcentaje.toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // 🥧 GRÁFICA PASTEL
  Widget _buildGraficaPastel(List<Map<String, dynamic>> items, int total) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final value = (item['value'] ?? 0).toDouble();
                final porcentaje = total > 0 ? (value / total * 100) : 0;

                return PieChartSectionData(
                  value: value,
                  title: "${porcentaje.toStringAsFixed(0)}%",
                  color: colors[index % colors.length],
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // LEYENDA
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final label = item['label'] ?? '';
            final value = item['value'] ?? 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors[index % colors.length].withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors[index % colors.length].withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$label: $value",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 🔄 ESTADO DE CARGA
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, double value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff073375)),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            "Cargando estadísticas...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ❌ ESTADO DE ERROR
  Widget _buildErrorState(String mensaje) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // 📭 ESTADO VACÍO
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No hay datos disponibles",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No se encontraron registros para mostrar",
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}