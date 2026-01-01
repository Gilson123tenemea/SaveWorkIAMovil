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

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> confirmarCambioContrasena(
      String token, String nuevaContrasena, int idPersona) async {
    final url = Uri.parse(api("/auth/confirmar-cambio-contrasena"));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "token": token,
        "nuevaContrasena": nuevaContrasena,
        "id_persona": idPersona,
      }),
    );

    return jsonDecode(response.body);
  }
}