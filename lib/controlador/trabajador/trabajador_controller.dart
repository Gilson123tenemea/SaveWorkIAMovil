import 'package:flutter/material.dart';
import '/servicios/trabajador_api.dart';

class TrabajadorController with ChangeNotifier {
  // Variables de estado
  Map<String, dynamic> perfil = {};
  Map<String, dynamic> estadisticas = {};
  Map<String, dynamic> incumplimientos = {};

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
}
