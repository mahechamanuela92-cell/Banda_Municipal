import 'package:flutter/material.dart';
import 'package:frontend/screens/multimedia/galeria_multimedia_admin.dart';
import 'package:frontend/themes/colores.dart';
import 'package:frontend/widgets/fondos.dart';

class MultimediaPantalla extends StatelessWidget {
  const MultimediaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colores.bloqueOscuro,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flecha para salir/volver al menú principal
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colores.naranja,
                          size: 30,
                        ),
                        tooltip: "Volver",
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Multimedia",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Desplegable de Fotos
                  ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      "Fotos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Serif',
                      ),
                    ),
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.photo_library,
                          color: Color(0xFFA1E3D8),
                        ),
                        title: const Text(
                          "Ver Galería de Fotos",
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white38,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GaleriaMultimediaAdmin(
                                    tipoMultimedia: 'foto',
                                    titulo: 'Fotos',
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Desplegable de Videos
                  ExpansionTile(
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      "Videos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Serif',
                      ),
                    ),
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.video_library,
                          color: Color(0xFFA1E3D8),
                        ),
                        title: const Text(
                          "Ver Galería de Videos",
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white38,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GaleriaMultimediaAdmin(
                                    tipoMultimedia: 'video',
                                    titulo: 'Videos',
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Pie de página
                  const Center(
                    child: Text(
                      "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD3A456),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
