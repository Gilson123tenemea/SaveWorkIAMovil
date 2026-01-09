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

class _ZonasInspectorPageState extends State<ZonasInspectorPage> {
  @override
  void initState() {
    super.initState();

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
                "Estadísticas",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      _buildSeccionGrafica(
                        titulo: "Incumplimientos por Zona",
                        icono: Icons.warning_rounded,
                        color: const Color(0xffE53935),
                        child: controller.errorIncumplimientos != null
                            ? _buildErrorState(controller.errorIncumplimientos!)
                            : _buildGraficaBarras(
                          controller.itemsIncumplimientos,
                          const Color(0xffE53935),
                          controller.totalIncumplimientos,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildSeccionGrafica(
                        titulo: "Cumplimientos por Zona",
                        icono: Icons.verified_rounded,
                        color: const Color(0xff43A047),
                        child: controller.errorCumplimientos != null
                            ? _buildErrorState(controller.errorCumplimientos!)
                            : _buildGraficaBarras(
                          controller.itemsCumplimientos,
                          const Color(0xff43A047),
                          controller.totalCumplimientos,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildSeccionGrafica(
                        titulo: "EPP Más Cumplido",
                        icono: Icons.security_rounded,
                        color: const Color(0xff1976D2),
                        child: controller.errorEpp != null
                            ? _buildErrorState(controller.errorEpp!)
                            : _buildGraficaPastel(
                          controller.itemsEpp,
                          controller.totalEpp,
                        ),
                      ),

                      const SizedBox(height: 32),
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

  Widget _buildSeccionGrafica({
    required String titulo,
    required IconData icono,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
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
                  child: Icon(icono, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }

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
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: total),
          duration: const Duration(milliseconds: 1500),
          builder: (context, value, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.trending_up, color: color, size: 26),
                  const SizedBox(width: 14),
                  Column(
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final label = item['label'] ?? '';
          final value = item['value'] ?? 0;
          final porcentaje = total > 0 ? (value / total * 100) : 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
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
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: value),
                      duration: Duration(milliseconds: 1000 + (index * 200)),
                      builder: (context, val, child) {
                        return Text(
                          val.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: porcentaje / 100,
                  ),
                  duration: Duration(milliseconds: 1200 + (index * 200)),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: val,
                        minHeight: 14,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  "${porcentaje.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGraficaPastel(List<Map<String, dynamic>> items, int total) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    final colors = [
      const Color(0xff1976D2),
      const Color(0xff43A047),
      const Color(0xffFB8C00),
      const Color(0xff9C27B0),
      const Color(0xffE53935),
      const Color(0xff00897B),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Column(
          children: [
            SizedBox(
              height: 240,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  startDegreeOffset: -90,
                  sections: items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final value = (item['value'] ?? 0).toDouble();
                    final porcentaje = total > 0 ? (value / total * 100) : 0;

                    return PieChartSectionData(
                      value: value * animValue,
                      title: animValue > 0.7
                          ? "${porcentaje.toStringAsFixed(0)}%"
                          : "",
                      color: colors[index % colors.length],
                      radius: 65,
                      titleStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // LEYENDA
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final label = item['label'] ?? '';
                final value = item['value'] ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: colors[index % colors.length].withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors[index % colors.length].withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        "$label: $value",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
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
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String mensaje) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 44),
          const SizedBox(height: 12),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No hay datos disponibles",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No se encontraron registros para mostrar",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}