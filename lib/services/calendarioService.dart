import 'package:myapp/models/reservation_data.dart';

class CalendarioService {
  // Singleton pattern
  static final CalendarioService _instance = CalendarioService._internal();

  factory CalendarioService() {
    return _instance;
  }

  CalendarioService._internal();

  // Estructura de datos para almacenar reservas por ID de habitación
  final Map<String, Map<DateTime, ReservationData>> _reservationsByRoom = {
    // Ejemplo de datos iniciales
    'R001': {
      DateTime.utc(2025, 11, 22): ReservationData(
          guestName: 'Ana García',
          persons: '3',
          arrivalDate: '22/11/2025',
          departureDate: '25/11/2025',
          phone: '555-0001',
          reservationNumber: 'RES-001'),
      DateTime.utc(2025, 11, 23): ReservationData(
          guestName: 'Ana García',
          persons: '3',
          arrivalDate: '22/11/2025',
          departureDate: '25/11/2025',
          phone: '555-0001',
          reservationNumber: 'RES-001'),
      DateTime.utc(2025, 11, 24): ReservationData(
          guestName: 'Ana García',
          persons: '3',
          arrivalDate: '22/11/2025',
          departureDate: '25/11/2025',
          phone: '555-0001',
          reservationNumber: 'RES-001'),
      DateTime.utc(2025, 11, 25): ReservationData(
          guestName: 'Ana García',
          persons: '3',
          arrivalDate: '22/11/2025',
          departureDate: '25/11/2025',
          phone: '555-0001',
          reservationNumber: 'RES-001'),
    }
  };

  // Obtener las reservas para una habitación específica
  Map<DateTime, ReservationData> getReservationsForRoom(String roomId) {
    return _reservationsByRoom[roomId] ?? {};
  }

  // Agregar una nueva reserva para una habitación
  void addReservation(String roomId, DateTime startDate, DateTime endDate, ReservationData reservationData) {
    if (!_reservationsByRoom.containsKey(roomId)) {
      _reservationsByRoom[roomId] = {};
    }

    DateTime currentDay = startDate;
    while (currentDay.isBefore(endDate) || currentDay.isAtSameMomentAs(endDate)) {
      final normalizedDay = DateTime.utc(currentDay.year, currentDay.month, currentDay.day);
      _reservationsByRoom[roomId]![normalizedDay] = reservationData;
      currentDay = currentDay.add(const Duration(days: 1));
    }
  }
}
