import 'dart:convert';

import 'package:frontend/config/api.dart';
import 'package:http/http.dart' as http;

class ChatBandaService {
  static Future<Map<String, dynamic>> enviarMensaje(
    String mensaje, {
    String? sesionId,
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/api/banda'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'mensaje': mensaje, 'sesionId': ?sesionId}),
    );

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const FormatException(
        'El servidor devolvió una respuesta inválida.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'El servidor devolvió una respuesta inválida.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded['message']?.toString() ??
            'Error del servidor (${response.statusCode}).',
      );
    }

    return decoded;
  }
}
