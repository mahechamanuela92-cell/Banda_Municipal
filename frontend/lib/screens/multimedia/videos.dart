import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/widgets/fondos.dart';

class VideosPantalla extends StatefulWidget {
  const VideosPantalla({super.key});

  @override
  State<VideosPantalla> createState() => _VideosPantallaState();
}

class _VideosPantallaState extends State<VideosPantalla> {
  final ImagePicker _picker = ImagePicker();

  final List<String> videosMiniaturas = [
    'https://picsum.photos/600/600?random=10',
    'https://picsum.photos/600/600?random=11',
    'https://picsum.photos/600/600?random=12',
  ];

  // Función para abrir la galería y seleccionar un video
  Future<void> _seleccionarVideo() async {
    final XFile? videoSeleccionado = await _picker.pickVideo(source: ImageSource.gallery);
    if (videoSeleccionado != null) {
      setState(() {
        videosMiniaturas.add(videoSeleccionado.path);
      });
    }
  }

  void _verVideoGrande(BuildContext context, String urlOPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black87,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, color: Colors.white, size: 64),
                      SizedBox(height: 10),
                      Text("Reproduciendo Video...", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colores.bloqueOscuro,
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.orange, size: 26),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Videos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Cuadrícula de videos con scrollbar lateral
                  Expanded(
                    child: RawScrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      thumbColor: const Color(0xFFD3A456),
                      thickness: 6,
                      radius: const Radius.circular(10),
                      child: GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(right: 12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Organizados de a 2
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: videosMiniaturas.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _verVideoGrande(context, videosMiniaturas[index]),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    videosMiniaturas[index].startsWith('http')
                                        ? videosMiniaturas[index]
                                        : 'https://picsum.photos/600/600?random=20', // Imagen temporal para local
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

// Botón Seleccionar Video
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _seleccionarVideo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA1E3D8),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text( // <--- Incluir 'child:'
                        "Seleccionar Video",
                        style: TextStyle(fontSize: 16, fontFamily: 'Serif', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Botón Guardar (Devuelve a Multimedia)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA1E3D8),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text( // <--- Incluir 'child:'
                        "Guardar",
                        style: TextStyle(fontSize: 16, fontFamily: 'Serif', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "BANDA SINFÓNICA SAN MIGUEL DE GARZÓN",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD3A456),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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