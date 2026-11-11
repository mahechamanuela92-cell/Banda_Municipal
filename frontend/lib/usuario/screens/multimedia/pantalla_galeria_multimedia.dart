import 'package:flutter/material.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import 'package:frontend/services/multimedia_api.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(
                        0xFFE2BC65,
                      ).withValues(alpha: 0.5), // 🌟 Borde sutil dorado
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Barra superior con botón de retroceso y botón de actualizar
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFFE2BC65),
                              size: 28,
                            ),
                            tooltip: 'Volver',
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Actualizar',
                            icon: const Icon(
                              Icons.refresh,
                              color: Color(0xFFE2BC65),
                            ),
                            onPressed: _recargar,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Título principal con degradado dorado unificado
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE2BC65), Color(0xFFC29B45)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.tipoMultimedia == 'foto'
                                  ? Icons.photo_library
                                  : Icons.video_library,
                              color: const Color.fromARGB(255, 23, 30, 32),
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.tituloSeccion.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 23, 30, 32),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Contenedor principal con FutureBuilder conectado al backend
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _archivos,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE2BC65),
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
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Color(0xFFE2BC65),
                                      ),
                                      label: const Text(
                                        'Reintentar',
                                        style: TextStyle(
                                          color: Color(0xFFE2BC65),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Text(
                                  'No hay ${widget.tituloSeccion.toLowerCase()} subidos por el administrador todavía.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            }

                            final listaMultimedia = snapshot.data!;

                            return GridView.builder(
                              itemCount: listaMultimedia.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.85,
                                  ),
                              itemBuilder: (context, index) {
                                final item = listaMultimedia[index];
                                final archivoUrl =
                                    item['url_archivo']?.toString() ?? '';
                                final esVideo =
                                    widget.tipoMultimedia == 'video';
                                final vistaPrevia = esVideo
                                    ? const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Color(0xFFE2BC65),
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
                                    color: const Color.fromARGB(255, 85, 86, 87).withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE2BC65,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                          child: Material(
                                            color: Colors.black26,
                                            child: InkWell(
                                              onTap: () =>
                                                  _abrirArchivo(archivoUrl),
                                              child: vistaPrevia,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color.fromARGB(
                                            255,
                                            23,
                                            30,
                                            32,
                                          ),
                                          backgroundColor: const Color(
                                            0xFFE2BC65,
                                          ),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(12),
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.open_in_new,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          'Abrir',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        onPressed: () =>
                                            _abrirArchivo(archivoUrl),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Pie de página institucional unificado
                      const Center(
                        child: Text(
                          "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFE2BC65),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}
