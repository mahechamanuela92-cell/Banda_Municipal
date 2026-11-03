import 'dart:convert';

import 'package:frontend/config/api.dart';
import 'package:http/http.dart' as http;

class EventosApi {
  static Uri get _eventosUri => Uri.parse('$apiUrl/eventos');

  static String _mensajeError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return (body['error'] ?? body['detalle'] ?? 'Error de eventos')
            .toString();
      }
    } on FormatException {
      return 'Respuesta inválida del servidor';
    }
    return 'Error de eventos (${response.statusCode})';
  }

  static Future<List<Map<String, dynamic>>> listar() async {
    final response = await http
        .get(_eventosUri)
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw const FormatException(
        'El servidor devolvió una lista de eventos inválida',
      );
    }
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> guardar({
    required String token,
    required Map<String, dynamic> evento,
    String? id,
  }) async {
    final uri = id == null ? _eventosUri : _eventosUri.resolve('/eventos/$id');
    final response = await (id == null ? http.post : http.put)(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(evento),
    ).timeout(const Duration(seconds: 20));

    final resultadoCorrecto = id == null ? 201 : 200;
    if (response.statusCode != resultadoCorrecto) {
      throw Exception(_mensajeError(response));
    }
  }

  static Future<void> eliminar({
    required String id,
    required String token,
  }) async {
    final response = await http
        .delete(
          _eventosUri.resolve('/eventos/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }
}
