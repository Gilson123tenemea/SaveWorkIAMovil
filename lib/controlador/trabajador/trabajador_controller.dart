import 'package:flutter/material.dart';
import '/servicios/trabajador_api.dart';

class TrabajadorController with ChangeNotifier {
  // Variables de estado
  Map<String, dynamic> perfil = {};
  Map<String, dynamic> estadisticas = {};
  Map<String, dynamic> incumplimientos = {};
  Map<String, dynamic> asistencias = {};


  bool isLoading = false;
  String? error;
  // 🔹 Obtener perfil del trabajador
  Future<void> obtenerPerfil(int idTrabajador) async {
    try {
      perfil = await TrabajadorApi.obtenerPerfil(idTrabajador);
      notifyListeners(); // Notifica a la vista para actualizar
    } catch (e) {
      print("Error al obtener perfil: $e");
    }
  }

  // 🔹 Obtener estadísticas del trabajador
  Future<void> obtenerEstadisticas(int idTrabajador) async {
    try {
      estadisticas = await TrabajadorApi.obtenerEstadisticas(idTrabajador);
      notifyListeners(); // Notifica a la vista para actualizar
    } catch (e) {
      print("Error al obtener estadísticas: $e");
    }
  }

  // 🔹 Obtener historial de incumplimientos del trabajador
  Future<void> obtenerIncumplimientos(int idTrabajador) async {
    try {
      incumplimientos = await TrabajadorApi.obtenerIncumplimientos(idTrabajador);
      notifyListeners(); // Notifica a la vista para actualizar
    } catch (e) {
      print("Error al obtener incumplimientos: $e");
    }
  }

  Future<void> obtenerAsistencias(
      int idTrabajador, {
        int? mes,
        int? ano,
      }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      asistencias = await TrabajadorApi.obtenerAsistencias(
        idTrabajador,
        mes: mes,
        ano: ano,
      );
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = "Error al obtener asistencias: $e";
      print(error);
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Obtener asistencias de un mes y año específico
  Future<void> obtenerAsistenciasPorMesAno(
  int idTrabajador,
  int mes,
  int ano,
  ) async {
  await obtenerAsistencias(idTrabajador, mes: mes, ano: ano);
  }

  // 🔹 Obtener asistencias de un año específico
  Future<void> obtenerAsistenciasPorAno(int idTrabajador, int ano) async {
  await obtenerAsistencias(idTrabajador, ano: ano);
  }
}
