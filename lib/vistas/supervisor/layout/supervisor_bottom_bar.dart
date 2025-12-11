import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../pages/home_supervisor_page.dart';
import '../pages/reportes_supervisor_page.dart';
import '../pages/estadisticas_supervisor_page.dart';
import '../pages/perfil_supervisor_page.dart';

class SupervisorBottomBar extends StatefulWidget {
  const SupervisorBottomBar({super.key});

  @override
  State<SupervisorBottomBar> createState() => _SupervisorBottomBarState();
}

class _SupervisorBottomBarState extends State<SupervisorBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeSupervisorPage(),
    ReportesSupervisorPage(),
    EstadisticasSupervisorPage(),
    PerfilSupervisorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Inicio"),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.description),
            title: const Text("Reportes"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.bar_chart),
            title: const Text("Estadísticas"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Perfil"),
            selectedColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
