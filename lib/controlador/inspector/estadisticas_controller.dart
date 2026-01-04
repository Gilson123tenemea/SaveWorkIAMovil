import 'package:flutter/material.dart';
import '/servicios/estadisticas_api.dart';

class EstadisticasController with ChangeNotifier {

  Map<String, dynamic> incumplimientosPorZona = {};
  Map<String, dynamic> cumplimientosPorZona = {};
  Map<String, dynamic> eppMasCumplido = {};

  bool isLoadingIncumplimientos = false;
  bool isLoadingCumplimientos = false;
  bool isLoadingEpp = false;

  String? errorIncumplimientos;
  String? errorCumplimientos;
  String? errorEpp;

  Future<void> obtenerIncumplimientosPorZona({
    required int idInspector,
    required int idEmpresa,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    isLoadingIncumplimientos = true;
    errorIncumplimientos = null;
    notifyListeners();

    try {
      incumplimientosPorZona = await EstadisticasApi.obtenerIncumplimientosPorZona(
        idInspector: idInspector,
        idEmpresa: idEmpresa,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      errorIncumplimientos = null;
    } catch (e) {
      errorIncumplimientos = "Error al obtener incumplimientos: $e";
      print(errorIncumplimientos);
    } finally {
      isLoadingIncumplimientos = false;
      notifyListeners();
    }
  }

  Future<void> obtenerCumplimientosPorZona({
    required int idInspector,
    required int idEmpresa,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    isLoadingCumplimientos = true;
    errorCumplimientos = null;
    notifyListeners();

    try {
      cumplimientosPorZona = await EstadisticasApi.obtenerCumplimientosPorZona(
        idInspector: idInspector,
        idEmpresa: idEmpresa,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      errorCumplimientos = null;
    } catch (e) {
      errorCumplimientos = "Error al obtener cumplimientos: $e";
      print(errorCumplimientos);
    } finally {
      isLoadingCumplimientos = false;
      notifyListeners();
    }
  }

  Future<void> obtenerEppMasCumplido({
    required int idEmpresa,
    int? idInspector,
    int? idZona,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    isLoadingEpp = true;
    errorEpp = null;
    notifyListeners();

    try {
      eppMasCumplido = await EstadisticasApi.obtenerEppMasCumplido(
        idEmpresa: idEmpresa,
        idInspector: idInspector,
        idZona: idZona,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      errorEpp = null;
    } catch (e) {
      errorEpp = "Error al obtener estadísticas de EPP: $e";
      print(errorEpp);
    } finally {
      isLoadingEpp = false;
      notifyListeners();
    }
  }

  void limpiarEstadisticas() {
    incumplimientosPorZona = {};
    cumplimientosPorZona = {};
    eppMasCumplido = {};
    errorIncumplimientos = null;
    errorCumplimientos = null;
    errorEpp = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> get itemsIncumplimientos {
    if (incumplimientosPorZona.isEmpty ||
        !incumplimientosPorZona.containsKey('items')) {
      return [];
    }
    return List<Map<String, dynamic>>.from(incumplimientosPorZona['items']);
  }

  List<Map<String, dynamic>> get itemsCumplimientos {
    if (cumplimientosPorZona.isEmpty ||
        !cumplimientosPorZona.containsKey('items')) {
      return [];
    }
    return List<Map<String, dynamic>>.from(cumplimientosPorZona['items']);
  }

  List<Map<String, dynamic>> get itemsEpp {
    if (eppMasCumplido.isEmpty ||
        !eppMasCumplido.containsKey('items')) {
      return [];
    }
    return List<Map<String, dynamic>>.from(eppMasCumplido['items']);
  }

  int get totalIncumplimientos {
    return incumplimientosPorZona['total'] ?? 0;
  }

  int get totalCumplimientos {
    return cumplimientosPorZona['total'] ?? 0;
  }

  int get totalEpp {
    return eppMasCumplido['total'] ?? 0;
  }
}