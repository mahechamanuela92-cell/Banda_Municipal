import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import '../fondos.dart';

class NuestraHistoriaPantalla extends StatefulWidget {
  const NuestraHistoriaPantalla({super.key});

  @override
  State<NuestraHistoriaPantalla> createState() => _NuestraHistoriaPantallaState();
}

class _NuestraHistoriaPantallaState extends State<NuestraHistoriaPantalla> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _paginaActual = 0;
  Timer? _timer;

  final List<String> imagenesAssets = const [
    'assets/images/foto1-carrusel.jpg',
    'assets/images/foto2-carrusel.jpg',
    'assets/images/foto3-carrusel.jpg',
    'assets/images/foto4-carrusel.jpg',
    'assets/images/foto5-carrusel.jpg',
    'assets/images/foto6-carrusel.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // ⏱️ Carrusel automático que cambia de foto cada 3 segundos
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (imagenesAssets.isNotEmpty) {
        if (_paginaActual < imagenesAssets.length - 1) {
          _paginaActual++;
        } else {
          _paginaActual = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _paginaActual,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelamos el timer para evitar fugas de memoria
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // 🌟 Borde sutil dorado
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de regresar unificado en dorado
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFE2BC65), size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),

                  // Título con degradado dorado unificado
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE2BC65),
                          Color(0xFFC29B45),
                        ],
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
                      children: const [
                        Icon(Icons.menu_book, color: Color.fromARGB(255, 23, 30, 32), size: 22),
                        SizedBox(width: 10),
                        Text(
                          'NUESTRA HISTORIA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color.fromARGB(255, 23, 30, 32),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Carrusel automático de 6 fotos redondeadas con marco sutil
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imagenesAssets.length,
                      onPageChanged: (index) {
                        setState(() {
                          _paginaActual = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(
                                color: const Color(0xFFE2BC65).withValues(alpha: 0.4),
                                width: 1.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18.0),
                              child: Image.asset(
                                imagenesAssets[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.white10,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        color: Colors.white38,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Texto de la historia desplazable
                  Expanded(
                    child: SingleChildScrollView(
                      child: const Text(
                        "La Banda Sinfónica Municipal de Garzón es el pilar cultural de la \"Capital Diocesana\" del Huila. Con una trayectoria que nace de la tradición de las retretas del siglo XX, se ha consolidado como una institución esencial para la formación artística de la juventud garzoneña, fusionando la disciplina técnica con el sentimiento regional.\n\n"
                        "Es reconocida por su maestría en ritmos tradicionales como el bambuco y el pasillo, además de un amplio repertorio internacional y clásico.\n"
                        "Funciona como una escuela de vida, permitiendo que niños y jóvenes se profesionalicen en la música de viento y percusión.\n\n"
                        "Participaciones constantes en el Concurso Nacional de Bandas de Paipa. Fue galardonada como una de las 10 mejores bandas del Huila, reafirmando su excelencia musical en el departamento. Bajo la dirección de maestros locales, continúa siendo el alma de las festividades en la Catedral de San Miguel y el parque principal, manteniendo vigente el patrimonio musical del municipio.\n\n",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.5,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Pie de página institucional dorado unificado
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}