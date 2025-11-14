import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Necesitas esta importación
import 'app_router.dart'; // Importa la configuración de tu router

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    // ⭐ Implementación correcta: Usar MaterialApp.router
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mi App',
      // Pasa la configuración del router que definiste
      routerConfig: router, 
    );
  }
}