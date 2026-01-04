import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 AGREGAR
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../../controlador/inspector/estadisticas_controller.dart'; // 👈 AGREGAR
import '../pages/home_inspector_page.dart';
import '../pages/zonas_inspector_page.dart';
import '../pages/incumplimientos_inspector_page.dart';
import '../pages/perfil_inspector_page.dart';

class InspectorBottomBar extends StatefulWidget {
  const InspectorBottomBar({super.key});

  @override
  State<InspectorBottomBar> createState() => _InspectorBottomBarState();
}

class _InspectorBottomBarState extends State<InspectorBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeInspectorPage(),
    ZonasInspectorPage(),
    IncumplimientosInspectorPage(),
    PerfilInspectorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EstadisticasController(),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text("Inicio"),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.bar_chart),
              title: const Text("Estadísticas"),
              selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.warning),
              title: const Text("Incumplimientos"),
              selectedColor: Colors.red,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.notification_add),
              title: const Text("Notificaciones"),
              selectedColor: Colors.orange,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person),
              title: const Text("Perfil"),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}