import 'package:flutter/material.dart';
import 'package:myapp/models/room.dart'; // Asegúrate de que este path sea correcto
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'Pantalla-Estados.dart'; // Asegúrate de que este path sea correcto
import 'Formulario-Reservas.dart'; // Asegúrate de que este path sea correcto
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/constantes/colors.dart';


// ----------------------------------------------------
// 1. CONSTANTES Y MODELO DE DATOS
// ----------------------------------------------------

// Mapeo de estados fijos a colores
const Map<String, Color> statusColors = {
  'Reservado': kReservedColor,
  'Disponible': kAvailableColor,
};

// Mapa que simula la data de Firebase para disponibilidad
final Map<DateTime, String> hostelAvailability = {
  // Ejemplo de fechas reservadas
  DateTime.utc(2025, 11, 8): 'Reservado',
  DateTime.utc(2025, 11, 9): 'Reservado',
  DateTime.utc(2025, 11, 10): 'Reservado',
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
  // 1. DECLARACIÓN DE VARIABLES DE ESTADO
  // 🌟 Inicializamos con el mes y día actual para la carga automática
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  PageController? _pageController;



  // Variables de Rango (usadas para selección de múltiples días)
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // 2. FUNCIONES DE LÓGICA

  // Manejo de la selección de un solo día
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Usamos isSameDay de table_calendar
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        // Mantenemos _focusedDay en el mes seleccionado
        _focusedDay = selectedDay;
        _rangeStart = null;
        _rangeEnd = null;
      });

      final normalizedDay = DateTime.utc(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
      );
      final String status = hostelAvailability[normalizedDay] ?? 'Disponible';

      if (status == 'Reservado') {
        // Navegación a detalles de la reserva
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RoomDetailsScreen(
              //date: selectedDay,
            ),
          ),
        );
      } else {
        // Navegación a formulario de nueva reserva
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReservationForm(
              //date: selectedDay,
            ),
          ),
        );
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
    // Lógica de Días Fuera de Mes
    final bool isOutside = !isSameMonthLocal(day, focusedDay);

    // Normalizar el día para buscar en el mapa de disponibilidad
    final normalizedDay = DateTime.utc(
      day.year,
      day.month,
      day.day,
    );

    Color backgroundColor;
    Color textColor;

    // 1. Prioridad Máxima: DÍA SELECCIONADO (Turquesa - kPrimaryColor). Se maneja en `selectedBuilder`
    // 2. Prioridad Baja: ESTADOS FIJOS (Reservado/Disponible)
    final String status = hostelAvailability[normalizedDay] ?? 'Disponible';
    backgroundColor = statusColors[status] ?? kAvailableColor;
    textColor = (status == 'Disponible') ? Colors.grey : Colors.white;

    // 3. LÓGICA DE OPACIDAD (Se aplica al color ya determinado)
    if (isOutside && !isSameDay(_selectedDay, day)) {
      backgroundColor = backgroundColor.withOpacity(0.5);
      textColor = Colors.grey.withOpacity(0.5);
    }

    const double fixedFontSize = 14.0;

    // Contenedor circular
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        // Borde para el día de hoy (solo si no está seleccionado y no es un día fuera del mes)
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
    const Color backgroundColor = kPrimaryColor; // Añadido 'const'
    final bool isOutside = !isSameMonthLocal(day, focusedDay);
    final Color finalTextColor = isOutside // Añadido 'final'
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
