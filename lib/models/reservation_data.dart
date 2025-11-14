// reservation_data.dart

class ReservationData {
  final String guestName;
  final String persons;
  final String arrivalDate;
  final String departureDate;
  final String phone;
  final String reservationNumber;

  ReservationData({
    required this.guestName,
    required this.persons,
    required this.arrivalDate,
    required this.departureDate,
    required this.phone,
    required this.reservationNumber,
  });
}