import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/reservation_data.dart';
import 'package:myapp/models/reservation_form.dart';
import 'package:myapp/models/room.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class ReservationForm extends StatefulWidget {
  final DateTime? initialArrivalDate;
  final Room room;

  const ReservationForm({
    super.key,
    this.initialArrivalDate,
    required this.room,
  });

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

  final primaryColor = const Color(0XFF2CB7A6);

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

  Future<ReservationResult?> _showSuccessDialog(
      ReservationData reservationData, DateTime startDate, DateTime endDate) {
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      DateTime arrivalDateObj;
      DateTime departureDateObj;

      try {
        arrivalDateObj = formatter.parse(_arrivalDateController.text);
        departureDateObj = formatter.parse(_departureDateController.text);

        if (departureDateObj.isBefore(arrivalDateObj)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'La fecha de salida debe ser posterior o igual a la de llegada.')),
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

      final ReservationResult? result = await _showSuccessDialog(
        reservationData,
        arrivalDateObj,
        departureDateObj,
      );

      if (result != null && mounted) {
        Navigator.pop(context, result);
      }
    }
  }

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
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
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
