import 'package:flutter/material.dart';
import 'package:myapp/models/room_status.dart';

class RoomProvider with ChangeNotifier {
  RoomStatus _status = RoomStatus.ocupada;

  RoomStatus get status => _status;

  void setStatus(RoomStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  String get statusText {
    switch (_status) {
      case RoomStatus.ocupada:
        return 'OCUPADA';
      case RoomStatus.disponible:
        return 'DISPONIBLE';
      case RoomStatus.enLimpieza:
        return 'EN LIMPIEZA';
      case RoomStatus.mantenimiento:
        return 'MANTENIMIENTO';
    }
  }

  IconData get statusIcon {
    switch (_status) {
      case RoomStatus.ocupada:
        return Icons.bed;
      case RoomStatus.disponible:
        return Icons.check_circle_outline;
      case RoomStatus.enLimpieza:
        return Icons.cleaning_services;
      case RoomStatus.mantenimiento:
        return Icons.build;
    }
  }
}
