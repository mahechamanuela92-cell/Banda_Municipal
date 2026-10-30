import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class InstrumentosService {
  // Obtener todos los instrumentos
  static Future<List<dynamic>> obtenerInstrumentos() async {
    try {
      // Cambia 'apiUrl' por el nombre exacto que tengas en tu archivo api.dart
      final response = await http.get(Uri.parse('$apiUrl/instrumentos'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar los instrumentos');
      }
    } catch (e) {
      throw Exception('Conexión fallida: $e');
    }
  }

  // Registrar un instrumento completo
  static Future<bool> registrarInstrumento({
    required String numeroSerial,
    required String nombreInstrumento,
    required String instrumentoEn,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/instrumentos'), // Asegúrate de usar el mismo nombre aquí
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numero_serial': numeroSerial,
          'nombre_de_instrumento': nombreInstrumento,
          'instrumento_en': instrumentoEn,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}