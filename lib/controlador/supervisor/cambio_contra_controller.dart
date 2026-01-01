import '../../servicios/cambio_contra_api.dart';

class CambioContraController {
  final CambioContraApi _api = CambioContraApi();

  Future<Map<String, dynamic>> solicitar(
      String correo, int idPersona) async {
    try {
      final response = await _api.solicitarCambioContrasena(correo, idPersona);

      if (response.containsKey('error')) {
        return {
          'success': false,
          'mensaje': response['error'] ?? 'Error al solicitar el token',
        };
      }

      return {
        'success': true,
        'mensaje': response['mensaje'] ?? 'Token enviado correctamente',
        'correo': response['correo'],
        'expira_en_minutos': response['expira_en_minutos'],
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexion: $e',
      };
    }
  }

  Future<Map<String, dynamic>> confirmar(
      String token, String nuevaContrasena, int idPersona) async {
    try {
      if (nuevaContrasena.isEmpty) {
        return {
          'success': false,
          'mensaje': 'La contrasena no puede estar vacia',
        };
      }

      if (nuevaContrasena.length < 6) {
        return {
          'success': false,
          'mensaje': 'La contrasena debe tener al menos 6 caracteres',
        };
      }

      final response = await _api.confirmarCambioContrasena(
          token, nuevaContrasena, idPersona);

      if (response.containsKey('error')) {
        return {
          'success': false,
          'mensaje': response['error'] ?? 'Error al cambiar la contrasena',
        };
      }

      return {
        'success': true,
        'mensaje': response['mensaje'] ?? 'Contrasena actualizada correctamente',
        'correo': response['correo'],
        'nombre': response['nombre'],
      };
    } catch (e) {
      return {
        'success': false,
        'mensaje': 'Error de conexion: $e',
      };
    }
  }
}