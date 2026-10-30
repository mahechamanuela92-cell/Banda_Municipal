import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';

class PantallaGaleriaMultimedia extends StatelessWidget {
  final String tituloSeccion; // Ej: "Fotos" o "Videos"
  final String tipoMultimedia; // Ej: "foto" o "video"

  const PantallaGaleriaMultimedia({
    super.key,
    required this.tituloSeccion,
    required this.tipoMultimedia,
  });

  // Consulta directa a Supabase filtrando por el tipo (foto o video)
  Future<List<Map<String, dynamic>>> _obtenerMultimediaDeSupabase() async {
    final response = await Supabase.instance.client
        .from('multimedia') // Asegúrate de que tu tabla en Supabase se llame así
        .select()
        .eq('tipo', tipoMultimedia);

    return List<Map<String, dynamic>>.from(response);
  }

  // Función para abrir o descargar el archivo multimedia externo
  Future<void> _descargarOVerArchivo(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('No se pudo abrir la URL: $urlString');
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
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colores.naranja, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      tituloSeccion,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenedor principal con FutureBuilder conectado a Supabase
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
                    future: _obtenerMultimediaDeSupabase(),
                    builder: (context, snapshot) {
                      // Estado de carga
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: Colores.amarillo),
                        );
                      }

                      // Si no hay datos registrados por el administrador
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay $tituloSeccion subidos por el administrador todavía.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        );
                      }

                      final listaMultimedia = snapshot.data!;

                      // Cuadrícula de 2 columnas idéntica a tu diseño visual[cite: 3]
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
                          final archivoUrl = item['url'] ?? '';
                          final esVideo = tipoMultimedia == 'video';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Vista previa de la imagen o miniatura de video
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                        child: Image.network(
                                          item['miniatura_url'] ?? archivoUrl, // Si es video, ideal tener una miniatura; si no, usa la misma URL
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                                        ),
                                      ),
                                      // Si es un video, mostrar icono de reproducción encima
                                      if (esVideo)
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Botón Descargar / Ver
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colores.amarillo,
                                    backgroundColor: Colors.black26,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                                    ),
                                  ),
                                  icon: Icon(Icons.download, size: 16),
                                  label: Text('Descargar', style: TextStyle(fontSize: 12)),
                                  onPressed: () => _descargarOVerArchivo(archivoUrl),
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