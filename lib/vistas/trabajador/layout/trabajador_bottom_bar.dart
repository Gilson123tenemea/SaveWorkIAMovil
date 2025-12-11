import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../pages/home_trabajador_page.dart';
import '../pages/asistencia_trabajador_page.dart';
import '../pages/alertas_trabajador_page.dart';
import '../pages/perfil_trabajador_page.dart';

class TrabajadorBottomBar extends StatefulWidget {
  const TrabajadorBottomBar({super.key});

  @override
  State<TrabajadorBottomBar> createState() => _TrabajadorBottomBarState();
}

class _TrabajadorBottomBarState extends State<TrabajadorBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeTrabajadorPage(),
    AsistenciaTrabajadorPage(),
    AlertasTrabajadorPage(),
    PerfilTrabajadorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Inicio"),
            selectedColor: Colors.deepPurple,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.access_time),
            title: const Text("Asistencia"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.notification_important),
            title: const Text("Alertas"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Perfil"),
            selectedColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
