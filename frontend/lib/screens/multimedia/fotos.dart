import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/widgets/fondos.dart';

class FotosPantalla extends StatefulWidget {
  const FotosPantalla({super.key});

  @override
  State<FotosPantalla> createState() => _FotosPantallaState();
}

class _FotosPantallaState extends State<FotosPantalla> {
  final ImagePicker _picker = ImagePicker();
  
  // Lista de fotos (puedes mezclar URLs de ejemplo y fotos seleccionadas locales)
  final List<String> fotos = [
    'https://picsum.photos/600/600?random=1',
    'https://picsum.photos/600/600?random=2',
    'https://picsum.photos/600/600?random=3',
    'https://picsum.photos/600/600?random=4',
  ];

  // Función para abrir la galería del celular y seleccionar imágenes
  Future<void> _seleccionarImagen() async {
    final List<XFile> imagenesSeleccionadas = await _picker.pickMultiImage();
    if (imagenesSeleccionadas.isNotEmpty) {
      setState(() {
        for (var img in imagenesSeleccionadas) {
          fotos.add(img.path); // Agrega la ruta local a la lista
        }
      });
    }
  }

  // Función para abrir imagen en grande (Modal)
  void _mostrarFotoGrande(BuildContext context, String urlOPath) {
    bool esLocal = !urlOPath.startsWith('http');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: Center(
                child: esLocal
                    ? Image.file(File(urlOPath), fit: BoxFit.contain)
                    : Image.network(urlOPath, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
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
                        "Fotos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Cuadrícula de fotos con scrollbar
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
                          crossAxisCount: 2, // Organizadas de a 2
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: fotos.length,
                        itemBuilder: (context, index) {
                          bool esLocal = !fotos[index].startsWith('http');
                          return GestureDetector(
                            onTap: () => _mostrarFotoGrande(context, fotos[index]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: esLocal
                                  ? Image.file(File(fotos[index]), fit: BoxFit.cover)
                                  : Image.network(fotos[index], fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

// Botón Seleccionar Imagen
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _seleccionarImagen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA1E3D8),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text( // <--- Asegúrate de incluir 'child:' aquí
                        "Seleccionar Imagen",
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
                      child: const Text( // <--- Y aquí también
                        "Guardar",
                        style: TextStyle(fontSize: 16, fontFamily: 'Serif', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
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