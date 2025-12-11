import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class AuthApi {
  static Future<Map<String, dynamic>> loginSupervisor(String correo, String contrasena) async {
    final url = Uri.parse(api("/supervisores/login"));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correo,
        "contrasena": contrasena,
      }),
    );

    return jsonDecode(response.body);
  }

  // 🔹 Login Inspector
  static Future<Map<String, dynamic>> loginInspector(String correo, String contrasena) async {
    final url = Uri.parse(api("/inspectores/login"));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correo,
        "contrasena": contrasena,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> loginTrabajador(
      String correo, String contrasena) async {

    final url = Uri.parse(api("/trabajadores/login"));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": correo,
        "contrasena": contrasena,
      }),
    );

    return jsonDecode(response.body);
  }


}
