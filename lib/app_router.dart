import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/Pantalla-Registro.dart';
import 'package:myapp/chat_list/chat_list_screen.dart';
import 'package:myapp/chat_list/chat_model.dart'; 
import 'package:myapp/widgets/Barra-Navegacion.dart'; 
import 'Pantalla-Conversacion.dart'; 
import 'Pantalla-Perfil.dart';
import 'Pantalla-Inicio.dart';
import 'Pantalla-Login.dart';

// Define una GlobalKey para el Navigator principal
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey, 
  initialLocation: '/login', // Iniciamos en login
  routes: [
    
    // RUTA 1: LOGIN (Fuera del ShellRoute, no tiene barra)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // RUTA 2: REGISTRO (Fuera del ShellRoute, no tiene barra)
    GoRoute(
      path: '/registro', 
      builder: (context, state) => const PantallaRegistro(),
    ),


    // ⭐ SHELLROUTE: Contenedor principal con la barra
    ShellRoute(
      // El builder define el layout con la barra de navegación
      builder: (context, state, child) {
        int selectedIndex = 0;
        final path = state.fullPath ?? ''; 

        // Lógica para determinar el índice (ajustada a las rutas dentro del Shell)
        if (path.startsWith('/chat')) { 
          selectedIndex = 0; // Chat
        } else if (path.startsWith('/inicio')) {
          selectedIndex = 1; // Inicio
        } else if (path.startsWith('/perfil')) {
          selectedIndex = 2; // Perfil
        }

        return Scaffold(
          body: child, // El contenido de la ruta actual
          bottomNavigationBar: BarraNavegacion(selectedIndex: selectedIndex),
        );
      },
      
      // Rutas que se mostrarán DENTRO del ShellRoute (las que tienen barra)
      routes: [
        // RUTA DE CHAT (LISTA)
        GoRoute(
          path: '/chat', 
          builder: (context, state) => const ChatListScreen(),
        ),
        
        // RUTA DE INICIO (El destino del login)
        GoRoute(
          path: '/inicio', 
          builder: (context, state) => const HomeScreen(),
        ),

        // RUTA DE PERFIL
        GoRoute(
          path: '/perfil',
          builder: (context, state) => const ProfileScreen(),
        ),

        // IMPORTANTE: Se eliminó /registro de aquí.
      ],
    ),
    
    // RUTA DE CHAT INDIVIDUAL: (Nivel superior, sin barra)
    GoRoute(
      path: '/chat/:chatId', 
      parentNavigatorKey: _rootNavigatorKey, 
      builder: (BuildContext context, GoRouterState state) {
        final chatId = state.pathParameters['chatId']!;
        final chatData = state.extra;
        return ChatScreen(
          chatId: chatId, 
          chat: chatData is Chat ? chatData : null, 
        ); 
      },
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error de Navegación')),
    body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
  ),
);