import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/Pantalla-Estados.dart';
import 'package:myapp/models/reservation_data.dart';
import 'package:myapp/models/reservation_form.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 


class ReservationForm extends StatefulWidget {
  final DateTime? initialArrivalDate;

  const ReservationForm({super.key, this.initialArrivalDate});

  @override
  State<ReservationForm> createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _personsController = TextEditingController();
  final TextEditingController _arrivalDateController = TextEditingController();
  final TextEditingController _departureDateController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _reservationNumberController =
      TextEditingController();

  final primaryColor = const Color(0XFF2CB7A6); // Color principal

  @override
  void initState() {
    super.initState();
    if (widget.initialArrivalDate != null) {
      _arrivalDateController.text =
          DateFormat('dd/MM/yyyy').format(widget.initialArrivalDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _personsController.dispose();
    _arrivalDateController.dispose();
    _departureDateController.dispose();
    _phoneController.dispose();
    _reservationNumberController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN DE DIÁLOGO MODIFICADA ---
  // Usa la clase ReservationResult importada
  Future<ReservationResult?> _showSuccessDialog(ReservationData reservationData, DateTime startDate, DateTime endDate) {
    final reservationDataMap = {
      'Huésped': reservationData.guestName,
      'Personas': reservationData.persons,
      'Llegada': reservationData.arrivalDate,
      'Salida': reservationData.departureDate,
      'Celular': reservationData.phone,
      'No. Reserva': reservationData.reservationNumber,
    };

    return showDialog<ReservationResult>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            '¡Reserva Creada con Éxito!',
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: reservationDataMap.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Cierra el diálogo y retorna el objeto ReservationResult completo.
                Navigator.of(context).pop(ReservationResult(
                  startDate: startDate,
                  endDate: endDate,
                  data: reservationData,
                ));
              },
              child: Text(
                'ACEPTAR',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- FUNCIÓN DE SUBMIT MODIFICADA ---
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 1. Parsear las fechas de texto a DateTime
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      DateTime arrivalDateObj;
      DateTime departureDateObj;

      try {
        arrivalDateObj = formatter.parse(_arrivalDateController.text);
        departureDateObj = formatter.parse(_departureDateController.text);
        
        // Validación extra: Salida no puede ser anterior a la Llegada
        if (departureDateObj.isBefore(arrivalDateObj)) {
           // Aquí deberías mostrar un error visual al usuario
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('La fecha de salida debe ser posterior o igual a la de llegada.')),
           );
           return;
        }

      } catch (e) {
        debugPrint('Error al parsear fechas: $e');
        return;
      }

      final reservationData = ReservationData(
        guestName: _nameController.text,
        persons: _personsController.text,
        arrivalDate: _arrivalDateController.text,
        departureDate: _departureDateController.text,
        phone: _phoneController.text,
        reservationNumber: _reservationNumberController.text,
      );

      // 2. Mostrar diálogo. Esperamos que devuelva el objeto de resultado.
      final ReservationResult? result = await _showSuccessDialog(
        reservationData, 
        arrivalDateObj, 
        departureDateObj,
      );

      if (result != null && mounted) {
        _formKey.currentState?.reset();

        // 3. Navegamos a la pantalla de detalles de la reserva usando los datos reales.
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(
              reservationData: result.data, 
            ),
          ),
        );

        // 4. Una vez que el usuario regrese de RoomDetailsScreen,
        // forzamos el regreso a CalendarPage y enviamos el objeto 'result' como resultado.
        if (mounted) {
           Navigator.pop(context, result); // Devuelve el objeto ReservationResult
        }
      }
    }
  }

  // Función de selección de fecha (sin cambios, solo las dependencias importadas arriba)
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('es'),
          delegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          child: Theme(
            data: ThemeData.light().copyWith(
              textTheme: GoogleFonts.poppinsTextTheme(
                Theme.of(context).textTheme,
              ),
              colorScheme: ColorScheme.light(
                primary: primaryColor,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
              datePickerTheme: DatePickerThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 8,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide(color: primaryColor, width: 1.5),
    );

    return PopScope(
      // Cuando el usuario presiona el botón de 'atrás'
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Si por alguna razón no se hizo pop, nos aseguramos de devolver null
          // para indicar a CalendarPage que no hubo reserva.
          Navigator.pop(context, null); 
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () {
              // Al salir del formulario sin completar, devolvemos 'null'
              Navigator.pop(context, null);
            },
          ),
          title: Text(
            'Formulario',
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildTextField(
                    context: context,
                    controller: _nameController,
                    label: 'Nombre del huésped',
                    inputDecoration: InputDecoration(
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context: context,
                    controller: _personsController,
                    label: 'Número de personas',
                    keyboardType: TextInputType.number,
                    inputDecoration: InputDecoration(
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    context: context,
                    controller: _arrivalDateController,
                    label: 'Llegada',
                    inputDecoration: InputDecoration(
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      suffixIcon: Icon(Icons.keyboard_arrow_down,
                          color: primaryColor, size: 30),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    context: context,
                    controller: _departureDateController,
                    label: 'Salida',
                    inputDecoration: InputDecoration(
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      suffixIcon: Icon(Icons.keyboard_arrow_down,
                          color: primaryColor, size: 30),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context: context,
                    controller: _phoneController,
                    label: 'Celular',
                    keyboardType: TextInputType.phone,
                    inputDecoration: InputDecoration(
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context: context,
                    controller: _reservationNumberController,
                    label: 'Número de reserva',
                    keyboardType: TextInputType.number,
                    inputDecoration: InputDecoration(
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 20),
                      ),
                      onPressed: _submitForm,
                      child: Text(
                        'CREAR RESERVA',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    required InputDecoration inputDecoration,
  }) {
    final List<TextInputFormatter>? inputFormatters =
        (keyboardType == TextInputType.number || keyboardType == TextInputType.phone)
            ? [FilteringTextInputFormatter.digitsOnly]
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            decoration: inputDecoration.copyWith(
              labelStyle: GoogleFonts.poppins(color: primaryColor),
              floatingLabelStyle:
                  GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese un valor';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required InputDecoration inputDecoration,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
            decoration: inputDecoration.copyWith(
              labelStyle: GoogleFonts.poppins(color: primaryColor),
              floatingLabelStyle:
                  GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onTap: () => _selectDate(context, controller),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, seleccione una fecha';
              }
              // Validación de formato simple
              try {
                DateFormat('dd/MM/yyyy').parse(value);
              } catch (_) {
                return 'Formato de fecha inválido (dd/MM/yyyy)';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}