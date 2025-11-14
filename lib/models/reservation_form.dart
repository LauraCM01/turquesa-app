import 'reservation_data.dart';

// Esta clase se define globalmente para ser usada por ReservationForm y CalendarPage.
class ReservationResult {
  final DateTime startDate;
  final DateTime endDate;
  final ReservationData data;

  ReservationResult({
    required this.startDate,
    required this.endDate,
    required this.data,
  });
}