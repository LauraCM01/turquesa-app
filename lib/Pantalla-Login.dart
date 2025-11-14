import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart'; 

// Define la clase LoginPage, que es un widget con estado (StatefulWidget).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // El método createState es obligatorio en un StatefulWidget y devuelve una instancia de su clase de estado asociada.
  State<LoginPage> createState() => _LoginPageState();
}

// La clase _LoginPageState contiene el estado y la lógica de la interfaz de usuario para LoginPage.
class _LoginPageState extends State<LoginPage> {
  // Declaración de variables que mantendrán el estado del widget.
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  Future<void> _submitForm(String emailAddress, String password) async {
    if (!mounted) return;
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password,
      );

      if (mounted) {
        context.go('/inicio');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String content;
      if (e.code == 'user-not-found') {
        content = 'No existe una cuenta registrada con ese correo electrónico.';
      } else if (e.code == 'wrong-password') {
        content = 'La clave que estás ingresando no es correcta.';
      } else {
        content = 'Ocurrió un error inesperado. Por favor, intenta de nuevo.';
      }

      // Mostrar el diálogo de error personalizado
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text(
              'Error de Autenticación',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0XFF2CB7A6),
              ),
            ),
            content: Text(
              content,
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0XFF2CB7A6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 60.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: Image.network(
                        'https://res.cloudinary.com/dfznn7pui/image/upload/v1761514333/LOGO-HOSTAL_yvkmmi.png',
                        fit: BoxFit.contain,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return const Icon(Icons.error, color: Colors.red);
                        },
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.only(top: 30.0, bottom: 0.0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0x1A2CB7A6),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0XFF2CB7A6),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                TextFormField(
                  controller: _usernameController,
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                    ),
                    hintText: 'Usuario',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    contentPadding: const EdgeInsets.fromLTRB(
                      20.0,
                      15.0,
                      20.0,
                      15.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(
                        color: Color(0XFF2CB7A6),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(
                        color: Color(0XFF2CB7A6),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                    ),
                    hintText: 'Contraseña',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    contentPadding: const EdgeInsets.fromLTRB(
                      20.0,
                      15.0,
                      20.0,
                      15.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(
                        color: Color(0XFF2CB7A6),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                      borderSide: const BorderSide(
                        color: Color(0XFF2CB7A6),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF2CB7A6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    _submitForm(
                      _usernameController.text,
                      _passwordController.text,
                    );
                  },
                  child: const Text('INGRESAR'),
                ),
                const SizedBox(height: 16.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: const Color(0XFF2CB7A6),
                        ),
                        Text(
                          'Recordar',
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        textStyle: GoogleFonts.poppins(fontSize: 14.0),
                      ),
                      onPressed: () {},
                      child: const Text('Recuperar contraseña'),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),

                Column(
                  children: [
                    Text(
                      '¿Todavía no tienes cuenta?',
                      style: GoogleFonts.poppins(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF2CB7A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        context.push('/registro');
                      },
                      child: const Text('CREAR CUENTA'),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
