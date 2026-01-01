import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class CambioContraApi {

  Future<Map<String, dynamic>> solicitarCambioContrasena(
      String correo, int idPersona) async {
    final url = Uri.parse(api("/auth/solicitar-cambio-contrasena"));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correo,
        "id_persona": idPersona,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      throw Exception(
        data['detail'] ?? data['mensaje'] ?? 'Error al solicitar token',
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> confirmarCambioContrasena(
      String token, String nuevaContrasena, int idPersona) async {

    print("TOKEN MOVIL 👉 '${token}'");

    final url = Uri.parse(api("/auth/confirmar-cambio-contrasena"));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "token": token.trim(),
        "nuevaContraseña": nuevaContrasena.trim(),
        "id_persona": idPersona,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      throw Exception(
        data['detail'] ?? data['mensaje'] ?? 'Error al cambiar contraseña',
      );
    }

    return data;
  }



}
