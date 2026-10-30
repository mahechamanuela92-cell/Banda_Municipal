import 'dart:convert';

import 'package:frontend/config/api.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MultimediaApi {
  static Uri get _multimediaUri => Uri.parse('$apiUrl/multimedia');

  static String _mensajeError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return (body['detalle'] ?? body['error'] ?? 'Error de multimedia')
            .toString();
      }
    } on FormatException {
      return 'Respuesta inválida del servidor';
    }
    return 'Error de multimedia (${response.statusCode})';
  }

  static Future<List<Map<String, dynamic>>> listar({String? tipo}) async {
    final uri = tipo == null
        ? _multimediaUri
        : _multimediaUri.replace(queryParameters: {'tipo_archivo': tipo});
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }

    final data = jsonDecode(response.body);
    if (data is! List) {
      throw const FormatException('El servidor devolvió una lista inválida');
    }
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> listarEventos() async {
    final response = await http
        .get(Uri.parse('$apiUrl/eventos'))
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

  static Future<void> subir({
    required XFile archivo,
    required String token,
    required String tipo,
    String? idEvento,
    required String titulo,
  }) async {
    final request = http.MultipartRequest('POST', _multimediaUri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['titulo'] = titulo
      ..fields['tipo_archivo'] = tipo;
    if (idEvento != null && idEvento.isNotEmpty) {
      request.fields['id_evento'] = idEvento;
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        'archivo',
        await archivo.readAsBytes(),
        filename: archivo.name,
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 201) {
      throw Exception(_mensajeError(response));
    }
  }

  static Future<void> borrar({
    required String id,
    required String token,
  }) async {
    final response = await http
        .delete(
          _multimediaUri.resolve('/multimedia/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception(_mensajeError(response));
    }
  }
}
