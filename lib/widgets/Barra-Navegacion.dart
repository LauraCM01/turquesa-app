import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BarraNavegacion extends StatelessWidget {
  final int selectedIndex;

  const BarraNavegacion({
    super.key,
    required this.selectedIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/chat'); // Navega a la lista de chats
        break;
      case 1:
        context.go('/inicio'); // ⭐ Navega a la nueva ruta de inicio
        break;
      case 2:
        context.go('/perfil'); // Navega a la pantalla de perfil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: const Color(0XFF2CB7A6),
      unselectedItemColor: Colors.grey[400],
      backgroundColor: Colors.white,
      elevation: 10,
      iconSize: 20,
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      selectedLabelStyle: GoogleFonts.poppins(),
      unselectedLabelStyle: GoogleFonts.poppins(),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}