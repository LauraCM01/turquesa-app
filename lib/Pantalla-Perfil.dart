// 🟢 profile_screen.dart - Implementación para leer datos de Firestore
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart'; // ⭐ NECESARIO PARA USAR GO_ROUTER

// 1. Crear un modelo de datos para mapear los campos de Firestore
class UserData {
  final String nombre;
  final String apellido;
  final String cedula;
  final String correo;

  UserData({
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.correo,
  });

  factory UserData.fromFirestore(Map<String, dynamic> data) {
    return UserData(
      // Usar 'N/A' si el campo no existe o es nulo
      nombre: data['nombre'] ?? 'N/A',
      apellido: data['apellido'] ?? 'N/A',
      cedula: data['cedula'] ?? 'N/A',
      correo: data['correo'] ?? 'N/A',
    );
  }
}

// 2. Convertir a StatefulWidget para manejar la carga de datos
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Estado para guardar los datos del usuario
  UserData? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Iniciar la carga de datos cuando el widget se inicializa
    _fetchUserData();
  }

  // 3. Función para cargar los datos desde Firestore
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'No hay usuario autenticado. Por favor, inicia sesión.';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // Obtener el documento con el UID del usuario
      final docSnapshot = await _db.collection('usuarios').doc(user.uid).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (mounted) {
          setState(() {
            _userData = UserData.fromFirestore(data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                'No se encontraron datos del perfil en Firestore. UID: ${user.uid}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar los datos: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Estilos y constructores de widgets (mantenidos del código original)
  TextStyle get _valueTextStyle => GoogleFonts.poppins(
    color: Colors.grey,
    fontSize: 14,
  );

  OutlineInputBorder _customBorder({required Color color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  Widget _buildTextField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: value,
            readOnly: true,
            style: _valueTextStyle,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 10.0,
              ),
              enabledBorder: _customBorder(color: const Color(0XFF2CB7A6)),
              focusedBorder: _customBorder(color: const Color(0XFF2CB7A6)),
              border: _customBorder(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
          const SizedBox(height: 5),
          TextFormField(
            initialValue: value,
            readOnly: true,
            style: _valueTextStyle,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 10.0,
              ),
              enabledBorder: _customBorder(color: const Color(0XFF2CB7A6)),
              focusedBorder: _customBorder(color: const Color(0XFF2CB7A6)),
              border: _customBorder(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 4. Mostrar estado de carga o error
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0XFF2CB7A6)),
        ),
        // ❌ ELIMINADA bottomNavigationBar
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Error al cargar perfil: $_errorMessage',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ),
        // ❌ ELIMINADA bottomNavigationBar
      );
    }

    // Si los datos se cargaron correctamente:
    final user = _userData!;
    final fullName = '${user.nombre} ${user.apellido}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        toolbarHeight: 80.0,
        title: Text(
          'Perfil',
          style: GoogleFonts.poppins(
            color: const Color(0XFF2CB7A6),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0XFF2CB7A6)),
            onPressed: () async {
              // Cierra sesión en Firebase
              await _auth.signOut();
              if (mounted) {
                // ⭐ CORRECCIÓN DE NAVEGACIÓN: Usar GoRouter para ir al Login y eliminar la pila
                context.go('/login'); // Asumiendo que '/' es la ruta del login
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0x1A2CB7A6),
                child: Icon(Icons.person, size: 70, color: Color(0XFF2CB7A6)),
              ),
              const SizedBox(height: 30),
              // 5. Usar los datos reales del usuario
              _buildTextField(label: 'Nombre Completo', value: fullName),
              const SizedBox(height: 20),
              _buildTextField(label: 'Correo', value: user.correo),
              const SizedBox(height: 20),
              _buildDateField(label: 'Cédula', value: user.cedula),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  if (mounted) {
                    context.go('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF2CB7A6),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'CERRAR SESIÓN',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}