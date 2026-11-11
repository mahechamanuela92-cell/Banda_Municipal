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
  String _rutaPdfLocal = '';
  bool _cargando = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _cargarPdfDesdeAssets();
  }

  // Función para extraer el PDF de los assets y guardarlo temporalmente para que el visor lo lea
  Future<void> _cargarPdfDesdeAssets() async {
    try {
      // 📂 Asegúrate de que el archivo coincida exactamente con la ruta en tus assets
      final ByteData datos = await rootBundle.load('assets/pdf/manual_usuario.pdf');
      final Directory directorioTemp = await getTemporaryDirectory();
      final File archivoTemp = File('${directorioTemp.path}/manual_usuario.pdf');
      
      await archivoTemp.writeAsBytes(datos.buffer.asUint8List(), flush: true);

      setState(() {
        _rutaPdfLocal = archivoTemp.path;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el manual local: $e';
        _cargando = false;
      });
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
        child: _cargando
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE2BC65),
                ),
              )
            : _error.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : PDFView(
                    filePath: _rutaPdfLocal,
                    enableSwipe: true,
                    swipeHorizontal: false, // Scroll vertical tradicional (puedes cambiarlo a true si prefieres pasar páginas de lado)
                    autoSpacing: true,
                    pageFling: true,
                    onError: (error) {
                      print(error.toString());
                    },
                    onPageError: (page, error) {
                      print('$page: ${error.toString()}');
                    },
                  ),
      ),
    );
  }
}