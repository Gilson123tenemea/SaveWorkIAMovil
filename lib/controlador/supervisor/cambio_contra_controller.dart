import '../../servicios/cambio_contra_api.dart';

class CambioContraController {
  final CambioContraApi _api = CambioContraApi();

  // Validar formato de contraseña
  bool _validarFormatoContrasena(String password) {
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'\d'));
    final hasSpecial = password.contains(RegExp(r'[@$!%*#?&]'));

    return hasLowercase && hasUppercase && hasNumber && hasSpecial;
  }

  Future<Map<String, dynamic>> solicitar(String correo, int idPersona) async {
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

  Future<void> confirmar(String token,
      String nuevaContrasena,
      int idPersona,) async {
    // 🔹 Validaciones locales (se quedan)
    if (token
        .trim()
        .isEmpty) {
      throw Exception('El token es obligatorio');
    }

    if (nuevaContrasena.isEmpty) {
      throw Exception('La contraseña no puede estar vacía');
    }

    if (nuevaContrasena.length < 8) {
      throw Exception('La contraseña debe tener al menos 8 caracteres');
    }

    if (!_validarFormatoContrasena(nuevaContrasena)) {
      throw Exception(
          'La contraseña debe tener mayúsculas, minúsculas, números y caracteres especiales (@\$!%*#?&)'
      );
    }

    // 🔹 Llamada al API
    final response = await _api.confirmarCambioContrasena(
      token,
      nuevaContrasena,
      idPersona,
    );

    // 🔴 ERROR DEL BACKEND → SE LANZA
    if (response.containsKey('error')) {
      throw Exception(response['error']);
    }

    // ✅ Si llega aquí, TODO salió bien

  }
}