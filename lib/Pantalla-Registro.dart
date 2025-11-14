import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final db = FirebaseFirestore.instance;

  bool _isLoading = false;
  // Estado para controlar si la contraseña está oculta o no
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _cedulaController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  // Se eliminó la función _showStyledSnackBar ya que el código anterior
  // usaba _showErrorDialog, y la nueva versión usará esa.
  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Error de Registro',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0XFF2CB7A6),
            ),
          ),
          content: Text(message, style: GoogleFonts.poppins()),
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _correoController.text.trim(),
            password: _contrasenaController.text.trim(),
          );

      await guardarDatosFormulario(credential);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error desconocido';
      if (e.code == 'weak-password') {
        mensaje = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        mensaje = 'El correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo no es válido.';
      }

      if (mounted) {
        _showErrorDialog(mensaje);
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _showErrorDialog(
          'Ocurrió un error inesperado. Por favor, intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> guardarDatosFormulario(UserCredential credential) async {
    final user = credential.user;
    if (user == null) {
      _showErrorDialog("Error: El usuario es nulo después del registro.");
      return;
    }

    final userData = {
      "nombre": _nombreController.text.trim(),
      "apellido": _apellidoController.text.trim(),
      "cedula": _cedulaController.text.trim(),
      "correo": _correoController.text.trim(),
      "fecha_registro": FieldValue.serverTimestamp(),
    };

    try {
      await db.collection("usuarios").doc(user.uid).set(userData);
      print('Usuario guardado en Firestore con UID: ${user.uid}');

      if (mounted) {
        context.go('/inicio');
      }
    } catch (e) {
      print('Error al guardar en Firestore: $e');
      if (mounted) {
        _showErrorDialog('Error al guardar los datos en la base de datos.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0XFF2CB7A6)),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Image.network(
                          'https://res.cloudinary.com/dfznn7pui/image/upload/v1761514333/LOGO-HOSTAL_yvkmmi.png',
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, exception, stackTrace) {
                            return const Icon(Icons.error, color: Colors.red);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  _buildTextFormField(
                    controller: _nombreController,
                    hintText: 'Nombre',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _apellidoController,
                    hintText: 'Apellido',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _cedulaController,
                    hintText: 'Cédula',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _correoController,
                    hintText: 'Correo',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _contrasenaController,
                    hintText: 'Contraseña',
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 40),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0XFF2CB7A6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _submitForm,
                          child: Text(
                            'REGISTRAR',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta?',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Inicia sesión',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF26A69A),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isPasswordField = hintText == 'Contraseña';

    return TextFormField(
      controller: controller,
      // Usar _isPasswordObscured para la propiedad obscureText
      obscureText: isPasswordField ? _isPasswordObscured : false,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (hintText == 'Correo' &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Por favor, introduce un correo válido';
        }
        if (isPasswordField && value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
      style: GoogleFonts.poppins(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0XFF2CB7A6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
      ),
    );
  }
}
