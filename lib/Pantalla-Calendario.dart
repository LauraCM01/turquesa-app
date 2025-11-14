import 'package:flutter/material.dart';
import 'package:myapp/Formulario-Reservas.dart';
import 'package:myapp/Pantalla-Estados.dart';
import 'package:myapp/models/reservation_data.dart';
import 'package:myapp/models/room.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constantes/colors.dart';

// ----------------------------------------------------
// 1. CONSTANTES Y MODELO DE DATOS
// ----------------------------------------------------

// Mapeo de estados fijos a colores
const Map<String, Color> statusColors = {
  // Ahora 'Reservado' indica que hay un objeto ReservationData asociado
  'Reservado': kReservedColor,
  'Disponible': kAvailableColor,
};

// Mapa que simula la data de Firebase para disponibilidad
// CLAVE: Ahora almacena ReservationData para las fechas reservadas
final Map<DateTime, Object?> hostelAvailability = {
  // Ejemplo de fechas reservadas iniciales (usando datos dummy completos)
  DateTime.utc(2025, 11, 22): ReservationData(
      guestName: 'Ana García (Dummy)',
      persons: '3',
      arrivalDate: '22/11/2025',
      departureDate: '25/11/2025',
      phone: '555-0001',
      reservationNumber: 'RES-001'),
  DateTime.utc(2025, 11, 23): ReservationData(
      guestName: 'Carlos López (Dummy)',
      persons: '1',
      arrivalDate: '23/11/2025',
      departureDate: '24/11/2025',
      phone: '555-0002',
      reservationNumber: 'RES-002'),
  DateTime.utc(2025, 11, 24): ReservationData(
      guestName: 'Beatriz Pérez (Dummy)',
      persons: '4',
      arrivalDate: '24/11/2025',
      departureDate: '27/11/2025',
      phone: '555-0003',
      reservationNumber: 'RES-003'),
};

// ----------------------------------------------------
// 2. WIDGET DE CALENDARIO (ESTRUCTURA BASE)
// ----------------------------------------------------

class CalendarPage extends StatefulWidget {
  final Room room;
  const CalendarPage({super.key, required this.room});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  PageController? _pageController;

  // Variables de Rango (usadas para selección de múltiples días)
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // 2. FUNCIONES DE LÓGICA

