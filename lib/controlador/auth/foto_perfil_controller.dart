import 'dart:convert';
import '../../servicios/foto_perfil.dart';
import '../../sesion/user_session.dart';

class FotoPerfilController {
  Future<Map<String, dynamic>> obtenerFotoPerfilActual() async {
    try {
      final session = UserSession();

      // Validar que exista una sesión activa
      if (session.idPersona == null) {
        return {
          'success': false,
          'mensaje': 'No hay sesión activa. Por favor inicia sesión.',
        };
      }

      final idPersona = session.idPersona!;

      print('🔍 Obteniendo foto del trabajador: ID Persona = $idPersona');

      final response = await FotoPerfilApi.obtenerFotoPerfil(idPersona);

      if (response.containsKey('success') && !response['success']) {
        return response;
      }

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al obtener foto: $e',
      };
    }
  }

  Future<Map<String, dynamic>> obtenerFotoPerfil(int idPersona) async {
    try {
      if (idPersona <= 0) {
        return {
          'success': false,
          'mensaje': 'ID de persona inválido',
        };
      }

      final response = await FotoPerfilApi.obtenerFotoPerfil(idPersona);

      if (response.containsKey('success') && !response['success']) {
        return response;
      }

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al obtener foto: $e',
      };
    }
  }

  Future<Map<String, dynamic>> actualizarFotoPerfilActual(
      String fotoBase64,
      ) async {
    try {
      final session = UserSession();

      // Validar que exista una sesión activa
      if (session.idPersona == null) {
        return {
          'success': false,
          'mensaje': 'No hay sesión activa. Por favor inicia sesión.',
        };
      }

      final idPersona = session.idPersona!;

      // Validaciones
      if (fotoBase64.isEmpty) {
        return {
          'success': false,
          'mensaje': 'La foto no puede estar vacía',
        };
      }

      // Validar que sea base64 válido
      if (!_esBase64Valido(fotoBase64)) {
        return {
          'success': false,
          'mensaje': 'La foto no tiene un formato base64 válido',
        };
      }

      print('📤 Actualizando foto del trabajador: ID Persona = $idPersona');

      final response = await FotoPerfilApi.actualizarFotoPerfil(idPersona, fotoBase64);

      if (!response['success']) {
        return response;
      }

      return {
        'success': true,
        'mensaje': 'Foto actualizada correctamente',
        'data': response['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al actualizar foto: $e',
      };
    }
  }

  Future<Map<String, dynamic>> actualizarFotoPerfil(
      int idPersona,
      String fotoBase64,
      ) async {
    try {
      // Validaciones
      if (idPersona <= 0) {
        return {
          'success': false,
          'mensaje': 'ID de persona inválido',
        };
      }

      if (fotoBase64.isEmpty) {
        return {
          'success': false,
          'mensaje': 'La foto no puede estar vacía',
        };
      }

      // Validar que sea base64 válido
      if (!_esBase64Valido(fotoBase64)) {
        return {
          'success': false,
          'mensaje': 'La foto no tiene un formato base64 válido',
        };
      }

      final response = await FotoPerfilApi.actualizarFotoPerfil(idPersona, fotoBase64);

      if (!response['success']) {
        return response;
      }

      return {
        'success': true,
        'mensaje': 'Foto actualizada correctamente',
        'data': response['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error al actualizar foto: $e',
      };
    }
  }

  bool _esBase64Valido(String base64String) {
    try {
      base64Decode(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }
}