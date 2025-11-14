// room_provider.dart

import 'package:flutter/material.dart';

enum RoomStatus { disponible, enLimpieza, mantenimiento, ocupada }

class RoomProvider extends ChangeNotifier {
  RoomStatus _status = RoomStatus.ocupada; // Estado inicial por defecto

  RoomStatus get status => _status;

  String get statusText {
    switch (_status) {
      case RoomStatus.disponible:
        return 'DISPONIBLE';
      case RoomStatus.enLimpieza:
        return 'EN LIMPIEZA';
      case RoomStatus.mantenimiento:
        return 'MANTENIMIENTO';
      case RoomStatus.ocupada:
        return 'OCUPADA';
    }
  }

  IconData get statusIcon {
    switch (_status) {
      case RoomStatus.disponible:
        return Icons.check_circle_outline;
      case RoomStatus.enLimpieza:
        return Icons.cleaning_services;
      case RoomStatus.mantenimiento:
        return Icons.build;
      case RoomStatus.ocupada:
        return Icons.bed;
    }
  }

  void setStatus(RoomStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}