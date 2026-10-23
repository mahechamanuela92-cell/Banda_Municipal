import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Útil para abrir o descargar el archivo
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class PantallaGaleriaPartituras extends StatelessWidget {
  final String nombreInstrumento;
  final String nombreVoz;

  const PantallaGaleriaPartituras({
    super.key,
    required this.nombreInstrumento,
    required this.nombreVoz,
  });

  // Consulta directa a Supabase filtrando por instrumento y voz
  Future<List<Map<String, dynamic>>> _obtenerPartiturasDeSupabase() async {
    final response = await Supabase.instance.client
        .from('partituras')
        .select()
        .eq('instrumento', nombreInstrumento)
        .eq('voz', nombreVoz);

    return List<Map<String, dynamic>>.from(response);
  }

  // Función para descargar o abrir el archivo de la partitura
  Future<void> _descargarPartitura(String urlString) async {
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
                    Expanded(
                      child: Text(
                        '$nombreVoz - $nombreInstrumento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Buscador superior
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar partitura...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colores.cajaOscura,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Contenedor principal con FutureBuilder para conectar con Supabase
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
                    future: _obtenerPartiturasDeSupabase(),
                    builder: (context, snapshot) {
                      // Estado de carga
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: Colores.amarillo),
                        );
                      }

                      // Manejo de errores o datos vacíos
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No hay partituras disponibles para esta voz todavía.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        );
                      }

                      final partituras = snapshot.data!;

                      // Cuadrícula (GridView) idéntica a tu diseño de 2 columnas
                      return GridView.builder(
                        itemCount: partituras.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final item = partituras[index];
                          final imageUrl = item['imagen_url'] ?? '';
                          final titulo = item['titulo_partitura'] ?? 'Partitura';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Imagen de la partitura obtenida desde Supabase
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: Colores.amarillo,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                                    ),
                                  ),
                                ),
                                // Botón Descargar que vincula la descarga de la URL
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
                                  onPressed: () => _descargarPartitura(imageUrl),
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
                  'BANDA SINFONICA SAN MIGUEL DE GARZÓN',
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