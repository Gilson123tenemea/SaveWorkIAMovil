import '../../servicios/trabajadores_api.dart';

class TrabajadoresController {
  // 🔹 Listar Trabajadores de un Supervisor
  Future<Map<String, dynamic>> listarTrabajadoresPorSupervisor(int idSupervisor) async {
    try {
      if (idSupervisor <= 0) {
        return {
          'success': false,
          'mensaje': 'ID de supervisor inválido',
        };
      }

      final response = await TrabajadoresApi.listarTrabajadoresPorSupervisor(idSupervisor);

      return {
        'success': true,
        'data': response,
        'total': response.length,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al listar trabajadores del supervisor: $e',
      };
    }
  }

  // 🔹 Obtener Detalles de Asignaciones Trabajador - Zona (ACTIVAS)
  Future<Map<String, dynamic>> obtenerDetallesTrabajadorZonas() async {
    try {
      final response = await TrabajadoresApi.obtenerDetallesTrabajadorZonas();

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al obtener detalles de asignaciones: $e',
      };
    }
  }

  // 🔹 Listar Zonas con Detalles por Supervisor
  Future<Map<String, dynamic>> listarZonasDetallesPorSupervisor(int idSupervisor) async {
    try {
      if (idSupervisor <= 0) {
        return {
          'success': false,
          'mensaje': 'ID de supervisor inválido',
        };
      }

      final response = await TrabajadoresApi.listarZonasDetallesPorSupervisor(idSupervisor);

      return {
        'success': true,
        'data': response,
        'total': response.length,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al listar zonas del supervisor: $e',
      };
    }
  }

  // 🔹 Eliminar Lógicamente Asignación Trabajador - Zona
  Future<Map<String, dynamic>> eliminarAsignacionZona(int idAsignacion) async {
    try {
      if (idAsignacion <= 0) {
        return {
          'success': false,
          'mensaje': 'ID de asignación inválido',
        };
      }

      final response = await TrabajadoresApi.eliminarLogicaAsignacionZona(idAsignacion);

      return {
        'success': true,
        'mensaje': 'Asignación eliminada correctamente',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al eliminar asignación: $e',
      };
    }
  }

  // 🔹 Crear Asignación Trabajador - Zona
  Future<Map<String, dynamic>> crearAsignacionTrabajadorZona({
    required int idTrabajador,
    required int idZona,
  }) async {
    try {
      if (idTrabajador <= 0 || idZona <= 0) {
        return {
          'success': false,
          'mensaje': 'Los IDs de trabajador y zona son requeridos',
        };
      }

      final data = {
        'id_trabajador_trabajadorzona': idTrabajador,
        'id_zona_trabajadorzona': idZona,
      };

      final response = await TrabajadoresApi.crearAsignacionTrabajadorZona(data);

      return {
        'success': true,
        'mensaje': 'Zona asignada correctamente',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al asignar zona: $e',
      };
    }
  }
}