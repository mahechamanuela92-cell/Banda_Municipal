import 'package:flutter/material.dart';
import 'package:frontend/services/multimedia_api.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';

class PantallaGaleriaMultimedia extends StatefulWidget {
  final String tituloSeccion; // Ej: "Fotos" o "Videos"
  final String tipoMultimedia; // Ej: "foto" o "video"

  const PantallaGaleriaMultimedia({
    super.key,
    required this.tituloSeccion,
    required this.tipoMultimedia,
  });

  @override
  State<PantallaGaleriaMultimedia> createState() =>
      _PantallaGaleriaMultimediaState();
}

class _PantallaGaleriaMultimediaState extends State<PantallaGaleriaMultimedia> {
  late Future<List<Map<String, dynamic>>> _archivos;

  @override
  void initState() {
    super.initState();
    _archivos = MultimediaApi.listar(tipo: widget.tipoMultimedia);
  }

  Future<void> _recargar() async {
    setState(() {
      _archivos = MultimediaApi.listar(tipo: widget.tipoMultimedia);
    });
    await _archivos;
  }

  Future<void> _abrirArchivo(String urlString) async {
    final url = Uri.tryParse(urlString);
    if (url == null ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el archivo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              // Barra superior con botón de retroceso y título
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colores.naranja,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.tituloSeccion,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar',
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _recargar,
                    ),
                  ],
                ),
              ),

              // Contenedor principal con FutureBuilder conectado al backend
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colores.cajaOscura,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _archivos,
                    builder: (context, snapshot) {
                      // Estado de carga
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colores.amarillo,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'No se pudo cargar el contenido multimedia.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70),
                              ),
                              TextButton.icon(
                                onPressed: _recargar,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Si no hay datos registrados por el administrador
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay ${widget.tituloSeccion.toLowerCase()} subidos por el administrador todavía.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final listaMultimedia = snapshot.data!;

                      return GridView.builder(
                        itemCount: listaMultimedia.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          final item = listaMultimedia[index];
                          final archivoUrl =
                              item['url_archivo']?.toString() ?? '';
                          final esVideo = widget.tipoMultimedia == 'video';
                          final vistaPrevia = esVideo
                              ? const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white,
                                    size: 56,
                                  ),
                                )
                              : Image.network(
                                  archivoUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                    ),
                                  ),
                                );

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                    child: Material(
                                      color: Colors.black26,
                                      child: InkWell(
                                        onTap: () => _abrirArchivo(archivoUrl),
                                        child: vistaPrevia,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colores.amarillo,
                                    backgroundColor: Colors.black26,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text(
                                    'Abrir',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () => _abrirArchivo(archivoUrl),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Pie de página institucional
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colores.amarillo,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
