import 'package:flutter/material.dart';
import 'vistas/auth/login_page.dart';
import 'vistas/supervisor/layout/supervisor_bottom_bar.dart';
import 'vistas/inspector/layout/inspector_bottom_bar.dart';
import 'vistas/trabajador/layout/trabajador_bottom_bar.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/login",
      routes: {
        "/login": (_) => LoginPage(),
        // Supervisor
        "/supervisor/menu": (_) => const SupervisorBottomBar(),
        // Inspector
        "/inspector/menu": (_) => const InspectorBottomBar(),

        // Trabajador
        "/trabajador/menu": (_) => const TrabajadorBottomBar(),
      },
    );
  }
}
