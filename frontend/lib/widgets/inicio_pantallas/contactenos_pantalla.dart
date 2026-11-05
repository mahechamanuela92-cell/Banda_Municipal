import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/themes/colores.dart';
import 'package:frontend/widgets/fondos.dart';
import 'package:latlong2/latlong.dart';


class PantallaContacto extends StatelessWidget {
  const PantallaContacto({super.key});

  // Coordenadas exactas de la Casa de la Cultura en Garzón, Huila
  static const LatLng _ubicacionCasaCultura = LatLng(2.197307, -75.625975);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flecha para volver
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colores.naranja, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // 1. LOGO PRINCIPAL (logo1.png)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/fondo_logo1.png',
                    height: 130,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 2. TÍTULO CLARO CONTÁCTENOS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colores.botonClaro,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'CONTÁCTENOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 3. CAJA OSCURA CON DATOS DE CONTACTO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colores.cajaOscura,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.phone, color: Colors.white),
                          SizedBox(width: 15),
                          Text('3225172363', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(Icons.email, color: Colors.white),
                          SizedBox(width: 15),
                          Text('mahechamanuela92@gmail.com', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(Icons.location_city, color: Colors.white),
                          SizedBox(width: 15),
                          Text('Casa de la Cultura', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),

                      // Texto del Encargado / Director
                      const Text(
                        'Sergio Mauricio Vargas Vargas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Imagen de Sergio Mauricio Vargas Vargas
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          'assets/images/sergio.jpg',
                          height: 160,
                          width: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              width: 150,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person, size: 50, color: Colors.white70),
                                  SizedBox(height: 6),
                                  Text(
                                    'Foto',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. MAPA INTERACTIVO REAL (OpenStreetMap)
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A3A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colores.amarillo, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.5),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _ubicacionCasaCultura,
                        initialZoom: 16,
                        minZoom: 5,
                        maxZoom: 18,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.frontend',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _ubicacionCasaCultura,
                              width: 180,
                              height: 75,
                              alignment: Alignment.topCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colores.amarillo, width: 1.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text(
                                          'Casa de la Cultura',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Text(
                                          'Garzón, Huila',
                                          style: TextStyle(
                                            color: Colors.yellowAccent,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.location_on, color: Colors.redAccent, size: 34),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const RichAttributionWidget(
                          alignment: AttributionAlignment.bottomLeft,
                          attributions: [
                            TextSourceAttribution('OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // TÍTULO INFERIOR
                Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colores.amarillo,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}