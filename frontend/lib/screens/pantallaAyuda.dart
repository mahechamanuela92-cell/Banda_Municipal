import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/fondos.dart';

class PantallaAyuda extends StatefulWidget {
  const PantallaAyuda({super.key});

  @override
  State<PantallaAyuda> createState() => _PantallaAyudaState();
}

class _PantallaAyudaState extends State<PantallaAyuda> {
  bool _cargando = false;

  Future<void> _abrirManual() async {
    setState(() => _cargando = true);
    try {
      // Cargar el PDF desde assets
      final bytes = await rootBundle.load('pdf/Manual_de_Usuario.pdf');

      // Copiarlo a la carpeta temporal
      final dir = await getTemporaryDirectory();
      final archivo = File('${dir.path}/Manual_de_Usuario.pdf');
      await archivo.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VisorPdf(ruta: archivo.path),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el manual: $e'),
          backgroundColor: const Color(0xFF3F4647),
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manual de Usuario',
          style: TextStyle(color: Color(0xFFE2BC65), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3F4647),
        iconTheme: const IconThemeData(color: Color(0xFFE2BC65)),
      ),
      body: FondoBase(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 72,
                        color: Color(0xFFE2BC65),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Manual de Usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Consulte aquí las pautas de uso y la documentación oficial del sistema.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _cargando ? null : _abrirManual,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F4647),
                          foregroundColor: const Color(0xFFE2BC65),
                          side: const BorderSide(color: Color(0xFFE2BC65)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: _cargando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFE2BC65),
                                ),
                              )
                            : const Icon(Icons.picture_as_pdf),
                        label: const Text(
                          'Abrir Manual_de_Usuario.pdf',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3F4647).withOpacity(0.9),
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2BC65), width: 1),
                ),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Desarrollado por:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Danny Camila Cediel Perdomo & Manuela Mahecha Paloma',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFE2BC65),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla que muestra el PDF
class VisorPdf extends StatelessWidget {
  final String ruta;
  const VisorPdf({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manual de Usuario',
          style: TextStyle(color: Color(0xFFE2BC65), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3F4647),
        iconTheme: const IconThemeData(color: Color(0xFFE2BC65)),
      ),
      body: PDFView(
        filePath: ruta,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}