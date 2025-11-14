// room_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/reservation_data.dart';
import 'package:myapp/providers/room_provider.dart';
import 'package:provider/provider.dart';


class RoomDetailsScreen extends StatefulWidget {
  // 1. VARIABLE para recibir los datos de la reserva
  final ReservationData reservationData;

  // 2. CONSTRUCTOR que requiere los datos
  const RoomDetailsScreen({super.key, required this.reservationData});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Accede a los datos de la reserva a través de widget.reservationData
    final data = widget.reservationData;
    final roomProvider = Provider.of<RoomProvider>(context);
    final primaryColor = const Color(0XFF2CB7A6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Habitación doble',
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    // USANDO DATO DINÁMICO
                    'NÚMERO DE RESERVA: ${data.reservationNumber}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              // Huésped
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Huésped:',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      // USANDO DATO DINÁMICO
                      data.guestName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              // Datos de la Reserva
              _buildInfoRow('Número de personas:', '${data.persons} adultos'),
              _buildInfoRow('Llegada:', data.arrivalDate),
              _buildInfoRow('Salida:', data.departureDate),
              _buildInfoRow('Número de contacto:', data.phone),
              const SizedBox(height: 24.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          roomProvider.statusIcon,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          roomProvider.statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: primaryColor,
                      ),
                      onPressed: () => _showStatusMenu(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: TextButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.grey.withOpacity(0.1);
                      }
                      return null;
                    }),
                  ),
                  child: Text(
                    'ELIMINAR RESERVA',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 20.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(subtitle, style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Cambiar Estado',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0XFF2CB7A6),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF2CB7A6),
                ),
                title: Text(
                  'DISPONIBLE',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
                onTap: () {
                  Provider.of<RoomProvider>(
                    context,
                    listen: false,
                  ).setStatus(RoomStatus.disponible);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cleaning_services,
                  color: Color(0xFF2CB7A6),
                ),
                title: Text(
                  'EN LIMPIEZA',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
                onTap: () {
                  Provider.of<RoomProvider>(
                    context,
                    listen: false,
                  ).setStatus(RoomStatus.enLimpieza);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.build, color: Color(0xFF2CB7A6)),
                title: Text(
                  'MANTENIMIENTO',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
                onTap: () {
                  Provider.of<RoomProvider>(
                    context,
                    listen: false,
                  ).setStatus(RoomStatus.mantenimiento);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bed, color: Color(0xFF2CB7A6)),
                title: Text(
                  'OCUPADA',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                ),
                onTap: () {
                  Provider.of<RoomProvider>(
                    context,
                    listen: false,
                  ).setStatus(RoomStatus.ocupada);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCELAR',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }
}