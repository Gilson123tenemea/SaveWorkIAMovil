import '../../servicios/perfil_supervisor_api.dart';

class PerfilSupervisorController {
  final PerfilSupervisorApi _api = PerfilSupervisorApi();

  /// Obtener perfil completo del supervisor
  Future<Map<String, dynamic>> obtenerPerfilSupervisor(int idSupervisor) async {
    try {
      return await _api.obtenerPerfilSupervisor(idSupervisor);
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al obtener perfil: $e',
      };
    }
  }

  /// Actualizar perfil del supervisor
  Future<Map<String, dynamic>> actualizar(
      int idSupervisor,
      String nombre,
      String apellido,
      String correo,
      String telefono,
      ) async {
    try {
      if (nombre.isEmpty || correo.isEmpty || telefono.isEmpty) {
        return {
          'success': false,
          'mensaje': 'Todos los campos son requeridos',
        };
      }

      if (!correo.contains('@')) {
        return {
          'success': false,
          'mensaje': 'El correo no es valido',
        };
      }

      final response = await _api.actualizarPerfilSupervisor(
        idSupervisor,
        nombre,
        apellido,
        correo,
        telefono,
      );

      return {
        'success': true,
        'mensaje': 'Perfil actualizado correctamente',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al actualizar perfil: $e',
      };
    }
  }

  /// Actualizar foto de perfil del supervisor
  Future<Map<String, dynamic>> actualizarFoto(
      int idPersona,
      String fotoBase64,
      ) async {
    try {
      if (fotoBase64.isEmpty) {
        return {
          'success': false,
          'mensaje': 'La foto no puede estar vacia',
        };
      }

      final response = await _api.actualizarFotoSupervisor(
        idPersona,
        fotoBase64,
      );

      return {
        'success': true,
        'mensaje': 'Foto actualizada correctamente',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al actualizar foto: $e',
      };
    }
  }
}