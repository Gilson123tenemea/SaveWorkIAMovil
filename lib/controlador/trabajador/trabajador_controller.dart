import 'package:flutter/material.dart';
import '/servicios/trabajador_api.dart';

class TrabajadorController with ChangeNotifier {
  Map<String, dynamic> perfil = {};
  Map<String, dynamic> estadisticas = {};
  Map<String, dynamic> incumplimientos = {};
  Map<String, dynamic> asistencias = {};


  bool isLoading = false;
  String? error;
  Future<void> obtenerPerfil(int idTrabajador) async {
    try {
      perfil = await TrabajadorApi.obtenerPerfil(idTrabajador);
      notifyListeners();
    } catch (e) {
      print("Error al obtener perfil: $e");
    }
  }

  Future<void> obtenerEstadisticas(int idTrabajador) async {
    try {
      estadisticas = await TrabajadorApi.obtenerEstadisticas(idTrabajador);
      notifyListeners();
    } catch (e) {
      print("Error al obtener estadísticas: $e");
    }
  }

  Future<void> obtenerIncumplimientos(int idTrabajador) async {
    try {
      incumplimientos = await TrabajadorApi.obtenerIncumplimientos(idTrabajador);
      notifyListeners();
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

  Future<void> obtenerAsistenciasPorMesAno(
  int idTrabajador,
  int mes,
  int ano,
  ) async {
  await obtenerAsistencias(idTrabajador, mes: mes, ano: ano);
  }

  Future<void> obtenerAsistenciasPorAno(int idTrabajador, int ano) async {
  await obtenerAsistencias(idTrabajador, ano: ano);
  }

  Future<void> actualizarTrabajador(
      int idTrabajador, {
        String? nombre,
        String? apellido,
        String? correo,
        String? telefono,
        String? cargo,
      }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final resultado = await TrabajadorApi.actualizarTrabajador(
        idTrabajador,
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        telefono: telefono,
        cargo: cargo,
      );

      perfil = resultado;
      isLoading = false;
      error = null;
      notifyListeners();
    } catch (e) {
      error = "Error al actualizar trabajador: $e";
      print(error);
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
