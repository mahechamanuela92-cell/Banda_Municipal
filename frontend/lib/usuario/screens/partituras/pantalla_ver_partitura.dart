import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PantallaVerPartitura extends StatefulWidget {
  final String nombre;
  final String url;

  const PantallaVerPartitura({
    super.key,
    required this.nombre,
    required this.url,
  });

  @override
  State<PantallaVerPartitura> createState() => _PantallaVerPartituraState();
}

class _PantallaVerPartituraState extends State<PantallaVerPartitura> {
  String? _rutaPdf;
  String? _error;
  bool _cargando = false;

  String get _extension {
    final segmentos = Uri.tryParse(widget.url)?.pathSegments ?? const [];
    if (segmentos.isEmpty) return '';
    final nombreArchivo = segmentos.last;
    final punto = nombreArchivo.lastIndexOf('.');
    return punto < 0 ? '' : nombreArchivo.substring(punto + 1).toLowerCase();
  }

  bool get _esPdf => _extension == 'pdf';
  bool get _esImagen =>
      const {'jpg', 'jpeg', 'png', 'webp'}.contains(_extension);

  @override
  void initState() {
    super.initState();
    if (_esPdf && !kIsWeb) _cargarPdf();
  }

  Future<void> _cargarPdf() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final response = await http
          .get(Uri.parse(widget.url))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        throw Exception('No se pudo cargar el PDF (${response.statusCode})');
      }

      final directorio = await getTemporaryDirectory();
      final archivo = File(
        '${directorio.path}/partitura_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await archivo.writeAsBytes(response.bodyBytes, flush: true);
      if (!mounted) return;
      setState(() => _rutaPdf = archivo.path);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirEnOtraAplicacion() async {
    try {
      if (!await launchUrl(
        Uri.parse(widget.url),
        mode: LaunchMode.externalApplication,
      )) {
        throw StateError('No se pudo abrir el archivo');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir la partitura: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget contenido;
    if (_esImagen) {
      contenido = InteractiveViewer(
        child: Center(
          child: Image.network(
            widget.url,
            errorBuilder: (context, error, stackTrace) => const Text(
              'No se pudo cargar la imagen.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    } else if (_esPdf && !kIsWeb) {
      contenido = _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _cargarPdf,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : _rutaPdf == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: _rutaPdf!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
            );
    } else {
      contenido = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.open_in_new, size: 48, color: Color(0xFFE2BC65)),
            const SizedBox(height: 12),
            Text(
              _esPdf
                  ? 'Abre el PDF para verlo.'
                  : 'Abre el archivo para verlo.',
              style: const TextStyle(color: Colors.white70),
            ),
            TextButton.icon(
              onPressed: _abrirEnOtraAplicacion,
              icon: const Icon(Icons.visibility),
              label: const Text('Abrir archivo'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombre, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF3F4647),
        foregroundColor: const Color(0xFFE2BC65),
      ),
      backgroundColor: const Color(0xFF303638),
      body: SafeArea(child: contenido),
    );
  }
}
