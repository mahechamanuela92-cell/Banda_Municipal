import 'dart:async';
import 'package:flutter/material.dart';
import '../themes/colores.dart';
import '../widgets/fondos.dart';

class PantallaHistoria extends StatefulWidget {
  const PantallaHistoria({super.key});

  @override
  State<PantallaHistoria> createState() => _PantallaHistoriaState();
}

class _PantallaHistoriaState extends State<PantallaHistoria> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;
  Timer? _timer;

  // Lista de imágenes para el carrusel (puedes agregar o cambiar las rutas)
  final List<String> _imagenesCarrusel = [
    'assets/images/fondo_login1.png',
    // Agrega más rutas de imágenes aquí si lo deseas, por ejemplo:
    // 'assets/images/banda_historia1.png',
    // 'assets/images/banda_historia2.png',
  ];

  @override
  void initState() {
    super.initState();
    // Configuración del carrusel automático cada 3 segundos
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_imagenesCarrusel.length > 1) {
        if (_paginaActual < _imagenesCarrusel.length - 1) {
          _paginaActual++;
        } else {
          _paginaActual = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _paginaActual,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              // Flecha para volver unificada
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFE2BC65), size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // Carrusel de fotos automático (Cambia cada 3 segundos)
              SizedBox(
                height: 140,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _imagenesCarrusel.length,
                  onPageChanged: (index) {
                    setState(() {
                      _paginaActual = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE2BC65).withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Image.asset(
                            _imagenesCarrusel[index],
                            fit: BoxFit.contain,
                            height: 140,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Indicadores de puntos del carrusel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _imagenesCarrusel.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _paginaActual == entry.key
                          ? const Color(0xFFE2BC65)
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 15),

              // Caja oscura translúcida con la historia
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C5C).withValues(alpha: 0.75), // Estilo unificado
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // Borde sutil dorado
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'NUESTRA HISTORIA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE2BC65),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'La Banda Sinfónica Municipal de Garzón es el pilar cultural de la "Capital Diocesana" del Huila. Con una trayectoria que nace de la tradición de las retretas del siglo XX, se ha consolidado como una institución esencial para la formación artística de la juventud garzonena, fusionando la disciplina técnica con el sentimiento regional.\n\n'
                          'Es reconocida por su maestría en ritmos tradicionales como el bambuco y el pasillo, además de un amplio repertorio internacional y clásico. Funciona como una escuela de vida, permitiendo que niños y jóvenes se profesionalicen en música de viento y percusión.\n\n'
                          'Participaciones constantes en el Concurso Nacional de Bandas de Paipa. Fue galardonada como una de las 10 mejores bandas del Huila, reafirmando su excelencia musical en el departamento. Bajo la dirección de maestros locales, continúa siendo el alma de las festividades en la Catedral de San Miguel y el parque principal, manteniendo vigente el patrimonio musical del municipio.\n\n',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Título inferior institucional
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colores.amarillo,
                    height: 1.3,
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