  // Manejo de la selección de un solo día
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = selectedDay;
        _rangeStart = null;
        _rangeEnd = null;
      });

      final normalizedDay = DateTime.utc(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
      );
      
      // Obtener el objeto de reserva o null
      final Object? reservation = hostelAvailability[normalizedDay];
      
      // Determinar si está reservado basándose en si existe data
      final bool isReserved = reservation is ReservationData;

      // Lógica para fechas ya reservadas
      if (isReserved) {
        // Usamos la data REAL almacenada en el mapa
        final ReservationData actualData = reservation as ReservationData;

        // Navegación a detalles de la reserva (con data real)
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(
              reservationData: actualData,
            ),
          ),
        );
      } 
      
      // Lógica para días disponibles
      else {
        // Navegación a formulario de nueva reserva
        // CAMBIO CLAVE: Esperamos el objeto ReservationData? como resultado
        final ReservationData? newReservationData = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationForm(
              initialArrivalDate: selectedDay,
            ),
          ),
        );

        // Si se devuelve un objeto ReservationData (es decir, la reserva fue creada)
        if (newReservationData != null) {
          // 1. Actualizamos el mapa de disponibilidad con el objeto de datos REAL.
          setState(() {
            hostelAvailability[normalizedDay] = newReservationData;
            // 2. Deseleccionamos el día para que se pinte de rojo.
            _selectedDay = null; 
          });
          
          // La navegación a RoomDetailsScreen se maneja ahora dentro del formulario.
        }
      }
    }
  }

  // Manejo de la selección de Rango (opcional)
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  // FUNCIÓN CLAVE: Construye la apariencia de cada día (círculos de colores)
  Widget _buildDayContainer(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    final bool isOutside = !isSameMonthLocal(day, focusedDay);
    final normalizedDay = DateTime.utc(
      day.year,
      day.month,
      day.day,
    );

    Color backgroundColor;
    Color textColor;

    // Verificar si hay un objeto de reserva para este día
    final Object? reservation = hostelAvailability[normalizedDay];
    final bool isReserved = reservation is ReservationData;

    // Determinar el estado y el color
    final String status = isReserved ? 'Reservado' : 'Disponible';
    backgroundColor = statusColors[status] ?? kAvailableColor;
    textColor = (status == 'Disponible') ? Colors.grey : Colors.white;

    if (isOutside && !isSameDay(_selectedDay, day)) {
      backgroundColor = backgroundColor.withOpacity(0.5);
      textColor = Colors.grey.withOpacity(0.5);
    }

    const double fixedFontSize = 14.0;

    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border:
            isSameDay(day, DateTime.now()) &&
                    !isSameDay(_selectedDay, day) &&
                    !isOutside
                ? Border.all(color: kPrimaryColor.withOpacity(0.7), width: 1.5)
                : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: fixedFontSize,
        ),
      ),
    );
  }

  // Builder dedicado para el día seleccionado (garantiza el color Turquesa)
  Widget _buildSelectedDayContainer(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    const Color backgroundColor = kPrimaryColor;
    final bool isOutside = !isSameMonthLocal(day, focusedDay);
    final Color finalTextColor = isOutside
        ? Colors.white.withOpacity(0.7)
        : Colors.white;

    const double fixedFontSize = 14.0;

    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: backgroundColor, // KPrimaryColor (Turquesa)
        shape: BoxShape.circle,
        border: isSameDay(day, DateTime.now())
            ? Border.all(color: Colors.white, width: 2.0)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: finalTextColor,
          fontWeight: FontWeight.w700,
          fontSize: fixedFontSize,
        ),
      ),
    );
  }

  // 3. WIDGET BUILD (VISTA)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.room.name,
          style: GoogleFonts.poppins(
            color: kPrimaryColor, // Usando la constante
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Simulación de la imagen de la habitación
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Image.network(
                    widget.room.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text("Error al cargar imagen"),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Título del Mes (Siempre el mes y año actual) y flechas
            Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                bottom: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.MMMM('es').format(_focusedDay).capitalize() +
                        ' ' +
                        DateFormat.y('es').format(_focusedDay),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      // Flechas de navegación
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _pageController?.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _pageController?.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // El Widget principal del Calendario
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TableCalendar(
                onCalendarCreated: (PageController controller) {
                  _pageController = controller;
                },
                locale: 'es',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,

                headerVisible: false,

                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: false,
                  outsideDaysVisible: true,
                ),

                calendarBuilders: CalendarBuilders(
                  // Usa el builder de seleccionado
                  selectedBuilder: (context, day, focusedDay) {
                    return _buildSelectedDayContainer(context, day, focusedDay);
                  },
                  // Usa el builder general para todos los demás días
                  defaultBuilder: (context, day, focusedDay) {
                    return _buildDayContainer(context, day, focusedDay);
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return _buildDayContainer(context, day, focusedDay);
                  },
                ),

                onDaySelected: _onDaySelected,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // LEYENDA (Los 3 Estados)
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 5.0,
                bottom: 20.0,
              ),
              child: Wrap(
                spacing: 16.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,

                children: [
                  _buildLegendItem(kPrimaryColor, 'Seleccionado'),
                  _buildLegendItem(kReservedColor, 'Reservado'),
                  _buildLegendItem(kAvailableColor, 'Disponible'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 4. FUNCIONES AUXILIARES
// ----------------------------------------------------

// Implementación local de isSameMonth
bool isSameMonthLocal(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month;
}

// Función auxiliar para construir los ítems de la leyenda
Widget _buildLegendItem(Color color, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.normal,
        ),
      ),
    ],
  );
}

// Extensión para poner la primera letra en mayúscula
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}