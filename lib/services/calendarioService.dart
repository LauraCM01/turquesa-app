import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CalendarioService {
  final String baseUrl = "https://hostalsanrosa-production.up.railway.app/api";

  /// Obtiene el token de acceso
  Future<String?> obtenerToken() async {
    final url = Uri.parse("$baseUrl/token/");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": "sanrosa",
        "password": "termalessantarosadecabal",
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["access"];
    } else {
      print("Error al obtener token: ${response.body}");
      return null;
    }
  }

  /// Obtiene la disponibilidad de la habitación entre fechas dinámicas
  Future<Map<DateTime, String>> obtenerDisponibilidad(int habitacionId) async {
    final token = await obtenerToken();
    if (token == null) return {};

    final now = DateTime.now();
    final fechaInicio = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 10)));
    final fechaFin = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month + 3, now.day));

    final url = Uri.parse(
      "$baseUrl/calendario/habitacion/$habitacionId/?fecha_inicio=$fechaInicio&fecha_fin=$fechaFin",
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final disponibilidad = data['disponibilidad'] as List;
      final Map<DateTime, String> mapa = {};

      for (var item in disponibilidad) {
        final fecha = DateTime.parse(item['fecha']);
        final disponible = item['disponible'];
        mapa[DateTime.utc(fecha.year, fecha.month, fecha.day)] =
            disponible ? 'Disponible' : 'Reservado';
      }

      return mapa;
    } else {
      print("Error al obtener disponibilidad: ${response.body}");
      return {};
    }
  }
}
